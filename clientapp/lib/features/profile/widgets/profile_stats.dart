// Donation and report counts for the signed-in citizen.

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';

class StatsRow extends StatelessWidget {
  final double totalDonated;
  final int totalDonations;
  final int reportedProblems;
  final String village;

  const StatsRow({super.key, 
    required this.totalDonated,
    required this.totalDonations,
    required this.reportedProblems,
    required this.village,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem('মোট দান', '৳ ${totalDonated.toStringAsFixed(0)}', Icons.volunteer_activism_outlined, AppColors.success),
      _StatItem('দান সংখ্যা', '$totalDonations টি', Icons.receipt_long_outlined, AppColors.info),
      _StatItem('রিপোর্ট', '$reportedProblems টি', Icons.report_outlined, AppColors.warning),
      _StatItem('গ্রাম', village.isNotEmpty ? village : 'উল্লেখ নেই', Icons.location_on_outlined, AppColors.primary),
    ];

    return Row(
      children: items
          .map((item) => Expanded(child: _StatCard(item: item)))
          .toList(),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  _StatItem(this.label, this.value, this.icon, this.color);
}

class _StatCard extends StatelessWidget {
  final _StatItem item;
  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md, horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.border),
        boxShadow: [
          BoxShadow(
              color: context.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(item.icon, size: 18, color: item.color),
          ),
          AppSpacing.hSm,
          Text(
            item.value,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          AppSpacing.hXs,
          Text(
            item.label,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.textTertiary,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
