// The two sign-in methods offered inside the login card.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/motion.dart';
import 'login_controls.dart';

class PhoneForm extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final FocusNode phoneFocus;
  final FocusNode passwordFocus;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;
  final bool loading;

  const PhoneForm({
    super.key,
    required this.phoneController,
    required this.passwordController,
    required this.phoneFocus,
    required this.passwordFocus,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onLogin,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Phone field
        FieldLabel(label: 'ফোন নম্বর'),
        AppSpacing.hXs,
        StyledTextField(
          controller: phoneController,
          focusNode: phoneFocus,
          hint: '01XXXXXXXXX',
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.next,
          onEditingComplete: () => passwordFocus.requestFocus(),
          prefix: Container(
            margin: const EdgeInsets.only(left: 14, right: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bangladesh flag emoji
                const Text('🇧🇩', style: TextStyle(fontSize: 16)),
                AppSpacing.wXs,
                Text(
                  '+880',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.textSecondary,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 1,
                  height: 18,
                  color: context.border,
                ),
              ],
            ),
          ),
        ),

        AppSpacing.hLg,

        // Password field
        FieldLabel(label: 'পাসওয়ার্ড'),
        AppSpacing.hXs,
        StyledTextField(
          controller: passwordController,
          focusNode: passwordFocus,
          hint: '••••••••',
          obscureText: obscurePassword,
          textInputAction: TextInputAction.done,
          onEditingComplete: loading ? null : onLogin,
          prefixIcon: Icons.lock_outline_rounded,
          suffix: GestureDetector(
            onTap: onTogglePassword,
            child: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Icon(
                obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: context.textTertiary,
              ),
            ),
          ),
        ),

        AppSpacing.hXxl,

        // Login button
        PrimaryButton(
          label: 'লগইন করুন',
          icon: Icons.arrow_forward_rounded,
          loading: loading,
          onTap: loading ? null : onLogin,
        ),
      ],
    );
  }
}

class GoogleForm extends StatelessWidget {
  final VoidCallback onLogin;
  final bool loading;

  const GoogleForm({super.key, required this.onLogin, required this.loading});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Illustration / info box
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.05),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              AppSpacing.wMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'নিরাপদ সাইন-ইন',
                      style: context.textTheme.labelLarge?.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppSpacing.hXs,
                    Text(
                      'আপনার Google অ্যাকাউন্ট দিয়ে তাৎক্ষণিকভাবে যোগ দিন।',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        AppSpacing.hXxl,

        // Google button
        PressScale(
          onTap: loading ? null : onLogin,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 54,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.primary,
                    ),
                  )
                else
                  Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                    height: 22,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.g_mobiledata, size: 28, color: AppColors.primary),
                  ),
                AppSpacing.wMd,
                Text(
                  loading ? 'অপেক্ষা করুন...' : 'Google দিয়ে লগইন করুন',
                  style: context.textTheme.labelLarge?.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class GoogleQuickButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool loading;
  const GoogleQuickButton({super.key, required this.onTap, required this.loading});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return PressScale(
      onTap: loading ? null : onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCanvas,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
              height: 18,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.g_mobiledata, size: 22, color: AppColors.primary),
            ),
            AppSpacing.wSm,
            Text(
              'Google দিয়ে লগইন করুন',
              style: context.textTheme.labelMedium?.copyWith(
                color: context.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PhoneQuickButton extends StatelessWidget {
  final VoidCallback onTap;
  const PhoneQuickButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: context.isDark ? AppColors.darkCard : AppColors.lightCanvas,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: context.isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phone_android_rounded,
                size: 18, color: AppColors.primary),
            AppSpacing.wSm,
            Text(
              'ফোন নম্বর দিয়ে লগইন করুন',
              style: context.textTheme.labelMedium?.copyWith(
                color: context.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
