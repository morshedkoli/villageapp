import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';

/// Confirms the donation was submitted and returns to the previous screen.
///
/// The donation is still `Pending` at this point — the copy says so, because
/// the village fund is only credited once an admin approves it in the panel.
Future<void> showDonationSuccessDialog(
  BuildContext context, {
  required String amount,
  required String paymentType,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SuccessBadge(),
          AppSpacing.hLg,
          Text(
            'দান সফলভাবে জমা হয়েছে!',
            style: context.textTheme.titleLarge?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.hSm,
          Text(
            'অ্যাডমিন যাচাই করার পর আপনার দান অনুমোদিত হবে',
            style: context.textTheme.bodySmall
                ?.copyWith(color: context.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (amount.isNotEmpty) ...[
            AppSpacing.hMd,
            Text(
              '৳$amount',
              style: context.textTheme.headlineSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'via $paymentType',
              style: context.textTheme.bodySmall
                  ?.copyWith(color: context.textSecondary),
            ),
          ],
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.pop();
            },
            child: const Text('ঠিক আছে'),
          ),
        ),
      ],
    ),
  );
}

class _SuccessBadge extends StatelessWidget {
  const _SuccessBadge();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, value, child) => Transform.scale(
        scale: value,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            size: 48,
            color: AppColors.success,
          ),
        ),
      ),
    );
  }
}
