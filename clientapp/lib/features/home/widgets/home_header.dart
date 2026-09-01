import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/motion.dart';

/// Time-of-day greeting shown above the community name.
String greetingForHour(int hour) {
  if (hour < 12) return 'শুভ সকাল';
  if (hour < 17) return 'শুভ বিকাল';
  return 'শুভ সন্ধ্যা';
}

/// Greeting, community name, and the notification bell with its unread dot.
class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key, required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentFirebaseUserProvider).asData?.value;
    // Only the first word, so a long legal name does not wrap the greeting.
    final rawName = user?.displayName?.trim() ?? '';
    final firstName = rawName.isEmpty ? null : rawName.split(' ').first;
    final greeting = greetingForHour(DateTime.now().hour);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting${firstName != null ? ', $firstName' : ''} 👋',
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'আল ইসলাহ কমিউনিটি',
                style: AppTypography.sectionTitle.copyWith(
                  color: context.textPrimary,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.wLg,
        _NotificationBell(unreadCount: unreadCount),
      ],
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: () => context.go('/notifications'),
      scale: 0.93,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: context.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Icon(
                Icons.notifications_outlined,
                size: 22,
                color: context.textPrimary,
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.surface, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
