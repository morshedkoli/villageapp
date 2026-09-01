import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';

/// Final onboarding slide, asking for notification permission and previewing
/// the kind of updates the app sends.
class NotificationPermissionPage extends StatelessWidget {
  const NotificationPermissionPage({super.key, required this.granted});

  final bool granted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 1),
          _PermissionBadge(granted: granted),
          const SizedBox(height: 36),
          Text(
            granted ? 'নোটিফিকেশন সক্রিয়' : 'আপডেট থাকুন',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
              letterSpacing: -0.4,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            granted
                ? 'আপনি নতুন অনুদান, প্রকল্প আপডেট এবং কমিউনিটি সতর্কতার জন্য নোটিফিকেশন পাবেন।'
                : 'গ্রামের তহবিল আপডেট, নতুন অনুদান, উন্নয়ন প্রকল্প এবং কমিউনিটি সতর্কতা সম্পর্কে নোটিফিকেশন পান।',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: context.textSecondary,
              height: 1.55,
            ),
          ),
          if (!granted) ...[
            const SizedBox(height: 28),
            const _NotificationPreview(),
          ],
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _PermissionBadge extends StatelessWidget {
  const _PermissionBadge({required this.granted});

  final bool granted;

  @override
  Widget build(BuildContext context) {
    final accent = granted ? context.success : context.primary;

    return SizedBox(
      width: 132,
      height: 132,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              color: granted
                  ? context.success.withValues(alpha: 0.10)
                  : context.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: accent.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Icon(
              granted
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_rounded,
              color: accent,
              size: 56,
            ),
          ),
          if (granted)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: context.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.surface, width: 3),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Sample notifications shown so the reader knows what they are opting into.
class _NotificationPreview extends StatelessWidget {
  const _NotificationPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.border, width: 1),
      ),
      child: Column(
        children: [
          _NotificationPreviewRow(
            icon: Icons.volunteer_activism_rounded,
            color: context.success,
            title: 'নতুন অনুদান',
            subtitle: 'রহিম ৳৫,০০০ অনুদান দিয়েছেন',
          ),
          Divider(color: context.divider, height: 18, thickness: 1),
          _NotificationPreviewRow(
            icon: Icons.construction_rounded,
            color: context.info,
            title: 'প্রকল্প আপডেট',
            subtitle: 'রাস্তা মেরামত ৭০% সম্পূর্ণ',
          ),
        ],
      ),
    );
  }
}

class _NotificationPreviewRow extends StatelessWidget {
  const _NotificationPreviewRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: TextStyle(color: context.textTertiary, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
