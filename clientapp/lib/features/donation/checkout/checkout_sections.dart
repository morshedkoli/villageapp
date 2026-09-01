import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import 'checkout_amount.dart';

/// Numbered heading introducing a checkout step.
class StepLabel extends StatelessWidget {
  const StepLabel({super.key, required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        AppSpacing.wSm,
        Text(
          label,
          style: context.textTheme.titleSmall?.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Step 2: quick-pick chips plus a free-entry amount field.
class AmountSelection extends StatelessWidget {
  const AmountSelection({
    super.key,
    required this.selectedAmount,
    required this.customAmountController,
    required this.onQuickAmountChanged,
    required this.onCustomAmountChanged,
  });

  final String selectedAmount;
  final TextEditingController customAmountController;

  /// Passes the chosen quick amount, or an empty string when it is cleared.
  final ValueChanged<String> onQuickAmountChanged;
  final ValueChanged<String> onCustomAmountChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final amount in kQuickAmounts)
              _AmountChip(
                amount: amount,
                selected: selectedAmount == amount,
                onSelected: (chosen) =>
                    onQuickAmountChanged(chosen ? amount : ''),
              ),
          ],
        ),
        AppSpacing.hMd,
        TextField(
          controller: customAmountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'অন্য পরিমাণ লিখুন (৳)',
            prefixIcon:
                Icon(Icons.edit_rounded, size: 20, color: context.textTertiary),
          ),
          onChanged: onCustomAmountChanged,
        ),
      ],
    );
  }
}

class _AmountChip extends StatelessWidget {
  const _AmountChip({
    required this.amount,
    required this.selected,
    required this.onSelected,
  });

  final String amount;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text('৳$amount'),
      selected: selected,
      onSelected: onSelected,
      labelStyle: context.textTheme.labelLarge?.copyWith(
        color: selected ? AppColors.primary : context.textSecondary,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      selectedColor: AppColors.primary.withValues(alpha: 0.12),
      backgroundColor:
          context.isDark ? AppColors.darkCard : AppColors.lightCanvas,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
    );
  }
}

/// Step 3: the transaction id and sender number the admin verifies against.
class TransactionInfoFields extends StatelessWidget {
  const TransactionInfoFields({
    super.key,
    required this.transactionIdController,
    required this.senderNumberController,
  });

  final TextEditingController transactionIdController;
  final TextEditingController senderNumberController;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          TextField(
            controller: transactionIdController,
            decoration: InputDecoration(
              hintText: 'ট্রানজেকশন আইডি (Transaction ID)',
              prefixIcon: Icon(Icons.receipt_long_rounded,
                  size: 20, color: context.textTertiary),
            ),
          ),
          AppSpacing.hMd,
          TextField(
            controller: senderNumberController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'প্রেরকের নম্বর (আপনার)',
              prefixIcon: Icon(Icons.phone_rounded,
                  size: 20, color: context.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Optional anonymity toggle and free-text note.
class DonationOptions extends StatelessWidget {
  const DonationOptions({
    super.key,
    required this.isAnonymous,
    required this.onAnonymousChanged,
    required this.noteController,
  });

  final bool isAnonymous;
  final ValueChanged<bool> onAnonymousChanged;
  final TextEditingController noteController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'অতিরিক্ত তথ্য',
          style: context.textTheme.titleSmall?.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        AppSpacing.hMd,
        GlassCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: Text(
                  'বেনামে দান করুন',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'আপনার নাম প্রকাশ করা হবে না',
                  style: context.textTheme.bodySmall
                      ?.copyWith(color: context.textSecondary),
                ),
                value: isAnonymous,
                onChanged: onAnonymousChanged,
                activeTrackColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: TextField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'একটি নোট যোগ করুন (ঐচ্ছিক)',
                    prefixIcon: Icon(Icons.edit_note_outlined,
                        size: 20, color: context.textTertiary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Terms checkbox gating the submit button.
class TermsCheckbox extends StatelessWidget {
  const TermsCheckbox({
    super.key,
    required this.accepted,
    required this.onChanged,
  });

  final bool accepted;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: accepted,
            onChanged: (value) => onChanged(value ?? false),
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
          ),
        ),
        AppSpacing.wSm,
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!accepted),
            child: Text(
              'শর্তাবলী স্বীকার করছি এবং দানের তথ্য সঠিক বলে নিশ্চিত করছি',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SubmitDonationButton extends StatelessWidget {
  const SubmitDonationButton({
    super.key,
    required this.onSubmit,
    required this.isSubmitting,
  });

  /// `null` while the form is incomplete, which disables the button.
  final VoidCallback? onSubmit;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onSubmit,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                'দান নিশ্চিত করুন',
                style: context.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}
