import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/motion.dart';
import 'widgets/fund_balance_card.dart';
import 'widgets/home_header.dart';
import 'widgets/recent_activity.dart';
import 'widgets/top_contributors.dart';
import 'widgets/village_stats_grid.dart';
import 'widgets/welcome_banner.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(dashboardProvider).asData?.value;
    final unread = ref.watch(unreadCountProvider).asData?.value ?? 0;

    return Scaffold(
      backgroundColor: context.canvas,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: context.surface,
          onRefresh: () async {
            ref.invalidate(dashboardProvider);
            ref.invalidate(recentDonationsProvider);
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  0,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    FadeSlideIn(delay: 0, child: HomeHeader(unreadCount: unread)),
                    AppSpacing.hLg,
                    const FadeSlideIn(delay: 60, child: WelcomeBanner()),
                    AppSpacing.hMd,
                    FadeSlideIn(
                      delay: 120,
                      child: FundBalanceCard(overview: overview),
                    ),
                    AppSpacing.hXxl,
                    FadeSlideIn(
                      delay: 160,
                      child: VillageStatsGrid(overview: overview),
                    ),
                    AppSpacing.hXxl,
                    const FadeSlideIn(delay: 240, child: RecentActivity()),
                    AppSpacing.hXxl,
                    const FadeSlideIn(delay: 320, child: TopContributors()),
                    const SizedBox(
                      height: AppSpacing.massive + AppSpacing.xxl,
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
