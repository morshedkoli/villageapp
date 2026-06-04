import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/timeline_item.dart';
import '../../core/widgets/avatar_widget.dart';
import '../../core/widgets/motion.dart';
import '../../core/widgets/login_prompt.dart';
import '../../core/providers/providers.dart';
import '../../models.dart';

class CitizenProfileScreen extends ConsumerStatefulWidget {
  final String citizenId;

  const CitizenProfileScreen({
    super.key,
    required this.citizenId,
  });

  @override
  ConsumerState<CitizenProfileScreen> createState() => _CitizenProfileScreenState();
}

class _CitizenProfileScreenState extends ConsumerState<CitizenProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final citizensAsync = ref.watch(citizensProvider);
    final isAuthenticated = ref
        .watch(isAuthenticatedProvider)
        .when(data: (v) => v, error: (_, _) => false, loading: () => false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('নাগরিক প্রোফাইল'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: citizensAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('ত্রুটি: $err')),
        data: (citizens) {
          final citizen = citizens.where((c) => c.id == widget.citizenId).firstOrNull;
          if (citizen == null) {
            return const Center(child: Text('নাগরিক পাওয়া যায়নি'));
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              FadeSlideIn(
                delay: 0,
                child: _ProfileHeader(citizen: citizen),
              ),
              AppSpacing.hLg,
              FadeSlideIn(
                delay: 100,
                child: _AboutSection(
                  citizen: citizen,
                  isAuthenticated: isAuthenticated,
                ),
              ),
              AppSpacing.hLg,
              FadeSlideIn(
                delay: 200,
                child: const _RecentActivitySection(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final Citizen citizen;

  const _ProfileHeader({required this.citizen});

  @override
  Widget build(BuildContext context) {
    final initials = citizen.name.isNotEmpty ? citizen.name[0] : '?';
    return GlassCard(
      child: Column(
        children: [
          AvatarWidget(
            initials: initials,
            size: 80,
            showOnline: true,
          ),
          AppSpacing.hLg,
          Text(
            citizen.name,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.hXs,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              citizen.profession.isNotEmpty ? citizen.profession : 'পেশা উল্লেখ নেই',
              style: context.textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          AppSpacing.hSm,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_outlined, size: 14, color: context.textSecondary),
              AppSpacing.wXs,
              Text(
                citizen.village.isNotEmpty ? citizen.village : 'ঠিকানা উল্লেখ নেই',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
          AppSpacing.hLg,
          Container(
            height: 1,
            color: context.isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),
          AppSpacing.hLg,
          Row(
            children: [
              _StatItem(
                value: '২৩',
                label: 'দান',
                icon: Icons.volunteer_activism_outlined,
              ),
              _StatDivider(),
              _StatItem(
                value: '১২',
                label: 'প্রকল্প',
                icon: Icons.construction_outlined,
              ),
              _StatDivider(),
              _StatItem(
                value: '৮',
                label: 'রিপোর্ট',
                icon: Icons.report_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          AppSpacing.hSm,
          Text(
            value,
            style: context.textTheme.titleSmall?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: context.isDark ? AppColors.darkDivider : AppColors.lightDivider,
    );
  }
}

class _AboutSection extends StatelessWidget {
  final Citizen citizen;
  final bool isAuthenticated;

  const _AboutSection({
    required this.citizen,
    required this.isAuthenticated,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'সম্পর্কে',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.hLg,
          // Phone row — hidden behind login gate
          if (isAuthenticated)
            _InfoRow(
              icon: Icons.phone_outlined,
              label: 'ফোন',
              value: citizen.phone.isNotEmpty ? citizen.phone : 'উল্লেখ নেই',
            )
          else
            _LockedInfoRow(
              icon: Icons.phone_outlined,
              label: 'ফোন',
            ),
          _InfoDivider(),
          _InfoRow(icon: Icons.email_outlined, label: 'ইমেইল', value: 'rahim@grambashi.com'),
          _InfoDivider(),
          _InfoRow(icon: Icons.location_on_outlined, label: 'ঠিকানা', value: citizen.village.isNotEmpty ? citizen.village : 'উল্লেখ নেই'),
          _InfoDivider(),
          _InfoRow(icon: Icons.calendar_month_outlined, label: 'সদস্য হন', value: '১৫ জানুয়ারি ২০২৪'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
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
        Column(
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
      ],
    );
  }
}

/// Shows a locked phone row with a login prompt on tap.
class _LockedInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _LockedInfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showLoginPrompt(
        context,
        reason: 'ফোন নম্বর দেখতে লগইন করুন',
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.textTertiary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: 18, color: context.textTertiary),
          ),
          AppSpacing.wMd,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.textSecondary,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.lock_outline_rounded, size: 13, color: context.textTertiary),
                  AppSpacing.wXs,
                  Text(
                    'লগইন করুন',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.textTertiary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Container(
        height: 1,
        color: context.isDark ? AppColors.darkDivider : AppColors.lightDivider,
      ),
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'সাম্প্রতিক কার্যক্রম',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.hMd,
          TimelineItem(
            title: 'দান করেছেন ৫,০০০ টাকা',
            description: 'গ্রামের মসজিদ তহবিলে দান',
            icon: Icons.volunteer_activism_outlined,
            iconColor: AppColors.success,
            isCompleted: true,
          ),
          TimelineItem(
            title: 'রাস্তা মেরামত প্রকল্প',
            description: 'উত্তর গ্রামের রাস্তা মেরামতে অংশগ্রহণ',
            icon: Icons.construction_outlined,
            iconColor: AppColors.info,
            isCompleted: true,
          ),
          TimelineItem(
            title: 'নলকূপ সংকট রিপোর্ট',
            description: 'দক্ষিণ পাড়ার নলকূপ নষ্ট হওয়ার রিপোর্ট',
            icon: Icons.report_outlined,
            iconColor: AppColors.warning,
            isCompleted: true,
          ),
          TimelineItem(
            title: 'বৃক্ষরোপণ কর্মসূচি',
            description: '৫০টি চারা রোপণে স্বেচ্ছাসেবক',
            icon: Icons.forest_outlined,
            iconColor: AppColors.primary,
            isCompleted: false,
          ),
        ],
      ),
    );
  }
}
