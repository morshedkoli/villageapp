import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/loading_shimmer.dart';
import '../../core/widgets/motion.dart';
import '../../core/widgets/status_badge.dart';
import '../../models.dart';

const _bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

String _bn(num value) {
  final n = value.round();
  if (n == 0) return '০';
  return n
      .abs()
      .toString()
      .split('')
      .map((c) => _bengaliDigits[int.parse(c)])
      .join();
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

/// Citizen-facing mirror of the admin panel's Reports page: fund totals,
/// expense breakdown by category, top donors and project status summary.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(dashboardProvider);
    final transactionsAsync = ref.watch(fundTransactionsProvider);
    final projectsAsync = ref.watch(projectsProvider);
    final topDonorsAsync = ref.watch(topDonorsProvider);

    return Scaffold(
      backgroundColor: context.canvas,
      appBar: AppBar(
        title: const Text('হিসাব ও প্রতিবেদন'),
        backgroundColor: context.canvas,
        elevation: 0,
      ),
      body: overviewAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: CardSkeleton(height: 200),
        ),
        error: (_, __) => const EmptyState(
          icon: Icons.error_outline,
          title: 'প্রতিবেদন লোড করা যায়নি',
          description: 'পরে আবার চেষ্টা করুন',
        ),
        data: (overview) => ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxxl,
          ),
          children: [
            FadeSlideIn(delay: 0, child: _SummaryCard(overview: overview)),
            AppSpacing.hLg,
            const _SectionTitle('ব্যয়ের খাতভিত্তিক হিসাব'),
            AppSpacing.hMd,
            transactionsAsync.when(
              loading: () => const CardSkeleton(height: 140),
              error: (_, __) => const SizedBox.shrink(),
              data: (txs) => _CategoryBreakdown(
                transactions: txs.where((t) => t.isExpense).toList(),
              ),
            ),
            AppSpacing.hLg,
            const _SectionTitle('শীর্ষ দাতা'),
            AppSpacing.hMd,
            topDonorsAsync.when(
              loading: () => const CardSkeleton(height: 140),
              error: (_, __) => const SizedBox.shrink(),
              data: (donors) => _TopDonors(donors: donors),
            ),
            AppSpacing.hLg,
            const _SectionTitle('প্রকল্পের অবস্থা'),
            AppSpacing.hMd,
            projectsAsync.when(
              loading: () => const CardSkeleton(height: 140),
              error: (_, __) => const SizedBox.shrink(),
              data: (projects) => _ProjectSummary(projects: projects),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.overview});

  final VillageOverview overview;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Row(
            label: 'মোট সংগ্রহ',
            value: '৳${_bn(overview.totalFundCollected)}',
            color: context.success,
          ),
          AppSpacing.hMd,
          _Row(
            label: 'মোট ব্যয়',
            value: '৳${_bn(overview.totalSpent)}',
            color: context.error,
          ),
          AppSpacing.hMd,
          _Row(
            label: 'বর্তমান স্থিতি',
            value: '৳${_bn(overview.availableBalance)}',
            color: context.primary,
          ),
          AppSpacing.hMd,
          _Row(
            label: 'মোট নাগরিক',
            value: _bn(overview.totalCitizens),
            color: context.info,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.textTheme.bodyMedium
              ?.copyWith(color: context.textSecondary),
        ),
        Text(
          value,
          style: context.textTheme.titleSmall
              ?.copyWith(color: color, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({required this.transactions});

  final List<FundTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'কোনো ব্যয় নেই',
        description: 'এখনো কোনো ব্যয় রেকর্ড করা হয়নি',
      );
    }

    final totals = <String, double>{};
    for (final tx in transactions) {
      final key = tx.category.isNotEmpty
          ? tx.category
          : (tx.reference.isNotEmpty ? tx.reference : 'অন্যান্য');
      totals[key] = (totals[key] ?? 0) + tx.amount;
    }
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final max = entries.first.value;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          for (var i = 0; i < entries.length && i < 8; i++) ...[
            if (i > 0) AppSpacing.hMd,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Row(
                  label: entries[i].key,
                  value: '৳${_bn(entries[i].value)}',
                  color: context.textPrimary,
                ),
                AppSpacing.hXs,
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: LinearProgressIndicator(
                    value: max > 0 ? entries[i].value / max : 0,
                    minHeight: 6,
                    backgroundColor: context.divider,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(context.accentTerracotta),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TopDonors extends StatelessWidget {
  const _TopDonors({required this.donors});

  final List<MapEntry<String, double>> donors;

  @override
  Widget build(BuildContext context) {
    if (donors.isEmpty) {
      return const EmptyState(
        icon: Icons.volunteer_activism_outlined,
        title: 'কোনো দাতা নেই',
        description: 'এখনো কোনো অনুমোদিত অনুদান নেই',
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          for (var i = 0; i < donors.length; i++) ...[
            if (i > 0) AppSpacing.hMd,
            _Row(
              label: '${_bn(i + 1)}. ${donors[i].key}',
              value: '৳${_bn(donors[i].value)}',
              color: context.success,
            ),
          ],
        ],
      ),
    );
  }
}

class _ProjectSummary extends StatelessWidget {
  const _ProjectSummary({required this.projects});

  final List<DevelopmentProject> projects;

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return const EmptyState(
        icon: Icons.construction_outlined,
        title: 'কোনো প্রকল্প নেই',
        description: 'এখনো কোনো প্রকল্প যোগ করা হয়নি',
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          for (var i = 0; i < projects.length; i++) ...[
            if (i > 0) AppSpacing.hMd,
            Row(
              children: [
                Expanded(
                  child: Text(
                    projects[i].title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium
                        ?.copyWith(color: context.textPrimary),
                  ),
                ),
                AppSpacing.wSm,
                Text(
                  '৳${_bn(projects[i].estimatedCost)}',
                  style: context.textTheme.bodySmall
                      ?.copyWith(color: context.textSecondary),
                ),
                AppSpacing.wSm,
                StatusBadge(
                  status: StatusBadge.badgeStatusFrom(projects[i].status),
                  label: _statusLabel(projects[i].status),
                  fontSize: 10,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.textTheme.titleSmall?.copyWith(
        color: context.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
