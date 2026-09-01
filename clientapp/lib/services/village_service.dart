import '../models.dart';
import 'firestore_refs.dart';
import 'stream_cache.dart';
import 'stream_utils.dart';

/// Streams the single village overview document that holds the aggregate
/// counters the admin panel maintains.
class VillageService {
  VillageService._();

  static final VillageService instance = VillageService._();

  static const VillageOverview _empty = VillageOverview(
    name: 'Our Village',
    totalCitizens: 0,
    totalFundCollected: 0,
    totalSpent: 0,
  );

  final StreamCache _cache = StreamCache('VillageService');

  void clearCache() => _cache.clear();

  Stream<VillageOverview> villageOverview() {
    return _cache.stream('villageOverview', () {
      return handleStreamErrors(
        Db.village().snapshots().map(
              (doc) =>
                  VillageOverview.fromMap(doc.data() ?? <String, dynamic>{}),
            ),
        _empty,
        'villageOverview',
      );
    });
  }
}
