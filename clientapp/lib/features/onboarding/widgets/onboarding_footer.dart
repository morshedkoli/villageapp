import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../onboarding_pages.dart';

const double _buttonHeight = 52;

/// Bottom action area: "next" while stepping through the feature slides, and
/// the permission choice on the final one.
class OnboardingFooter extends StatelessWidget {
  const OnboardingFooter({
    super.key,
    required this.currentPage,
    required this.permissionGranted,
    required this.requestingPermission,
    required this.onNext,
    required this.onRequestPermission,
    required this.onFinish,
  });

  final int currentPage;
  final bool permissionGranted;
  final bool requestingPermission;
  final VoidCallback onNext;
  final VoidCallback onRequestPermission;
  final VoidCallback onFinish;

  bool get _isLastPage => currentPage == kOnboardingPageCount - 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: _buttonHeight,
            child: _isLastPage
                ? _PermissionActions(
                    granted: permissionGranted,
                    requesting: requestingPermission,
                    onRequestPermission: onRequestPermission,
                    onFinish: onFinish,
                  )
                : _NextButton(onPressed: onNext),
          ),
          if (!_isLastPage) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                '${currentPage + 1} / $kOnboardingPageCount',
                style: TextStyle(
                  fontSize: 12,
                  color: context.textTertiary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: _primaryStyle(context),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'পরবর্তী',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 6),
          Icon(Icons.arrow_forward_rounded, size: 18),
        ],
      ),
    );
  }
}

class _PermissionActions extends StatelessWidget {
  const _PermissionActions({
    required this.granted,
    required this.requesting,
    required this.onRequestPermission,
    required this.onFinish,
  });

  final bool granted;
  final bool requesting;
  final VoidCallback onRequestPermission;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    if (granted) {
      return FilledButton(
        onPressed: onFinish,
        style: _primaryStyle(context),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'শুরু করুন',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            // Declining is still a way through onboarding, not a dead end.
            onPressed: requesting ? null : onFinish,
            style: OutlinedButton.styleFrom(
              foregroundColor: context.textSecondary,
              backgroundColor: context.surface,
              side: BorderSide(color: context.border, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              minimumSize: const Size.fromHeight(_buttonHeight),
            ),
            child: const Text(
              'পরে হবে',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton(
            onPressed: requesting ? null : onRequestPermission,
            style: FilledButton.styleFrom(
              backgroundColor: context.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: context.primary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              minimumSize: const Size.fromHeight(_buttonHeight),
              elevation: 0,
            ),
            child: requesting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'অনুমতি দিন',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

ButtonStyle _primaryStyle(BuildContext context) {
  return FilledButton.styleFrom(
    backgroundColor: context.primary,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    elevation: 0,
  );
}
