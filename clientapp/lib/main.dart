import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'push_notification_service.dart';
import 'ui/accessibility.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Enable offline persistence — data is cached locally and only
  // changed documents are synced when the device comes back online.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Restore saved language & accessibility preferences.
  await accessibilityController.loadSavedPreferences();

  // Initialize local push notifications (Firestore listener approach — free).
  await PushNotificationService.instance.initialize();

  runApp(const VillageDevelopmentApp());
}
