import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'splash_screen.dart';
import 'ui/accessibility.dart';

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
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = accessibilityController.value;
    const accent = Color(0xFFFF9500);
    const primary = Color(0xFF1C1C1E);
    const secondary = Color(0xFF8E8E93);
    const borderColor = Color(0xFFE5E7EB);
    final background = settings.highContrast
        ? const Color(0xFFF2F2F7)
        : const Color(0xFFFFFFFF);
    const surface = Colors.white;
    final foreground = settings.highContrast
        ? const Color(0xFF000000)
        : const Color(0xFF1C1C1E);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: accent,
      secondary: secondary,
      surface: surface,
      brightness: Brightness.light,
    );

    final baseTextTheme = GoogleFonts.interTextTheme().copyWith(
      headlineSmall: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3),
      titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.1),
      bodyLarge: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
      bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93)),
      labelLarge: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    );
    final textTheme = baseTextTheme.apply(
      fontSizeFactor: settings.largeText ? 1.25 : 1,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: tr('Doulatpara', 'দৌলতপাড়া'),
      locale: Locale(settings.languageCode),
      supportedLocales: const [Locale('en'), Locale('bn')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: background,
        textTheme: textTheme,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: surface,
          foregroundColor: foreground,
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: textTheme.titleLarge?.copyWith(
            color: foreground,
            letterSpacing: -0.3,
          ),
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: borderColor),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 70,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          indicatorColor: Colors.transparent,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: accent, size: 26);
            }
            return const IconThemeData(color: Color(0xFF8E8E93), size: 26);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return textTheme.labelSmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              );
            }
            return textTheme.labelSmall?.copyWith(
              color: const Color(0xFF8E8E93),
              letterSpacing: 0,
            );
          }),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          side: const BorderSide(color: borderColor),
          selectedColor: const Color(0xFFFFF0E0),
          backgroundColor: surface,
          labelStyle: textTheme.bodySmall?.copyWith(
            color: primary,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return accent;
              }
              return surface;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return secondary;
            }),
            textStyle: WidgetStatePropertyAll(
              textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            side: const WidgetStatePropertyAll(
              BorderSide(color: borderColor),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            visualDensity: VisualDensity.compact,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: borderColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        listTileTheme: const ListTileThemeData(minVerticalPadding: 12),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFF1F5F9),
          thickness: 1,
          space: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: accent, width: 1.5),
          ),
          hintStyle: const TextStyle(color: secondary),
          labelStyle: const TextStyle(color: secondary),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: primary,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
      ),
      builder: (context, child) {
        final media = MediaQuery.of(context);
        final compactLayout = media.size.width <= 360;
        final scale =
            media.textScaler.scale(1.0) * (settings.largeText ? 1.25 : 1.0);
        final theme = Theme.of(context);

        final adaptiveTheme = theme.copyWith(
          cardTheme: theme.cardTheme.copyWith(
            margin: EdgeInsets.symmetric(vertical: compactLayout ? 4 : 6),
          ),
          listTileTheme: theme.listTileTheme.copyWith(
            minVerticalPadding: compactLayout ? 10 : 12,
            dense: compactLayout,
          ),
          chipTheme: theme.chipTheme.copyWith(
            labelPadding: EdgeInsets.symmetric(
              horizontal: compactLayout ? 8 : 10,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: compactLayout ? 6 : 8,
              vertical: compactLayout ? 2 : 4,
            ),
          ),
        );

        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(scale),
            boldText: settings.highContrast ? true : media.boldText,
          ),
          child: Theme(
            data: adaptiveTheme,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}
