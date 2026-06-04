import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

/// ──────────────────────────────────────────────
///  KpiCard — Premium metric stat card
///
///  Design language:
///  • Fixed 120px height for grid alignment
///  • Soft icon container (tinted bg, no harsh outline)
///  • Left-side accent bar in icon color
///  • Headline figure uses Hind Siliguri display style
///  • Subtle surface, no harsh shadows
/// ──────────────────────────────────────────────
class KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String? subtitle;
  final bool isLoading;
  final VoidCallback? onTap;
  final Color? accentColor;

  /// Backward-compat: explicit icon container background (overrides computed tint)
  final Color? iconBackground;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.subtitle,
    this.isLoading = false,
    this.onTap,
    this.accentColor,
    this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _KpiSkeleton();

    final isDark = context.isDark;
    final accent = accentColor ?? AppColors.primary;
    final bg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final card = Container(
      height: 116,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: isDark
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))]
            : [
                BoxShadow(color: AppColors.shadowLight, blurRadius: 1, offset: const Offset(0, 1)),
                BoxShadow(color: AppColors.shadowLight, blurRadius: 6, offset: const Offset(0, 3)),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBackground ?? accent.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              const Spacer(),
              if (subtitle != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    subtitle!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: AppTypography.kpiValue.copyWith(
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          splashColor: AppColors.primary.withValues(alpha: 0.04),
          highlightColor: Colors.transparent,
          child: card,
        ),
      );
    }
    return card;
  }
}

class _KpiSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final shimBase = isDark ? AppColors.darkCard : AppColors.lightCanvas;
    final shimHigh = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      height: 116,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Bone(width: 36, height: 36, radius: AppRadius.md, base: shimBase, high: shimHigh),
          const Spacer(),
          _Bone(width: 72, height: 22, radius: AppRadius.sm, base: shimBase, high: shimHigh),
          const SizedBox(height: 6),
          _Bone(width: 52, height: 12, radius: AppRadius.xs, base: shimBase, high: shimHigh),
        ],
      ),
    );
  }
}

class _Bone extends StatelessWidget {
  final double width, height, radius;
  final Color base, high;
  const _Bone({required this.width, required this.height, required this.radius, required this.base, required this.high});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      builder: (_, v, _) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Color.lerp(base, high, (v * 2 - 1).abs()),
            borderRadius: BorderRadius.circular(radius),
          ),
        );
      },
    );
  }
}
