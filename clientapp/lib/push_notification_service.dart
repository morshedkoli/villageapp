import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'models.dart';
import 'screens.dart';

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  static const String _broadcastTopic = 'village_broadcast';

  StreamSubscription<QuerySnapshot>? _firestoreSub;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundMessageSub;
  StreamSubscription<RemoteMessage>? _messageOpenedSub;
  DateTime? _startTime;
  GlobalKey<NavigatorState>? _navigatorKey;

  bool _permissionGranted = false;
  bool get permissionGranted => _permissionGranted;

  final _notificationController = StreamController<AppNotification>.broadcast();
  Stream<AppNotification> get inAppNotificationStream =>
      _notificationController.stream;

  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    _startTime = DateTime.now();
    _navigatorKey = navigatorKey;

    if (_supportsFirebaseMessaging) {
      await _initializeFirebaseMessaging();
    } else {
      _startFirestoreListener();
    }

    _listenToAuthState();
  }

  void dispose() {
    _authSub?.cancel();
    _authSub = null;
    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
    _foregroundMessageSub?.cancel();
    _foregroundMessageSub = null;
    _messageOpenedSub?.cancel();
    _messageOpenedSub = null;
    _firestoreSub?.cancel();
    _firestoreSub = null;
    _notificationController.close();
  }

  Future<bool> requestPermission() async {
    if (!_supportsFirebaseMessaging) {
      return false;
    }

    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    _permissionGranted = _isAuthorized(settings.authorizationStatus);

    await _subscribeToBroadcasts();
    await _syncTokenToCurrentUser();

    return _permissionGranted;
  }

  bool get _supportsFirebaseMessaging {
    if (kIsWeb) {
      return false;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return false;
    }
  }

  Future<void> _initializeFirebaseMessaging() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    _permissionGranted = _isAuthorized(settings.authorizationStatus);

    await _subscribeToBroadcasts();

    _foregroundMessageSub = FirebaseMessaging.onMessage.listen((message) {
      final notification = _notificationFromRemoteMessage(message);
      if (notification != null) {
        _notificationController.add(notification);
      }
    });

    _messageOpenedSub = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _openNotificationsScreen();
    });

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openNotificationsScreen();
      });
    }

    _tokenRefreshSub = messaging.onTokenRefresh.listen((_) async {
      await _subscribeToBroadcasts();
      await _syncTokenToCurrentUser();
    });
  }

  bool _isAuthorized(AuthorizationStatus status) {
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  void _listenToAuthState() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        unawaited(_onLogin(user));
      } else {
        _onLogout();
      }
    });
  }

  Future<void> _onLogin(User user) async {
    if (_supportsFirebaseMessaging && _permissionGranted) {
      await _subscribeToBroadcasts();
      await _syncTokenToUser(user);
      return;
    }

    if (!_supportsFirebaseMessaging) {
      _startFirestoreListener();
    }
  }

  void _onLogout() {
    _firestoreSub?.cancel();
    _firestoreSub = null;
  }

  Future<void> _subscribeToBroadcasts() async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(_broadcastTopic);
    } catch (error) {
      debugPrint('Failed to subscribe to broadcast topic: $error');
    }
  }

  Future<void> _syncTokenToCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    await _syncTokenToUser(user);
  }

  Future<void> _syncTokenToUser(User user) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty) {
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'lastFcmToken': token,
      'lastFcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  AppNotification? _notificationFromRemoteMessage(RemoteMessage message) {
    final createdAt = DateTime.now();
    if (_startTime != null && createdAt.isBefore(_startTime!)) {
      return null;
    }

    final title =
        message.notification?.title ?? message.data['title']?.toString() ?? '';
    final body =
        message.notification?.body ?? message.data['body']?.toString() ?? '';

    if (title.isEmpty && body.isEmpty) {
      return null;
    }

    return AppNotification(
      id: message.messageId ?? createdAt.microsecondsSinceEpoch.toString(),
      type: message.data['type']?.toString() ?? 'general',
      title: title,
      body: body,
      createdAt: createdAt,
    );
  }

  void _openNotificationsScreen() {
    final context = _navigatorKey?.currentContext;
    if (context == null) {
      return;
    }

    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => const NotificationScreen()),
    );
  }

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
        if (_startTime != null && createdAt.toDate().isBefore(_startTime!)) {
          continue;
        }

        _notificationController.add(
          AppNotification(
            id: change.doc.id,
            type: data['type']?.toString() ?? '',
            title: data['title']?.toString() ?? '',
            body: data['body']?.toString() ?? '',
            createdAt: createdAt.toDate(),
          ),
        );
      }
    }, onError: (e) => debugPrint('Notification listener error: $e'));
  }
}
