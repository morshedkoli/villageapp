import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/bengali_number.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/timeline_item.dart';

/// The four most recent approved donations, as a timeline.
class RecentActivity extends ConsumerWidget {
  const RecentActivity({super.key});

  static const int _visibleCount = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentDonations = ref.watch(recentDonationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'সাম্প্রতিক কার্যক্রম',
          actionLabel: 'সব দেখুন',
          actionIcon: Icons.arrow_forward_ios_rounded,
          onAction: () => context.go('/donate'),
        ),
        AppSpacing.hMd,
        recentDonations.when(
          loading: () => const CardSkeleton(height: 240),
          error: (_, __) => const CardSkeleton(height: 240),
          data: (donations) {
            final items = donations.take(_visibleCount).toList();
            return PremiumCard(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Column(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: Divider(height: 1, color: context.divider),
                      ),
                    TimelineItem(
                      title: 'দান গৃহীত',
                      description:
                          '${items[i].donorName} ৳${formatBengaliAmount(items[i].amount)} দান করেছেন',
                      icon: Icons.volunteer_activism_rounded,
                      iconColor: AppColors.success,
                      timestamp: items[i].createdAt,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
