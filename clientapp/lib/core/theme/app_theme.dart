import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modern Minimal Theme for AL ISLAH.
///
/// Hairline borders, restrained motion, neutral surfaces with a single
/// emerald accent. Compact radii (8/12/16) for a calmer rhythm.

// ============================================================================
// DESIGN TOKENS
// ============================================================================

abstract final class _LightTokens {
  static const Color background     = Color(0xFFFAFAFA);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF4F4F5);
  static const Color primary        = Color(0xFF15803D); // emerald-700
  static const Color primaryMuted   = Color(0xFFECFDF5);
  static const Color onSurface      = Color(0xFF09090B);
  static const Color muted          = Color(0xFF52525B);
  static const Color border         = Color(0xFFE4E4E7);
  static const Color borderLight    = Color(0xFFF4F4F5);
  static const Color success        = Color(0xFF16A34A);
  // ignore: unused_field
  static const Color successMuted   = Color(0xFFDCFCE7);
  static const Color warning        = Color(0xFFD97706);
  // ignore: unused_field
  static const Color warningMuted   = Color(0xFFFEF3C7);
  static const Color error          = Color(0xFFDC2626);
  // ignore: unused_field
  static const Color errorMuted     = Color(0xFFFEE2E2);
  static const Color info           = Color(0xFF2563EB);
  // ignore: unused_field
  static const Color infoMuted      = Color(0xFFDBEAFE);
}

abstract final class _DarkTokens {
  static const Color background     = Color(0xFF09090B);
  static const Color surface        = Color(0xFF18181B);
  static const Color surfaceVariant = Color(0xFF27272A);
  static const Color primary        = Color(0xFF34D399); // emerald-400
  static const Color primaryMuted   = Color(0xFF052E1B);
  static const Color onSurface      = Color(0xFFFAFAFA);
  static const Color muted          = Color(0xFFA1A1AA);
  static const Color border         = Color(0xFF27272A);
  static const Color borderLight    = Color(0xFF1F1F23);
  static const Color success        = Color(0xFF4ADE80);
  // ignore: unused_field
  static const Color successMuted   = Color(0xFF052E1B);
  static const Color warning        = Color(0xFFFBBF24);
  // ignore: unused_field
  static const Color warningMuted   = Color(0xFF451A03);
  static const Color error          = Color(0xFFF87171);
  // ignore: unused_field
  static const Color errorMuted     = Color(0xFF450A0A);
  static const Color info           = Color(0xFF60A5FA);
  // ignore: unused_field
  static const Color infoMuted      = Color(0xFF0C2747);
}

// ============================================================================
// SPACING / SHAPE
// ============================================================================

abstract final class Sp {
  static const double xs  =  4.0;
  static const double sm  =  8.0;
  static const double md  = 12.0;
  static const double lg  = 16.0;
  static const double xl  = 20.0;
  static const double xxl = 24.0;
  static const double x3  = 32.0;
  static const double x4  = 48.0;
  static const double x5  = 64.0;
}

abstract final class Rd {
  static const double sm   =  6.0;
  static const double md   = 10.0;
  static const double lg   = 12.0;
  static const double xl   = 16.0;
  static const double pill = 999.0;
}

// ============================================================================
// THEME
// ============================================================================

abstract final class AppTheme {
  static TextTheme _buildTextTheme(Color onSurface, Color muted) {
    final base = GoogleFonts.notoSansTextTheme();
    return base.copyWith(
      displayLarge: GoogleFonts.notoSans(
        fontSize: 32, fontWeight: FontWeight.w700,
        color: onSurface, letterSpacing: -0.4, height: 1.15,
      ),
      displayMedium: GoogleFonts.notoSans(
        fontSize: 28, fontWeight: FontWeight.w700,
        color: onSurface, letterSpacing: -0.3, height: 1.2,
      ),
      headlineLarge: GoogleFonts.notoSans(
        fontSize: 24, fontWeight: FontWeight.w600,
        color: onSurface, letterSpacing: -0.3, height: 1.25,
      ),
      headlineMedium: GoogleFonts.notoSans(
        fontSize: 20, fontWeight: FontWeight.w600,
        color: onSurface, letterSpacing: -0.2,
      ),
      headlineSmall: GoogleFonts.notoSans(
        fontSize: 18, fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleLarge: GoogleFonts.notoSans(
        fontSize: 17, fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleMedium: GoogleFonts.notoSans(
        fontSize: 15, fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleSmall: GoogleFonts.notoSans(
        fontSize: 13, fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      bodyLarge: GoogleFonts.notoSans(
        fontSize: 15, fontWeight: FontWeight.w400,
        color: muted, height: 1.5,
      ),
      bodyMedium: GoogleFonts.notoSans(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: muted, height: 1.5,
      ),
      bodySmall: GoogleFonts.notoSans(
        fontSize: 13, fontWeight: FontWeight.w400,
        color: muted, height: 1.45,
      ),
      labelLarge: GoogleFonts.notoSans(
        fontSize: 14, fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      labelMedium: GoogleFonts.notoSans(
        fontSize: 12, fontWeight: FontWeight.w500,
        color: muted,
      ),
      labelSmall: GoogleFonts.notoSans(
        fontSize: 11, fontWeight: FontWeight.w500,
        color: muted, letterSpacing: 0.4,
      ),
    );
  }

  static ColorScheme get _lightScheme => const ColorScheme.light(
    brightness: Brightness.light,
    primary:            _LightTokens.primary,
    onPrimary:          Colors.white,
    primaryContainer:   _LightTokens.primaryMuted,
    onPrimaryContainer: _LightTokens.primary,
    secondary:          Color(0xFF334155),
    onSecondary:        Colors.white,
    surface:            _LightTokens.surface,
    onSurface:          _LightTokens.onSurface,
    surfaceContainerHighest: _LightTokens.surfaceVariant,
    error:              _LightTokens.error,
    onError:            Colors.white,
    outline:            _LightTokens.border,
    outlineVariant:     _LightTokens.borderLight,
    shadow:             Color(0xFF000000),
    scrim:              Color(0xFF000000),
  );

  static ColorScheme get _darkScheme => const ColorScheme.dark(
    brightness: Brightness.dark,
    primary:            _DarkTokens.primary,
    onPrimary:          Color(0xFF052E1B),
    primaryContainer:   _DarkTokens.primaryMuted,
    onPrimaryContainer: _DarkTokens.primary,
    secondary:          Color(0xFF94A3B8),
    onSecondary:        Color(0xFF0F172A),
    surface:            _DarkTokens.surface,
    onSurface:          _DarkTokens.onSurface,
    surfaceContainerHighest: _DarkTokens.surfaceVariant,
    error:              _DarkTokens.error,
    onError:            Color(0xFF450A0A),
    outline:            _DarkTokens.border,
    outlineVariant:     _DarkTokens.borderLight,
    shadow:             Color(0xFF000000),
    scrim:              Color(0xFF000000),
  );

  // ── Sub-themes ────────────────────────────────────────────────────────
  static AppBarTheme _appBarTheme(ColorScheme cs) => AppBarTheme(
    backgroundColor: cs.surface,
    foregroundColor: cs.onSurface,
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
    systemOverlayStyle: cs.brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark,
    titleTextStyle: GoogleFonts.notoSans(
      fontSize: 17, fontWeight: FontWeight.w600,
      color: cs.onSurface,
    ),
    toolbarHeight: 56,
  );

  static CardThemeData _cardTheme(ColorScheme cs) => CardThemeData(
    color: cs.surface,
    elevation: 0,
    shadowColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    margin: const EdgeInsets.symmetric(vertical: Sp.sm),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Rd.lg),
      side: BorderSide(color: cs.outline, width: 1),
    ),
  );

  static NavigationBarThemeData _navBarTheme(ColorScheme cs) =>
      NavigationBarThemeData(
    height: 64,
    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    backgroundColor: cs.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    indicatorColor: cs.primaryContainer,
    indicatorShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Rd.lg),
    ),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return GoogleFonts.notoSans(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: cs.primary,
        );
      }
      return GoogleFonts.notoSans(
        fontSize: 11, fontWeight: FontWeight.w500,
        color: cs.onSurface.withValues(alpha: 0.55),
      );
    }),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return IconThemeData(color: cs.primary, size: 22);
      }
      return IconThemeData(
        color: cs.onSurface.withValues(alpha: 0.55),
        size: 22,
      );
    }),
  );

  static InputDecorationTheme _inputTheme(ColorScheme cs) =>
      InputDecorationTheme(
    filled: true,
    fillColor: cs.surface,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: Sp.lg,
      vertical: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Rd.md),
      borderSide: BorderSide(color: cs.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Rd.md),
      borderSide: BorderSide(color: cs.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Rd.md),
      borderSide: BorderSide(color: cs.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Rd.md),
      borderSide: BorderSide(color: cs.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Rd.md),
      borderSide: BorderSide(color: cs.error, width: 1.5),
    ),
    labelStyle: GoogleFonts.notoSans(
      fontSize: 14, color: cs.onSurface.withValues(alpha: 0.7),
    ),
    hintStyle: GoogleFonts.notoSans(
      fontSize: 14, color: cs.onSurface.withValues(alpha: 0.4),
    ),
  );

  static FilledButtonThemeData _filledBtnTheme(ColorScheme cs) =>
      FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: cs.primary,
      foregroundColor: cs.onPrimary,
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Rd.md),
      ),
      textStyle: GoogleFonts.notoSans(
        fontSize: 14, fontWeight: FontWeight.w600,
      ),
      elevation: 0,
    ),
  );

  static OutlinedButtonThemeData _outlinedBtnTheme(ColorScheme cs) =>
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: cs.onSurface,
      side: BorderSide(color: cs.outline, width: 1),
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Rd.md),
      ),
      textStyle: GoogleFonts.notoSans(
        fontSize: 14, fontWeight: FontWeight.w600,
      ),
    ),
  );

  static TextButtonThemeData _textBtnTheme(ColorScheme cs) =>
      TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: cs.primary,
      minimumSize: const Size(0, 40),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Rd.sm),
      ),
      textStyle: GoogleFonts.notoSans(
        fontSize: 14, fontWeight: FontWeight.w600,
      ),
    ),
  );

  static SnackBarThemeData _snackBarTheme(ColorScheme cs) => SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: cs.brightness == Brightness.dark
        ? _DarkTokens.surfaceVariant
        : _LightTokens.onSurface,
    contentTextStyle: GoogleFonts.notoSans(
      fontSize: 14, fontWeight: FontWeight.w500,
      color: cs.brightness == Brightness.dark
          ? _DarkTokens.onSurface
          : Colors.white,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Rd.md),
    ),
    actionTextColor: cs.primary,
  );

  static SwitchThemeData _switchTheme(ColorScheme cs) => SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected) ? Colors.white : cs.outline,
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected)
          ? cs.primary
          : cs.surfaceContainerHighest,
    ),
    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
  );

  // ── ThemeData builders ────────────────────────────────────────────────
  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme cs,
    required Color background,
    required Color borderColor,
    required Color surface,
    required Color onSurface,
    required Color muted,
  }) {
    final text = _buildTextTheme(onSurface, muted);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: cs,
      scaffoldBackgroundColor: background,
      canvasColor: surface,
      fontFamily: GoogleFonts.notoSans().fontFamily,
      fontFamilyFallback: const ['Noto Sans Bengali', 'Noto Sans', 'sans-serif'],
      textTheme: text,
      appBarTheme: _appBarTheme(cs),
      cardTheme: _cardTheme(cs),
      navigationBarTheme: _navBarTheme(cs),
      inputDecorationTheme: _inputTheme(cs),
      filledButtonTheme: _filledBtnTheme(cs),
      outlinedButtonTheme: _outlinedBtnTheme(cs),
      textButtonTheme: _textBtnTheme(cs),
      snackBarTheme: _snackBarTheme(cs),
      switchTheme: _switchTheme(cs),
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: Sp.xxl,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cs.surfaceContainerHighest,
        selectedColor: cs.primaryContainer,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Rd.pill),
        ),
        labelStyle: GoogleFonts.notoSans(
          fontSize: 13, fontWeight: FontWeight.w500,
          color: onSurface,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Rd.xl),
        ),
        elevation: 0,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Rd.md),
        ),
      ),
      splashColor: cs.primary.withValues(alpha: 0.05),
      highlightColor: cs.primary.withValues(alpha: 0.03),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Sp.lg, vertical: Sp.xs,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Rd.md)),
      ),
      iconTheme: IconThemeData(color: onSurface.withValues(alpha: 0.85)),
    );
  }

  static ThemeData get light => _buildTheme(
    brightness: Brightness.light,
    cs: _lightScheme,
    background: _LightTokens.background,
    borderColor: _LightTokens.border,
    surface: _LightTokens.surface,
    onSurface: _LightTokens.onSurface,
    muted: _LightTokens.muted,
  );

  static ThemeData get dark => _buildTheme(
    brightness: Brightness.dark,
    cs: _darkScheme,
    background: _DarkTokens.background,
    borderColor: _DarkTokens.border,
    surface: _DarkTokens.surface,
    onSurface: _DarkTokens.onSurface,
    muted: _DarkTokens.muted,
  );

  // ── Palette helpers (kept for legacy call-sites) ─────────────────────
  static Color success(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _DarkTokens.success
          : _LightTokens.success;
  static Color successMuted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _DarkTokens.successMuted
          : _LightTokens.successMuted;
  static Color warning(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _DarkTokens.warning
          : _LightTokens.warning;
  static Color warningMuted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _DarkTokens.warningMuted
          : _LightTokens.warningMuted;
  static Color info(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _DarkTokens.info
          : _LightTokens.info;
  static Color infoMuted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _DarkTokens.infoMuted
          : _LightTokens.infoMuted;
  static Color surfaceVariant(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _DarkTokens.surfaceVariant
          : _LightTokens.surfaceVariant;
}
