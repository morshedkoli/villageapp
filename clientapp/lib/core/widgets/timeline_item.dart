import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

/// ──────────────────────────────────────────────
///  TimelineItem — activity feed row
///  Design: Rounded icon · Subtle separator line ·
///          Clean 3-line layout · Token colors only
/// ──────────────────────────────────────────────
class TimelineItem extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final Color? iconColor;
  final DateTime? timestamp;
  final bool isCompleted;
  final Widget? trailing;

  const TimelineItem({
    super.key,
    required this.title,
    this.description,
    required this.icon,
    this.iconColor,
    this.timestamp,
    this.isCompleted = false,
    this.trailing,
  });

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'এখনই';
    if (diff.inMinutes < 60) return '${diff.inMinutes} মি. আগে';
    if (diff.inHours < 24) return '${diff.inHours} ঘণ্টা আগে';
    if (diff.inDays < 7) return '${diff.inDays} দিন আগে';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final ic = iconColor ?? AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: ic.withValues(alpha: context.isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, size: 18, color: ic),
          ),
          const SizedBox(width: AppSpacing.md),

          // Text column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: context.textTheme.labelLarge?.copyWith(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isCompleted) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: AppColors.success,
                      ),
                    ],
                  ],
                ),
                if (description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    description!,
                    style: AppTypography.caption.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
                if (timestamp != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    _formatTime(timestamp!),
                    style: AppTypography.caption.copyWith(
                      color: context.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );
  }
}
