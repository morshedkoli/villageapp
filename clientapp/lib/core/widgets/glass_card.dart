import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// ──────────────────────────────────────────────
///  PremiumCard — the foundational card component
///
///  • Pure white surface (or darkSurface in dark)
///  • Subtle 1px border + layered soft shadow
///  • Optional tap/hover states
///  • Replaces the old GlassCard
/// ──────────────────────────────────────────────
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? backgroundColor;

  /// Backward-compat alias for [backgroundColor]
  final Color? background;
  final bool showBorder;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.height,
    this.width,
    this.onTap,
    this.borderRadius = AppRadius.xxl,
    this.backgroundColor,
    this.background,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bg = backgroundColor ?? background ?? (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final container = Container(
      height: height,
      width: width,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(color: borderColor, width: 1)
            : null,
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: AppColors.primary.withValues(alpha: 0.05),
          highlightColor: AppColors.primary.withValues(alpha: 0.03),
          child: container,
        ),
      );
    }
    return container;
  }
}

/// Legacy alias — allows existing code that imports GlassCard to compile.
/// Gradually migrate callers to PremiumCard.
typedef GlassCard = PremiumCard;
