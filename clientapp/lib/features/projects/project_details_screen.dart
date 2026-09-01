import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/loading_shimmer.dart';
import '../../core/widgets/motion.dart';
import '../../core/widgets/status_badge.dart';
import '../../models.dart';

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

/// Full read-only view of a project managed from the admin panel: budget,
/// funding progress, photo gallery, progress updates and the spending report.
class ProjectDetailsScreen extends ConsumerWidget {
  const ProjectDetailsScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectByIdProvider(projectId));

    return Scaffold(
      backgroundColor: context.canvas,
      appBar: AppBar(
        title: const Text('প্রকল্পের বিবরণ'),
        backgroundColor: context.canvas,
        elevation: 0,
      ),
      body: projectAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: CardSkeleton(height: 220),
        ),
        error: (_, __) => const EmptyState(
          icon: Icons.error_outline,
          title: 'প্রকল্প লোড করা যায়নি',
          description: 'পরে আবার চেষ্টা করুন',
        ),
        data: (project) {
          if (project == null) {
            return const EmptyState(
              icon: Icons.search_off,
              title: 'প্রকল্পটি পাওয়া যায়নি',
              description: 'এটি সরিয়ে ফেলা হয়ে থাকতে পারে',
            );
          }
          return _buildBody(context, project);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, DevelopmentProject project) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
      children: [
        FadeSlideIn(
          delay: 0,
          child: _HeaderCard(project: project),
        ),
        if (project.photos.isNotEmpty) ...[
          AppSpacing.hLg,
          _SectionTitle(title: 'ছবি'),
          AppSpacing.hMd,
          _PhotoStrip(photos: project.photos),
        ],
        if (project.updates.isNotEmpty) ...[
          AppSpacing.hLg,
          _SectionTitle(title: 'অগ্রগতির হালনাগাদ'),
          AppSpacing.hMd,
          _BulletCard(
            items: project.updates,
            icon: Icons.update_rounded,
            color: context.info,
          ),
        ],
        if (project.spendingReport.isNotEmpty) ...[
          AppSpacing.hLg,
          _SectionTitle(title: 'ব্যয়ের হিসাব'),
          AppSpacing.hMd,
          _BulletCard(
            items: project.spendingReport,
            icon: Icons.receipt_long_rounded,
            color: context.warning,
          ),
        ],
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.project});

  final DevelopmentProject project;

  @override
  Widget build(BuildContext context) {
    final percent = (project.fundingProgress * 100).round();

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  project.title,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              AppSpacing.wSm,
              StatusBadge(
                status: StatusBadge.badgeStatusFrom(project.status),
                label: _statusLabel(project.status),
                fontSize: 11,
              ),
            ],
          ),
          if (project.description.isNotEmpty) ...[
            AppSpacing.hMd,
            Text(
              project.description,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.textSecondary,
                height: 1.6,
              ),
            ),
          ],
          AppSpacing.hLg,
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'বাজেট',
                  value: '৳${_formatAmount(project.estimatedCost)}',
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ),
              Expanded(
                child: _Metric(
                  label: 'বরাদ্দকৃত',
                  value: '৳${_formatAmount(project.allocatedFunds)}',
                  icon: Icons.savings_outlined,
                ),
              ),
              Expanded(
                child: _Metric(
                  label: 'বাকি',
                  value: '৳${_formatAmount(project.remainingCost)}',
                  icon: Icons.pending_actions_outlined,
                ),
              ),
            ],
          ),
          AppSpacing.hLg,
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: project.fundingProgress,
              minHeight: 8,
              backgroundColor: context.divider,
              valueColor: AlwaysStoppedAnimation<Color>(context.primary),
            ),
          ),
          AppSpacing.hSm,
          Text(
            'অর্থায়ন সম্পন্ন ${_formatAmount(percent.toDouble())}%',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: context.textSecondary),
        AppSpacing.hXs,
        Text(
          value,
          style: context.textTheme.titleSmall?.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

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

class _PhotoStrip extends StatelessWidget {
  const _PhotoStrip({required this.photos});

  final List<String> photos;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (_, __) => AppSpacing.wMd,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Image.network(
              photos[index],
              width: 220,
              height: 160,
              fit: BoxFit.cover,
              errorBuilder: (context, _, __) => Container(
                width: 220,
                height: 160,
                color: context.divider,
                child: Icon(
                  Icons.broken_image_outlined,
                  color: context.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BulletCard extends StatelessWidget {
  const _BulletCard({
    required this.items,
    required this.icon,
    required this.color,
  });

  final List<String> items;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) AppSpacing.hMd,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 18, color: color),
                AppSpacing.wSm,
                Expanded(
                  child: Text(
                    items[i],
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.textPrimary,
                      height: 1.5,
                    ),
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
