import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../onboarding_pages.dart';

/// Segmented progress bar plus the skip action, shown above the slides.
class OnboardingProgress extends StatelessWidget {
  const OnboardingProgress({
    super.key,
    required this.currentPage,
    required this.onSkip,
  });

  final int currentPage;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                for (var i = 0; i < kOnboardingPageCount; i++)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      margin: EdgeInsets.only(
                        right: i == kOnboardingPageCount - 1 ? 0 : 6,
                      ),
                      height: 3,
                      decoration: BoxDecoration(
                        color: i <= currentPage
                            ? context.primary
                            : context.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              foregroundColor: context.textTertiary,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'এড়িয়ে যান',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
