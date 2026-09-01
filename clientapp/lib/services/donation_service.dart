import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../connectivity_service.dart';
import '../models.dart';
import 'firestore_refs.dart';
import 'offline_queue_service.dart';
import 'stream_cache.dart';
import 'stream_utils.dart';

/// Reads donations and the village payment accounts, and submits a citizen's
/// own donation for admin review.
///
/// Approving, rejecting and deleting donations, and editing payment accounts,
/// are admin operations. They live in the web admin panel behind
/// `verifyAdmin`, which also keeps `villages/main_village.totalFundCollected`
/// and the `fund_transactions` ledger consistent. The app never performs them.
class DonationService {
  DonationService._();

  static final DonationService instance = DonationService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StreamCache _cache = StreamCache('DonationService');

  void clearCache() => _cache.clear();

  /// Approved donations, newest first. Shared per [limit] so the home preview
  /// and the full list do not open two identical subscriptions.
  Stream<List<Donation>> donations({int limit = 100}) {
    return _cache.stream('donations:$limit', () {
      return handleStreamErrors(
        Db.collection(Db.donations)
            .where('status', isEqualTo: 'Approved')
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .snapshots()
            .map((snap) => snap.docs.map(Donation.fromDoc).toList()),
        const <Donation>[],
        'donations(limit:$limit)',
      );
    });
  }

  /// The signed-in citizen's own donations, including pending ones.
  Stream<List<Donation>> myDonations() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream<List<Donation>>.value(const <Donation>[]);
    }
    return handleStreamErrors(
      Db.collection(Db.donations)
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map(Donation.fromDoc).toList()),
      const <Donation>[],
      'myDonations',
    );
  }

  /// Payment accounts the village can receive donations on.
  ///
  /// The admin panel stores these as an array on the village document; very old
  /// installs stored a map keyed by payment type. Both shapes are read here.
  Stream<List<Map<String, String>>> donationAccounts() {
    return _cache.stream('donationAccounts', () {
      return handleStreamErrors(
        Db.village().snapshots().map(
              (doc) => parsePaymentAccounts(
                (doc.data() ?? const <String, dynamic>{})['paymentAccounts'],
              ),
            ),
        const <Map<String, String>>[],
        'donationAccounts',
      );
    });
  }

  /// Reads the `paymentAccounts` field in either storage shape.
  static List<Map<String, String>> parsePaymentAccounts(dynamic raw) {
    if (raw is List) return _accountsFromList(raw);
    if (raw is Map) return _accountsFromLegacyMap(raw);
    return const <Map<String, String>>[];
  }

  static List<Map<String, String>> _accountsFromList(List<dynamic> raw) {
    final result = <Map<String, String>>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final type = normalizePaymentType(_text(item['type']));
      final id = _text(item['id']);
      result.add(
        _account(
          id: id.isNotEmpty ? id : _fallbackId(type, result.length),
          type: type,
          item: item,
        ),
      );
    }
    return result;
  }

  static List<Map<String, String>> _accountsFromLegacyMap(
    Map<dynamic, dynamic> raw,
  ) {
    final result = <Map<String, String>>[];
    for (final entry in raw.entries) {
      final type = normalizePaymentType(_text(entry.key));
      final id = _fallbackId(type, result.length);
      final value = entry.value;
      if (value is Map) {
        result.add(_account(id: id, type: type, item: value));
      } else {
        result.add({
          'id': id,
          'type': type,
          'number': _text(value),
          'name': '',
        });
      }
    }
    return result;
  }

  static Map<String, String> _account({
    required String id,
    required String type,
    required Map<dynamic, dynamic> item,
  }) {
    final bankName = _text(item['bankName']);
    final branch = _text(item['branch']);
    return {
      'id': id,
      'type': type,
      'number': _text(item['number']),
      'name': _text(item['name']),
      if (bankName.isNotEmpty) 'bankName': bankName,
      if (branch.isNotEmpty) 'branch': branch,
    };
  }

  static String _fallbackId(String type, int index) =>
      '${type.toLowerCase()}_${index + 1}';

  static String _text(dynamic value) => (value ?? '').toString().trim();

  /// Maps the admin panel's lowercase account type onto the app's display name.
  static String normalizePaymentType(String type) {
    switch (type.toLowerCase()) {
      case 'bkash':
        return 'bKash';
      case 'nagad':
        return 'Nagad';
      case 'rocket':
        return 'Rocket';
      case 'bank':
        return 'Bank';
      default:
        return type;
    }
  }

  /// Submits a donation for admin review. Always written as `Pending`: the
  /// village fund is only credited when an admin approves it in the panel.
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

    if (!ConnectivityService.instance.isOnline) {
      await OfflineQueueService.instance.queueWrite({
        'type': OfflineQueueService.donationWrite,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'transactionId': transactionId,
        'senderNumber': senderNumber,
        'receivedAccountId': receivedAccountId,
        'receivedAccountLabel': receivedAccountLabel,
      });
      return;
    }

    final profile = await _firestore.collection(Db.users).doc(user.uid).get();
    final donorName =
        profile.data()?['name'] as String? ?? user.email ?? 'Citizen';

    await Db.collection(Db.donations).add({
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
      'source': 'app',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
