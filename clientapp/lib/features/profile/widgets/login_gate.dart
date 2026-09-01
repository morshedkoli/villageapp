// Shown in place of the profile when nobody is signed in.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/motion.dart';
import '../../../services/auth_service.dart';

class LoginGate extends StatefulWidget {
  const LoginGate({super.key});

  @override
  State<LoginGate> createState() => LoginGateState();
}

class LoginGateState extends State<LoginGate> {
  bool _loading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      await AuthService.instance.signInWithGoogle();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('লগইন ব্যর্থ: ${e.toString()}'),
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Gradient background ──────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [AppColors.darkCanvas, AppColors.darkSurface, AppColors.darkCanvas]
                    : [AppColors.primaryContainer, Colors.white, Colors.white],
                stops: const [0, 0.45, 1],
              ),
            ),
          ),

          // ── Decorative circles ────────────────────────────────────
          Positioned(
            top: -60,
            right: -60,
            child: _GlowCircle(size: 220, color: AppColors.primary, opacity: isDark ? 0.08 : 0.12),
          ),
          Positioned(
            top: 80,
            left: -40,
            child: _GlowCircle(size: 140, color: AppColors.primaryLight, opacity: isDark ? 0.06 : 0.10),
          ),

          // ── Content ───────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.08),

                  // Village icon
                  FadeSlideIn(
                    delay: 0,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primaryLight, AppColors.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.xxl),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.holiday_village_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  AppSpacing.hXxl,

                  // Headline
                  FadeSlideIn(
                    delay: 80,
                    child: Text(
                      'আল ইসলাহ-তে স্বাগতম',
                      style: context.textTheme.headlineSmall?.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  AppSpacing.hSm,
                  FadeSlideIn(
                    delay: 130,
                    child: Text(
                      'আপনার প্রোফাইল দেখতে, সমস্যা রিপোর্ট করতে এবং গ্রামের উন্নয়নে অংশ নিতে লগইন করুন।',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.textSecondary,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  AppSpacing.hHuge,

                  // Feature chips
                  FadeSlideIn(
                    delay: 180,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: const [
                        _FeatureChip(icon: Icons.volunteer_activism_outlined, label: 'অনুদান ট্র্যাক'),
                        _FeatureChip(icon: Icons.report_outlined, label: 'সমস্যা রিপোর্ট'),
                        _FeatureChip(icon: Icons.people_alt_outlined, label: 'নাগরিক যোগাযোগ'),
                        _FeatureChip(icon: Icons.emoji_events_outlined, label: 'অর্জন দেখুন'),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Google sign-in button
                  FadeSlideIn(
                    delay: 250,
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _signInWithGoogle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
                          foregroundColor: context.textPrimary,
                          elevation: 0,
                          side: BorderSide(color: context.border, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                          ),
                        ),
                        child: _loading
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.primary,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                                    height: 22,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.g_mobiledata, size: 26, color: AppColors.primary),
                                  ),
                                  AppSpacing.wMd,
                                  Text(
                                    'গুগল দিয়ে লগইন করুন',
                                    style: context.textTheme.labelLarge?.copyWith(
                                      color: context.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  AppSpacing.hMd,

                  // Full login page
                  FadeSlideIn(
                    delay: 300,
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _loading ? null : () => context.push('/login'),
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                          ),
                        ),
                        child: const Text(
                          'লগইন পেজে যান',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.hXxl,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.isDark
            ? AppColors.darkCard
            : AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          AppSpacing.wXs,
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  const _GlowCircle(
      {required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [
          color.withValues(alpha: opacity),
          color.withValues(alpha: 0),
        ]),
      ),
    );
  }
}
