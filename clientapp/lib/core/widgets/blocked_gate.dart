import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/auth_service.dart';
import '../providers/providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// Wraps the whole app and replaces it with a lock screen while an admin has
/// the signed-in account blocked (`users/{uid}.blocked == true`).
class BlockedGate extends ConsumerWidget {
  const BlockedGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocked = ref.watch(isBlockedProvider).value ?? false;
    if (!blocked) return child;
    return const _BlockedNotice();
  }
}

class _BlockedNotice extends StatelessWidget {
  const _BlockedNotice();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.canvas,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(AppRadius.xxl),
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    size: 34,
                    color: AppColors.error,
                  ),
                ),
                AppSpacing.hLg,
                Text(
                  'আপনার অ্যাকাউন্ট সাময়িকভাবে বন্ধ',
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.hSm,
                Text(
                  'প্রশাসক আপনার অ্যাকাউন্টটি ব্লক করেছেন। '
                  'বিস্তারিত জানতে গ্রাম কমিটির সাথে যোগাযোগ করুন।',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.textSecondary,
                    height: 1.6,
                  ),
                ),
                AppSpacing.hXl,
                FilledButton(
                  onPressed: () => AuthService.instance.signOut(),
                  child: const Text('সাইন আউট'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
