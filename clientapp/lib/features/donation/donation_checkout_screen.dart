import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_shimmer.dart';
import '../../core/widgets/motion.dart';
import '../../services/donation_service.dart';
import 'checkout/account_picker.dart';
import 'checkout/checkout_amount.dart';
import 'checkout/checkout_sections.dart';
import 'checkout/donation_success_dialog.dart';

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

  @override
  void dispose() {
    _customAmountController.dispose();
    _trxIdController.dispose();
    _senderNumberController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _accountSelected => _selectedAccount != null;

  /// Whichever amount field the citizen used, as raw display text.
  String get _amountText => _selectedAmount.isNotEmpty
      ? _selectedAmount
      : _customAmountController.text.trim();

  bool get _canSubmit =>
      _accountSelected &&
      parseDonationAmount(_amountText) != null &&
      _termsAccepted &&
      !_isSubmitting;

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(donationAccountsProvider);

    return Scaffold(
      backgroundColor: context.canvas,
      appBar: AppBar(title: const Text('দান সম্পন্ন করুন')),
      body: SafeArea(
        child: accountsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                CardSkeleton(height: 72),
                SizedBox(height: AppSpacing.md),
                CardSkeleton(height: 72),
                SizedBox(height: AppSpacing.md),
                CardSkeleton(height: 72),
              ],
            ),
          ),
          error: (error, _) => Center(
            child: EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'একাউন্ট তথ্য লোড করা যায়নি',
              subtitle: 'ইন্টারনেট সংযোগ চেক করে পুনরায় চেষ্টা করুন',
              actionLabel: 'পুনরায় চেষ্টা করুন',
              onAction: () => ref.invalidate(donationAccountsProvider),
            ),
          ),
          data: _buildForm,
        ),
      ),
    );
  }

  Widget _buildForm(List<Map<String, String>> accounts) {
    final active =
        accounts.where((a) => a['type']?.isNotEmpty == true).toList();
    final selected = _selectedAccount;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FadeSlideIn(
            delay: 0,
            child: StepLabel(number: '১', label: 'একাউন্ট নির্বাচন করুন'),
          ),
          AppSpacing.hMd,
          FadeSlideIn(
            delay: 50,
            child: AccountPicker(
              accounts: active,
              selectedId: selected?['id'],
              onSelect: (account) =>
                  setState(() => _selectedAccount = account),
            ),
          ),
          if (selected != null) ...[
            AppSpacing.hMd,
            FadeSlideIn(
              delay: 0,
              child: SelectedAccountDetail(account: selected),
            ),
          ],
          AppSpacing.hXxl,
          if (_accountSelected) ..._buildDonationSteps() else _buildPrompt(),
        ],
      ),
    );
  }

  List<Widget> _buildDonationSteps() {
    return [
      const FadeSlideIn(
        delay: 80,
        child: StepLabel(number: '২', label: 'পরিমাণ নির্বাচন করুন'),
      ),
      AppSpacing.hMd,
      FadeSlideIn(
        delay: 120,
        child: AmountSelection(
          selectedAmount: _selectedAmount,
          customAmountController: _customAmountController,
          onQuickAmountChanged: (amount) => setState(() {
            _selectedAmount = amount;
            if (amount.isNotEmpty) _customAmountController.clear();
          }),
          onCustomAmountChanged: (value) => setState(() {
            if (value.isNotEmpty) _selectedAmount = '';
          }),
        ),
      ),
      AppSpacing.hXxl,
      const FadeSlideIn(
        delay: 160,
        child: StepLabel(number: '৩', label: 'লেনদেনের তথ্য'),
      ),
      AppSpacing.hMd,
      FadeSlideIn(
        delay: 200,
        child: TransactionInfoFields(
          transactionIdController: _trxIdController,
          senderNumberController: _senderNumberController,
        ),
      ),
      AppSpacing.hXxl,
      FadeSlideIn(
        delay: 240,
        child: DonationOptions(
          isAnonymous: _isAnonymous,
          onAnonymousChanged: (value) => setState(() => _isAnonymous = value),
          noteController: _noteController,
        ),
      ),
      AppSpacing.hXxl,
      FadeSlideIn(
        delay: 280,
        child: TermsCheckbox(
          accepted: _termsAccepted,
          onChanged: (value) => setState(() => _termsAccepted = value),
        ),
      ),
      AppSpacing.hXxl,
      FadeSlideIn(
        delay: 320,
        child: SubmitDonationButton(
          onSubmit: _canSubmit ? _handleSubmit : null,
          isSubmitting: _isSubmitting,
        ),
      ),
    ];
  }

  Widget _buildPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Text(
          'দান করতে উপরে একটি একাউন্ট নির্বাচন করুন',
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium
              ?.copyWith(color: context.textSecondary),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final selectedAccount = _selectedAccount;
    if (selectedAccount == null) return;

    final amount = parseDonationAmount(_amountText);
    final transactionId = _trxIdController.text.trim();
    final senderNumber = _senderNumberController.text.trim();

    if (amount == null) {
      _showMessage('সঠিক দানের পরিমাণ লিখুন');
      return;
    }
    if (transactionId.isEmpty) {
      _showMessage('ট্রানজেকশন আইডি দিন');
      return;
    }
    if (senderNumber.isEmpty) {
      _showMessage('প্রেরকের নম্বর দিন');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await DonationService.instance.addDonation(
        amount: amount,
        paymentMethod: selectedAccount['type'] ?? 'Manual Transfer',
        transactionId: transactionId,
        senderNumber: senderNumber,
        receivedAccountId: selectedAccount['id'],
        receivedAccountLabel: _accountLabel(selectedAccount),
      );

      if (!mounted) return;
      await showDonationSuccessDialog(
        context,
        amount: _amountText,
        paymentType: selectedAccount['type'] ?? '',
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString().replaceFirst('Bad state: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  /// Denormalized description of the receiving account, stored alongside the
  /// donation so it survives the account later being edited or removed.
  static String _accountLabel(Map<String, String> account) {
    return [account['type'], account['number'], account['name']]
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .join(' • ');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
