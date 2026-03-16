import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'connectivity_service.dart';
import 'firebase_options.dart';
import 'push_notification_service.dart';
import 'ui/accessibility.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Enable offline persistence with generous cache size (100 MB).
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: 100 * 1024 * 1024,
  );

  // Initialize connectivity monitoring.
  await ConnectivityService.instance.initialize();

  // Restore saved language & accessibility preferences.
  await accessibilityController.loadSavedPreferences();

  // Initialize OneSignal push notifications.
  await PushNotificationService.instance.initialize();

  runApp(const VillageDevelopmentApp());
}
