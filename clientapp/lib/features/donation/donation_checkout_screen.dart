import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/motion.dart';
import '../../core/providers/providers.dart';
import '../../data_service.dart';

class DonationCheckoutScreen extends ConsumerStatefulWidget {
  const DonationCheckoutScreen({super.key});

  @override
  ConsumerState<DonationCheckoutScreen> createState() =>
      _DonationCheckoutScreenState();
}

class _DonationCheckoutScreenState
    extends ConsumerState<DonationCheckoutScreen> {
  // ── Step 1: Account selection ──────────────────────
  Map<String, String>? _selectedAccount;

  // ── Step 2: Amount & details ────────────────────────
  String _selectedAmount = '';
  final _customAmountController = TextEditingController();
  final _trxIdController = TextEditingController();
  final _senderNumberController = TextEditingController();
  bool _isAnonymous = false;
  final _noteController = TextEditingController();
  bool _termsAccepted = false;
  bool _isSubmitting = false;

  final _quickAmounts = ['৫০০', '১,০০০', '২,০০০', '৫,০০০', '১০,০০০'];

  @override
  void dispose() {
    _customAmountController.dispose();
    _trxIdController.dispose();
    _senderNumberController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _accountSelected => _selectedAccount != null;
  bool get _amountEntered =>
      _selectedAmount.isNotEmpty || _customAmountController.text.isNotEmpty;
  bool get _canSubmit =>
      _accountSelected && _amountEntered && _termsAccepted && !_isSubmitting;

  // ── Provider icon / colour ─────────────────────────
  Color _providerColor(String type) {
    switch (type.toLowerCase()) {
      case 'bkash':       return const Color(0xFFE2136E);
      case 'nagad':       return const Color(0xFFFF6B00);
      case 'dutch-bangla':
      case 'dbbl':        return const Color(0xFF00A859);
      case 'rocket':      return const Color(0xFF8B008B);
      default:            return AppColors.primary;
    }
  }

  IconData _providerIcon(String type) {
    switch (type.toLowerCase()) {
      case 'bank':        return Icons.account_balance_rounded;
      default:            return Icons.phone_android_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(donationAccountsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('দান সম্পন্ন করুন')),
      body: SafeArea(
        child: accountsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('ত্রুটি: $e')),
          data: (accounts) {
            final active = accounts
                .where((a) => a['type']?.isNotEmpty == true)
                .toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Step 1 ─────────────────────────
                  FadeSlideIn(
                    delay: 0,
                    child: _buildStepLabel('১', 'একাউন্ট নির্বাচন করুন'),
                  ),
                  AppSpacing.hMd,
                  FadeSlideIn(
                    delay: 50,
                    child: _buildAccountList(active),
                  ),

                  // ── Selected account detail ─────────
                  if (_selectedAccount != null) ...[
                    AppSpacing.hMd,
                    FadeSlideIn(
                      delay: 0,
                      child: _buildSelectedAccountDetail(_selectedAccount!),
                    ),
                  ],

                  AppSpacing.hXxl,

                  // ── Step 2 (only when account selected) ──
                  if (_accountSelected) ...[
                    FadeSlideIn(
                      delay: 80,
                      child: _buildStepLabel('২', 'পরিমাণ নির্বাচন করুন'),
                    ),
                    AppSpacing.hMd,
                    FadeSlideIn(
                      delay: 120,
                      child: _buildAmountSelection(),
                    ),
                    AppSpacing.hXxl,

                    // ── Step 3 ─────────────────────────
                    FadeSlideIn(
                      delay: 160,
                      child: _buildStepLabel('৩', 'লেনদেনের তথ্য'),
                    ),
                    AppSpacing.hMd,
                    FadeSlideIn(
                      delay: 200,
                      child: _buildTransactionInfo(),
                    ),
                    AppSpacing.hXxl,

                    // ── Options ────────────────────────
                    FadeSlideIn(
                      delay: 240,
                      child: _buildOptions(),
                    ),
                    AppSpacing.hXxl,

                    // ── Terms & submit ─────────────────
                    FadeSlideIn(
                      delay: 280,
                      child: _buildTerms(),
                    ),
                    AppSpacing.hXxl,
                    FadeSlideIn(
                      delay: 320,
                      child: _buildSubmitButton(),
                    ),
                  ] else ...[
                    // Prompt when no account selected
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: Text(
                          'দান করতে উপরে একটি একাউন্ট নির্বাচন করুন',
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Step label ─────────────────────────────────────────────────────────────

  Widget _buildStepLabel(String num, String label) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              num,
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

  // ── Account list ───────────────────────────────────────────────────────────

  Widget _buildAccountList(List<Map<String, String>> accounts) {
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
      children: accounts.map((acc) {
        final type = acc['type'] ?? '';
        final number = acc['number'] ?? '';
        final name = acc['name'] ?? '';
        final color = _providerColor(type);
        final isSelected = _selectedAccount?['id'] == acc['id'];

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: PressScale(
            scale: 0.98,
            onTap: () => setState(() => _selectedAccount = acc),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.08)
                    : context.card,
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
                    child: Icon(_providerIcon(type), color: color, size: 22),
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
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                        if (name.isNotEmpty)
                          Text(
                            number,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.textTertiary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle_rounded, color: color, size: 22)
                  else
                    Icon(Icons.radio_button_unchecked_rounded,
                        color: context.border, size: 22),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Selected account detail with copy button ───────────────────────────────

  Widget _buildSelectedAccountDetail(Map<String, String> acc) {
    final type = acc['type'] ?? '';
    final number = acc['number'] ?? '';
    final instructions = acc['instructions'] ?? '';
    final bankName = acc['bankName'] ?? '';
    final branch = acc['branch'] ?? '';
    final color = _providerColor(type);

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
                icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.white),
                tooltip: 'কপি করুন',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: number));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('নম্বর কপি করা হয়েছে'),
                      backgroundColor: color,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          if (bankName.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('ব্যাংক: $bankName', style: context.textTheme.bodySmall?.copyWith(color: context.textSecondary)),
          ],
          if (branch.isNotEmpty)
            Text('শাখা: $branch', style: context.textTheme.bodySmall?.copyWith(color: context.textSecondary)),
          if (instructions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              instructions,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.textSecondary,
              ),
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

  // ── Amount selection ───────────────────────────────────────────────────────

  Widget _buildAmountSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _quickAmounts.map((amount) {
            final selected = _selectedAmount == amount;
            return ChoiceChip(
              label: Text('৳$amount'),
              selected: selected,
              onSelected: (val) {
                setState(() {
                  _selectedAmount = val ? amount : '';
                  if (val) _customAmountController.clear();
                });
              },
              labelStyle: context.textTheme.labelLarge?.copyWith(
                color: selected ? AppColors.primary : context.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              selectedColor: AppColors.primary.withValues(alpha: 0.12),
              backgroundColor:
                  context.isDark ? AppColors.darkCard : AppColors.lightBackground,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl, vertical: AppSpacing.md),
            );
          }).toList(),
        ),
        AppSpacing.hMd,
        TextField(
          controller: _customAmountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'অন্য পরিমাণ লিখুন (৳)',
            prefixIcon: Icon(Icons.edit_rounded,
                size: 20, color: context.textTertiary),
          ),
          onChanged: (val) {
            setState(() {
              if (val.isNotEmpty) _selectedAmount = '';
            });
          },
        ),
      ],
    );
  }

  // ── Transaction info ───────────────────────────────────────────────────────

  Widget _buildTransactionInfo() {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          TextField(
            controller: _trxIdController,
            decoration: InputDecoration(
              hintText: 'ট্রানজেকশন আইডি (Transaction ID)',
              prefixIcon: Icon(Icons.receipt_long_rounded,
                  size: 20, color: context.textTertiary),
            ),
          ),
          AppSpacing.hMd,
          TextField(
            controller: _senderNumberController,
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

  // ── Options ────────────────────────────────────────────────────────────────

  Widget _buildOptions() {
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
              horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
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
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                value: _isAnonymous,
                onChanged: (val) => setState(() => _isAnonymous = val),
                activeTrackColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(height: 1),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: TextField(
                  controller: _noteController,
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

  // ── Terms ──────────────────────────────────────────────────────────────────

  Widget _buildTerms() {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _termsAccepted,
            onChanged: (val) =>
                setState(() => _termsAccepted = val ?? false),
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
          ),
        ),
        AppSpacing.wSm,
        Expanded(
          child: GestureDetector(
            onTap: () =>
                setState(() => _termsAccepted = !_termsAccepted),
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

  // ── Submit ─────────────────────────────────────────────────────────────────

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _canSubmit ? _handleSubmit : null,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
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

  // ── Logic ──────────────────────────────────────────────────────────────────

  Future<void> _handleSubmit() async {
    final amountText = _selectedAmount.isNotEmpty
        ? _selectedAmount.replaceAll(',', '')
        : _customAmountController.text.trim().replaceAll(',', '');
    final amount = double.tryParse(amountText);
    final transactionId = _trxIdController.text.trim();
    final senderNumber = _senderNumberController.text.trim();
    final selectedAccount = _selectedAccount;

    if (selectedAccount == null) {
      return;
    }

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('সঠিক দানের পরিমাণ লিখুন')),
      );
      return;
    }

    if (transactionId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ট্রানজেকশন আইডি দিন')),
      );
      return;
    }

    if (senderNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('প্রেরকের নম্বর দিন')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await DataService.instance.addDonation(
        amount: amount,
        paymentMethod: selectedAccount['type'] ?? 'Manual Transfer',
        transactionId: transactionId,
        senderNumber: senderNumber,
        receivedAccountId: selectedAccount['id'],
        receivedAccountLabel: [
          selectedAccount['type'],
          selectedAccount['number'],
          selectedAccount['name'],
        ].whereType<String>().where((value) => value.isNotEmpty).join(' • '),
      );

      if (!mounted) {
        return;
      }
      _showSuccessDialog();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSuccessDialog() {
    final amount = _selectedAmount.isNotEmpty
        ? _selectedAmount
        : _customAmountController.text;
    final type = _selectedAccount?['type'] ?? '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (context, value, child) => Transform.scale(
                scale: value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle_rounded,
                      size: 48, color: AppColors.success),
                ),
              ),
            ),
            AppSpacing.hLg,
            Text(
              'দান সফলভাবে জমা হয়েছে!',
              style: context.textTheme.titleLarge?.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.hSm,
            Text(
              'অ্যাডমিন যাচাই করার পর আপনার দান অনুমোদিত হবে',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (amount.isNotEmpty) ...[
              AppSpacing.hMd,
              Text(
                '৳$amount',
                style: context.textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'via $type',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.pop();
              },
              child: const Text('ঠিক আছে'),
            ),
          ),
        ],
      ),
    );
  }
}
