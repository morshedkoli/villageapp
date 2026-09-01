import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/bengali_number.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/category_icon_badge.dart';
import '../../../core/widgets/motion.dart';
import '../../../models.dart';

/// Headline card: available village balance plus the three primary actions.
class FundBalanceCard extends StatelessWidget {
  const FundBalanceCard({super.key, required this.overview});

  final VillageOverview? overview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xxxl),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CategoryIconBadge(
                icon: Icons.account_balance_rounded,
                color: AppColors.inkOnPrimary,
                size: 36,
              ),
              AppSpacing.wMd,
              Text(
                'সামগ্রিক তহবিল',
                style: context.textTheme.titleSmall?.copyWith(
                  color: AppColors.inkOnPrimary.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          AppSpacing.hLg,
          Text(
            formatTaka(overview?.availableBalance),
            style: AppTypography.heroAmount
                .copyWith(color: AppColors.inkOnPrimary),
          ),
          AppSpacing.hXxl,
          Row(
            children: [
              Expanded(
                child: QuickActionButton(
                  icon: Icons.volunteer_activism_outlined,
                  label: 'দান করুন',
                  onTap: () => context.go('/donate'),
                ),
              ),
              AppSpacing.wSm,
              Expanded(
                child: QuickActionButton(
                  icon: Icons.report_outlined,
                  label: 'সমস্যা রিপোর্ট',
                  onTap: () => context.go('/problems/report'),
                ),
              ),
              AppSpacing.wSm,
              Expanded(
                child: QuickActionButton(
                  icon: Icons.person_add_outlined,
                  label: 'নাগরিক তালিকা',
                  onTap: () => context.go('/citizens'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      scale: 0.95,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.inkOnPrimary.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.inkOnPrimary, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: AppColors.inkOnPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
