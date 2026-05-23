import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'splash_screen.dart';
import 'ui/accessibility.dart';

/// Global navigator key for push notification navigation.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class VillageDevelopmentApp extends StatefulWidget {
  const VillageDevelopmentApp({super.key});

  @override
  State<VillageDevelopmentApp> createState() => _VillageDevelopmentAppState();
}

class _VillageDevelopmentAppState extends State<VillageDevelopmentApp> {
  @override
  void initState() {
    super.initState();
    accessibilityController.addListener(_refresh);
  }

  @override
  void dispose() {
    accessibilityController.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final settings = accessibilityController.value;

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: tr('AL ISLAH', 'আল ইসলাহ'),
      locale: Locale(settings.languageCode),
      supportedLocales: const [Locale('en'), Locale('bn')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ── Theme ─────────────────────────────────────────────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,

      // ── Global builder — accessibility overrides ──────────────────────
      builder: (context, child) {
        final media = MediaQuery.of(context);
        final scale = media.textScaler.scale(1.0) *
            (settings.largeText ? 1.25 : 1.0);

        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(scale),
            boldText: settings.highContrast ? true : media.boldText,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },

      home: const SplashScreen(),
    );
  }
}
