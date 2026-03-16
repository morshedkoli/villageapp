import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// Push notification service using OneSignal.
///
/// Features:
/// - Initializes OneSignal SDK with the configured App ID.
/// - Requests notification permission on Android 13+ / iOS.
/// - Sets the Firebase UID as the OneSignal external user ID so
///   server-side targeting works per user.
/// - Handles foreground notification display via OneSignal's built-in UI.
/// - Keeps a Firestore real-time listener as an in-app fallback for
///   desktop platforms (Windows / Linux) where OneSignal is unsupported.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  // ── Configure your OneSignal App ID here (or via env / remote config) ──
  static const String _oneSignalAppId = 'a8ab892b-a4ca-4161-b54b-8828c22dfc8f';

  StreamSubscription<QuerySnapshot>? _firestoreSub;
  StreamSubscription<User?>? _authSub;
  DateTime? _startTime;

  bool _permissionGranted = false;
  bool get permissionGranted => _permissionGranted;

  /// Call once at app startup (after Firebase.initializeApp).
  Future<void> initialize() async {
    _startTime = DateTime.now();

    // OneSignal is only supported on Android / iOS / macOS.
    if (!kIsWeb) {
      OneSignal.initialize(_oneSignalAppId);

      // Request permission (shows system dialog on Android 13+ / iOS).
      _permissionGranted =
          await OneSignal.Notifications.requestPermission(true);
      debugPrint('OneSignal permission granted: $_permissionGranted');

      // Display foreground notifications using OneSignal's default UI.
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        event.notification.display();
      });

      OneSignal.Notifications.addClickListener((event) {
        debugPrint(
            'OneSignal notification tapped: ${event.notification.additionalData}');
      });
    }

    _listenToAuthState();
    debugPrint('PushNotificationService initialized (OneSignal + Firestore)');
  }

  /// Stop all listeners and log out of OneSignal.
  void dispose() {
    _authSub?.cancel();
    _authSub = null;
    _firestoreSub?.cancel();
    _firestoreSub = null;
  }

  /// Public method to re-request permission (e.g., from settings screen).
  Future<bool> requestPermission() async {
    if (!kIsWeb) {
      _permissionGranted =
          await OneSignal.Notifications.requestPermission(true);
    }
    return _permissionGranted;
  }

  // ─── Auth state: login / logout OneSignal ────────────────────────

  void _listenToAuthState() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _onLogin(user);
      } else {
        _onLogout();
      }
    });
  }

  Future<void> _onLogin(User user) async {
    if (!kIsWeb) {
      // Link OneSignal device to the Firebase UID for targeted pushes.
      await OneSignal.login(user.uid);
      debugPrint('OneSignal logged in as: ${user.uid}');
    }
    _startFirestoreListener();
  }

  void _onLogout() {
    if (!kIsWeb) {
      OneSignal.logout();
    }
    _firestoreSub?.cancel();
    _firestoreSub = null;
  }

  // ─── Firestore real-time listener (fallback / in-app display) ────

  void _startFirestoreListener() {
    _firestoreSub?.cancel();
    _firestoreSub = FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type != DocumentChangeType.added) continue;

        final data = change.doc.data();
        if (data == null) continue;

        final createdAt = data['createdAt'] as Timestamp?;
        if (createdAt == null) continue;
        if (_startTime != null &&
            createdAt.toDate().isBefore(_startTime!)) continue;

        // On desktop (no OneSignal), log the incoming notification so the
        // app's own notification UI can pick it up via Firestore.
        if (kIsWeb || !_permissionGranted) {
          debugPrint(
              'In-app notification: ${data['title']} — ${data['body']}');
        }
      }
    }, onError: (e) => debugPrint('Notification listener error: $e'));
  }
}
