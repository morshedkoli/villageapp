// Headline card showing how much the village has collected.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/format/bengali_number.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';

class FundOverviewCard extends StatelessWidget {
  final double collectedAmount;

  const FundOverviewCard({super.key, required this.collectedAmount});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.4 : 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.account_balance_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                AppSpacing.wMd,
                Text(
                  'তহবিলের অবস্থা',
                  style: context.textTheme.titleSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            AppSpacing.hXxl,
            Text(
              'মোট সংগৃহীত',
              style: context.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            AppSpacing.hXs,
            Text(
              formatTakaExact(collectedAmount),
              style: GoogleFonts.notoSansBengali(
                textStyle: context.textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            AppSpacing.hXxl,
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.push('/donate/checkout'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryDark,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                ),
                child: const Text(
                  'দান করুন',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
