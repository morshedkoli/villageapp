import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/bengali_number.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../../models.dart';

/// Two-by-two grid of the headline village figures.
class VillageStatsGrid extends StatelessWidget {
  const VillageStatsGrid({super.key, required this.overview});

  final VillageOverview? overview;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: KpiCard(
                label: 'মোট সংগ্রহ',
                value: formatTaka(overview?.totalFundCollected),
                icon: Icons.volunteer_activism_rounded,
                subtitle: 'মোট দান',
                accentColor: AppColors.success,
                onTap: () => context.push('/all-donations'),
              ),
            ),
            AppSpacing.wMd,
            Expanded(
              child: KpiCard(
                label: 'মোট ব্যয়',
                value: formatTaka(overview?.totalSpent),
                icon: Icons.payments_rounded,
                subtitle: 'খরচ হয়েছে',
                accentColor: AppColors.error,
                onTap: () => context.push('/all-expenses'),
              ),
            ),
          ],
        ),
        AppSpacing.hMd,
        Row(
          children: [
            Expanded(
              child: KpiCard(
                label: 'নিবন্ধিত নাগরিক',
                value: formatBengaliCount(overview?.totalCitizens ?? 0),
                icon: Icons.people_rounded,
                accentColor: AppColors.primary,
                onTap: () => context.push('/all-citizens'),
              ),
            ),
            AppSpacing.wMd,
            Expanded(
              child: KpiCard(
                label: 'অবশিষ্ট ব্যালেন্স',
                value: formatTaka(overview?.availableBalance),
                icon: Icons.account_balance_wallet_rounded,
                subtitle: 'ব্যবহারযোগ্য',
                accentColor: AppColors.info,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
