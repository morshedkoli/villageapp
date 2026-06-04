import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Status states used across problem reports and donations
enum BadgeStatus {
  pending,
  inProgress,
  approved,
  resolved,
  rejected,
  info;

  Color get color {
    return switch (this) {
      pending    => AppColors.warning,
      inProgress => AppColors.info,
      approved   => AppColors.success,
      resolved   => AppColors.success,
      rejected   => AppColors.error,
      info       => AppColors.info,
    };
  }

  Color get background {
    return switch (this) {
      pending    => AppColors.warningContainer,
      inProgress => AppColors.infoContainer,
      approved   => AppColors.successContainer,
      resolved   => AppColors.successContainer,
      rejected   => AppColors.errorContainer,
      info       => AppColors.infoContainer,
    };
  }

  IconData get icon {
    return switch (this) {
      pending    => Icons.schedule_rounded,
      inProgress => Icons.sync_rounded,
      approved   => Icons.check_circle_rounded,
      resolved   => Icons.verified_rounded,
      rejected   => Icons.cancel_rounded,
      info       => Icons.info_rounded,
    };
  }

  String get labelBn {
    return switch (this) {
      pending    => 'বিচারাধীন',
      inProgress => 'প্রক্রিয়াধীন',
      approved   => 'অনুমোদিত',
      resolved   => 'সমাধানকৃত',
      rejected   => 'বাতিল',
      info       => 'তথ্য',
    };
  }
}

/// ──────────────────────────────────────────────
///  StatusBadge — compact semantic pill chip
///  Design: Pill shape · Soft tinted background ·
///          Matching icon + Bengali label · No border
/// ──────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final BadgeStatus status;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12,
    this.padding,
  });

  factory StatusBadge.fromString(String text, {double fontSize = 12}) {
    final s = text.toLowerCase().replaceAll(' ', '');
    final status = s.contains('pending') || s.contains('বিচার')
        ? BadgeStatus.pending
        : s.contains('progress') || s.contains('প্রক্রিয়')
            ? BadgeStatus.inProgress
            : s.contains('approved') || s.contains('অনুমোদ')
                ? BadgeStatus.approved
                : s.contains('resolved') || s.contains('সমাধান')
                    ? BadgeStatus.resolved
                    : s.contains('rejected') || s.contains('বাতিল')
                        ? BadgeStatus.rejected
                        : BadgeStatus.info;
    return StatusBadge(status: status, fontSize: fontSize);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: fontSize + 2,
            vertical: fontSize * 0.42,
          ),
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: fontSize + 1, color: status.color),
          const SizedBox(width: 5),
          Text(
            status.labelBn,
            style: AppTypography.caption.copyWith(
              color: status.color,
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
