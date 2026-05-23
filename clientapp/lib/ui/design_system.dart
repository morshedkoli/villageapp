import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modern Minimal Design System for AL ISLAH
///
/// Philosophy:
///   • Flat surfaces, subtle borders instead of heavy shadows
///   • Neutral palette with a single refined accent (emerald)
///   • Generous whitespace, clear typographic hierarchy
///   • Smaller, consistent radii (8/12/16)
///   • Calm, restrained motion
///
/// Tokens are kept under their original names so existing screens pick up
/// the new look automatically.

// ============================================================================
// COLORS
// ============================================================================

class AppColors {
  AppColors._();

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // ── Brand accent ────────────────────────────────────────────────────
  // Refined emerald — keeps the village/community identity while feeling
  // modern. Used sparingly for actions, links, and key highlights.
  static const Color primary = Color(0xFF15803D);       // emerald-700
  static const Color primaryLight = Color(0xFF22C55E);  // emerald-500
  static const Color primaryDark = Color(0xFF166534);   // emerald-800
  static const Color primaryMuted = Color(0xFFECFDF5);  // emerald-50

  // Reserved for badges/secondary; keep close to primary tonality.
  static const Color secondary = Color(0xFF334155);     // slate-700
  static const Color secondaryLight = Color(0xFF64748B); // slate-500
  static const Color secondaryDark = Color(0xFF1E293B); // slate-800

  static const Color accent = Color(0xFF22C55E);
  static const Color accentLight = Color(0xFFD1FAE5);

  // Dark mode brand tones
  static const Color _primaryD = Color(0xFF34D399);     // emerald-400
  static const Color _primaryMutedD = Color(0xFF052E1B); // emerald-950

  // ── Surface / Background ────────────────────────────────────────────
  // Light, calm neutrals. No tint, no gradient.
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF4F4F5);
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  static const Color _backgroundD = Color(0xFF09090B);
  static const Color _surfaceD = Color(0xFF18181B);
  static const Color _surfaceVariantD = Color(0xFF27272A);
  static const Color _surfaceElevatedD = Color(0xFF1F1F23);

  // ── Text ────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF09090B);
  static const Color textSecondary = Color(0xFF52525B);
  static const Color textTertiary = Color(0xFF71717A);
  static const Color textMuted = Color(0xFFA1A1AA);

  static const Color _textPrimaryD = Color(0xFFFAFAFA);
  static const Color _textSecondaryD = Color(0xFFA1A1AA);
  static const Color _textTertiaryD = Color(0xFF71717A);
  static const Color _textMutedD = Color(0xFF52525B);

  // ── Semantic ────────────────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color successDark = Color(0xFF15803D);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFFDBEAFE);

  static const Color _successD = Color(0xFF4ADE80);
  static const Color _warningD = Color(0xFFFBBF24);
  static const Color _errorD = Color(0xFFF87171);
  static const Color _infoD = Color(0xFF60A5FA);

  // ── Border / Divider ────────────────────────────────────────────────
  static const Color border = Color(0xFFE4E4E7);
  static const Color borderLight = Color(0xFFF4F4F5);
  static const Color divider = Color(0xFFE4E4E7);

  static const Color _borderD = Color(0xFF27272A);
  static const Color _borderLightD = Color(0xFF1F1F23);

  // ── Overlay ─────────────────────────────────────────────────────────
  static const Color overlayLight = Color(0x66FFFFFF);
  static const Color overlayDark = Color(0x66000000);

  // ── Context-aware getters (use in widgets) ──────────────────────────
  static Color primaryC(BuildContext c) => isDark(c) ? _primaryD : primary;
  static Color primaryMutedC(BuildContext c) =>
      isDark(c) ? _primaryMutedD : primaryMuted;
  static Color backgroundC(BuildContext c) =>
      isDark(c) ? _backgroundD : background;
  static Color surfaceC(BuildContext c) => isDark(c) ? _surfaceD : surface;
  static Color surfaceVariantC(BuildContext c) =>
      isDark(c) ? _surfaceVariantD : surfaceVariant;
  static Color surfaceElevatedC(BuildContext c) =>
      isDark(c) ? _surfaceElevatedD : surfaceElevated;
  static Color textPrimaryC(BuildContext c) =>
      isDark(c) ? _textPrimaryD : textPrimary;
  static Color textSecondaryC(BuildContext c) =>
      isDark(c) ? _textSecondaryD : textSecondary;
  static Color textTertiaryC(BuildContext c) =>
      isDark(c) ? _textTertiaryD : textTertiary;
  static Color textMutedC(BuildContext c) =>
      isDark(c) ? _textMutedD : textMuted;
  static Color successC(BuildContext c) => isDark(c) ? _successD : success;
  static Color warningC(BuildContext c) => isDark(c) ? _warningD : warning;
  static Color errorC(BuildContext c) => isDark(c) ? _errorD : error;
  static Color infoC(BuildContext c) => isDark(c) ? _infoD : info;
  static Color borderC(BuildContext c) => isDark(c) ? _borderD : border;
  static Color borderLightC(BuildContext c) =>
      isDark(c) ? _borderLightD : borderLight;
  static Color dividerC(BuildContext c) =>
      isDark(c) ? _borderD : divider;

  /// Color for icons/text on top of solid primary surfaces.
  static const Color onGradient = Colors.white;

  // ── Legacy gradient tokens kept for API compatibility ───────────────
  // These now resolve to subtle two-stop ramps within the same hue so
  // existing call-sites get a much flatter look without code changes.
  static const List<Color> primaryGradient = [
    Color(0xFF16A34A),
    Color(0xFF15803D),
  ];
  static const List<Color> primaryGradientDark = [
    Color(0xFF15803D),
    Color(0xFF166534),
  ];
  static const List<Color> secondaryGradient = [
    Color(0xFF475569),
    Color(0xFF334155),
  ];
  static const List<Color> successGradient = [
    Color(0xFF22C55E),
    Color(0xFF16A34A),
  ];
  static const List<Color> warningGradient = [
    Color(0xFFF59E0B),
    Color(0xFFD97706),
  ];
  static const List<Color> errorGradient = [
    Color(0xFFEF4444),
    Color(0xFFDC2626),
  ];
  static const List<Color> accentGradient = [
    Color(0xFF34D399),
    Color(0xFF22C55E),
  ];

  // Hero/page ramps reduced to a single near-flat tone.
  static const List<Color> heroGradient = [
    Color(0xFF15803D),
    Color(0xFF166534),
  ];
  static const List<Color> pageBackgroundGradient = [
    Color(0xFFFAFAFA),
    Color(0xFFFAFAFA),
  ];
  static const List<Color> pageTopGlowGradient = [
    Color(0x00FFFFFF),
    Color(0x00FFFFFF),
    Color(0x00FFFFFF),
  ];
  static const List<Color> sunsetGradient = [
    Color(0xFFFAFAFA),
    Color(0xFFF4F4F5),
    Color(0xFFFAFAFA),
  ];

  // Leaderboard medals (kept distinct, but more muted)
  static const List<Color> goldGradient = [
    Color(0xFFEAB308),
    Color(0xFFCA8A04),
  ];
  static const List<Color> silverGradient = [
    Color(0xFF94A3B8),
    Color(0xFF64748B),
  ];
  static const List<Color> bronzeGradient = [
    Color(0xFFB45309),
    Color(0xFF92400E),
  ];

  // Glassmorphism (rarely used now; kept for legacy call-sites)
  static const Color glassWhite = Color(0xCCFFFFFF);
  static const Color glassBlack = Color(0xCC000000);
}

// ============================================================================
// SPACING (4dp grid)
// ============================================================================

class AppSpacing {
  AppSpacing._();

  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  static const double sectionSmall = 12.0;
  static const double sectionMedium = 20.0;
  static const double sectionLarge = 28.0;

  static const double pagePaddingCompact = 16.0;
  static const double pagePaddingStandard = 20.0;
  static const double pagePaddingLarge = 24.0;
}

// ============================================================================
// BORDER RADIUS (compact, modern scale)
// ============================================================================

class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 6.0;
  static const double md = 10.0;
  static const double lg = 12.0;
  static const double xl = 14.0;
  static const double xxl = 16.0;
  static const double xxxl = 20.0;
  static const double pill = 999.0;

  static BorderRadius get xsRadius => BorderRadius.circular(xs);
  static BorderRadius get smallRadius => BorderRadius.circular(sm);
  static BorderRadius get mediumRadius => BorderRadius.circular(md);
  static BorderRadius get largeRadius => BorderRadius.circular(lg);
  static BorderRadius get xlRadius => BorderRadius.circular(xl);
  static BorderRadius get xxlRadius => BorderRadius.circular(xxl);
  static BorderRadius get pillRadius => BorderRadius.circular(pill);
}

// ============================================================================
// SHADOWS — minimal, almost imperceptible
// ============================================================================

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get none => const [];

  /// Single hairline shadow — the only shadow needed in most cases.
  static List<BoxShadow> get ultraSoft => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get soft => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get medium => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevated => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get high => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];

  // Glow helpers retained for API compatibility but rendered as flat.
  static List<BoxShadow> primaryGlow([double opacity = 0.0]) => const [];
  static List<BoxShadow> successGlow([double opacity = 0.0]) => const [];
  static List<BoxShadow> errorGlow([double opacity = 0.0]) => const [];
  static List<BoxShadow> warningGlow([double opacity = 0.0]) => const [];
  static List<BoxShadow> colorGlow(Color color, [double opacity = 0.0]) =>
      const [];

  static BoxDecoration get innerShadow => BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ],
  );
}

// ============================================================================
// MOTION
// ============================================================================

class AppDurations {
  AppDurations._();

  static const Duration instant = Duration(milliseconds: 50);
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 320);
  static const Duration slower = Duration(milliseconds: 480);
  static const Duration pageTransition = Duration(milliseconds: 280);
  static const Duration shimmer = Duration(milliseconds: 1500);
}

class AppCurves {
  AppCurves._();

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeInOutCubic;
  static const Curve decelerate = Curves.decelerate;
  static const Curve bounce = Curves.easeOutBack;
  static const Curve overshoot = Curves.easeOutBack;
  static const Curve snap = Curves.easeOutExpo;
}

// ============================================================================
// TYPOGRAPHY
// ============================================================================

class AppTypography {
  AppTypography._();

  static const double displayLarge = 40.0;
  static const double displayMedium = 32.0;
  static const double displaySmall = 28.0;

  static const double headlineLarge = 26.0;
  static const double headlineMedium = 22.0;
  static const double headlineSmall = 20.0;

  static const double titleLarge = 18.0;
  static const double titleMedium = 16.0;
  static const double titleSmall = 14.0;

  static const double bodyLarge = 15.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 13.0;
  static const double bodyXs = 12.0;

  static const double labelLarge = 14.0;
  static const double labelMedium = 13.0;
  static const double labelSmall = 12.0;

  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightSemiBold = FontWeight.w600;
  static const FontWeight weightBold = FontWeight.w700;
  static const FontWeight weightExtraBold = FontWeight.w800;

  static const double letterSpacingTight = -0.4;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.4;
}

class AppIconSizes {
  AppIconSizes._();

  static const double xs = 14.0;
  static const double sm = 18.0;
  static const double md = 20.0;
  static const double lg = 24.0;
  static const double xl = 28.0;
  static const double xxl = 36.0;
  static const double xxxl = 44.0;
}

class AppButtonSizes {
  AppButtonSizes._();

  static const double small = 36.0;
  static const double medium = 44.0;
  static const double large = 48.0;
  static const double xlarge = 52.0;
}

// ============================================================================
// DECORATIONS
// ============================================================================

class AppDecorations {
  AppDecorations._();

  /// Standard surface — flat with hairline border. The default container.
  static BoxDecoration get card => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppRadius.xxlRadius,
    border: Border.all(color: AppColors.border, width: 1),
  );

  static BoxDecoration get cardElevated => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppRadius.xxlRadius,
    border: Border.all(color: AppColors.border, width: 1),
    boxShadow: AppShadows.soft,
  );

  static BoxDecoration get cardSubtle => BoxDecoration(
    color: AppColors.surfaceVariant,
    borderRadius: AppRadius.xlRadius,
  );

  static BoxDecoration get primaryGradient => BoxDecoration(
    color: AppColors.primary,
    borderRadius: AppRadius.xxlRadius,
  );

  static BoxDecoration get glass => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppRadius.xxlRadius,
    border: Border.all(color: AppColors.border, width: 1),
  );

  /// Compact accent container for icons. Uses tinted background, no glow.
  static BoxDecoration iconContainer([List<Color>? gradient]) {
    final base = (gradient != null && gradient.isNotEmpty)
        ? gradient.first
        : AppColors.primary;
    return BoxDecoration(
      color: base.withValues(alpha: 0.10),
      borderRadius: AppRadius.mediumRadius,
    );
  }

  static BoxDecoration get subtle => BoxDecoration(
    color: AppColors.surfaceVariant,
    borderRadius: AppRadius.xxlRadius,
  );

  static BoxDecoration get pageBackground => const BoxDecoration(
    color: AppColors.background,
  );

  static BoxDecoration get pageSurface => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppRadius.xxlRadius,
    border: Border.all(color: AppColors.border, width: 1),
  );

  static BoxDecoration get input => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppRadius.largeRadius,
    border: Border.all(color: AppColors.border),
  );

  static BoxDecoration get inputActive => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppRadius.largeRadius,
    border: Border.all(color: AppColors.primary, width: 2),
  );
}

/// Clean, flat backdrop for full-page surfaces.
///
/// Replaces the previous decorative dot/line pattern with a calm solid
/// background that matches the modern minimal aesthetic.
class PatternBackdrop extends StatelessWidget {
  const PatternBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.backgroundC(context),
      child: child,
    );
  }
}

// ============================================================================
// TEXT STYLES
// ============================================================================
//
// IMPORTANT: These styles deliberately omit `color`. Widgets that use them
// inherit the color from the surrounding `DefaultTextStyle` (i.e. the active
// `Theme.textTheme`), so they switch automatically between light and dark
// mode. To override, callers can `.copyWith(color: ...)`.

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get displayLarge => GoogleFonts.notoSans(
    fontSize: AppTypography.displayLarge,
    fontWeight: AppTypography.weightBold,
    letterSpacing: AppTypography.letterSpacingTight,
    height: 1.1,
  );

  static TextStyle get displayMedium => GoogleFonts.notoSans(
    fontSize: AppTypography.displayMedium,
    fontWeight: AppTypography.weightBold,
    letterSpacing: AppTypography.letterSpacingTight,
    height: 1.15,
  );

  static TextStyle get headlineLarge => GoogleFonts.notoSans(
    fontSize: AppTypography.headlineLarge,
    fontWeight: AppTypography.weightSemiBold,
    letterSpacing: AppTypography.letterSpacingTight,
    height: 1.2,
  );

  static TextStyle get headlineMedium => GoogleFonts.notoSans(
    fontSize: AppTypography.headlineMedium,
    fontWeight: AppTypography.weightSemiBold,
    letterSpacing: AppTypography.letterSpacingTight,
    height: 1.25,
  );

  static TextStyle get titleLarge => GoogleFonts.notoSans(
    fontSize: AppTypography.titleLarge,
    fontWeight: AppTypography.weightSemiBold,
  );

  static TextStyle get titleMedium => GoogleFonts.notoSans(
    fontSize: AppTypography.titleMedium,
    fontWeight: AppTypography.weightSemiBold,
  );

  static TextStyle get titleSmall => GoogleFonts.notoSans(
    fontSize: AppTypography.titleSmall,
    fontWeight: AppTypography.weightSemiBold,
  );

  static TextStyle get bodyLarge => GoogleFonts.notoSans(
    fontSize: AppTypography.bodyLarge,
    fontWeight: AppTypography.weightRegular,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.notoSans(
    fontSize: AppTypography.bodyMedium,
    fontWeight: AppTypography.weightRegular,
    height: 1.5,
  );

  static TextStyle get bodySmall => GoogleFonts.notoSans(
    fontSize: AppTypography.bodySmall,
    fontWeight: AppTypography.weightRegular,
    height: 1.45,
  );

  static TextStyle get labelLarge => GoogleFonts.notoSans(
    fontSize: AppTypography.labelLarge,
    fontWeight: AppTypography.weightSemiBold,
  );

  static TextStyle get labelMedium => GoogleFonts.notoSans(
    fontSize: AppTypography.labelMedium,
    fontWeight: AppTypography.weightMedium,
  );

  static TextStyle get labelSmall => GoogleFonts.notoSans(
    fontSize: AppTypography.labelSmall,
    fontWeight: AppTypography.weightMedium,
    letterSpacing: AppTypography.letterSpacingWide,
  );
}
