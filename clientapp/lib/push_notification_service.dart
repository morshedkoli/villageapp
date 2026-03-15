import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Push-like notification service using Firestore real-time listener +
/// flutter_local_notifications. Works on the free Firebase Spark plan —
/// no Cloud Functions needed.
///
/// How it works:
/// 1. Listens to the `notifications` Firestore collection in real-time.
/// 2. When a new document appears (created after the app started), it shows
///    a system-level local notification (heads-up / banner).
/// 3. All devices running the app will see the notification instantly.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<QuerySnapshot>? _firestoreSub;
  DateTime? _startTime;

  /// Android notification channel.
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'village_high_importance',
    'Village Updates',
    description: 'গ্রামের সব আপডেট নোটিফিকেশন',
    importance: Importance.high,
  );

  /// Call once at app startup (after Firebase.initializeApp).
  Future<void> initialize() async {
    _startTime = DateTime.now();

    await _setupLocalNotifications();
    _startListening();

    debugPrint('PushNotificationService initialized (Firestore listener)');
  }

  /// Stop listening (call on dispose if needed).
  void dispose() {
    _firestoreSub?.cancel();
    _firestoreSub = null;
  }

  Future<void> _setupLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );
    await _localNotifications.initialize(initSettings);

    // Create the notification channel on Android.
    if (!kIsWeb && Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }
  }

  /// Listen to the most recent notification doc and show a local notification
  /// for any doc created after the app started.
  void _startListening() {
    _firestoreSub = FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data == null) continue;

          // Only show notifications created after the app started.
          final createdAt = data['createdAt'] as Timestamp?;
          if (createdAt == null) continue;
          if (_startTime != null &&
              createdAt.toDate().isBefore(_startTime!)) {
            continue;
          }

          _showLocalNotification(
            id: change.doc.id.hashCode,
            title: data['title'] as String? ?? 'Village Update',
            body: data['body'] as String? ?? '',
          );
        }
      }
    }, onError: (e) {
      debugPrint('Notification listener error: $e');
    });
  }

  void _showLocalNotification({
    required int id,
    required String title,
    required String body,
  }) {
    _localNotifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }
}
