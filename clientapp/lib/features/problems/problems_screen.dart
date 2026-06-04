import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/kpi_card.dart';
import '../../core/widgets/avatar_widget.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/motion.dart';
import '../../core/widgets/login_prompt.dart';
import '../../core/providers/providers.dart';
import '../../models.dart';

class ProblemsScreen extends ConsumerStatefulWidget {
  const ProblemsScreen({super.key});

  @override
  ConsumerState<ProblemsScreen> createState() => _ProblemsScreenState();
}

class _ProblemsScreenState extends ConsumerState<ProblemsScreen> {
  String _selectedFilter = 'সব';

  final _filters = ['সব', 'বিচারাধীন', 'প্রক্রিয়াধীন', 'সমাধানকৃত', 'বাতিল'];

  @override
  Widget build(BuildContext context) {
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
              FadeSlideIn(delay: 80, child: _buildStatsGrid()),
              AppSpacing.hXxl,
              FadeSlideIn(delay: 160, child: _buildFilterChips()),
              AppSpacing.hLg,
              FadeSlideIn(delay: 240, child: _buildProblemList()),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            final isAuthenticated = ref
                .read(isAuthenticatedProvider)
                .when(data: (v) => v, error: (_, _) => false, loading: () => false);
            if (isAuthenticated) {
              context.push('/problems/report');
            } else {
              showLoginPrompt(
                context,
                reason: 'সমস্যা রিপোর্ট করতে লগইন করুন',
                onSuccess: () => context.push('/problems/report'),
              );
            }
          },
          icon: const Icon(Icons.add, size: 20),
          label: const Text('নতুন রিপোর্ট'),
        ),
      ),
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
              'সমস্যা রিপোর্ট',
              style: context.textTheme.headlineMedium?.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.hXs,
            Text(
              'আপনার এলাকার সমস্যা জানান',
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
          child: Icon(Icons.report_outlined, size: 22, color: context.error),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: KpiCard(
                  label: 'মোট রিপোর্ট',
                  value: '৪২',
                  icon: Icons.assignment_outlined,
                  iconBackground: Color(0xFF3B82F6),
                ),
              ),
              AppSpacing.wMd,
              const Expanded(
                child: KpiCard(
                  label: 'বিচারাধীন',
                  value: '১৫',
                  icon: Icons.schedule_outlined,
                  iconBackground: Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          AppSpacing.hMd,
          Row(
            children: [
              const Expanded(
                child: KpiCard(
                  label: 'প্রক্রিয়াধীন',
                  value: '১২',
                  icon: Icons.sync_outlined,
                  iconBackground: Color(0xFF3B82F6),
                ),
              ),
              AppSpacing.wMd,
              Expanded(
                child: KpiCard(
                  label: 'সমাধানকৃত',
                  value: '১৫',
                  icon: Icons.task_alt,
                  subtitle: '৩৬%',
                  iconBackground: AppColors.success.withValues(alpha: 0.15),
                ),
              ),
            ],
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

  Widget _buildProblemList() {
    final problemsAsync = ref.watch(problemsProvider);

    return problemsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => EmptyState(
        icon: Icons.error_outline,
        title: 'ত্রুটি',
        description: error.toString(),
      ),
      data: (problems) {
        final filtered = _selectedFilter == 'সব'
            ? problems
            : problems.where((p) => _statusLabel(p) == _selectedFilter).toList();

        if (filtered.isEmpty) {
          return const EmptyState(
            icon: Icons.search_off,
            title: 'কোনো সমস্যা পাওয়া যায়নি',
            description: 'এই বিভাগে কোনো রিপোর্ট নেই',
          );
        }

        return Column(
          children: filtered.map((problem) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: FadeSlideIn(
                delay: 0,
                child: PressScale(
                  scale: 0.98,
                  onTap: () => context.push('/problems/${problem.id}'),
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
                                problem.title,
                                style: context.textTheme.headlineSmall?.copyWith(
                                  color: context.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            AppSpacing.wSm,
                            StatusBadge.fromString(_statusLabel(problem), fontSize: 10),
                          ],
                        ),
                        AppSpacing.hMd,
                        Row(
                          children: [
                            AvatarWidget(
                              initials: problem.reportedBy.isNotEmpty ? problem.reportedBy[0] : '?',
                              size: 24,
                            ),
                            AppSpacing.wSm,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    problem.reportedBy,
                                    style: context.textTheme.labelMedium?.copyWith(
                                      color: context.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    _formatDate(problem.createdAt),
                                    style: context.textTheme.labelSmall?.copyWith(
                                      color: context.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.hMd,
                        Row(
                          children: [
                            _buildStatChip(Icons.thumb_up_outlined, '${problem.upvotes}'),
                            AppSpacing.wLg,
                            _buildStatChip(Icons.chat_bubble_outline, '0'),
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
      },
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: context.textTertiary),
        AppSpacing.wXs,
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.textTertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _statusLabel(ProblemReport p) {
    switch (p.status.toLowerCase()) {
      case 'pending':
        return 'বিচারাধীন';
      case 'under_review':
        return 'বিচারাধীন';
      case 'in_progress':
        return 'প্রক্রিয়াধীন';
      case 'resolved':
        return 'সমাধানকৃত';
      case 'cancelled':
      case 'rejected':
        return 'বাতিল';
      default:
        return 'বিচারাধীন';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
      'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর',
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}
