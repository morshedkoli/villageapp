import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Queues writes made while offline and replays them once connectivity
/// returns. Used by [DonationService] and [ProblemService].
class OfflineQueueService {
  OfflineQueueService._();

  static final OfflineQueueService instance = OfflineQueueService._();

  static const _pendingWritesKey = 'pending_offline_writes';

  /// `type` tags stored with each queued write. They are persisted, so
  /// changing a value strands whatever is already in a user's queue.
  static const String donationWrite = 'donation';
  static const String problemWrite = 'problem';

  /// Queue a write operation for later sync when device comes back online.
  Future<void> queueWrite(Map<String, dynamic> writeOp) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_pendingWritesKey) ?? [];
    existing.add(jsonEncode(writeOp));
    await prefs.setStringList(_pendingWritesKey, existing);
    debugPrint('OfflineQueueService: Queued offline write (${writeOp['type']})');
  }

  /// Process any pending offline writes. Call when connectivity returns.
  /// [handlers] maps a write `type` to the function that replays it.
  Future<void> processPendingWrites(
    Map<String, Future<void> Function(Map<String, dynamic> op)> handlers,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getStringList(_pendingWritesKey) ?? [];
    if (pending.isEmpty) return;

    debugPrint('OfflineQueueService: Processing ${pending.length} pending writes');
    final failed = <String>[];

    for (final raw in pending) {
      try {
        final op = jsonDecode(raw) as Map<String, dynamic>;
        final handler = handlers[op['type']];
        if (handler == null) {
          debugPrint('OfflineQueueService: Unknown queued write type: ${op['type']}');
          continue;
        }
        await handler(op);
      } catch (e) {
        debugPrint('OfflineQueueService: Failed to process queued write: $e');
        failed.add(raw);
      }
    }

    await prefs.setStringList(_pendingWritesKey, failed);
    if (failed.isEmpty) {
      debugPrint('OfflineQueueService: All pending writes processed successfully');
    }
  }

  /// Returns the count of pending offline writes.
  Future<int> pendingWriteCount() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_pendingWritesKey) ?? []).length;
  }
}
