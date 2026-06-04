import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/motion.dart';
import '../../core/widgets/status_badge.dart';
import '../../data_service.dart';
import '../../models.dart';

class ProblemDetailsScreen extends ConsumerWidget {
  final String problemId;

  const ProblemDetailsScreen({super.key, required this.problemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final problemsAsync = ref.watch(problemsProvider);
    final myVoteAsync = ref.watch(_myVoteProvider(problemId));

    return Scaffold(
      body: SafeArea(
        child: problemsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('ত্রুটি: $error')),
          data: (problems) {
            final problem = problems.where((item) => item.id == problemId).firstOrNull;
            if (problem == null) {
              return const Center(child: Text('সমস্যাটি পাওয়া যায়নি'));
            }

            final myVote = myVoteAsync.asData?.value;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xxxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeSlideIn(delay: 0, child: _buildAppBar(context, problem.title)),
                  AppSpacing.hLg,
                  FadeSlideIn(delay: 80, child: _buildHero(problem)),
                  AppSpacing.hXxl,
                  FadeSlideIn(delay: 120, child: _buildProblemInfo(context, problem)),
                  AppSpacing.hXxl,
                  FadeSlideIn(
                    delay: 180,
                    child: _VotingCard(
                      problem: problem,
                      myVote: myVote,
                    ),
                  ),
                  AppSpacing.hXxl,
                  FadeSlideIn(delay: 240, child: _buildMeta(context, problem)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String title) {
    return Row(
      children: [
        PressScale(
          scale: 0.92,
          onTap: () => context.pop(),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.card,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 22),
          ),
        ),
        AppSpacing.wMd,
        Expanded(
          child: Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildHero(ProblemReport problem) {
    if (problem.photoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        child: Image.network(
          problem.photoUrl,
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, error, stackTrace) => _buildFallbackHero(),
        ),
      );
    }
    return _buildFallbackHero();
  }

  Widget _buildFallbackHero() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withValues(alpha: 0.3),
            AppColors.error.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Icon(
            Icons.report_problem_rounded,
            size: 36,
            color: AppColors.warning,
          ),
        ),
      ),
    );
  }

  Widget _buildProblemInfo(BuildContext context, ProblemReport problem) {
    return GlassCard(
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
                  ),
                ),
              ),
              AppSpacing.wSm,
              StatusBadge.fromString(problem.status, fontSize: 10),
            ],
          ),
          AppSpacing.hLg,
          Text(
            problem.description,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeta(BuildContext context, ProblemReport problem) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'বিস্তারিত',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.hLg,
          _MetaRow(
            icon: Icons.person_outline,
            label: 'রিপোর্ট করেছেন',
            value: problem.reportedBy.isNotEmpty ? problem.reportedBy : 'নাগরিক',
          ),
          AppSpacing.hMd,
          _MetaRow(
            icon: Icons.location_on_outlined,
            label: 'অবস্থান',
            value: problem.location.isNotEmpty ? problem.location : 'উল্লেখ নেই',
          ),
          AppSpacing.hMd,
          _MetaRow(
            icon: Icons.calendar_month_outlined,
            label: 'তারিখ',
            value: _formatDate(problem.createdAt),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    return '${value.day}/${value.month}/${value.year}';
  }
}

class _VotingCard extends ConsumerWidget {
  final ProblemReport problem;
  final int? myVote;

  const _VotingCard({
    required this.problem,
    required this.myVote,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ভোট',
                style: context.textTheme.titleSmall?.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${problem.voteScore} নেট ভোট',
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
          AppSpacing.hLg,
          Row(
            children: [
              Expanded(
                child: _VoteButton(
                  label: 'সমর্থন',
                  icon: Icons.thumb_up_rounded,
                  active: myVote == 1,
                  color: AppColors.success,
                  onTap: () => _submitVote(context, 1),
                ),
              ),
              AppSpacing.wMd,
              Expanded(
                child: _VoteButton(
                  label: 'অসমর্থন',
                  icon: Icons.thumb_down_rounded,
                  active: myVote == -1,
                  color: AppColors.error,
                  onTap: () => _submitVote(context, -1),
                ),
              ),
            ],
          ),
          AppSpacing.hMd,
          Text(
            'আপনার ভোট একই হলে আবার চাপলে তা সরিয়ে নেওয়া হবে।',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitVote(BuildContext context, int value) async {
    try {
      await DataService.instance.voteOnProblem(problem.id, value);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', ''))),
      );
    }
  }
}

class _VoteButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _VoteButton({
    required this.label,
    required this.icon,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressScale(
      scale: 0.96,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: active
              ? color.withValues(alpha: 0.12)
              : (context.isDark ? AppColors.darkBorder : AppColors.lightBackground),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: active ? color.withValues(alpha: 0.35) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? color : context.textTertiary, size: 20),
            AppSpacing.wSm,
            Text(
              label,
              style: context.textTheme.labelLarge?.copyWith(
                color: active ? color : context.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        AppSpacing.wMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.textSecondary,
                ),
              ),
              Text(
                value,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final _myVoteProvider = StreamProvider.family<int?, String>((ref, problemId) {
  ref.watch(currentFirebaseUserProvider);
  return DataService.instance.myVoteOnProblem(problemId);
});
