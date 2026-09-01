import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/avatar_widget.dart';
import '../../core/widgets/motion.dart';
import '../../core/widgets/login_prompt.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_shimmer.dart';
import '../../core/providers/providers.dart';
import '../../models.dart';

Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
  final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
  if (cleanNumber.isEmpty) return;
  final uri = Uri.parse('tel:$cleanNumber');
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('কল সংযোগ করা সম্ভব হচ্ছে না')),
        );
      }
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('কল সংযোগ করা সম্ভব হচ্ছে না')),
      );
    }
  }
}

Future<void> _sendSms(BuildContext context, String phoneNumber) async {
  final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
  if (cleanNumber.isEmpty) return;
  final uri = Uri.parse('sms:$cleanNumber');
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('বার্তা পাঠানো সম্ভব হচ্ছে না')),
        );
      }
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('বার্তা পাঠানো সম্ভব হচ্ছে না')),
      );
    }
  }
}

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
        .when(data: (v) => v, error: (_, __) => false, loading: () => false);

    return Scaffold(
      backgroundColor: context.canvas,
      appBar: AppBar(
        title: const Text('নাগরিক প্রোফাইল'),
      ),
      body: citizensAsync.when(
        loading: () => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: const [
              CardSkeleton(height: 200),
              SizedBox(height: AppSpacing.lg),
              CardSkeleton(height: 160),
            ],
          ),
        ),
        error: (err, stack) => Center(
          child: EmptyState(
            icon: Icons.error_outline_rounded,
            title: 'তথ্য লোড করা যায়নি',
            subtitle: 'ইন্টারনেট সংযোগ চেক করে পুনরায় চেষ্টা করুন',
            actionLabel: 'পুনরায় চেষ্টা করুন',
            onAction: () => ref.invalidate(citizensProvider),
          ),
        ),
        data: (citizens) {
          final citizen = citizens.where((c) => c.id == widget.citizenId).firstOrNull;
          if (citizen == null) {
            return const Center(
              child: EmptyState(
                icon: Icons.person_off_outlined,
                title: 'নাগরিক পাওয়া যায়নি',
                description: 'এই নাগরিকের কোনো তথ্য সিস্টেমে নেই',
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.massive,
            ),
            children: [
              FadeSlideIn(
                delay: 0,
                child: _ProfileHeader(
                  citizen: citizen,
                  isAuthenticated: isAuthenticated,
                ),
              ),
              AppSpacing.hLg,
              FadeSlideIn(
                delay: 100,
                child: _AboutSection(
                  citizen: citizen,
                  isAuthenticated: isAuthenticated,
                ),
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
  final bool isAuthenticated;

  const _ProfileHeader({
    required this.citizen,
    required this.isAuthenticated,
  });

  @override
  Widget build(BuildContext context) {
    final initials = citizen.name.isNotEmpty ? citizen.name.characters.first : '?';
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          AvatarWidget(
            initials: initials,
            size: 84,
            showOnline: false,
          ),
          AppSpacing.hLg,
          Text(
            citizen.name,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.hXs,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              citizen.profession.isNotEmpty ? citizen.profession : 'নাগরিক',
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
                citizen.village.isNotEmpty ? citizen.village : 'গ্রাম উল্লেখ নেই',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
          AppSpacing.hLg,
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    if (isAuthenticated) {
                      _makePhoneCall(context, citizen.phone);
                    } else {
                      showLoginPrompt(
                        context,
                        reason: 'কল করতে লগইন করুন',
                        onSuccess: () => _makePhoneCall(context, citizen.phone),
                      );
                    }
                  },
                  icon: const Icon(Icons.phone_outlined, size: 18),
                  label: const Text('কল করুন'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
              ),
              AppSpacing.wMd,
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (isAuthenticated) {
                      _sendSms(context, citizen.phone);
                    } else {
                      showLoginPrompt(
                        context,
                        reason: 'বার্তা পাঠাতে লগইন করুন',
                        onSuccess: () => _sendSms(context, citizen.phone),
                      );
                    }
                  },
                  icon: const Icon(Icons.message_outlined, size: 18),
                  label: const Text('বার্তা'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'বিস্তারিত তথ্য',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.hLg,
          if (isAuthenticated)
            _InfoRow(
              icon: Icons.phone_outlined,
              label: 'ফোন নম্বর',
              value: citizen.phone.isNotEmpty ? citizen.phone : 'উল্লেখ নেই',
              isActionable: citizen.phone.isNotEmpty,
              onTap: () => _makePhoneCall(context, citizen.phone),
            )
          else
            _LockedInfoRow(
              icon: Icons.phone_outlined,
              label: 'ফোন নম্বর',
            ),
          const Divider(height: AppSpacing.xl),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'ঠিকানা ও গ্রাম',
            value: citizen.village.isNotEmpty ? citizen.village : 'উল্লেখ নেই',
          ),
          if (citizen.address.isNotEmpty) ...[
            const Divider(height: AppSpacing.xl),
            _InfoRow(
              icon: Icons.home_outlined,
              label: 'বিস্তারিত ঠিকানা',
              value: citizen.address,
            ),
          ],
          if (citizen.profession.isNotEmpty) ...[
            const Divider(height: AppSpacing.xl),
            _InfoRow(
              icon: Icons.work_outline_rounded,
              label: 'পেশা',
              value: citizen.profession,
            ),
          ],
          if (citizen.bloodGroup.isNotEmpty) ...[
            const Divider(height: AppSpacing.xl),
            _InfoRow(
              icon: Icons.bloodtype_outlined,
              label: 'রক্তের গ্রুপ',
              value: citizen.bloodGroup,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isActionable;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isActionable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: context.isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
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
              const SizedBox(height: 2),
              Text(
                value,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isActionable ? AppColors.primary : context.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (isActionable)
          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: context.textTertiary),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: row,
        ),
      );
    }
    return row;
  }
}

class _LockedInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _LockedInfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showLoginPrompt(
        context,
        reason: 'ফোন নম্বর দেখতে লগইন করুন',
      ),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.textTertiary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, size: 20, color: context.textTertiary),
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
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.lock_outline_rounded, size: 13, color: context.textTertiary),
                      AppSpacing.wXs,
                      Text(
                        'লগইন করুন (গোপনীয়)',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.textTertiary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

