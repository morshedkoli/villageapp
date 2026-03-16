import 'dart:io';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'connectivity_service.dart';
import 'models.dart';
import 'onesignal_api_service.dart';

class DataService {
  DataService._();

  static final DataService instance = DataService._();

  static const String villageDocId = 'main_village';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  Stream<User?> authState() => _auth.authStateChanges();

  Future<void> signOut() => _auth.signOut();

  Future<void> sendLoginLink(String email) async {
    await _auth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: ActionCodeSettings(
        url: 'https://doulatpara.page.link/login',
        handleCodeInApp: true,
        androidPackageName: 'com.example.doulatpara',
        iOSBundleId: 'com.example.doulatpara',
      ),
    );
  }

  Future<void> signInWithEmailLink({
    required String email,
    required String emailLink,
  }) async {
    await _auth.signInWithEmailLink(email: email, emailLink: emailLink);
    await _upsertUserProfile();
  }

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
        .where('status', isEqualTo: 'Approved')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(Donation.fromDoc).toList());
  }

  Stream<List<Donation>> pendingDonations() {
    return _firestore
        .collection('donations')
        .where('status', isEqualTo: 'Pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Donation.fromDoc).toList());
  }

  Stream<Map<String, Map<String, String>>> paymentAccounts() {
    return _firestore
        .collection('villages')
        .doc(villageDocId)
        .snapshots()
        .map((doc) {
      final data = doc.data() ?? {};
      final accounts = data['paymentAccounts'] as Map<String, dynamic>? ?? {};
      return accounts.map((k, v) {
        if (v is Map) {
          final m = <String, String>{
            'number': (v['number'] ?? '').toString(),
            'name': (v['name'] ?? '').toString(),
          };
          if (v['bankName'] != null) m['bankName'] = v['bankName'].toString();
          if (v['branch'] != null) m['branch'] = v['branch'].toString();
          return MapEntry(k, m);
        }
        return MapEntry(k, {'number': v.toString(), 'name': ''});
      });
    });
  }

  Future<void> updatePaymentAccounts(Map<String, Map<String, String>> accounts) async {
    await _firestore.collection('villages').doc(villageDocId).set({
      'paymentAccounts': accounts,
    }, SetOptions(merge: true));
  }

  Future<bool> isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final tokenResult = await user.getIdTokenResult();
    return tokenResult.claims?['admin'] == true;
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

  /// Returns a real-time count of registered citizens from the users collection.
  Stream<int> citizenCount() {
    return _firestore
        .collection('users')
        .where('isCitizen', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.size);
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
    required String transactionId,
    required String senderNumber,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Login required to donate.');
    }

    // Queue for later if offline.
    if (!ConnectivityService.instance.isOnline) {
      await _queueOfflineWrite({
        'type': 'donation',
        'amount': amount,
        'paymentMethod': paymentMethod,
        'transactionId': transactionId,
        'senderNumber': senderNumber,
      });
      return;
    }

    final profile = await _firestore.collection('users').doc(user.uid).get();
    final donorName =
        profile.data()?['name'] as String? ?? user.email ?? 'Citizen';

    await _firestore.collection('donations').add({
      'userId': user.uid,
      'donorName': donorName,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'senderNumber': senderNumber,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> approveDonation(String donationId) async {
    final donationDoc =
        await _firestore.collection('donations').doc(donationId).get();
    final data = donationDoc.data();
    if (data == null) throw StateError('Donation not found.');

    final amount = (data['amount'] as num?)?.toDouble() ?? 0;
    final donorName = data['donorName'] as String? ?? 'Anonymous';

    await _firestore.runTransaction((tx) async {
      final villageRef = _firestore.collection('villages').doc(villageDocId);
      tx.set(villageRef, {
        'totalFundCollected': FieldValue.increment(amount),
      }, SetOptions(merge: true));

      tx.update(_firestore.collection('donations').doc(donationId), {
        'status': 'Approved',
      });

      tx.set(_firestore.collection('fund_transactions').doc(), {
        'type': 'donation',
        'amount': amount,
        'reference': donorName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      tx.set(_firestore.collection('notifications').doc(), {
        'title': 'নতুন অনুদান',
        'body': '$donorName ৳$amount অনুদান দিয়েছেন',
        'type': 'donation',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    // Send OneSignal push (no server required).
    await OneSignalApiService.sendToAll(
      title: 'নতুন অনুদান',
      body: '$donorName ৳$amount অনুদান দিয়েছেন',
      type: 'donation',
    );
  }

  Future<void> rejectDonation(String donationId) async {
    await _firestore.collection('donations').doc(donationId).update({
      'status': 'Rejected',
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

    // Queue for later if offline (photo will be lost).
    if (!ConnectivityService.instance.isOnline) {
      await _queueOfflineWrite({
        'type': 'problem',
        'title': title,
        'description': description,
        'location': location,
      });
      return;
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
      final request = await HttpClient().postUrl(
        Uri.parse('https://api.imgbb.com/1/upload?key=$imgbbApiKey'),
      );
      request.headers.contentType = ContentType('application', 'x-www-form-urlencoded');
      request.write('image=${Uri.encodeComponent(base64Image)}');
      final res = await request.close();
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

    // Send OneSignal push (no server required).
    await OneSignalApiService.sendToAll(
      title: 'নতুন সমস্যা রিপোর্ট',
      body: '$reporterName "$title" সমস্যা রিপোর্ট করেছেন',
      type: 'problem',
    );
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

      // Increment totalCitizens counter on the village document.
      await _firestore.collection('villages').doc(villageDocId).set({
        'totalCitizens': FieldValue.increment(1),
      }, SetOptions(merge: true));

      await _firestore.collection('notifications').add({
        'title': 'নতুন নাগরিক যোগ হয়েছে',
        'body': '$displayName গ্রামে যোগদান করেছেন',
        'type': 'citizen',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Send OneSignal push (no server required).
      await OneSignalApiService.sendToAll(
        title: 'নতুন নাগরিক যোগ হয়েছে',
        body: '$displayName গ্রামে যোগদান করেছেন',
        type: 'citizen',
      );
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

  // ─── Offline write queue ───────────────────────────────────────────

  static const _pendingWritesKey = 'pending_offline_writes';

  /// Queue a write operation for later sync when device comes back online.
  Future<void> _queueOfflineWrite(Map<String, dynamic> writeOp) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_pendingWritesKey) ?? [];
    existing.add(jsonEncode(writeOp));
    await prefs.setStringList(_pendingWritesKey, existing);
    debugPrint('DataService: Queued offline write (${writeOp['type']})');
  }

  /// Process any pending offline writes. Call when connectivity returns.
  Future<void> processPendingWrites() async {
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getStringList(_pendingWritesKey) ?? [];
    if (pending.isEmpty) return;

    debugPrint('DataService: Processing ${pending.length} pending writes');
    final failed = <String>[];

    for (final raw in pending) {
      try {
        final op = jsonDecode(raw) as Map<String, dynamic>;
        switch (op['type']) {
          case 'donation':
            await addDonation(
              amount: (op['amount'] as num).toDouble(),
              paymentMethod: op['paymentMethod'] as String,
              transactionId: op['transactionId'] as String,
              senderNumber: op['senderNumber'] as String,
            );
          case 'problem':
            await reportProblem(
              title: op['title'] as String,
              description: op['description'] as String,
              location: op['location'] as String,
            );
          default:
            debugPrint('DataService: Unknown queued write type: ${op['type']}');
        }
      } catch (e) {
        debugPrint('DataService: Failed to process queued write: $e');
        failed.add(raw);
      }
    }

    await prefs.setStringList(_pendingWritesKey, failed);
    if (failed.isEmpty) {
      debugPrint('DataService: All pending writes processed successfully');
    }
  }

  /// Returns the count of pending offline writes.
  Future<int> pendingWriteCount() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_pendingWritesKey) ?? []).length;
  }
}
