import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'push_notification_service.dart';
import 'ui/accessibility.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Restore saved language & accessibility preferences.
  await accessibilityController.loadSavedPreferences();

  // Initialize local push notifications (Firestore listener approach — free).
  await PushNotificationService.instance.initialize();

  runApp(const VillageDevelopmentApp());
}
