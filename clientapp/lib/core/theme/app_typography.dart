import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ──────────────────────────────────────────────
///  গ্রামবাসী — Typography System
///  Heading: Hind Siliguri (bold, display character)
///  Body:     Noto Sans Bengali (readable, accessible)
///  Number:   Tabular figures for currency & stats
/// ──────────────────────────────────────────────
abstract final class AppTypography {
  AppTypography._();

  // ─────────────────────────────────────────────
  //  Text Theme (registered with ThemeData)
  // ─────────────────────────────────────────────
  static TextTheme textTheme() {
    final bodyBase = GoogleFonts.notoSansBengaliTextTheme();
    return bodyBase.copyWith(
      // Display — only for hero numbers / large callouts
      displayLarge: GoogleFonts.hindSiliguri(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -0.03,
      ),
      displayMedium: GoogleFonts.hindSiliguri(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -0.025,
      ),

      // Headline — section titles / screen headers
      headlineLarge: GoogleFonts.hindSiliguri(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.02,
      ),
      headlineMedium: GoogleFonts.hindSiliguri(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.015,
      ),
      headlineSmall: GoogleFonts.hindSiliguri(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.01,
      ),

      // Title — card headers / list headers
      titleLarge: GoogleFonts.notoSansBengali(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.01,
      ),
      titleMedium: GoogleFonts.notoSansBengali(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.35,
        letterSpacing: -0.005,
      ),
      titleSmall: GoogleFonts.notoSansBengali(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),

      // Body — content paragraphs
      bodyLarge: GoogleFonts.notoSansBengali(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.65,
      ),
      bodyMedium: GoogleFonts.notoSansBengali(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.6,
      ),
      bodySmall: GoogleFonts.notoSansBengali(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),

      // Label — buttons / chips / badges / metadata
      labelLarge: GoogleFonts.notoSansBengali(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.01,
      ),
      labelMedium: GoogleFonts.notoSansBengali(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.01,
      ),
      labelSmall: GoogleFonts.notoSansBengali(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.02,
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Standalone styles (for direct use)
  // ─────────────────────────────────────────────

  /// Hero currency / numeric amount — e.g. ৳১২,৪৫,৭৮০
  static TextStyle get heroAmount => GoogleFonts.hindSiliguri(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.02,
  );

  /// Large KPI value — e.g. ৳৫লাখ or 1.2k
  static TextStyle get kpiValue => GoogleFonts.hindSiliguri(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.01,
  );

  /// Small count / badge number
  static TextStyle get badgeNumber => GoogleFonts.notoSansBengali(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.01,
  );

  /// Section header title
  static TextStyle get sectionTitle => GoogleFonts.hindSiliguri(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.005,
  );

  /// Caption / timestamp text
  static TextStyle get caption => GoogleFonts.notoSansBengali(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.01,
  );
}
