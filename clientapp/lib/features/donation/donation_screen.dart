import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/motion.dart';
import '../../core/widgets/loading_shimmer.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/providers/providers.dart';
import '../../models.dart';
import 'widgets/category_filters.dart';
import 'widgets/donation_header.dart';
import 'widgets/fund_overview_card.dart';
import 'widgets/recent_donations_section.dart';
import 'widgets/top_donors_section.dart';

class DonationScreen extends ConsumerStatefulWidget {
  const DonationScreen({super.key});

  @override
  ConsumerState<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends ConsumerState<DonationScreen> {
  /// Highlighted category chip. Purely visual for now — see the note in
  /// [CategoryFilters]; the donation list below is not filtered by it.
  String _selectedCategory = 'সব';

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final donationsAsync = ref.watch(recentDonationsProvider);
    final topDonorsAsync = ref.watch(topDonorsProvider);

    if (dashboardAsync.isLoading || donationsAsync.isLoading || topDonorsAsync.isLoading) {
      return Scaffold(
        backgroundColor: context.canvas,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DonationHeader(),
                AppSpacing.hLg,
                const HeroCardSkeleton(),
                AppSpacing.hXxl,
                const ShimmerLoading(height: 36, width: double.infinity),
                AppSpacing.hXxl,
                const Expanded(child: ListSkeleton(itemCount: 4)),
              ],
            ),
          ),
        ),
      );
    }

    if (dashboardAsync.hasError || donationsAsync.hasError) {
      return Scaffold(
        backgroundColor: context.canvas,
        body: SafeArea(
          child: Center(
            child: EmptyStateWidget(
              icon: Icons.error_outline_rounded,
              title: 'তথ্য লোড করা যায়নি',
              subtitle: 'ইন্টারনেট সংযোগ পরীক্ষা করে পুনরায় চেষ্টা করুন',
              actionLabel: 'পুনরায় লোড করুন',
              onAction: () {
                ref.invalidate(dashboardProvider);
                ref.invalidate(recentDonationsProvider);
                ref.invalidate(topDonorsProvider);
              },
            ),
          ),
        ),
      );
    }

    final overview = dashboardAsync.valueOrNull ??
        const VillageOverview(
          name: 'আল ইসলাহ',
          totalCitizens: 0,
          totalFundCollected: 0,
          totalSpent: 0,
        );
    final donations = donationsAsync.valueOrNull ?? [];
    final topDonors = topDonorsAsync.valueOrNull ?? [];

    return Scaffold(
      backgroundColor: context.canvas,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: context.surface,
          onRefresh: () async {
            ref.invalidate(dashboardProvider);
            ref.invalidate(recentDonationsProvider);
            ref.invalidate(topDonorsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.massive,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FadeSlideIn(delay: 0, child: DonationHeader()),
                AppSpacing.hLg,
                FadeSlideIn(
                  delay: 80, 
                  child: FundOverviewCard(collectedAmount: overview.totalFundCollected),
                ),
                AppSpacing.hXxl,
                FadeSlideIn(
                  delay: 160, 
                  child: CategoryFilters(
                    selectedCategory: _selectedCategory,
                    onSelected: (cat) => setState(() => _selectedCategory = cat),
                  ),
                ),
                AppSpacing.hXxl,
                FadeSlideIn(
                  delay: 240, 
                  child: RecentDonationsSection(donations: donations),
                ),
                AppSpacing.hXxl,
                FadeSlideIn(
                  delay: 320, 
                  child: TopDonorsSection(topDonors: topDonors),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72.0),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/donate/checkout'),
          icon: const Icon(Icons.add, size: 20),
          label: const Text('নতুন দান'),
        ),
      ),
    );
  }
}


