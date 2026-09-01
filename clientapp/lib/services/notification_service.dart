import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

import '../models.dart';
import 'stream_utils.dart';

/// App notifications and per-user read tracking.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<AppNotification>> notifications({int limit = 100}) {
    return handleStreamErrors(
      _firestore
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snap) => snap.docs.map(AppNotification.fromDoc).toList()),
      const <AppNotification>[],
    ).asBroadcastStream();
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
    ).asBroadcastStream();
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
}
