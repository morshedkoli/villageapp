import 'dart:async';

import 'package:flutter/foundation.dart';

import '../connectivity_service.dart';
import 'citizen_service.dart';
import 'donation_service.dart';
import 'fund_service.dart';
import 'offline_queue_service.dart';
import 'problem_service.dart';
import 'project_service.dart';
import 'village_service.dart';

/// Cross-service coordination: dropping cached streams on sign-out, and
/// replaying writes that were queued while the device was offline.
///
/// The replay used to be unreachable — writes were queued but nothing ever
/// drained the queue, so a donation or report submitted offline was stored on
/// the device and never sent. [start] wires it to connectivity changes.
class SyncService {
  SyncService._();

  static final SyncService instance = SyncService._();

  bool _started = false;
  bool _draining = false;

  /// Begins watching connectivity and flushes anything already queued.
  /// Safe to call more than once.
  void start() {
    if (_started) return;
    _started = true;

    ConnectivityService.instance.addListener(_onConnectivityChanged);
    if (ConnectivityService.instance.isOnline) {
      unawaited(drainOfflineQueue());
    }
  }

  void _onConnectivityChanged() {
    if (ConnectivityService.instance.isOnline) {
      unawaited(drainOfflineQueue());
    }
  }

  /// Replays queued writes. Re-entrant calls are ignored so a connectivity
  /// flap cannot start two drains over the same queue.
  Future<void> drainOfflineQueue() async {
    if (_draining) return;
    _draining = true;
    try {
      await OfflineQueueService.instance.processPendingWrites({
        OfflineQueueService.donationWrite: (op) =>
            DonationService.instance.addDonation(
              amount: (op['amount'] as num).toDouble(),
              paymentMethod: op['paymentMethod'] as String,
              transactionId: op['transactionId'] as String,
              senderNumber: op['senderNumber'] as String,
              receivedAccountId: op['receivedAccountId'] as String?,
              receivedAccountLabel: op['receivedAccountLabel'] as String?,
            ),
        OfflineQueueService.problemWrite: (op) =>
            ProblemService.instance.reportProblem(
              title: op['title'] as String,
              description: op['description'] as String,
              location: op['location'] as String,
            ),
      });
    } catch (error) {
      debugPrint('SyncService: offline queue drain failed - $error');
    } finally {
      _draining = false;
    }
  }

  /// Number of writes still waiting to be sent.
  Future<int> pendingWriteCount() =>
      OfflineQueueService.instance.pendingWriteCount();

  /// Drops every cached stream so the next reader re-subscribes. Called on
  /// sign-out, where the previous user's data must not leak into the next
  /// session and the old subscriptions would fail on permissions anyway.
  void clearStreamCaches() {
    VillageService.instance.clearCache();
    DonationService.instance.clearCache();
    ProblemService.instance.clearCache();
    ProjectService.instance.clearCache();
    CitizenService.instance.clearCache();
    FundService.instance.clearCache();
  }
}
