// Timeline of the most recent approved donations.

import 'package:flutter/material.dart';
import '../../../core/format/bengali_number.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/timeline_item.dart';
import '../../../models.dart';

class RecentDonationsSection extends StatelessWidget {
  final List<Donation> donations;

  const RecentDonationsSection({super.key, required this.donations});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'সাম্প্রতিক দান',
          actionLabel: 'সব দেখুন',
          actionIcon: Icons.arrow_forward_ios,
        ),
        AppSpacing.hMd,
        GlassCard(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            children: donations.map((d) {
              return Column(
                children: [
                  TimelineItem(
                    title: '${d.donorName} দান করেছেন',
                    icon: Icons.volunteer_activism,
                    iconColor: AppColors.success,
                    timestamp: d.createdAt,
                    trailing: Text(
                      formatTakaExact(d.amount),
                      style: context.textTheme.labelLarge?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (d != donations.last)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Divider(),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
