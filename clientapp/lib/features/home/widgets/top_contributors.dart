import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/bengali_number.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/section_header.dart';

/// Horizontal strip of the largest donors.
///
/// Reads [topDonorsProvider] rather than re-tallying the donation list, which
/// this screen used to do with its own copy of the same aggregation.
class TopContributors extends ConsumerWidget {
  const TopContributors({super.key});

  static const double _stripHeight = 134;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topDonors = ref.watch(topDonorsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'শীর্ষ দাতা',
          actionLabel: 'সব দেখুন',
          actionIcon: Icons.arrow_forward_ios_rounded,
          onAction: () => context.go('/donate'),
        ),
        AppSpacing.hMd,
        SizedBox(
          height: _stripHeight,
          child: topDonors.when(
            loading: () => const SizedBox(height: _stripHeight),
            error: (_, __) => const SizedBox(height: _stripHeight),
            data: (donors) => ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: donors.length,
              separatorBuilder: (_, __) => AppSpacing.wMd,
              itemBuilder: (context, index) => _ContributorCard(
                name: donors[index].key,
                total: donors[index].value,
                rank: index,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContributorCard extends StatelessWidget {
  const _ContributorCard({
    required this.name,
    required this.total,
    required this.rank,
  });

  final String name;
  final double total;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final isTop = rank == 0;

    return SizedBox(
      width: 100,
      child: PressScale(
        scale: 0.97,
        onTap: () => context.go('/donate'),
        child: PremiumCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AvatarWidget(initials: name, size: 40, showOnline: isTop),
                  if (isTop)
                    const Positioned(top: -6, right: -6, child: _TopBadge()),
                ],
              ),
              AppSpacing.hSm,
              Text(
                name,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              AppSpacing.hXs,
              Text(
                '৳${formatBengaliAmount(total)}',
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBadge extends StatelessWidget {
  const _TopBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.warning,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        '১ম',
        style: context.textTheme.labelSmall?.copyWith(
          color: AppColors.inkOnPrimary,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
