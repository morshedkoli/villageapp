import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'connectivity_service.dart';
import 'firebase_options.dart';
import 'push_notification_service.dart';
import 'ui/accessibility.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Graceful UI error widget ───────────────────────────────────────────
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 32),
          const SizedBox(height: 12),
          Text(
            'UI Error: ${details.exception.toString().split('\n').first}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  };

  // ── Hive — offline cache ───────────────────────────────────────────────
  await Hive.initFlutter();
  // Open boxes used by HiveCacheService
  await Future.wait([
    Hive.openBox<String>('village_overview'),
    Hive.openBox<String>('donations'),
    Hive.openBox<String>('problems'),
    Hive.openBox<String>('projects'),
    Hive.openBox<String>('citizens'),
    Hive.openBox<String>('notifications'),
  ]);

  // ── Firebase ───────────────────────────────────────────────────────────
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configure Firestore offline cache (100 MB)
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: 100 * 1024 * 1024,
  );

  // ── Services ───────────────────────────────────────────────────────────
  await ConnectivityService.instance.initialize();
  await accessibilityController.loadSavedPreferences();
  await PushNotificationService.instance.initialize(navigatorKey);

  runApp(const VillageDevelopmentApp());
}
