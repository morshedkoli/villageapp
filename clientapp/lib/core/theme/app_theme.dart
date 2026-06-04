import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// ──────────────────────────────────────────────
///  গ্রামবাসী — Theme Builder
///  All component themes are driven from tokens.
///  No hardcoded colors anywhere in this file.
/// ──────────────────────────────────────────────
abstract final class AppTheme {
  AppTheme._();

  static ThemeData get light => _buildTheme(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.inkOnPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.primaryDark,
      onSecondary: AppColors.inkOnPrimary,
      secondaryContainer: AppColors.primaryContainer,
      onSecondaryContainer: AppColors.primaryDark,
      tertiary: AppColors.info,
      onTertiary: AppColors.inkOnPrimary,
      tertiaryContainer: AppColors.infoContainer,
      onTertiaryContainer: AppColors.info,
      error: AppColors.error,
      onError: AppColors.inkOnPrimary,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.error,
      surface: AppColors.lightSurface,
      onSurface: AppColors.ink900,
      onSurfaceVariant: AppColors.ink500,
      outline: AppColors.lightBorder,
      outlineVariant: AppColors.lightDivider,
      surfaceContainerHighest: AppColors.lightCanvas,
      surfaceContainerLow: AppColors.lightCanvas,
      surfaceContainer: AppColors.lightSurface,
      shadow: AppColors.shadowMedium,
      scrim: AppColors.scrimLight,
    ),
  );

  static ThemeData get dark => _buildTheme(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.inkOnPrimary,
      primaryContainer: AppColors.primaryContainer.withValues(alpha: 0.12),
      onPrimaryContainer: AppColors.primaryLight,
      secondary: AppColors.primaryLight,
      onSecondary: AppColors.ink900,
      secondaryContainer: AppColors.primaryContainer.withValues(alpha: 0.08),
      onSecondaryContainer: AppColors.primaryLight,
      tertiary: AppColors.info,
      onTertiary: AppColors.inkOnPrimary,
      tertiaryContainer: AppColors.infoContainer.withValues(alpha: 0.12),
      onTertiaryContainer: AppColors.info,
      error: AppColors.error,
      onError: AppColors.inkOnPrimary,
      errorContainer: AppColors.errorContainer.withValues(alpha: 0.12),
      onErrorContainer: AppColors.error,
      surface: AppColors.darkSurface,
      onSurface: const Color(0xFFF0F4F2),
      onSurfaceVariant: const Color(0xFF8D9E99),
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkDivider,
      surfaceContainerHighest: AppColors.darkCanvas,
      surfaceContainerLow: AppColors.darkCanvas,
      surfaceContainer: AppColors.darkCard,
      shadow: Colors.black,
      scrim: AppColors.scrimDark,
    ),
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
  }) {
    final isDark = brightness == Brightness.dark;
    final text = AppTypography.textTheme();
    final cs = colorScheme;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: cs,
      scaffoldBackgroundColor: isDark ? AppColors.darkCanvas : AppColors.lightCanvas,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: AppColors.primary.withValues(alpha: 0.04),
      textTheme: text,

      // ── AppBar ──────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: isDark ? AppColors.darkCanvas : AppColors.lightCanvas,
        foregroundColor: cs.onSurface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        titleTextStyle: text.titleLarge?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: cs.onSurface),
      ),

      // ── Card ────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xxlBorder,
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),

      // ── Bottom Nav ──────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primary.withValues(alpha: 0.1),
        indicatorShape: const StadiumBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return text.labelSmall?.copyWith(
            color: active ? AppColors.primary : cs.onSurfaceVariant,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return IconThemeData(
            size: active ? 24 : 22,
            color: active ? AppColors.primary : cs.onSurfaceVariant,
          );
        }),
      ),

      // ── Input ───────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkInputFill : AppColors.lightInputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        hintStyle: text.bodyMedium?.copyWith(color: AppColors.ink300),
        errorStyle: text.labelSmall?.copyWith(color: AppColors.error),
        prefixIconColor: cs.onSurfaceVariant,
        suffixIconColor: cs.onSurfaceVariant,
      ),

      // ── Filled Button ───────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.inkOnPrimary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.38),
          disabledForegroundColor: AppColors.inkOnPrimary.withValues(alpha: 0.6),
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(0, 48),
          shape: const StadiumBorder(),
          textStyle: text.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Outlined Button ─────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(0, 48),
          shape: const StadiumBorder(),
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // ── Text Button ─────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          minimumSize: const Size(0, 40),
          shape: const StadiumBorder(),
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // ── Snack Bar ───────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
        elevation: 8,
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        backgroundColor: isDark ? AppColors.darkCard : AppColors.ink900,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: isDark ? const Color(0xFFF0F4F2) : AppColors.inkOnPrimary,
        ),
      ),

      // ── Bottom Sheet ────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        dragHandleColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        dragHandleSize: const Size(36, 4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xxxl),
            topRight: Radius.circular(AppRadius.xxxl),
          ),
        ),
        surfaceTintColor: Colors.transparent,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 16,
      ),

      // ── Divider ─────────────────────────────
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        thickness: 1,
        space: 0,
      ),

      // ── Chip ────────────────────────────────
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        labelStyle: text.labelMedium?.copyWith(fontWeight: FontWeight.w500),
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCanvas,
        selectedColor: AppColors.primary.withValues(alpha: 0.1),
        disabledColor: AppColors.ink300.withValues(alpha: 0.1),
        brightness: brightness,
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),

      // ── Switch ──────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.primary
              : (isDark ? AppColors.darkBorder : AppColors.ink300);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.primary.withValues(alpha: 0.25)
              : (isDark ? AppColors.darkDivider : AppColors.lightDivider);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // ── Progress ────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearMinHeight: 4,
        linearTrackColor: AppColors.primary.withValues(alpha: 0.1),
        circularTrackColor: AppColors.primary.withValues(alpha: 0.1),
      ),

      // ── Dialog ──────────────────────────────
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xxlBorder),
        elevation: 24,
        surfaceTintColor: Colors.transparent,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        titleTextStyle: text.titleLarge?.copyWith(color: cs.onSurface),
        contentTextStyle: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
      ),

      // ── FAB ─────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.inkOnPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 2,
        highlightElevation: 0,
        shape: const StadiumBorder(),
        extendedSizeConstraints: const BoxConstraints(minHeight: 52, minWidth: 120),
        extendedPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.md,
        ),
      ),

      // ── Tab Bar ─────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: cs.onSurfaceVariant,
        labelStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w500),
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        dividerHeight: 1,
        overlayColor: WidgetStateProperty.all(
          AppColors.primary.withValues(alpha: 0.04),
        ),
      ),

      // ── Badge ───────────────────────────────
      badgeTheme: BadgeThemeData(
        backgroundColor: AppColors.error,
        textColor: AppColors.inkOnPrimary,
        smallSize: 8,
        largeSize: 18,
        alignment: Alignment.topRight,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        textStyle: text.labelSmall?.copyWith(
          color: AppColors.inkOnPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),

      // ── List Tile ───────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
        titleTextStyle: text.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        subtitleTextStyle: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        iconColor: cs.onSurfaceVariant,
        textColor: cs.onSurface,
        selectedColor: AppColors.primary,
        selectedTileColor: AppColors.primary.withValues(alpha: 0.06),
        enableFeedback: true,
        horizontalTitleGap: AppSpacing.md,
        minLeadingWidth: 24,
        minVerticalPadding: AppSpacing.sm,
      ),

      // ── Popup Menu ──────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
        elevation: 12,
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        textStyle: text.bodyMedium,
      ),

      // ── Tooltip ─────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.ink900,
          borderRadius: AppRadius.smBorder,
        ),
        textStyle: text.labelSmall?.copyWith(
          color: AppColors.inkOnPrimary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),

      // ── Page Transitions ────────────────────
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
          TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}

// ── BuildContext Shortcuts ────────────────────────
extension ThemeContext on BuildContext {
  ThemeData get theme       => Theme.of(this);
  TextTheme get textTheme   => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  bool get isDarkMode       => Theme.of(this).brightness == Brightness.dark;
}
