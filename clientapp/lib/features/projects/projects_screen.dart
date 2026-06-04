import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/providers.dart';
import '../../models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/kpi_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/motion.dart';

const _bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

String _formatAmount(double amount) {
  final n = amount.round();
  if (n == 0) return '০';
  return n.toString().split('').map((c) => _bengaliDigits[int.parse(c)]).join();
}

String _statusLabel(String status) {
  switch (status) {
    case 'Planning':
      return 'পরিকল্পনাধীন';
    case 'Ongoing':
    case 'InProgress':
      return 'চলমান';
    case 'Completed':
      return 'সম্পন্ন';
    default:
      return status;
  }
}

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  String _selectedFilter = 'সব';

  final _filters = ['সব', 'চলমান', 'সম্পন্ন', 'পরিকল্পনাধীন'];

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      body: SafeArea(
        child: projectsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'ত্রুটি: $err',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (projects) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.xxxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeSlideIn(delay: 0, child: _buildHeader()),
                AppSpacing.hLg,
                FadeSlideIn(delay: 80, child: _buildStatsRow(projects)),
                AppSpacing.hXxl,
                FadeSlideIn(delay: 160, child: _buildFilterChips()),
                AppSpacing.hLg,
                FadeSlideIn(delay: 240, child: _buildProjectList(projects)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'কমিউনিটি প্রকল্প',
                style: context.textTheme.headlineMedium?.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppSpacing.hXs,
              Text(
                'আমাদের গ্রামের উন্নয়নমূলক কাজ',
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
            child: Icon(Icons.construction_outlined, size: 22, color: context.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(List<DevelopmentProject> projects) {
    final total = projects.length;
    final ongoing = projects.where((p) => p.status == 'Ongoing' || p.status == 'InProgress').length;
    final completed = projects.where((p) => p.status == 'Completed').length;
    final completionRate = total > 0 ? (completed / total * 100).round() : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: KpiCard(
              label: 'মোট প্রকল্প',
              value: _formatAmount(total.toDouble()),
              icon: Icons.assignment_outlined,
              iconBackground: AppColors.info.withValues(alpha: 0.1),
            ),
          ),
          AppSpacing.wMd,
          Expanded(
            child: KpiCard(
              label: 'চলমান',
              value: _formatAmount(ongoing.toDouble()),
              icon: Icons.sync_outlined,
              iconBackground: AppColors.warning.withValues(alpha: 0.1),
            ),
          ),
          AppSpacing.wMd,
          Expanded(
            child: KpiCard(
              label: 'সম্পন্ন',
              value: _formatAmount(completed.toDouble()),
              subtitle: '$completionRate%',
              icon: Icons.check_circle_outlined,
              iconBackground: AppColors.success.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ফিল্টার',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.hMd,
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, _) => AppSpacing.wSm,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final selected = _selectedFilter == filter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: selected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedFilter = filter);
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
      ),
    );
  }

  Widget _buildProjectList(List<DevelopmentProject> projects) {
    final filtered = _selectedFilter == 'সব'
        ? projects
        : projects.where((p) => _statusLabel(p.status) == _selectedFilter).toList();

    if (filtered.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'কোনো প্রকল্প পাওয়া যায়নি',
        description: 'এই বিভাগে কোনো প্রকল্প নেই',
      );
    }

    return Column(
      children: filtered.map((project) {
        final progress = project.estimatedCost > 0
            ? (project.allocatedFunds / project.estimatedCost * 100).round().clamp(0, 100)
            : 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: FadeSlideIn(
            delay: 0,
            child: PressScale(
              scale: 0.98,
              onTap: () {},
              child: GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            project.title,
                            style: context.textTheme.titleSmall?.copyWith(
                              color: context.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        AppSpacing.wSm,
                        StatusBadge.fromString(_statusLabel(project.status), fontSize: 10),
                      ],
                    ),
                    AppSpacing.hMd,
                    Row(
                      children: [
                        Icon(Icons.account_balance_wallet_outlined, size: 16, color: context.textSecondary),
                        AppSpacing.wSm,
                        Text(
                          'বাজেট: ৳${_formatAmount(project.estimatedCost)}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.hMd,
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        minHeight: 8,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress >= 100
                              ? AppColors.success
                              : AppColors.primary,
                        ),
                      ),
                    ),
                    AppSpacing.hSm,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$progress% সম্পন্ন',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: progress >= 100
                                ? AppColors.success
                                : context.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.people_outline, size: 14, color: context.textTertiary),
                            AppSpacing.wXs,
                            Text(
                              '০ সদস্য',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: context.textTertiary,
                              ),
                            ),
                            AppSpacing.wLg,
                            Icon(Icons.access_time, size: 14, color: context.textTertiary),
                            AppSpacing.wXs,
                            Text(
                              '',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: context.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
