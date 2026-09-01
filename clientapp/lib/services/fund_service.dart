import '../models.dart';
import 'firestore_refs.dart';
import 'stream_cache.dart';
import 'stream_utils.dart';

/// Reads the village fund ledger.
///
/// Recording an expense is an admin operation: the web admin panel writes the
/// `fund_transactions` row and the matching `totalSpent` increment in one
/// transaction, and reverses both if the expense is deleted. The app only
/// displays the ledger.
class FundService {
  FundService._();

  static final FundService instance = FundService._();

  final StreamCache _cache = StreamCache('FundService');

  void clearCache() => _cache.clear();

  /// All fund transactions, newest first. Callers filter by
  /// [FundTransaction.isExpense] for the expenses view.
  Stream<List<FundTransaction>> fundTransactions({int limit = 200}) {
    return _cache.stream('fundTransactions:$limit', () {
      return handleStreamErrors(
        Db.collection(Db.fundTransactions)
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .snapshots()
            .map((snap) => snap.docs.map(FundTransaction.fromDoc).toList()),
        const <FundTransaction>[],
        'fundTransactions(limit:$limit)',
      );
    });
  }
}
