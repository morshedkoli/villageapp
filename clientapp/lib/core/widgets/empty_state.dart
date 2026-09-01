import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// ──────────────────────────────────────────────
///  EmptyState — zero-data / error placeholder
///  Premium design: Tinted icon container,
///  clean vertical rhythm, optional CTA button
/// ──────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  String? get _effectiveDescription => description ?? subtitle;

  @override
  Widget build(BuildContext context) {
    final ic = iconColor ?? AppColors.primary;
    final desc = _effectiveDescription;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.xxxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: ic.withValues(alpha: context.isDark ? 0.14 : 0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: ic.withValues(alpha: context.isDark ? 0.22 : 0.12),
                  width: 1.5,
                ),
              ),
              child: Icon(icon, size: 38, color: ic),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            if (desc != null && desc.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Text(
                  desc,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Backward compatibility alias
typedef EmptyStateWidget = EmptyState;

