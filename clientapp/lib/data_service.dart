import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'models.dart';

class DataService {
  DataService._();

  static final DataService instance = DataService._();

  static const String villageDocId = 'main_village';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  Stream<User?> authState() => _auth.authStateChanges();

  Future<void> signOut() => _auth.signOut();

  /// Returns `true` if this is a brand-new user (profile setup needed).
  Future<bool> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return false;
    final googleAuth = await googleUser.authentication;
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

  Stream<VillageOverview> villageOverview() {
    return _firestore
        .collection('villages')
        .doc(villageDocId)
        .snapshots()
        .map(
          (doc) => VillageOverview.fromMap(doc.data() ?? <String, dynamic>{}),
        );
  }

  Stream<List<Donation>> donations({int limit = 100}) {
    return _firestore
        .collection('donations')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(Donation.fromDoc).toList());
  }

  Stream<List<ProblemReport>> problems({int limit = 100}) {
    return _firestore
        .collection('problems')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(ProblemReport.fromDoc).toList());
  }

  Stream<List<DevelopmentProject>> projects({int limit = 100}) {
    return _firestore
        .collection('projects')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(DevelopmentProject.fromDoc).toList());
  }

  Stream<List<Citizen>> citizens() {
    return _firestore
        .collection('users')
        .where('isCitizen', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs.map(Citizen.fromDoc).toList());
  }

  Stream<List<AppNotification>> notifications({int limit = 100}) {
    return _firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(AppNotification.fromDoc).toList());
  }

  Stream<Set<String>> myReadNotificationIds() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream<Set<String>>.value(<String>{});
    }
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notification_reads')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toSet());
  }

  Future<void> markNotificationRead(String notificationId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Login required to update notifications.');
    }
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notification_reads')
        .doc(notificationId)
        .set({'readAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }

  Future<void> markNotificationUnread(String notificationId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Login required to update notifications.');
    }
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notification_reads')
        .doc(notificationId)
        .delete();
  }

  Future<void> markAllNotificationsRead(Iterable<String> ids) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Login required to update notifications.');
    }
    final batch = _firestore.batch();
    for (final id in ids) {
      final ref = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notification_reads')
          .doc(id);
      batch.set(ref, {'readAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    }
    await batch.commit();
  }

  Future<void> addDonation({
    required double amount,
    required String paymentMethod,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Login required to donate.');
    }

    final profile = await _firestore.collection('users').doc(user.uid).get();
    final donorName =
        profile.data()?['name'] as String? ?? user.email ?? 'Citizen';

    await _firestore.runTransaction((tx) async {
      final villageRef = _firestore.collection('villages').doc(villageDocId);
      tx.set(villageRef, {
        'totalFundCollected': FieldValue.increment(amount),
      }, SetOptions(merge: true));

      tx.set(_firestore.collection('donations').doc(), {
        'userId': user.uid,
        'donorName': donorName,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'createdAt': FieldValue.serverTimestamp(),
      });

      tx.set(_firestore.collection('fund_transactions').doc(), {
        'type': 'donation',
        'amount': amount,
        'reference': donorName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Write an in-app notification for all users.
      tx.set(_firestore.collection('notifications').doc(), {
        'title': 'নতুন অনুদান',
        'body': '$donorName ৳$amount অনুদান দিয়েছেন',
        'type': 'donation',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> reportProblem({
    required String title,
    required String description,
    required String location,
    File? photo,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Login required to report problems.');
    }

    final profile = await _firestore.collection('users').doc(user.uid).get();
    final reporterName =
        profile.data()?['name'] as String? ?? user.email ?? 'Citizen';

    var photoUrl = '';
    if (photo != null) {
      // Upload image to imgbb
      final bytes = await photo.readAsBytes();
      final base64Image = base64Encode(bytes);
      const imgbbApiKey = '707ad238025806ece51d9e63679151f7';
      final response = await HttpClient().postUrl(Uri.parse('https://api.imgbb.com/1/upload?key=$imgbbApiKey'))
        ..headers.contentType = ContentType('application', 'x-www-form-urlencoded')
        ..write('image=$base64Image');
      final res = await response.close();
      final resBody = await res.transform(utf8.decoder).join();
      final json = jsonDecode(resBody);
      if (json['success'] == true) {
        photoUrl = json['data']['url'];
      } else {
        throw Exception('Image upload failed: ${json['error']['message']}');
      }
    }

    await _firestore.collection('problems').add({
      'title': title,
      'description': description,
      'location': location,
      'photoUrl': photoUrl,
      'status': 'Pending',
      'reportedBy': user.uid,
      'reportedByName': reporterName,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Write an in-app notification for all users.
    await _firestore.collection('notifications').add({
      'title': 'নতুন সমস্যা রিপোর্ট',
      'body': '$reporterName "$title" সমস্যা রিপোর্ট করেছেন',
      'type': 'problem',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Donation>> myDonations() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream<List<Donation>>.empty();
    }
    return _firestore
        .collection('donations')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Donation.fromDoc).toList());
  }

  Stream<List<ProblemReport>> myProblems() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream<List<ProblemReport>>.empty();
    }
    return _firestore
        .collection('problems')
        .where('reportedBy', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ProblemReport.fromDoc).toList());
  }

  /// Returns `true` if the user is new (no existing doc).
  Future<bool> _upsertUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      return false;
    }

    final existingDoc =
        await _firestore.collection('users').doc(user.uid).get();
    final isNew = !existingDoc.exists;

    await _firestore.collection('users').doc(user.uid).set({
      'name': user.displayName ?? user.email?.split('@').first ?? 'Citizen',
      'email': user.email,
      'photoUrl': user.photoURL ?? '',
      'isCitizen': true,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Notify all users about the new citizen.
    if (isNew) {
      final displayName =
          user.displayName ?? user.email?.split('@').first ?? 'Citizen';
      await _firestore.collection('notifications').add({
        'title': 'নতুন নাগরিক যোগ হয়েছে',
        'body': '$displayName গ্রামে যোগদান করেছেন',
        'type': 'citizen',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return isNew;
  }

  /// Check if the current user's profile has phone number set.
  Future<bool> isProfileComplete() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final doc = await _firestore.collection('users').doc(user.uid).get();
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
    String? nidNumber,
    String? bloodGroup,
    String? dateOfBirth,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Login required to update profile.');
    }
    await _firestore.collection('users').doc(user.uid).set({
      'name': name,
      'phone': phone,
      'profession': profession,
      'village': village,
      'address': address,
      'nidNumber': nidNumber ?? '',
      'bloodGroup': bloodGroup ?? '',
      'dateOfBirth': dateOfBirth ?? '',
      'profileComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Fetch the current user's full profile data from Firestore.
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data();
  }
}
