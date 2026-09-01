import '../models.dart';
import 'firestore_refs.dart';
import 'stream_cache.dart';
import 'stream_utils.dart';

/// Reads development projects. Creating and editing them is an admin
/// operation performed in the web admin panel.
class ProjectService {
  ProjectService._();

  static final ProjectService instance = ProjectService._();

  final StreamCache _cache = StreamCache('ProjectService');

  void clearCache() => _cache.clear();

  /// Projects, newest first. Shared per [limit].
  Stream<List<DevelopmentProject>> projects({int limit = 100}) {
    return _cache.stream('projects:$limit', () {
      return handleStreamErrors(
        Db.collection(Db.projects)
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .snapshots()
            .map((snap) => snap.docs.map(DevelopmentProject.fromDoc).toList()),
        const <DevelopmentProject>[],
        'projects(limit:$limit)',
      );
    });
  }
}
