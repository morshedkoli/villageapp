import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'connectivity_service.dart';
import 'core/theme/app_colors.dart';
import 'data_service.dart';
import 'firebase_options.dart';
import 'push_notification_service.dart';
import 'ui/accessibility.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 32, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              details.exception.toString().split('\n').first,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  };

  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox<String>('village_overview'),
    Hive.openBox<String>('donations'),
    Hive.openBox<String>('problems'),
    Hive.openBox<String>('projects'),
    Hive.openBox<String>('citizens'),
    Hive.openBox<String>('notifications'),
  ]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: 100 * 1024 * 1024,
  );

  await ConnectivityService.instance.initialize();
  await accessibilityController.loadSavedPreferences();
  await PushNotificationService.instance.initialize(navigatorKey);
  await DataService.instance.initialize();

  runApp(const ProviderScope(child: VillageDevelopmentApp()));
}
