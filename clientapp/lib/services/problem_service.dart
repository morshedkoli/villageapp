import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../connectivity_service.dart';
import '../models.dart';
import 'firestore_refs.dart';
import 'image_upload_service.dart';
import 'offline_queue_service.dart';
import 'stream_cache.dart';
import 'stream_utils.dart';

/// Problem reports a citizen can file, browse and vote on.
///
/// Moderation — approving, rejecting and completing reports — is an admin
/// operation performed in the web admin panel behind `verifyAdmin`.
class ProblemService {
  ProblemService._();

  static final ProblemService instance = ProblemService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StreamCache _cache = StreamCache('ProblemService');

  void clearCache() => _cache.clear();

  /// Reported problems, newest first. Shared per [limit].
  Stream<List<ProblemReport>> problems({int limit = 100}) {
    return _cache.stream('problems:$limit', () {
      return handleStreamErrors(
        Db.collection(Db.problems)
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .snapshots()
            .map((snap) => snap.docs.map(ProblemReport.fromDoc).toList()),
        const <ProblemReport>[],
        'problems(limit:$limit)',
      );
    });
  }

  /// Problems filed by the signed-in citizen, including pending ones.
  Stream<List<ProblemReport>> myProblems() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream<List<ProblemReport>>.value(const <ProblemReport>[]);
    }
    return handleStreamErrors(
      Db.collection(Db.problems)
          .where('reportedBy', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map(ProblemReport.fromDoc).toList()),
      const <ProblemReport>[],
      'myProblems',
    );
  }

  /// Files a new report. Always `Pending`: reports stay hidden from other
  /// citizens until an admin approves them.
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

    if (!ConnectivityService.instance.isOnline) {
      // The queue is JSON in shared preferences, so a photo cannot ride along.
      if (photo != null) {
        throw StateError(
          'Cannot attach photos while offline. Please connect to internet or submit without photo.',
        );
      }
      await OfflineQueueService.instance.queueWrite({
        'type': OfflineQueueService.problemWrite,
        'title': title,
        'description': description,
        'location': location,
      });
      return;
    }

    final profile = await _firestore.collection(Db.users).doc(user.uid).get();
    final reporterName =
        profile.data()?['name'] as String? ?? user.email ?? 'Citizen';

    final photoUrl =
        photo == null ? '' : await ImageUploadService.instance.upload(photo);

    await Db.collection(Db.problems).add({
      'title': title,
      'description': description,
      'location': location,
      'photoUrl': photoUrl,
      'status': 'Pending',
      'reportedBy': user.uid,
      'reportedByName': reporterName,
      'upvotes': 0,
      'downvotes': 0,
      'source': 'app',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── Voting ─────────────────────────────────────────────────────────

  /// Casts a vote: `1` to upvote, `-1` to downvote. Voting the same way twice
  /// clears the vote.
  ///
  /// Runs in a transaction because the security rules only permit a ±1 change
  /// per write; reading the existing vote outside the write let two rapid taps
  /// compute their deltas from the same stale value and produce a count the
  /// rules would then reject.
  Future<void> voteOnProblem(String problemId, int vote) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Login required to vote.');
    }
    if (vote != 1 && vote != -1) {
      throw ArgumentError('Vote must be 1 (upvote) or -1 (downvote).');
    }

    final problemRef = Db.collection(Db.problems).doc(problemId);
    final voteRef = problemRef.collection('votes').doc(user.uid);

    await _firestore.runTransaction((tx) async {
      final voteDoc = await tx.get(voteRef);
      final existing =
          voteDoc.exists ? (voteDoc.data()?['vote'] as num?)?.toInt() : null;

      if (existing == vote) {
        tx.delete(voteRef);
        tx.set(problemRef, _voteDeltas(removed: vote), SetOptions(merge: true));
        return;
      }

      tx.set(voteRef, {
        'vote': vote,
        'voterId': user.uid,
        'votedAt': FieldValue.serverTimestamp(),
      });
      tx.set(
        problemRef,
        _voteDeltas(added: vote, removed: existing),
        SetOptions(merge: true),
      );
    });
  }

  /// Field increments for adding and/or clearing a vote, omitting any counter
  /// that nets to zero so no needless write is sent.
  static Map<String, Object> _voteDeltas({int? added, int? removed}) {
    var up = 0;
    var down = 0;
    if (added == 1) up += 1;
    if (added == -1) down += 1;
    if (removed == 1) up -= 1;
    if (removed == -1) down -= 1;

    return {
      if (up != 0) 'upvotes': FieldValue.increment(up),
      if (down != 0) 'downvotes': FieldValue.increment(down),
    };
  }

  /// The signed-in citizen's vote on [problemId]: `1`, `-1`, or `null`.
  Stream<int?> myVoteOnProblem(String problemId) {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream<int?>.value(null);
    }
    return Db.collection(Db.problems)
        .doc(problemId)
        .collection('votes')
        .doc(user.uid)
        .snapshots()
        .map((doc) => (doc.data()?['vote'] as num?)?.toInt());
  }
}
