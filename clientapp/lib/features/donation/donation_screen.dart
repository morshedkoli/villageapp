import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/timeline_item.dart';
import '../../core/widgets/avatar_widget.dart';
import '../../core/widgets/motion.dart';
import '../../core/providers/providers.dart';
import '../../models.dart';


class DonationScreen extends ConsumerStatefulWidget {
  const DonationScreen({super.key});

  @override
  ConsumerState<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends ConsumerState<DonationScreen> {
  String _selectedCategory = 'সব';

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final donationsAsync = ref.watch(recentDonationsProvider);

    return dashboardAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (overview) {
        final collectedAmount = overview.totalFundCollected;

        return donationsAsync.when(
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
          data: (donations) {
            return Scaffold(
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.xxxl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeSlideIn(delay: 0, child: _buildHeader()),
                      AppSpacing.hLg,
                      FadeSlideIn(delay: 80, child: _buildFundOverview(collectedAmount)),
                      AppSpacing.hXxl,
                      FadeSlideIn(delay: 160, child: _buildCategories()),
                      AppSpacing.hXxl,
                      FadeSlideIn(delay: 240, child: _buildRecentDonations(donations)),
                      AppSpacing.hXxl,
                      FadeSlideIn(delay: 320, child: _buildTopDonors(donations)),
                    ],
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
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'দান ও তহবিল',
              style: context.textTheme.headlineMedium?.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.hXs,
            Text(
              'আপনার দানেই সমৃদ্ধ আমাদের গ্রাম',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(Icons.volunteer_activism_outlined, size: 22, color: context.primary),
        ),
      ],
    );
  }

  Widget _buildFundOverview(double collectedAmount) {
    final isDark = context.isDark;
    final format = NumberFormat('#,##0');
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
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
              '৳${format.format(collectedAmount)}',
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

  Widget _buildCategories() {
    final categories = ['সব', 'জরুরি তহবিল', 'মসজিদ', 'শিক্ষা', 'স্বাস্থ্য', 'রাস্তা মেরামত'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'বিভাগ',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        AppSpacing.hMd,
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: categories.length,
            separatorBuilder: (_, _) => AppSpacing.wSm,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final selected = _selectedCategory == cat;
              return ChoiceChip(
                label: Text(cat),
                selected: selected,
                onSelected: (val) {
                  if (val) setState(() => _selectedCategory = cat);
                },
                labelStyle: context.textTheme.labelMedium?.copyWith(
                  color: selected ? AppColors.primary : context.textSecondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                selectedColor: AppColors.primary.withValues(alpha: 0.12),
                backgroundColor: context.isDark ? AppColors.darkCard : AppColors.lightBackground,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentDonations(List<Donation> donations) {
    final format = NumberFormat('#,##0');
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
                      '৳${format.format(d.amount)}',
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

  Widget _buildTopDonors(List<Donation> donations) {
    final format = NumberFormat('#,##0');
    final totals = <String, double>{};
    for (final d in donations) {
      if (d.donorName.isNotEmpty) {
        totals[d.donorName] = (totals[d.donorName] ?? 0) + d.amount;
      }
    }
    final sorted = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();

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
            itemCount: top.length,
            separatorBuilder: (_, _) => AppSpacing.wMd,
            itemBuilder: (context, index) {
              final entry = top[index];
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
                          '৳${format.format(entry.value)}',
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

  String _initials(String name) {
    if (name.length >= 2) return name.substring(0, 2);
    return name.isNotEmpty ? name[0] : '';
  }
}

