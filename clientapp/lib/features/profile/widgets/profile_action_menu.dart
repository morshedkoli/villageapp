// Navigation and account actions listed below the profile header.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../services/auth_service.dart';

class ActionMenu extends ConsumerWidget {
  const ActionMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiles = [
      _TileData(Icons.volunteer_activism_outlined, 'আমার দান', AppColors.success, () => context.push('/all-donations')),
      _TileData(Icons.report_outlined, 'আমার রিপোর্ট', AppColors.warning, () => context.push('/problems')),
      _TileData(Icons.construction_outlined, 'সব প্রকল্প', AppColors.info, () => context.push('/projects')),
      _TileData(Icons.insert_chart_outlined, 'হিসাব ও প্রতিবেদন', AppColors.accentTerracotta, () => context.push('/reports')),
      _TileData(Icons.settings_outlined, 'সেটিংস', context.textSecondary, () => context.push('/settings')),
      _TileData(Icons.logout_rounded, 'লগআউট', AppColors.error, () => _confirmSignOut(context, ref)),
    ];

    return Column(
      children: tiles.indexed
          .map((entry) => Padding(
                padding: EdgeInsets.only(bottom: entry.$1 < tiles.length - 1 ? AppSpacing.sm : 0),
                child: _ActionTile(data: entry.$2),
              ))
          .toList(),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: const Text('লগআউট'),
        content: const Text('আপনি কি সত্যিই লগআউট করতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.instance.signOut();
            },
            child: const Text('লগআউট'),
          ),
        ],
      ),
    );
  }
}

class _TileData {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _TileData(this.icon, this.label, this.color, this.onTap);
}

class _ActionTile extends StatelessWidget {
  final _TileData data;
  const _ActionTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final isDestructive = data.color == AppColors.error;
    return GlassCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
      onTap: data.onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: isDestructive ? 0.08 : 0.10),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(data.icon, size: 22, color: data.color),
          ),
          AppSpacing.wMd,
          Expanded(
            child: Text(
              data.label,
              style: context.textTheme.bodyMedium?.copyWith(
                color: isDestructive ? AppColors.error : context.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              size: 20,
              color: isDestructive ? AppColors.error.withValues(alpha: 0.5) : context.textTertiary),
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        AppSpacing.wSm,
        Text(
          text,
          style: context.textTheme.titleSmall?.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
