import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/motion.dart';
import '../../core/widgets/glass_card.dart';
import '../../data_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _loading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      await DataService.instance.signInWithGoogle();
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('লগইন ব্যর্থ হয়েছে: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showPhoneSheet() {
    final phoneController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xxxl),
          topRight: Radius.circular(AppRadius.xxxl),
        ),
      ),
      builder: (ctx) {
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxl, bottom + AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              AppSpacing.hXxl,
              Text(
                'ফোন নম্বর লিখুন',
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.hSm,
              Text(
                'আমরা আপনাকে একটি OTP কোড পাঠাব',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.hXxl,
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '০১৭XXXXXXXX',
                  prefixText: '+88 ',
                  prefixStyle: context.textTheme.bodyLarge?.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AppSpacing.hXxl,
              FilledButton(
                onPressed: () {
                  final phone = phoneController.text.trim();
                  if (phone.isNotEmpty) {
                    Navigator.of(ctx).pop();
                    context.push('/otp', extra: {'phone': phone});
                  }
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text('OTP পাঠান'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppSpacing.hHuge,
              FadeSlideIn(
                delay: 0,
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: context.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.xxl),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.xxl - 1),
                        child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                      ),
                    ),
                    AppSpacing.hLg,
                    Text(
                      'গ্রামবাসী',
                      style: context.textTheme.headlineMedium?.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppSpacing.hSm,
                    Text(
                      'স্বাগতম! আপনার গ্রামের কমিউনিটিতে যোগ দিন',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              AppSpacing.hXxxl,
              FadeSlideIn(
                delay: 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildGoogleButton(),
                    AppSpacing.hMd,
                    _buildPhoneButton(),
                  ],
                ),
              ),
              AppSpacing.hXxxl,
              FadeSlideIn(
                delay: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Divider(color: context.divider)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          child: Text(
                            'গ্রামবাসী কেন?',
                            style: context.textTheme.labelLarge?.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: context.divider)),
                      ],
                    ),
                    AppSpacing.hXxl,
                    _buildBenefit(
                      icon: Icons.account_balance_rounded,
                      title: 'তহবিলের স্বচ্ছতা',
                      subtitle: 'প্রতিটি অনুদান ও ব্যয় রিয়েল-টাইমে ট্র্যাক করুন',
                    ),
                    AppSpacing.hLg,
                    _buildBenefit(
                      icon: Icons.construction_rounded,
                      title: 'উন্নয়ন প্রকল্প',
                      subtitle: 'গ্রামের প্রকল্প ও অগ্রগতি পর্যবেক্ষণ করুন',
                    ),
                    AppSpacing.hLg,
                    _buildBenefit(
                      icon: Icons.people_rounded,
                      title: 'গণতান্ত্রিক অংশগ্রহণ',
                      subtitle: 'সিদ্ধান্ত গ্রহণে সবাইকে সম্পৃক্ত করুন',
                    ),
                    AppSpacing.hLg,
                    _buildBenefit(
                      icon: Icons.notifications_active_rounded,
                      title: 'রিয়েল-টাইম আপডেট',
                      subtitle: 'সকল কার্যকলাপের তাৎক্ষণিক নোটিফিকেশন',
                    ),
                  ],
                ),
              ),
              AppSpacing.hXxxl,
              FadeSlideIn(
                delay: 450,
                child: Text(
                  'চালিয়ে যাওয়ার মাধ্যমে, আপনি আমাদের শর্তাবলী ও গোপনীয়তা নীতিতে সম্মত হচ্ছেন',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              AppSpacing.hXxl,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return PressScale(
      onTap: _loading ? null : _signInWithGoogle,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: context.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.04),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
              height: 20,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.g_mobiledata, size: 28, color: Colors.grey),
            ),
            AppSpacing.wMd,
            Text(
              _loading ? 'অপেক্ষা করুন...' : 'গুগল দিয়ে লগইন করুন',
              style: context.textTheme.labelLarge?.copyWith(
                color: context.textPrimary,
              ),
            ),
            if (_loading) ...[
              AppSpacing.wSm,
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneButton() {
    return PressScale(
      onTap: _showPhoneSheet,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: context.primary,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: context.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_android_rounded, size: 20, color: context.onPrimary),
            AppSpacing.wMd,
            Text(
              'ফোন নম্বর দিয়ে লগইন করুন',
              style: context.textTheme.labelLarge?.copyWith(
                color: context.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefit({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: context.primary, size: 22),
          ),
          AppSpacing.wLg,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.textPrimary,
                  ),
                ),
                AppSpacing.hXs,
                Text(
                  subtitle,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
