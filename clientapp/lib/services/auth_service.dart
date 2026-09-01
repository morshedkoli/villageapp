import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

import 'firestore_refs.dart';
import 'sync_service.dart';

/// Handles Firebase Auth sign-in/out, phone-as-email convention, and the
/// user profile document in Firestore.
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Overridable at build time via --dart-define=GOOGLE_WEB_CLIENT_ID=...
  static const String _webClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '1064035305311-2ovc90ovj0ujdslrgpot09id15uhuho7.apps.googleusercontent.com',
  );

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? _webClientId : null,
    scopes: ['email', 'profile'],
  );

  User? get currentUser => _auth.currentUser;
  Stream<User?> authState() => _auth.authStateChanges();

  /// Signs out and drops every cached stream, so the next session cannot
  /// read data subscribed under the previous account.
  Future<void> signOut() async {
    SyncService.instance.clearStreamCaches();
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Returns `true` if this is a brand-new user (profile setup needed).
  Future<bool> signInWithGoogle() async {
    // Ensure a clean session before opening the account picker.
    await _googleSignIn.signOut();
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return false;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _auth.signInWithCredential(credential);
    try {
      return await _upsertUserProfile();
    } catch (_) {
      // Profile upsert may fail if Firestore rules aren't deployed yet
      return false;
    }
  }

  /// Sign in with phone number and password.
  ///
  /// Internally uses the convention `{phone}@village.app` as the Firebase
  /// Auth email so that we don't require SMS/OTP billing.  The admin panel
  /// creates accounts this way when a password is supplied.
  Future<void> signInWithPhoneAndPassword({
    required String phone,
    required String password,
  }) async {
    final normalizedPhone = normalizePhone(phone);
    final email = _phoneToEmail(normalizedPhone);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // Translate Firebase error codes into friendly messages.
      throw friendlyAuthError(e);
    }
  }

  /// Sign in with plain email and password (for users who registered via email).
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw friendlyAuthError(e);
    }
  }

  /// Update the current user's phone number in both Firestore and Auth (email convention).
  Future<void> updateUserPhone(String phone, String currentPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Login required.');

    final normalizedPhone = normalizePhone(phone);
    final newEmail = _phoneToEmail(normalizedPhone);

    // Re-authenticate first so Firebase allows the email update.
    final oldEmail = user.email ?? '';
    if (oldEmail.isNotEmpty && currentPassword.isNotEmpty) {
      final credential = EmailAuthProvider.credential(
        email: oldEmail,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
    }

    // Only update Auth email if it follows the phone convention.
    if (oldEmail.endsWith('@village.app') || oldEmail.isEmpty) {
      await user.verifyBeforeUpdateEmail(newEmail);
    }

    // Always persist in Firestore regardless.
    await Db.collection(Db.users).doc(user.uid).set({
      'phone': normalizedPhone,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Update the current user's email address in Firestore.
  /// Also sends a verification email if the Auth provider supports it.
  Future<void> updateUserEmailAddress(String newEmail) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Login required.');

    final trimmed = newEmail.trim().toLowerCase();

    // Persist in Firestore.
    await Db.collection(Db.users).doc(user.uid).set({
      'email': trimmed,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<bool> isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final tokenResult = await user.getIdTokenResult();
    return tokenResult.claims?['admin'] == true;
  }

  /// Check if the current user's profile has phone number set.
  Future<bool> isProfileComplete() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final doc = await Db.collection(Db.users).doc(user.uid).get();
    final data = doc.data();
    if (data == null) return false;
    final phone = data['phone'] as String? ?? '';
    return phone.isNotEmpty;
  }

  /// Save additional profile fields after setup.
  Future<void> updateUserProfile({
    required String name,
    required String phone,
    required String profession,
    required String village,
    required String address,
    String? email,
    String? nidNumber,
    String? bloodGroup,
    String? dateOfBirth,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Login required to update profile.');
    }
    await Db.collection(Db.users).doc(user.uid).set({
      'name': name,
      'phone': phone,
      'profession': profession,
      'village': village,
      'address': address,
      if (email != null) 'email': email.trim().toLowerCase(),
      'nidNumber': nidNumber ?? '',
      'bloodGroup': bloodGroup ?? '',
      'dateOfBirth': dateOfBirth ?? '',
      'profileComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Live `blocked` flag for the signed-in user. Admins toggle this from the
  /// web panel; the app uses it to lock the account out of every write action.
  Stream<bool> blockedState() {
    return _auth.authStateChanges().switchMap((user) {
      if (user == null) return Stream<bool>.value(false);
      return Db.collection(Db.users)
          .doc(user.uid)
          .snapshots()
          .map((doc) => (doc.data()?['blocked'] as bool?) ?? false)
          .onErrorReturn(false);
    });
  }

  /// Fetch the current user's full profile data from Firestore.
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await Db.collection(Db.users).doc(user.uid).get();
    return doc.data();
  }

  /// Returns `true` if the user is new (no existing doc).
  Future<bool> _upsertUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      return false;
    }

    final existingDoc =
        await Db.collection(Db.users).doc(user.uid).get();
    final isNew = !existingDoc.exists;

    await Db.collection(Db.users).doc(user.uid).set({
      'name': user.displayName ?? user.email?.split('@').first ?? 'Citizen',
      'email': user.email,
      'photoUrl': user.photoURL ?? '',
      'isCitizen': true,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Increment citizen counter for new users.
    // Notification is sent by Cloud Function onCitizenRegisteredNotifyAll.
    if (isNew) {
      await Db.village().set({
        'totalCitizens': FieldValue.increment(1),
      }, SetOptions(merge: true));
    }

    return isNew;
  }

  /// Convert a phone number to the internal email convention used for
  /// Firebase Auth when users log in with phone+password.
  static String _phoneToEmail(String normalizedPhone) {
    return '$normalizedPhone@village.app';
  }

  /// Strip non-digit characters except leading +.
  static String normalizePhone(String phone) {
    final stripped = phone.trim().replaceAll(RegExp(r'\s+'), '');
    // Keep leading + for international format.
    if (stripped.startsWith('+')) {
      return '+${stripped.substring(1).replaceAll(RegExp(r'[^0-9]'), '')}';
    }
    return stripped.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Translate Firebase Auth error codes into user-friendly Bengali/English messages.
  static Exception friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return Exception('ফোন নম্বর বা পাসওয়ার্ড সঠিক নয়।');
      case 'user-disabled':
        return Exception('এই অ্যাকাউন্টটি ব্লক করা হয়েছে। অ্যাডমিনের সাথে যোগাযোগ করুন।');
      case 'too-many-requests':
        return Exception('অনেকবার ভুল হয়েছে। কিছুক্ষণ পরে আবার চেষ্টা করুন।');
      case 'network-request-failed':
        return Exception('ইন্টারনেট সংযোগ নেই। আবার চেষ্টা করুন।');
      default:
        return Exception(e.message ?? 'লগইন ব্যর্থ হয়েছে।');
    }
  }
}
