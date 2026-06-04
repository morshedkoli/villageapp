import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../../data_service.dart';

/// Shows a bottom sheet asking the user to log in.
/// [onSuccess] is called after a successful sign-in.
Future<void> showLoginPrompt(
  BuildContext context, {
  String? reason,
  VoidCallback? onSuccess,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _LoginPromptSheet(reason: reason, onSuccess: onSuccess),
  );
}

class _LoginPromptSheet extends StatefulWidget {
  final String? reason;
  final VoidCallback? onSuccess;

  const _LoginPromptSheet({this.reason, this.onSuccess});

  @override
  State<_LoginPromptSheet> createState() => _LoginPromptSheetState();
}

class _LoginPromptSheetState extends State<_LoginPromptSheet> {
  bool _loading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      await DataService.instance.signInWithGoogle();
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onSuccess?.call();
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

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.xxl + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xxxl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 32,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.textTertiary.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          AppSpacing.hXxl,
          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.xxl),
            ),
            child: const Icon(
              Icons.lock_person_rounded,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          AppSpacing.hLg,
          Text(
            'লগইন প্রয়োজন',
            style: context.textTheme.titleLarge?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.hSm,
          Text(
            widget.reason ?? 'এই সুবিধাটি ব্যবহার করতে লগইন করুন',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.hXxl,
          // Google Sign-In button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _signInWithGoogle,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.darkCard : Colors.white,
                foregroundColor: context.textPrimary,
                elevation: 0,
                side: BorderSide(color: context.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              icon: _loading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                      height: 20,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.g_mobiledata, size: 24),
                    ),
              label: Text(
                _loading ? 'অপেক্ষা করুন...' : 'গুগল দিয়ে লগইন করুন',
                style: context.textTheme.labelLarge?.copyWith(
                  color: context.textPrimary,
                ),
              ),
            ),
          ),
          AppSpacing.hMd,
          // Full login page button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _loading
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      context.push('/login');
                    },
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: const Text(
                'লগইন পেজে যান',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
