import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/providers.dart';
import '../../models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/kpi_card.dart';
import '../../core/widgets/avatar_widget.dart';
import '../../core/widgets/motion.dart';

class LeadersScreen extends ConsumerStatefulWidget {
  const LeadersScreen({super.key});

  @override
  ConsumerState<LeadersScreen> createState() => _LeadersScreenState();
}

class _LeadersScreenState extends ConsumerState<LeadersScreen> {
  @override
  Widget build(BuildContext context) {
    final leaders = ref.watch(leadersProvider);
    final totalLeaders = leaders.length;
    final activeLeaders = leaders.where((l) => l.isOnline).length;

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
              AppSpacing.hXxl,
              FadeSlideIn(delay: 80, child: _buildStatsRow(totalLeaders, activeLeaders)),
              AppSpacing.hXxl,
              if (leaders.isEmpty)
                _buildEmptyState()
              else
                FadeSlideIn(delay: 160, child: _buildLeadersGrid(leaders)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(
          'কোনো নেতা পাওয়া যায়নি',
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.textSecondary,
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
                'কমিউনিটি নেতৃবৃন্দ',
                style: context.textTheme.headlineMedium?.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppSpacing.hXs,
              Text(
                'আমাদের গর্বিত নেতৃত্ব দল',
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
            child: Icon(Icons.group_outlined, size: 22, color: context.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int totalLeaders, int activeLeaders) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: KpiCard(
              label: 'মোট নেতা',
              value: '$totalLeaders',
              icon: Icons.person_outlined,
              iconBackground: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
          AppSpacing.wMd,
          Expanded(
            child: KpiCard(
              label: 'অভিজ্ঞতা',
              value: '২৫+ বছর',
              icon: Icons.workspace_premium_outlined,
              iconBackground: AppColors.warning.withValues(alpha: 0.1),
            ),
          ),
          AppSpacing.wMd,
          Expanded(
            child: KpiCard(
              label: 'সক্রিয়',
              value: '$activeLeaders জন',
              subtitle: totalLeaders > 0
                  ? '${(activeLeaders * 100 / totalLeaders).round()}%'
                  : '০%',
              icon: Icons.verified_outlined,
              iconBackground: AppColors.success.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadersGrid(List<Leader> leaders) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.78,
        ),
        itemCount: leaders.length,
        itemBuilder: (context, index) {
          final leader = leaders[index];
          final initials = leader.name.isNotEmpty ? leader.name[0] : '?';
          return FadeSlideIn(
            delay: index * 60,
            child: PressScale(
              scale: 0.97,
              onTap: () {},
              child: GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AvatarWidget(
                      imageUrl: leader.photoUrl.isNotEmpty ? leader.photoUrl : null,
                      initials: initials,
                      size: 64,
                      showOnline: leader.isOnline,
                    ),
                    AppSpacing.hMd,
                    Text(
                      leader.name,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.hXs,
                    Text(
                      leader.role,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.hXs,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        leader.experience,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(Icons.call_outlined, AppColors.success, () {}),
                        _buildActionButton(Icons.chat_outlined, AppColors.info, () {}),
                        _buildActionButton(Icons.email_outlined, AppColors.warning, () {}),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
