import 'package:flutter/material.dart';

/// ──────────────────────────────────────────────
///  গ্রামবাসী — Premium Color System
///  Philosophy: Soft white canvas · Green accent ·
///              Generous contrast · No hardcoded hex
/// ──────────────────────────────────────────────
abstract final class AppColors {
  AppColors._();

  // ── Brand Moss Green ─────────────────────────
  /// Primary action color — warm moss green
  static const Color primary = Color(0xFF3F8A4E);

  /// Pressed / gradient end
  static const Color primaryDark = Color(0xFF2E6B3D);

  /// Hover / gradient start (lighter)
  static const Color primaryLight = Color(0xFF6FAE6E);

  /// Muted green for dark-mode secondary
  static const Color primaryMuted = Color(0xFF9BC49A);

  /// Tinted surface — chip, badge backgrounds
  static const Color primaryContainer = Color(0xFFEEF3E7);

  // ── Warm Accents ─────────────────────────────
  /// CTAs, highlights, one of the icon-badge rotation colors
  static const Color accentTerracotta = Color(0xFFD97757);

  /// Achievements, top-contributor badges, warning color
  static const Color accentGold = Color(0xFFE8A94C);

  // ── Semantic ─────────────────────────────────
  static const Color success = Color(0xFF2E6B3D);
  static const Color successLight = Color(0xFF3F8A4E);
  static const Color successContainer = Color(0xFFEEF3E7);

  static const Color warning = accentGold;
  static const Color warningContainer = Color(0xFFFBF3E4);

  static const Color error = Color(0xFFC1502E);
  static const Color errorContainer = Color(0xFFFBEEE8);

  static const Color info = Color(0xFF3B6E8F);
  static const Color infoContainer = Color(0xFFE9F0F4);

  // ── Text ─────────────────────────────────────
  static const Color ink900 = Color(0xFF1B1712);   // Near black — headlines
  static const Color ink700 = Color(0xFF433C33);   // Body text
  static const Color ink500 = Color(0xFF766D5F);   // Secondary text
  static const Color ink300 = Color(0xFFAEA595);   // Tertiary / placeholder
  static const Color inkOnPrimary = Color(0xFFFFFFFF);

  // ── Light Surface System ──────────────────────
  /// Warm cream — main page background
  static const Color lightCanvas = Color(0xFFFBF8F3);

  /// Pure white — card / surface
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Warm tan-gray border
  static const Color lightBorder = Color(0xFFE8E0D4);

  /// Slightly more visible divider
  static const Color lightDivider = Color(0xFFF1ECE1);

  /// Input field fill
  static const Color lightInputFill = Color(0xFFFBF8F3);

  // ── Dark Surface System ───────────────────────
  /// Deep warm near-black background
  static const Color darkCanvas = Color(0xFF14120F);

  /// Card / elevated surface in dark
  static const Color darkSurface = Color(0xFF1C1814);

  /// Slightly lighter card for nested elements
  static const Color darkCard = Color(0xFF241F18);

  /// Visible but subtle warm border in dark
  static const Color darkBorder = Color(0xFF33291F);

  /// Softer divider in dark
  static const Color darkDivider = Color(0xFF2A2319);

  /// Input fill in dark
  static const Color darkInputFill = Color(0xFF241F18);

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
  Color get accentTerracotta => AppColors.accentTerracotta;
  Color get accentGold       => AppColors.accentGold;

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
