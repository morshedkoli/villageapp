import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/motion.dart';
import 'payment_provider_style.dart';

/// Step 1 of checkout: pick which village account the donation was sent to.
class AccountPicker extends StatelessWidget {
  const AccountPicker({
    super.key,
    required this.accounts,
    required this.selectedId,
    required this.onSelect,
  });

  final List<Map<String, String>> accounts;
  final String? selectedId;
  final ValueChanged<Map<String, String>> onSelect;

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return GlassCard(
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded,
                size: 20, color: context.textSecondary),
            AppSpacing.wSm,
            Expanded(
              child: Text(
                'এখনো কোনো একাউন্ট যোগ করা হয়নি। অ্যাডমিন প্যানেল থেকে একাউন্ট যোগ করুন।',
                style: context.textTheme.bodySmall
                    ?.copyWith(color: context.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final account in accounts)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _AccountTile(
              account: account,
              isSelected: selectedId == account['id'],
              onTap: () => onSelect(account),
            ),
          ),
      ],
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.account,
    required this.isSelected,
    required this.onTap,
  });

  final Map<String, String> account;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final type = account['type'] ?? '';
    final number = account['number'] ?? '';
    final name = account['name'] ?? '';
    final color = providerColor(type);

    return PressScale(
      scale: 0.98,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : context.card,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: isSelected ? color : context.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(providerIcon(type), color: color, size: 22),
            ),
            AppSpacing.wMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: context.textTheme.titleSmall?.copyWith(
                      color: isSelected ? color : context.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name.isNotEmpty ? name : number,
                    style: context.textTheme.bodySmall
                        ?.copyWith(color: context.textSecondary),
                  ),
                  if (name.isNotEmpty)
                    Text(
                      number,
                      style: context.textTheme.labelSmall
                          ?.copyWith(color: context.textTertiary),
                    ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected ? color : context.border,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

/// Account number and payment instructions for the account chosen above.
class SelectedAccountDetail extends StatelessWidget {
  const SelectedAccountDetail({super.key, required this.account});

  final Map<String, String> account;

  @override
  Widget build(BuildContext context) {
    final type = account['type'] ?? '';
    final number = account['number'] ?? '';
    final instructions = account['instructions'] ?? '';
    final bankName = account['bankName'] ?? '';
    final branch = account['branch'] ?? '';
    final color = providerColor(type);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: color),
              AppSpacing.wSm,
              Text(
                '$type একাউন্ট নম্বর',
                style: context.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  number,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: color,
                  minimumSize: const Size(36, 36),
                ),
                icon: const Icon(Icons.copy_rounded,
                    size: 16, color: Colors.white),
                tooltip: 'কপি করুন',
                onPressed: () => _copyNumber(context, number, color),
              ),
            ],
          ),
          if (bankName.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('ব্যাংক: $bankName',
                style: context.textTheme.bodySmall
                    ?.copyWith(color: context.textSecondary)),
          ],
          if (branch.isNotEmpty)
            Text('শাখা: $branch',
                style: context.textTheme.bodySmall
                    ?.copyWith(color: context.textSecondary)),
          if (instructions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              instructions,
              style: context.textTheme.bodySmall
                  ?.copyWith(color: context.textSecondary),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            'উপরের নম্বরে $type করুন, তারপর নিচে ট্রানজেকশন আইডি দিন।',
            style: context.textTheme.bodySmall?.copyWith(
              color: color,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void _copyNumber(BuildContext context, String number, Color color) {
    Clipboard.setData(ClipboardData(text: number));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('নম্বর কপি করা হয়েছে'),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
