// Bottom sheet card holding the sign-in methods.

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/motion.dart';
import 'login_forms.dart';

class LoginCard extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChange;
  final bool loading;
  final bool obscurePassword;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final FocusNode phoneFocus;
  final FocusNode passwordFocus;
  final VoidCallback onTogglePassword;
  final VoidCallback onPhoneLogin;
  final VoidCallback onGoogleLogin;

  const LoginCard({super.key, 
    required this.selectedTab,
    required this.onTabChange,
    required this.loading,
    required this.obscurePassword,
    required this.phoneController,
    required this.passwordController,
    required this.phoneFocus,
    required this.passwordFocus,
    required this.onTogglePassword,
    required this.onPhoneLogin,
    required this.onGoogleLogin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return FadeSlideIn(
      delay: 380,
      offset: 30,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xxxl),
            topRight: Radius.circular(AppRadius.xxxl),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.10),
              blurRadius: 40,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.xxl,
            right: AppSpacing.xxl,
            top: AppSpacing.xxl,
            bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),

              // Heading
              Text(
                'লগইন করুন',
                style: context.textTheme.headlineSmall?.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              AppSpacing.hXs,
              Text(
                'আপনার অ্যাকাউন্টে প্রবেশ করুন',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.textSecondary,
                ),
              ),

              AppSpacing.hXxl,

              // Segmented tab switcher
              _SegmentedSwitcher(
                selected: selectedTab,
                onSelect: onTabChange,
              ),

              AppSpacing.hXxl,

              // Animated tab content
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: selectedTab == 0
                    ? PhoneForm(
                        key: const ValueKey('phone'),
                        phoneController: phoneController,
                        passwordController: passwordController,
                        phoneFocus: phoneFocus,
                        passwordFocus: passwordFocus,
                        obscurePassword: obscurePassword,
                        onTogglePassword: onTogglePassword,
                        onLogin: onPhoneLogin,
                        loading: loading,
                      )
                    : GoogleForm(
                        key: const ValueKey('google'),
                        onLogin: onGoogleLogin,
                        loading: loading,
                      ),
              ),

              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md),
                      child: Text(
                        selectedTab == 0 ? 'অথবা' : 'অথবা',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.textTertiary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
              ),

              // Alternate sign-in option
              if (selectedTab == 0)
                GoogleQuickButton(onTap: onGoogleLogin, loading: loading)
              else
                PhoneQuickButton(
                  onTap: () => onTabChange(0),
                ),

              AppSpacing.hXl,

              // Terms
              Text(
                'লগইন করার মাধ্যমে আপনি আমাদের ব্যবহারের শর্তাবলী ও গোপনীয়তা নীতিতে সম্মত হচ্ছেন।',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.textTertiary,
                  fontSize: 11,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SegmentedSwitcher extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  const _SegmentedSwitcher({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final tabs = [
      (Icons.phone_android_rounded, 'ফোন নম্বর'),
      (Icons.g_mobiledata, 'Google'),
    ];

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCanvas,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final i = entry.key;
          final (icon, label) = entry.value;
          final isActive = selected == i;

          return Expanded(
            child: PressScale(
              scale: 0.96,
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: isActive ? Colors.white : context.textSecondary,
                    ),
                    AppSpacing.wXs,
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}


