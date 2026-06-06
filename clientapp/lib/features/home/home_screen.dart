import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../core/providers/providers.dart';
import '../../models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/kpi_card.dart';
import '../../core/widgets/timeline_item.dart';
import '../../core/widgets/avatar_widget.dart';
import '../../core/widgets/motion.dart';
import '../../core/widgets/loading_shimmer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieCtrl;

  @override
  void initState() {
    super.initState();
    _lottieCtrl = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _lottieCtrl.dispose();
    super.dispose();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'শুভ সকাল';
    if (hour < 17) return 'শুভ বিকাল';
    return 'শুভ সন্ধ্যা';
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(dashboardProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    final dashboardData = dashboard.asData?.value;
    final unread = unreadCount.asData?.value ?? 0;

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
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Header ────────────────────────
                    FadeSlideIn(
                      delay: 0,
                      child: _buildHeader(unread),
                    ),
                    AppSpacing.hLg,

                    // ── Lottie banner ─────────────────
                    FadeSlideIn(
                      delay: 60,
                      child: _buildLottieBanner(),
                    ),
                    AppSpacing.hMd,

                    // ── Hero balance card ─────────────
                    FadeSlideIn(
                      delay: 120,
                      child: _buildHeroBalanceCard(dashboardData),
                    ),
                    AppSpacing.hXxl,

                    // ── Stats Grid ───────────────────
                    FadeSlideIn(
                      delay: 160,
                      child: _buildQuickStatsGrid(dashboardData),
                    ),
                    AppSpacing.hXxl,

                    // ── Community Activity ────────────
                    FadeSlideIn(
                      delay: 240,
                      child: _buildCommunityActivity(),
                    ),
                    AppSpacing.hXxl,

                    // ── Top Contributors ──────────────
                    FadeSlideIn(
                      delay: 320,
                      child: _buildTopContributors(),
                    ),

                    // Bottom safe-area padding
                    const SizedBox(height: AppSpacing.massive + AppSpacing.xxl),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────
  Widget _buildHeader(int unread) {
    final firebaseUser = ref.watch(currentFirebaseUserProvider).asData?.value;
    final rawName = firebaseUser?.displayName ?? '';
    // Show only the first word of the display name as a short greeting
    final firstName = rawName.isNotEmpty
        ? rawName.trim().split(' ').first
        : null;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_greeting${firstName != null ? ', $firstName' : ''} 👋',
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'আল ইসলাহ কমিউনিটি',
                style: AppTypography.sectionTitle.copyWith(
                  color: context.textPrimary,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.wLg,
        PressScale(
          onTap: () => context.go('/notifications'),
          scale: 0.93,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: context.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: Icon(
                    Icons.notifications_outlined,
                    size: 22,
                    color: context.textPrimary,
                  ),
                ),
                if (unread > 0)
                  Positioned(
                    top: 7,
                    right: 7,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.surface, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Lottie Banner ─────────────────────────────────
  Widget _buildLottieBanner() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.06),
            AppColors.primary.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          // ── Lottie animation ────────────────────────
          SizedBox(
            width: 150,
            height: 150,
            child: Lottie.asset(
              'assets/village_animation.json',
              controller: _lottieCtrl,
              fit: BoxFit.contain,
              onLoaded: (composition) {
                _lottieCtrl
                  ..duration = composition.duration
                  ..repeat();
              },
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.location_city_rounded,
                size: 80,
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
          ),

          // ── Text side ────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      '🌿 স্বাগতম',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'আমাদের গ্রামকে\nগড়ে তুলি একসাথে',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'স্বচ্ছতা ও অংশগ্রহণেই সমৃদ্ধি',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero Balance Card ─────────────────────────────
  Widget _buildHeroBalanceCard(VillageOverview? overview) {
    final balance = overview != null
        ? '৳${_formatAmount(overview.availableBalance)}'
        : '--';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xxxl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.inkOnPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.account_balance_rounded,
                  color: AppColors.inkOnPrimary,
                  size: 20,
                ),
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

          // Balance amount
          Text(
            balance,
            style: AppTypography.heroAmount.copyWith(
              color: AppColors.inkOnPrimary,
            ),
          ),
          AppSpacing.hXxl,

          // Quick-action row
          Row(
            children: [
              Expanded(
                child: _QuickActionBtn(
                  icon: Icons.volunteer_activism_outlined,
                  label: 'দান করুন',
                  onTap: () => context.go('/donate'),
                ),
              ),
              AppSpacing.wSm,
              Expanded(
                child: _QuickActionBtn(
                  icon: Icons.report_outlined,
                  label: 'সমস্যা রিপোর্ট',
                  onTap: () => context.go('/problems/report'),
                ),
              ),
              AppSpacing.wSm,
              Expanded(
                child: _QuickActionBtn(
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

  // ── Stats 2×2 Grid ──────────────────────────────
  Widget _buildQuickStatsGrid(VillageOverview? overview) {
    final totalFund = overview != null
        ? '৳${_formatAmount(overview.totalFundCollected)}'
        : '--';
    final totalSpent = overview != null
        ? '৳${_formatAmount(overview.totalSpent)}'
        : '--';
    final balance = overview != null
        ? '৳${_formatAmount(overview.availableBalance)}'
        : '--';
    final citizens = overview?.totalCitizens ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: KpiCard(
                label: 'মোট সংগ্রহ',
                value: totalFund,
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
                value: totalSpent,
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
                value: _formatCount(citizens),
                icon: Icons.people_rounded,
                accentColor: AppColors.primary,
                onTap: () => context.push('/all-citizens'),
              ),
            ),
            AppSpacing.wMd,
            Expanded(
              child: KpiCard(
                label: 'অবশিষ্ট ব্যালেন্স',
                value: balance,
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

  // ── Community Activity ───────────────────────────
  Widget _buildCommunityActivity() {
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
          error: (_, _) => const CardSkeleton(height: 240),
          data: (donations) {
            final items = donations.take(4).toList();
            return PremiumCard(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Column(
                children: items.asMap().entries.map((entry) {
                  final i = entry.key;
                  final d = entry.value;
                  return Column(
                    children: [
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
                            '${d.donorName} ৳${_formatAmount(d.amount)} দান করেছেন',
                        icon: Icons.volunteer_activism_rounded,
                        iconColor: AppColors.success,
                        timestamp: d.createdAt,
                      ),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Top Contributors ─────────────────────────────
  Widget _buildTopContributors() {
    final donations = ref.watch(donationsProvider);
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
          height: 134,
          child: donations.when(
            loading: () => const SizedBox(height: 134),
            error: (_, _) => const SizedBox(height: 134),
            data: (list) {
              final totals = <String, double>{};
              for (final donation in list) {
                if (donation.donorName.isEmpty) {
                  continue;
                }
                totals[donation.donorName] =
                    (totals[donation.donorName] ?? 0) + donation.amount;
              }
              final top5 = totals.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));
              final ranked = top5.take(5).toList();
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: ranked.length,
                separatorBuilder: (_, _) => AppSpacing.wMd,
                itemBuilder: (context, index) {
                  final donor = ranked[index];
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
                            AvatarWidget(
                                  initials: donor.key,
                                  size: 40,
                                  showOnline: index == 0,
                                ),
                                if (index == 0)
                                  Positioned(
                                    top: -6,
                                    right: -6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.warning,
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.sm),
                                      ),
                                      child: Text(
                                        '১ম',
                                        style: context.textTheme.labelSmall
                                            ?.copyWith(
                                          color: AppColors.inkOnPrimary,
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
                              donor.key,
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
                              '৳${_formatAmount(donor.value)}',
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
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    final lakh = (amount / 100000).floor();
    final thousand = ((amount % 100000) / 1000).floor();
    if (lakh > 0) {
      if (thousand > 0) return '$lakhলাখ $thousandহাজার';
      return '$lakhলাখ';
    }
    return amount.toInt().toString();
  }

  String _formatCount(int count) {
    if (count >= 10000000) return '${(count / 10000000).toStringAsFixed(1)}Cr';
    if (count >= 100000) return '${(count / 100000).toStringAsFixed(1)}L';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }
}

// ── _QuickActionBtn (private, card-internal) ──────
class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

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
