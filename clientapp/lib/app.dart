import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'ui/accessibility.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class VillageDevelopmentApp extends ConsumerStatefulWidget {
  const VillageDevelopmentApp({super.key});

  @override
  ConsumerState<VillageDevelopmentApp> createState() => _VillageDevelopmentAppState();
}

class _VillageDevelopmentAppState extends ConsumerState<VillageDevelopmentApp> {
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

    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      title: 'আল ইসলাহ',
      locale: Locale(settings.languageCode),
      supportedLocales: const [Locale('en'), Locale('bn')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        final scale = media.textScaler.scale(1.0) *
            (settings.largeText ? 1.25 : 1.0);
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(scale),
            boldText: settings.highContrast ? true : media.boldText,
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
