import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/motion.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isDarkMode = false;
  bool _pushEnabled = true;
  bool _smsEnabled = false;
  bool _emailEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('সেটিংস'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          FadeSlideIn(
            delay: 0,
            child: SectionHeader(title: 'চেহারা ও ভাষা'),
          ),
          AppSpacing.hMd,
          FadeSlideIn(
            delay: 50,
            child: GlassCard(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    label: 'ডার্ক মোড',
                    trailing: Switch(
                      value: _isDarkMode,
                      onChanged: (v) => setState(() => _isDarkMode = v),
                    ),
                  ),
                  _SettingsDivider(),
                  _SettingsTile(
                    icon: Icons.language_outlined,
                    label: 'ভাষা',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'বাংলা',
                            style: context.textTheme.labelMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          AppSpacing.wXs,
                          Icon(Icons.check, size: 16, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.hXxl,
          FadeSlideIn(
            delay: 100,
            child: SectionHeader(title: 'নোটিফিকেশন'),
          ),
          AppSpacing.hMd,
          FadeSlideIn(
            delay: 150,
            child: GlassCard(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    label: 'পুশ নোটিফিকেশন',
                    trailing: Switch(
                      value: _pushEnabled,
                      onChanged: (v) => setState(() => _pushEnabled = v),
                    ),
                  ),
                  _SettingsDivider(),
                  _SettingsTile(
                    icon: Icons.sms_outlined,
                    label: 'এসএমএস নোটিফিকেশন',
                    trailing: Switch(
                      value: _smsEnabled,
                      onChanged: (v) => setState(() => _smsEnabled = v),
                    ),
                  ),
                  _SettingsDivider(),
                  _SettingsTile(
                    icon: Icons.email_outlined,
                    label: 'ইমেইল নোটিফিকেশন',
                    trailing: Switch(
                      value: _emailEnabled,
                      onChanged: (v) => setState(() => _emailEnabled = v),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.hXxl,
          FadeSlideIn(
            delay: 200,
            child: SectionHeader(title: 'গোপনীয়তা ও নিরাপত্তা'),
          ),
          AppSpacing.hMd,
          FadeSlideIn(
            delay: 250,
            child: GlassCard(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    label: 'গোপনীয়তা নীতি',
                    trailing: Icon(Icons.chevron_right, color: context.textTertiary),
                    onTap: () {},
                  ),
                  _SettingsDivider(),
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    label: 'সেবার শর্তাবলী',
                    trailing: Icon(Icons.chevron_right, color: context.textTertiary),
                    onTap: () {},
                  ),
                  _SettingsDivider(),
                  _SettingsTile(
                    icon: Icons.download_outlined,
                    label: 'ডেটা এক্সপোর্ট',
                    trailing: Icon(Icons.chevron_right, color: context.textTertiary),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ডেটা এক্সপোর্ট শুরু হয়েছে')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.hXxl,
          FadeSlideIn(
            delay: 300,
            child: SectionHeader(title: 'অ্যাপ সম্পর্কে'),
          ),
          AppSpacing.hMd,
          FadeSlideIn(
            delay: 350,
            child: GlassCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Center(
                          child: Text(
                            'গ',
                            style: context.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      AppSpacing.wMd,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'আল ইসলাহ',
                            style: context.textTheme.bodyLarge?.copyWith(
                              color: context.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'ভার্সন ১.০.০',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  AppSpacing.hMd,
                  Container(
                    height: 1,
                    color: context.isDark ? AppColors.darkDivider : AppColors.lightDivider,
                  ),
                  AppSpacing.hMd,
                  Text(
                    'আল ইসলাহ একটি কমিউনিটি প্ল্যাটফর্ম যা গ্রামের মানুষকে '
                    'সংযুক্ত করে, সমস্যা রিপোর্ট করা, প্রকল্পে অংশগ্রহণ এবং '
                    'একে অপরকে সাহায্য করার সুযোগ করে দেয়।',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.hXxl,
          FadeSlideIn(
            delay: 400,
            child: Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('লগআউট'),
                      content: const Text('আপনি কি লগআউট করতে চান?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('বাতিল'),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                          },
                          child: const Text('লগআউট'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('লগআউট'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxxl,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
            ),
          ),
          AppSpacing.hMassive,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            AppSpacing.wMd,
            Expanded(
              child: Text(
                label,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Container(
        height: 1,
        color: context.isDark ? AppColors.darkDivider : AppColors.lightDivider,
      ),
    );
  }
}
