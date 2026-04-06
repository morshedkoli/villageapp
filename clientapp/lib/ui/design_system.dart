import 'package:flutter/material.dart';

/// Premium Design System for Village Development App
/// Centralized design tokens for consistent UI/UX

// ============================================================================
// COLORS
// ============================================================================

class AppColors {
  AppColors._();

  // Primary Colors (Green)
  static const Color primary = Color(0xFF1F7A5A);
  static const Color primaryLight = Color(0xFF2E9B73);
  static const Color primaryDark = Color(0xFF165C44);

  // Secondary Colors (Blue)
  static const Color secondary = Color(0xFF4A90E2);
  static const Color secondaryLight = Color(0xFF6BA5E9);

  // Background & Surface
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Semantic Colors
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color info = Color(0xFF3B82F6);

  // Border & Divider
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  // Gradients
  static const List<Color> primaryGradient = [
    Color(0xFF1F7A5A),
    Color(0xFF2E9B73),
  ];

  static const List<Color> primaryGradientDark = [
    Color(0xFF165C44),
    Color(0xFF1F7A5A),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF4A90E2),
    Color(0xFF6BA5E9),
  ];

  static const List<Color> successGradient = [
    Color(0xFF22C55E),
    Color(0xFF4ADE80),
  ];

  static const List<Color> warningGradient = [
    Color(0xFFF59E0B),
    Color(0xFFFBBF24),
  ];

  static const List<Color> errorGradient = [
    Color(0xFFEF4444),
    Color(0xFFF87171),
  ];

  // Leaderboard Colors (Gold, Silver, Bronze)
  static const List<Color> goldGradient = [
    Color(0xFFFFD700),
    Color(0xFFFFA500),
  ];

  static const List<Color> silverGradient = [
    Color(0xFFC0C0C0),
    Color(0xFFE8E8E8),
  ];

  static const List<Color> bronzeGradient = [
    Color(0xFFCD7F32),
    Color(0xFFE8A858),
  ];
}

// ============================================================================
// SPACING (8px Grid System)
// ============================================================================

class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// ============================================================================
// BORDER RADIUS
// ============================================================================

class AppRadius {
  AppRadius._();

  static const double xs = 6.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double pill = 999.0;

  // Commonly used BorderRadius instances
  static BorderRadius get smallRadius => BorderRadius.circular(sm);
  static BorderRadius get mediumRadius => BorderRadius.circular(md);
  static BorderRadius get largeRadius => BorderRadius.circular(lg);
  static BorderRadius get xlRadius => BorderRadius.circular(xl);
  static BorderRadius get xxlRadius => BorderRadius.circular(xxl);
  static BorderRadius get pillRadius => BorderRadius.circular(pill);
}

// ============================================================================
// SHADOWS
// ============================================================================

class AppShadows {
  AppShadows._();

  /// Subtle shadow for cards and surfaces
  static List<BoxShadow> get soft => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  /// Elevated shadow for interactive elements
  static List<BoxShadow> get elevated => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
      ];

  /// Primary color glow for accent elements
  static List<BoxShadow> primaryGlow([double opacity = 0.25]) => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: opacity),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  /// Success color glow
  static List<BoxShadow> successGlow([double opacity = 0.25]) => [
        BoxShadow(
          color: AppColors.success.withValues(alpha: opacity),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  /// Error color glow
  static List<BoxShadow> errorGlow([double opacity = 0.25]) => [
        BoxShadow(
          color: AppColors.error.withValues(alpha: opacity),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  /// Custom color glow
  static List<BoxShadow> colorGlow(Color color, [double opacity = 0.3]) => [
        BoxShadow(
          color: color.withValues(alpha: opacity),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}

// ============================================================================
// ANIMATION DURATIONS & CURVES
// ============================================================================

class AppDurations {
  AppDurations._();

  static const Duration instant = Duration(milliseconds: 50);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration pageTransition = Duration(milliseconds: 350);
  static const Duration shimmer = Duration(milliseconds: 1500);
}

class AppCurves {
  AppCurves._();

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeInOutCubic;
  static const Curve decelerate = Curves.decelerate;
  static const Curve bounce = Curves.elasticOut;
  static const Curve overshoot = Curves.easeOutBack;
}

// ============================================================================
// TYPOGRAPHY SIZES
// ============================================================================

class AppTypography {
  AppTypography._();

  // Title sizes
  static const double titleLarge = 26.0;
  static const double titleMedium = 20.0;
  static const double titleSmall = 18.0;

  // Body sizes
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;

  // Label sizes
  static const double labelLarge = 15.0;
  static const double labelMedium = 13.0;
  static const double labelSmall = 11.0;
}

// ============================================================================
// ICON SIZES
// ============================================================================

class AppIconSizes {
  AppIconSizes._();

  static const double xs = 16.0;
  static const double sm = 20.0;
  static const double md = 24.0;
  static const double lg = 28.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// ============================================================================
// BUTTON HEIGHTS
// ============================================================================

class AppButtonSizes {
  AppButtonSizes._();

  static const double small = 40.0;
  static const double medium = 48.0;
  static const double large = 54.0;
}

// ============================================================================
// DECORATIONS (Commonly used BoxDecorations)
// ============================================================================

class AppDecorations {
  AppDecorations._();

  /// Standard card decoration with soft shadow
  static BoxDecoration get card => BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xlRadius,
        boxShadow: AppShadows.soft,
      );

  /// Elevated card decoration
  static BoxDecoration get cardElevated => BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xlRadius,
        boxShadow: AppShadows.elevated,
      );

  /// Primary gradient decoration
  static BoxDecoration get primaryGradient => BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.xlRadius,
        boxShadow: AppShadows.primaryGlow(),
      );

  /// Icon container decoration (for stat cards, list tiles)
  static BoxDecoration iconContainer([List<Color>? gradient]) => BoxDecoration(
        gradient: LinearGradient(
          colors: gradient ?? AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.mediumRadius,
        boxShadow: AppShadows.colorGlow(
          (gradient ?? AppColors.primaryGradient)[0],
          0.3,
        ),
      );

  /// Subtle container (for backgrounds, sections)
  static BoxDecoration get subtle => BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: AppRadius.xlRadius,
      );
}
