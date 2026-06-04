import 'package:flutter/material.dart';

/// ──────────────────────────────────────────────
///  গ্রামবাসী — Premium Color System
///  Philosophy: Soft white canvas · Green accent ·
///              Generous contrast · No hardcoded hex
/// ──────────────────────────────────────────────
abstract final class AppColors {
  AppColors._();

  // ── Brand Green ──────────────────────────────
  /// Primary action color — vibrant but not harsh
  static const Color primary = Color(0xFF22C55E);

  /// Pressed / gradient end
  static const Color primaryDark = Color(0xFF16A34A);

  /// Hover / gradient start (lighter)
  static const Color primaryLight = Color(0xFF4ADE80);

  /// Muted green for dark-mode secondary
  static const Color primaryMuted = Color(0xFF86EFAC);

  /// Tinted surface — chip, badge backgrounds
  static const Color primaryContainer = Color(0xFFF0FDF4);

  // ── Semantic ─────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFF22C55E);
  static const Color successContainer = Color(0xFFF0FDF4);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFFFFFBEB);

  static const Color error = Color(0xFFE53E3E);
  static const Color errorContainer = Color(0xFFFFF5F5);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoContainer = Color(0xFFEFF6FF);

  // ── Text ─────────────────────────────────────
  static const Color ink900 = Color(0xFF0D1117);   // Near black — headlines
  static const Color ink700 = Color(0xFF374151);   // Body text
  static const Color ink500 = Color(0xFF6B7280);   // Secondary text
  static const Color ink300 = Color(0xFF9CA3AF);   // Tertiary / placeholder
  static const Color inkOnPrimary = Color(0xFFFFFFFF);

  // ── Backward-compat static aliases ───────────
  /// @deprecated Use lightCanvas instead
  static const Color lightBackground = Color(0xFFF9FAFB);  // = lightCanvas
  /// @deprecated Use ink500 or context.textSecondary instead
  static const Color textSecondary = ink500;
  /// @deprecated Use ink300 or context.textTertiary instead
  static const Color textTertiary = ink300;


  // ── Light Surface System ──────────────────────
  /// True off-white — main page background
  static const Color lightCanvas = Color(0xFFF9FAFB);

  /// Pure white — card / surface
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Very subtle border (almost invisible)
  static const Color lightBorder = Color(0xFFE5E7EB);

  /// Slightly more visible divider
  static const Color lightDivider = Color(0xFFF3F4F6);

  /// Input field fill
  static const Color lightInputFill = Color(0xFFF9FAFB);

  // ── Dark Surface System ───────────────────────
  /// Deep dark background — warm black-green tint
  static const Color darkCanvas = Color(0xFF0C0F0E);

  /// Card / elevated surface in dark
  static const Color darkSurface = Color(0xFF161B19);

  /// Slightly lighter card for nested elements
  static const Color darkCard = Color(0xFF1C2420);

  /// Visible but subtle border in dark
  static const Color darkBorder = Color(0xFF2C3531);

  /// Softer divider in dark
  static const Color darkDivider = Color(0xFF232B28);

  /// Input fill in dark
  static const Color darkInputFill = Color(0xFF1C2420);

  // ── Shadows ───────────────────────────────────
  /// Card drop shadow color (light mode)
  static const Color shadowLight = Color(0x0A000000);   // 4% black
  static const Color shadowMedium = Color(0x12000000);  // 7% black
  static const Color shadowStrong = Color(0x1A000000);  // 10% black

  // ── Overlay / Scrim ───────────────────────────
  static const Color scrimLight = Color(0x80000000);
  static const Color scrimDark = Color(0xCC000000);
}

// ── Context convenience extension ─────────────────
extension ContextColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // Brand
  Color get primary       => AppColors.primary;
  Color get primaryDark   => AppColors.primaryDark;
  Color get primaryLight  => AppColors.primaryLight;
  Color get onPrimary     => AppColors.inkOnPrimary;
  Color get primaryContainer => AppColors.primaryContainer;

  // Semantic
  Color get success           => AppColors.success;
  Color get successContainer  => AppColors.successContainer;
  Color get warning           => AppColors.warning;
  Color get warningContainer  => AppColors.warningContainer;
  Color get error             => AppColors.error;
  Color get errorContainer    => AppColors.errorContainer;
  Color get info              => AppColors.info;
  Color get infoContainer     => AppColors.infoContainer;

  // Surfaces (theme-aware)
  Color get canvas  => isDark ? AppColors.darkCanvas  : AppColors.lightCanvas;
  Color get surface => isDark ? AppColors.darkSurface : AppColors.lightSurface;
  Color get card    => isDark ? AppColors.darkCard    : AppColors.lightSurface;
  Color get border  => isDark ? AppColors.darkBorder  : AppColors.lightBorder;
  Color get divider => isDark ? AppColors.darkDivider : AppColors.lightDivider;
  Color get inputFill => isDark ? AppColors.darkInputFill : AppColors.lightInputFill;

  // Text (theme-aware)
  Color get textPrimary   => isDark ? const Color(0xFFF0F4F2) : AppColors.ink900;
  Color get textSecondary => isDark ? const Color(0xFF8D9E99)  : AppColors.ink500;
  Color get textTertiary  => isDark ? const Color(0xFF5A706A)  : AppColors.ink300;
  Color get textOnPrimary => AppColors.inkOnPrimary;

  // Shadow color for cards
  Color get cardShadow => isDark ? Colors.black26 : AppColors.shadowLight;

  // Backward-compat alias
  Color get background => canvas;
}
