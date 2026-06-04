import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/motion.dart';
import '../../data_service.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final readIdsAsync = ref.watch(notificationReadIdsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('বিজ্ঞপ্তি'),
        actions: [
          TextButton(
            onPressed: () async {
              final notifications = notificationsAsync.asData?.value;
              if (notifications == null || notifications.isEmpty) {
                return;
              }
              await DataService.instance.markAllNotificationsRead(
                notifications.map((item) => item.id),
              );
            },
            child: const Text('সব পড়া হয়েছে'),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        child: notificationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('ত্রুটি: $e')),
          data: (notifications) {
            final readIds = readIdsAsync.asData?.value ?? <String>{};
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxxl,
              ),
              itemCount: notifications.length,
              separatorBuilder: (_, _) => AppSpacing.hMd,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final isUnread = !readIds.contains(notification.id);
                final icon = _iconForType(notification.type);
                final iconColor = _colorForType(context, notification.type);
                final time = _formatTime(notification.createdAt);

                return FadeSlideIn(
                  delay: index * 50,
                  child: PressScale(
                    scale: 0.98,
                    onTap: () async {
                      if (isUnread) {
                        await DataService.instance
                            .markNotificationRead(notification.id);
                      }
                    },
                    child: GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 6, right: 12),
                              decoration: BoxDecoration(
                                color: context.primary,
                                shape: BoxShape.circle,
                              ),
                            )
                          else
                            const SizedBox(width: 20),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: iconColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Icon(
                              icon,
                              size: 22,
                              color: iconColor,
                            ),
                          ),
                          AppSpacing.wMd,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.title,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: isUnread
                                        ? context.textPrimary
                                        : context.textSecondary,
                                    fontWeight: isUnread
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                                AppSpacing.hXs,
                                Text(
                                  notification.body,
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: isUnread
                                        ? context.textSecondary
                                        : context.textTertiary,
                                  ),
                                ),
                                AppSpacing.hXs,
                                Text(
                                  time,
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: context.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'donation':
        return Icons.volunteer_activism_outlined;
      case 'project':
        return Icons.construction_outlined;
      case 'problem':
        return Icons.report_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _colorForType(BuildContext context, String type) {
    switch (type) {
      case 'donation':
        return context.success;
      case 'project':
        return context.info;
      case 'problem':
        return context.warning;
      default:
        return context.primary;
    }
  }

  String _formatTime(DateTime createdAt) {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return 'এইমাত্র';
    if (diff.inMinutes < 60) return '${diff.inMinutes} মিনিট আগে';
    if (diff.inHours < 24) return '${diff.inHours} ঘণ্টা আগে';
    if (diff.inDays < 30) return '${diff.inDays} দিন আগে';
    return '${(diff.inDays / 30).floor()} মাস আগে';
  }
}
