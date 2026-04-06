import 'dart:io';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'connectivity_service.dart';
import 'models.dart';

class DataService {
  DataService._();

  static final DataService instance = DataService._();

  static const String villageDocId = 'main_village';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  Stream<User?> authState() => _auth.authStateChanges();

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> sendLoginLink(String email) async {
    await _auth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: ActionCodeSettings(
        url: 'https://doulatpara.page.link/login',
        handleCodeInApp: true,
        androidPackageName: 'com.murshedkoli.alislah',
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
    // Ensure a clean session before opening the account picker.
    await _googleSignIn.signOut();
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

  /// Wraps a Firestore stream with error handling for web platform issues.
  /// Returns the last known value on transient errors instead of breaking the stream.
  Stream<T> _handleStreamErrors<T>(Stream<T> source, T fallback) {
    return source.handleError(
      (error, stackTrace) {
        debugPrint('DataService: Stream error - $error');
        // On web, Firestore can throw internal assertion errors during refresh.
        // Log the error but don't break the stream - return fallback value.
      },
      test: (error) {
        // Handle Firestore internal errors gracefully
        final errorStr = error.toString();
        return errorStr.contains('INTERNAL ASSERTION FAILED') ||
            errorStr.contains('Unexpected state');
      },
    );
  }

  Stream<VillageOverview> villageOverview() {
    return _handleStreamErrors(
      _firestore
          .collection('villages')
          .doc(villageDocId)
          .snapshots()
          .map(
            (doc) => VillageOverview.fromMap(doc.data() ?? <String, dynamic>{}),
          ),
      const VillageOverview(
        name: 'Our Village',
        totalCitizens: 0,
        totalFundCollected: 0,
        totalSpent: 0,
      ),
    );
  }

  Stream<List<Donation>> donations({int limit = 100}) {
    return _handleStreamErrors(
      _firestore
          .collection('donations')
          .where('status', isEqualTo: 'Approved')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snap) => snap.docs.map(Donation.fromDoc).toList()),
      const <Donation>[],
    );
  }

  Stream<List<Donation>> pendingDonations() {
    return _handleStreamErrors(
      _firestore
          .collection('donations')
          .where('status', isEqualTo: 'Pending')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map(Donation.fromDoc).toList()),
      const <Donation>[],
    );
  }

  Stream<Map<String, Map<String, String>>> paymentAccounts() {
    return _handleStreamErrors(
      _firestore
          .collection('villages')
          .doc(villageDocId)
          .snapshots()
          .map((doc) {
        final data = doc.data() ?? {};
        final raw = data['paymentAccounts'];
        
        debugPrint('=== PAYMENT ACCOUNTS STREAM DEBUG ===');
        debugPrint('Raw paymentAccounts data: $raw');
        debugPrint('Data type: ${raw.runtimeType}');
        
        final result = <String, Map<String, String>>{};

        // Handle array format (from web admin panel)
        if (raw is List) {
          debugPrint('Processing as List (${raw.length} items)');
          for (final item in raw) {
            if (item is Map) {
              final rawType = (item['type'] ?? '').toString();
              debugPrint('  Item type: $rawType, number: ${item['number']}, name: ${item['name']}');
              if (rawType.isNotEmpty) {
                // Normalize type to match mobile app keys (bkash -> bKash, etc.)
                final type = _normalizePaymentType(rawType);
                debugPrint('  Normalized type: $rawType -> $type');
                final m = <String, String>{
                  'number': (item['number'] ?? '').toString(),
                  'name': (item['name'] ?? '').toString(),
                };
                if (item['bankName'] != null) m['bankName'] = item['bankName'].toString();
                if (item['branch'] != null) m['branch'] = item['branch'].toString();
                result[type] = m;
              }
            }
          }
          debugPrint('Result from List: $result');
          return result;
        }

        // Handle legacy map format
        debugPrint('Processing as Map');
        final accounts = raw as Map<String, dynamic>? ?? {};
        return accounts.map((k, v) {
          final normalizedKey = _normalizePaymentType(k);
          if (v is Map) {
            final m = <String, String>{
              'number': (v['number'] ?? '').toString(),
              'name': (v['name'] ?? '').toString(),
            };
            if (v['bankName'] != null) m['bankName'] = v['bankName'].toString();
            if (v['branch'] != null) m['branch'] = v['branch'].toString();
            return MapEntry(normalizedKey, m);
          }
          return MapEntry(normalizedKey, {'number': v.toString(), 'name': ''});
        });
      }),
      const <String, Map<String, String>>{},
    );
  }

  /// Returns donation accounts from villages/main_village.paymentAccounts.
  /// Supports both the new array format and legacy map format.
  Stream<List<Map<String, String>>> donationAccounts() {
    return _handleStreamErrors(
      _firestore
          .collection('villages')
          .doc(villageDocId)
          .snapshots()
          .map((doc) {
        final data = doc.data() ?? <String, dynamic>{};
        final raw = data['paymentAccounts'];
        final result = <Map<String, String>>[];

        if (raw is List) {
          for (final item in raw) {
            if (item is! Map) continue;
            final id = (item['id'] ?? '').toString().trim();
            final type = _normalizePaymentType((item['type'] ?? '').toString());
            final number = (item['number'] ?? '').toString().trim();
            final name = (item['name'] ?? '').toString().trim();
            final bankName = (item['bankName'] ?? '').toString().trim();
            final branch = (item['branch'] ?? '').toString().trim();
            result.add({
              'id': id.isNotEmpty
                  ? id
                  : '${type.toLowerCase()}_${result.length + 1}',
              'type': type,
              'number': number,
              'name': name,
              if (bankName.isNotEmpty) 'bankName': bankName,
              if (branch.isNotEmpty) 'branch': branch,
            });
          }
          return result;
        }

        final legacy = raw as Map<String, dynamic>? ?? <String, dynamic>{};
        for (final entry in legacy.entries) {
          final type = _normalizePaymentType(entry.key);
          if (entry.value is Map) {
            final mapValue = entry.value as Map;
            final number = (mapValue['number'] ?? '').toString().trim();
            final name = (mapValue['name'] ?? '').toString().trim();
            final bankName = (mapValue['bankName'] ?? '').toString().trim();
            final branch = (mapValue['branch'] ?? '').toString().trim();
            result.add({
              'id': '${type.toLowerCase()}_${result.length + 1}',
              'type': type,
              'number': number,
              'name': name,
              if (bankName.isNotEmpty) 'bankName': bankName,
              if (branch.isNotEmpty) 'branch': branch,
            });
          } else {
            result.add({
              'id': '${type.toLowerCase()}_${result.length + 1}',
              'type': type,
              'number': entry.value.toString(),
              'name': '',
            });
          }
        }
        return result;
      }),
      const <Map<String, String>>[],
    );
  }

  /// Normalize payment type from admin panel format to mobile app format
  static String _normalizePaymentType(String type) {
    final lower = type.toLowerCase();
    switch (lower) {
      case 'bkash':
        return 'bKash';
      case 'nagad':
        return 'Nagad';
      case 'rocket':
        return 'Rocket';
      case 'bank':
        return 'Bank';
      default:
        return type; // Return as-is for unknown types
    }
  }

  Future<void> updatePaymentAccounts(Map<String, Map<String, String>> accounts) async {
    // Convert to array format (compatible with web admin panel)
    final List<Map<String, dynamic>> accountsList = [];
    accounts.forEach((type, details) {
      if (details['number']?.isNotEmpty ?? false) {
        accountsList.add({
          'id': type.toLowerCase(),
          'type': type,
          'number': details['number'] ?? '',
          'name': details['name'] ?? '',
          if (details['bankName']?.isNotEmpty ?? false) 'bankName': details['bankName'],
          if (details['branch']?.isNotEmpty ?? false) 'branch': details['branch'],
        });
      }
    });
    await _firestore.collection('villages').doc(villageDocId).set({
      'paymentAccounts': accountsList,
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
        .where('status', whereIn: ['Approved', 'Completed'])
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
    // Query all users and filter client-side for isCitizen == true
    final usersStream = _firestore
        .collection('users')
        .snapshots()
        .map(
          (snap) => snap.docs
              .where((doc) => doc.data()['isCitizen'] == true)
              .map((doc) => _citizenFromMap(doc.id, doc.data()))
              .toList(),
        )
        .onErrorReturn(const <Citizen>[]);

    final legacyCitizensStream = _firestore
        .collection('citizens')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => _citizenFromMap(doc.id, doc.data()))
              .toList(),
        )
        .onErrorReturn(const <Citizen>[]);

    return CombineLatestStream.combine2(
      usersStream,
      legacyCitizensStream,
      (List<Citizen> users, List<Citizen> legacyCitizens) {
        final merged = <String, Citizen>{};
        for (final c in users) {
          merged[_citizenIdentity(c)] = c;
        }
        for (final c in legacyCitizens) {
          merged.putIfAbsent(_citizenIdentity(c), () => c);
        }
        final list = merged.values.toList()
          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        return list;
      },
    );
  }

  /// Returns a real-time count of registered citizens across users and citizens collections.
  Stream<int> citizenCount() {
    return citizens().map((items) => items.length);
  }

  Citizen _citizenFromMap(String id, Map<String, dynamic> map) {
    final name = ((map['name'] as String?) ??
            (map['fullName'] as String?) ??
            (map['displayName'] as String?) ??
            (map['email'] as String?) ??
            '')
        .trim();

    final profession = ((map['profession'] as String?) ??
            (map['occupation'] as String?) ??
            (map['job'] as String?) ??
            '')
        .trim();

    final phone = ((map['phone'] as String?) ??
            (map['phoneNumber'] as String?) ??
            (map['mobile'] as String?) ??
            '')
        .trim();

    final photoUrl = ((map['photoUrl'] as String?) ??
            (map['profileImage'] as String?) ??
            (map['avatar'] as String?) ??
            '')
        .trim();

    final village = ((map['village'] as String?) ??
            (map['address'] as String?) ??
            (map['location'] as String?) ??
            '')
        .trim();

    return Citizen(
      id: id,
      name: name,
      profession: profession,
      phone: phone,
      photoUrl: photoUrl,
      village: village,
    );
  }

  String _citizenIdentity(Citizen c) {
    final cleanPhone = c.phone.replaceAll(RegExp(r'[^0-9+]'), '').toLowerCase();
    if (cleanPhone.isNotEmpty) return 'phone:$cleanPhone';
    final cleanName = c.name.trim().toLowerCase();
    final cleanVillage = c.village.trim().toLowerCase();
    if (cleanName.isNotEmpty) return 'name:$cleanName|village:$cleanVillage';
    return 'id:${c.id}';
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

  /// Returns a stream of unread notification count.
  /// Combines notifications collection with user's notification_reads subcollection.
  Stream<int> unreadNotificationCount() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream<int>.value(0);
    }
    
    return CombineLatestStream.combine2(
      notifications(),
      myReadNotificationIds(),
      (List<AppNotification> notifications, Set<String> readIds) {
        return notifications.where((n) => !readIds.contains(n.id)).length;
      },
    );
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
    String? receivedAccountId,
    String? receivedAccountLabel,
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
        'receivedAccountId': receivedAccountId,
        'receivedAccountLabel': receivedAccountLabel,
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
      if (receivedAccountId != null && receivedAccountId.isNotEmpty)
        'receivedAccountId': receivedAccountId,
      if (receivedAccountLabel != null && receivedAccountLabel.isNotEmpty)
        'receivedAccountLabel': receivedAccountLabel,
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
      if (photo != null) {
        throw StateError('Cannot attach photos while offline. Please connect to internet or submit without photo.');
      }
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
      // Validate image size (max 5MB)
      final bytes = await photo.readAsBytes();
      if (bytes.length > 5 * 1024 * 1024) {
        throw StateError('Image size too large. Please select an image smaller than 5MB.');
      }
      
      final base64Image = base64Encode(bytes);
      
      // Get API key from environment (should be set up securely)
      const imgbbApiKey = String.fromEnvironment('IMGBB_API_KEY', defaultValue: '');
      if (imgbbApiKey.isEmpty) {
        throw StateError('Image upload is not configured. Please contact administrator or submit without photo.');
      }
      
      try {
        final httpClient = HttpClient()..connectionTimeout = const Duration(seconds: 30);
        final request = await httpClient.postUrl(
          Uri.parse('https://api.imgbb.com/1/upload?key=$imgbbApiKey'),
        );
        request.headers.contentType = ContentType('application', 'x-www-form-urlencoded');
        request.write('image=${Uri.encodeComponent(base64Image)}');
        final res = await request.close().timeout(const Duration(seconds: 60));
        
        if (res.statusCode != 200) {
          throw StateError('Image upload failed with status ${res.statusCode}');
        }
        
        final resBody = await res.transform(utf8.decoder).join();
        final json = jsonDecode(resBody);
        if (json['success'] == true) {
          photoUrl = json['data']['url'];
        } else {
          final errorMsg = json['error']?['message'] ?? 'Unknown error';
          throw StateError('Image upload failed: $errorMsg');
        }
      } catch (e) {
        if (e is StateError) rethrow;
        throw StateError('Image upload failed: ${e.toString()}');
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
      'upvotes': 0,
      'downvotes': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Note: Notifications will be sent when admin approves the problem,
    // not when it's submitted (since pending problems are hidden from citizens).
  }

  /// Admin approves a pending problem, making it visible to all citizens.
  Future<void> approveProblem(String problemId) async {
    final problemDoc = await _firestore.collection('problems').doc(problemId).get();
    final data = problemDoc.data();
    if (data == null) throw StateError('Problem not found.');

    final title = data['title'] as String? ?? 'Untitled';
    final reporterName = data['reportedByName'] as String? ?? 'Citizen';

    await _firestore.collection('problems').doc(problemId).update({
      'status': 'Approved',
    });

    // Now send notification since problem is visible
    await _firestore.collection('notifications').add({
      'title': 'নতুন সমস্যা রিপোর্ট',
      'body': '$reporterName "$title" সমস্যা রিপোর্ট করেছেন',
      'type': 'problem',
      'createdAt': FieldValue.serverTimestamp(),
    });

  }

  /// Admin rejects a pending problem.
  Future<void> rejectProblem(String problemId) async {
    await _firestore.collection('problems').doc(problemId).delete();
  }

  /// Admin marks a problem as completed.
  Future<void> completeProblem(String problemId) async {
    await _firestore.collection('problems').doc(problemId).update({
      'status': 'Completed',
    });
  }

  /// Get all pending problems (for admin review).
  Stream<List<ProblemReport>> pendingProblems() {
    return _firestore
        .collection('problems')
        .where('status', isEqualTo: 'Pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ProblemReport.fromDoc).toList());
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

  // ─── Problem Voting ─────────────────────────────────────────────────

  /// Vote on a problem report. Pass `1` for upvote, `-1` for downvote.
  /// If the user already voted the same way, the vote is removed.
  Future<void> voteOnProblem(String problemId, int vote) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Login required to vote.');
    }
    if (vote != 1 && vote != -1) {
      throw ArgumentError('Vote must be 1 (upvote) or -1 (downvote).');
    }

    final problemRef = _firestore.collection('problems').doc(problemId);
    final voteRef = problemRef.collection('votes').doc(user.uid);

    // Get current vote status
    final voteDoc = await voteRef.get();
    final existingVote = voteDoc.exists ? (voteDoc.data()?['vote'] as int?) : null;

    final batch = _firestore.batch();

    if (existingVote == vote) {
      // Same vote again = remove vote (toggle off)
      batch.delete(voteRef);
      if (vote == 1) {
        batch.set(problemRef, {'upvotes': FieldValue.increment(-1)}, SetOptions(merge: true));
      } else {
        batch.set(problemRef, {'downvotes': FieldValue.increment(-1)}, SetOptions(merge: true));
      }
    } else if (existingVote != null) {
      // Changing vote direction
      batch.set(voteRef, {
        'vote': vote,
        'votedAt': FieldValue.serverTimestamp(),
        'voterId': user.uid,
      });
      if (vote == 1) {
        // Was downvote, now upvote
        batch.set(problemRef, {
          'upvotes': FieldValue.increment(1),
          'downvotes': FieldValue.increment(-1),
        }, SetOptions(merge: true));
      } else {
        // Was upvote, now downvote
        batch.set(problemRef, {
          'upvotes': FieldValue.increment(-1),
          'downvotes': FieldValue.increment(1),
        }, SetOptions(merge: true));
      }
    } else {
      // New vote - first ensure problem has vote fields
      batch.set(voteRef, {
        'vote': vote,
        'votedAt': FieldValue.serverTimestamp(),
        'voterId': user.uid,
      });
      if (vote == 1) {
        batch.set(problemRef, {'upvotes': FieldValue.increment(1)}, SetOptions(merge: true));
      } else {
        batch.set(problemRef, {'downvotes': FieldValue.increment(1)}, SetOptions(merge: true));
      }
    }

    await batch.commit();
  }

  /// Get the current user's vote on a specific problem.
  /// Returns a stream with vote value (+1, -1, or null if not voted).
  Stream<int?> myVoteOnProblem(String problemId) {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream<int?>.value(null);
    }
    return _firestore
        .collection('problems')
        .doc(problemId)
        .collection('votes')
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.exists ? (doc.data()?['vote'] as int?) : null);
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
              receivedAccountId: op['receivedAccountId'] as String?,
              receivedAccountLabel: op['receivedAccountLabel'] as String?,
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

  // ─── Payment Methods (from Firestore configuration) ───────────────

  /// Returns a stream of available payment methods from Firestore.
  /// Falls back to default methods if not configured in database.
  Stream<List<Map<String, dynamic>>> paymentMethods() async* {
    try {
      await for (final snap in _firestore
          .collection('config')
          .doc('paymentMethods')
          .snapshots()) {
        
        if (!snap.exists) {
          debugPrint('Payment methods document does not exist, using defaults');
          yield _getDefaultPaymentMethods();
          continue;
        }
        
        final data = snap.data() ?? {};
        final methods = data['methods'] as List<dynamic>? ?? [];
        
        debugPrint('Payment methods from Firestore: ${methods.length} items, data: $methods');
        
        if (methods.isEmpty) {
          // Return default methods if not configured
          debugPrint('Payment methods array is empty, using defaults');
          yield _getDefaultPaymentMethods();
          continue;
        }
        
        final result = methods.map((m) {
          if (m is Map<String, dynamic>) {
            return m;
          }
          return <String, dynamic>{};
        }).toList();
        
        debugPrint('Returning ${result.length} payment methods from Firestore');
        yield result;
      }
    } catch (error) {
      debugPrint('Error in paymentMethods stream: $error, returning defaults');
      yield _getDefaultPaymentMethods();
    }
  }

  /// Get default payment methods (fallback if not in database)
  static List<Map<String, dynamic>> _getDefaultPaymentMethods() {
    return const [
      {
        'key': 'bKash',
        'bn': 'বিকাশ',
        'color': 0xFFE2136E,
        'icon': 'phone_android_rounded',
      },
      {
        'key': 'Nagad',
        'bn': 'নগদ',
        'color': 0xFFFF6A00,
        'icon': 'phone_android_rounded',
      },
      {
        'key': 'Rocket',
        'bn': 'রকেট',
        'color': 0xFF8B2FA0,
        'icon': 'phone_android_rounded',
      },
      {
        'key': 'Bank',
        'bn': 'ব্যাংক অ্যাকাউন্ট',
        'color': 0xFF1E40AF,
        'icon': 'account_balance_rounded',
      },
    ];
  }

  /// Update payment methods (admin only)
  Future<void> updatePaymentMethods(List<Map<String, dynamic>> methods) async {
    await _firestore.collection('config').doc('paymentMethods').set({
      'methods': methods,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // ─── Pending Problems Count (for UI badges) ──────────────────────

  /// Returns a stream of the count of pending/unresolved problems.
  Stream<int> pendingProblemsCount() {
    return _firestore
        .collection('problems')
        .where('status', isEqualTo: 'Pending')
        .snapshots()
        .map((snap) => snap.size);
  }
}
