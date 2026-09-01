// Leaderboard of the largest donors.

import 'package:flutter/material.dart';
import '../../../core/format/bengali_number.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/section_header.dart';

class TopDonorsSection extends StatelessWidget {
  final List<MapEntry<String, double>> topDonors;

  const TopDonorsSection({super.key, required this.topDonors});

  String _initials(String name) {
    if (name.length >= 2) return name.substring(0, 2);
    return name.isNotEmpty ? name[0] : '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'শীর্ষ দাতা',
          actionLabel: 'সব দেখুন',
          actionIcon: Icons.arrow_forward_ios,
        ),
        AppSpacing.hMd,
        SizedBox(
          height: 134,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: topDonors.length,
            separatorBuilder: (_, __) => AppSpacing.wMd,
            itemBuilder: (context, index) {
              final entry = topDonors[index];
              return SizedBox(
                width: 104,
                child: PressScale(
                  scale: 0.97,
                  onTap: () {},
                  child: GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AvatarWidget(
                              initials: _initials(entry.key),
                              size: 40,
                              showOnline: index == 0,
                            ),
                            if (index == 0)
                              Positioned(
                                top: -6,
                                right: -6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '১ম',
                                    style: context.textTheme.labelSmall?.copyWith(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        AppSpacing.hSm,
                        Text(
                          entry.key,
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
                          formatTakaExact(entry.value),
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
            },
          ),
        ),
      ],
    );
  }
}
