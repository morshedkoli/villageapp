import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// ──────────────────────────────────────────────
///  Shimmer Loading Components
///  Colors come entirely from token system
/// ──────────────────────────────────────────────

class ShimmerLoading extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.height = 20,
    this.width,
    this.borderRadius = AppRadius.sm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final base = isDark ? AppColors.darkCard : AppColors.lightCanvas;
    final highlight = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      period: const Duration(milliseconds: 1400),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Full card skeleton with shimmer
class CardSkeleton extends StatelessWidget {
  final double height;

  const CardSkeleton({super.key, this.height = 116});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading(height: 36, width: 36, borderRadius: AppRadius.md),
          const Spacer(),
          ShimmerLoading(height: 20, width: 72, borderRadius: AppRadius.xs),
          const SizedBox(height: 6),
          ShimmerLoading(height: 12, width: 56, borderRadius: AppRadius.xs),
        ],
      ),
    );
  }
}

/// List row skeleton
class ListSkeleton extends StatelessWidget {
  final int itemCount;

  const ListSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (i) => Padding(
          padding: EdgeInsets.only(
            bottom: i < itemCount - 1 ? AppSpacing.md : 0,
          ),
          child: Row(
            children: [
              ShimmerLoading(
                height: 40,
                width: 40,
                borderRadius: AppRadius.md,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading(height: 14, width: 140, borderRadius: AppRadius.xs),
                    const SizedBox(height: 6),
                    ShimmerLoading(height: 11, width: 96, borderRadius: AppRadius.xs),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hero card shimmer (for balance card loading state)
class HeroCardSkeleton extends StatelessWidget {
  const HeroCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.xxxl),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading(height: 16, width: 120, borderRadius: AppRadius.xs),
          const SizedBox(height: AppSpacing.lg),
          ShimmerLoading(height: 36, width: 200, borderRadius: AppRadius.sm),
          const SizedBox(height: AppSpacing.sm),
          ShimmerLoading(height: 14, width: 140, borderRadius: AppRadius.xs),
          const Spacer(),
          Row(
            children: [
              Expanded(child: ShimmerLoading(height: 44, borderRadius: AppRadius.lg)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: ShimmerLoading(height: 44, borderRadius: AppRadius.lg)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: ShimmerLoading(height: 44, borderRadius: AppRadius.lg)),
            ],
          ),
        ],
      ),
    );
  }
}
