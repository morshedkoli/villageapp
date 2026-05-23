part of '../screens.dart';


class DonateScreen extends StatefulWidget {
  const DonateScreen({super.key});

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  final _txForm = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _transactionId = TextEditingController();
  final _senderNumber = TextEditingController();
  String? _selectedAccountId;
  bool _submitting = false;
  bool _submitted = false;

  String _normalizeMethodKey(String key) {
    final normalized = key.trim().toLowerCase();
    switch (normalized) {
      case 'bkash':
        return 'bKash';
      case 'nagad':
        return 'Nagad';
      case 'rocket':
        return 'Rocket';
      case 'bank':
        return 'Bank';
      default:
        return key.trim();
    }
  }

  List<Map<String, dynamic>> _buildVisibleDonationAccounts({
    required List<Map<String, String>> accounts,
    required List<Map<String, dynamic>> configuredMethods,
  }) {
    final methodByKey = <String, Map<String, dynamic>>{};
    for (final method in configuredMethods) {
      final rawKey = (method['key'] as String?) ?? '';
      final key = _normalizeMethodKey(rawKey);
      if (key.isNotEmpty) {
        methodByKey[key] = method;
      }
    }

    final visible = <Map<String, dynamic>>[];
    for (final account in accounts) {
      final id = (account['id'] ?? '').trim();
      final rawType = (account['type'] ?? '').trim();
      final key = _normalizeMethodKey(rawType);
      final number = (account['number'] ?? '').trim();
      if (number.isEmpty) {
        continue;
      }

      final configured = methodByKey[key] ?? const <String, dynamic>{};
      visible.add({
        'id': id.isNotEmpty ? id : '${key.toLowerCase()}_${visible.length + 1}',
        'type': key,
        'bn': (configured['bn'] as String?) ?? key,
        'color': (configured['color'] as int?) ?? 0xFF2563EB,
        'icon':
            configured['icon'] ??
            (key == 'Bank'
                ? 'account_balance_rounded'
                : 'phone_android_rounded'),
        'number': number,
        'name': (account['name'] ?? '').trim(),
        'bankName': (account['bankName'] ?? '').trim(),
        'branch': (account['branch'] ?? '').trim(),
      });
    }
    return visible;
  }

  /// Convert icon name string to IconData
  IconData _getIconFromName(String name) {
    switch (name.toLowerCase()) {
      case 'phone_android_rounded':
        return Icons.phone_android_rounded;
      case 'account_balance_rounded':
        return Icons.account_balance_rounded;
      default:
        return Icons.phone_android_rounded;
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _transactionId.dispose();
    _senderNumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: _buildSidebarDrawer(context: context, selectedId: _MenuId.fund),
      appBar: AppBar(
        title: Text(tr('Donate to Fund', 'তহবিলে অনুদান')),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: _pageBackdrop(
        child: _submitted ? _buildSuccess() : _buildDonationPage(),
      ),
    );
  }

  Widget _buildDonationPage() {
    return StreamBuilder<List<Map<String, String>>>(
      stream: DataService.instance.donationAccounts(),
      builder: (context, accountsSnap) {
        if (accountsSnap.connectionState == ConnectionState.waiting &&
            !accountsSnap.hasData) {
          return const DonateSkeleton();
        }
        final accounts = accountsSnap.data ?? const <Map<String, String>>[];

        // Get payment methods from database
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: DataService.instance.paymentMethods(),
          builder: (context, methodsSnap) {
            final configuredMethods =
                methodsSnap.data ?? const <Map<String, dynamic>>[];
            final methods = _buildVisibleDonationAccounts(
              accounts: accounts,
              configuredMethods: configuredMethods,
            );

            final selectedAccount = _selectedAccountId == null
                ? null
                : methods.firstWhere(
                    (m) => m['id'] == _selectedAccountId,
                    orElse: () => const <String, dynamic>{},
                  );

            // Reset selected account if it was removed
            if (_selectedAccountId != null &&
                (selectedAccount == null || selectedAccount.isEmpty)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _selectedAccountId = null);
              });
            }

            return ListView(
              padding: _pagePadding(context),
              children: [
                // Header
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.primaryGradient,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryC(context).withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.volunteer_activism_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    tr('Make a Donation', 'অনুদান দিন'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryC(context),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    tr(
                      'Select a payment method to donate',
                      'অনুদান দিতে একটি পেমেন্ট পদ্ধতি নির্বাচন করুন',
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondaryC(context),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                if (methods.isEmpty && methodsSnap.hasData)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          color: AppColors.errorC(context),
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tr(
                            'No payment methods available',
                            'কোনো পেমেন্ট পদ্ধতি উপলব্ধ নেই',
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.errorC(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tr(
                            'Please contact the admin to set up payment accounts.',
                            'পেমেন্ট অ্যাকাউন্ট সেট আপ করতে অ্যাডমিনের সাথে যোগাযোগ করুন।',
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryC(context),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                // Payment method selection
                ...List.generate(methods.length, (i) {
                  final m = methods[i];
                  final accountId = m['id'] as String;
                  final key = m['type'] as String;
                  final bn = m['bn'] as String;
                  final color = Color(m['color'] as int);
                  final methodTitle = tr(
                    key == 'Bank' ? 'Bank Account' : key,
                    key == 'Bank' ? 'ব্যাংক অ্যাকাউন্ট' : bn,
                  );

                  // Convert icon name to IconData
                  IconData icon;
                  final iconData = m['icon'];
                  if (iconData is IconData) {
                    icon = iconData;
                  } else if (iconData is String) {
                    // Map icon string names to IconData
                    icon = _getIconFromName(iconData);
                  } else {
                    icon = Icons.phone_android_rounded; // fallback
                  }

                  final selected = _selectedAccountId == accountId;
                  final number = (m['number'] as String?) ?? '';
                  final name = (m['name'] as String?) ?? '';
                  final isBank = key == 'Bank';
                  final bankName = (m['bankName'] as String?) ?? '';
                  final branch = (m['branch'] as String?) ?? '';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => setState(
                        () => _selectedAccountId = selected ? null : accountId,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: selected
                              ? color.withValues(alpha: 0.05)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected ? color : AppColors.borderC(context),
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(icon, color: color, size: 24),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          methodTitle,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: selected
                                                ? color
                                                : const Color(0xFF1C1C1E),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFECFDF3),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                tr('Active', 'সক্রিয়'),
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF059669),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    selected
                                        ? Icons.radio_button_checked_rounded
                                        : Icons.radio_button_off_rounded,
                                    color: selected
                                        ? color
                                        : const Color(0xFFC7C7CC),
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                            // Show account details when selected
                            if (selected)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      isBank
                                          ? tr(
                                              'Bank Transfer Details',
                                              'ব্যাংক ট্রান্সফারের তথ্য',
                                            )
                                          : tr('Send Money To', 'টাকা পাঠান'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondaryC(context),
                                      ),
                                    ),
                                    if (isBank && bankName.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        bankName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: color,
                                        ),
                                      ),
                                      if (branch.isNotEmpty)
                                        Text(
                                          branch,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondaryC(context),
                                          ),
                                        ),
                                    ],
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          number,
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: color,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () {
                                            Clipboard.setData(
                                              ClipboardData(text: number),
                                            );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  tr(
                                                    'Number copied',
                                                    'নম্বর কপি হয়েছে',
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Icon(
                                            Icons.copy_rounded,
                                            size: 18,
                                            color: color.withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (name.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimaryC(context),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // Donation form — visible when a method is selected
                if (_selectedAccountId != null) ...[
                  const SizedBox(height: 8),
                  AppCard(
                    child: Form(
                      key: _txForm,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (selectedAccount?['type'] as String?) == 'Bank'
                                ? tr(
                                    'After transferring, fill this form',
                                    'ট্রান্সফারের পর এই ফর্ম পূরণ করুন',
                                  )
                                : tr(
                                    'After sending money, fill this form',
                                    'টাকা পাঠানোর পর এই ফর্ম পূরণ করুন',
                                  ),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimaryC(context),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _amount,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: tr(
                                'Donation Amount',
                                'অনুদানের পরিমাণ',
                              ),
                              prefixIcon: Icon(
                                Icons.currency_exchange_rounded,
                                color: AppColors.primaryC(context),
                              ),
                            ),
                            validator: (v) {
                              final n = double.tryParse((v ?? '').trim());
                              if (n == null || n <= 0) {
                                return tr(
                                  'Enter a valid donation amount',
                                  'সঠিক অনুদানের পরিমাণ লিখুন',
                                );
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _transactionId,
                            decoration: InputDecoration(
                              labelText:
                                  (selectedAccount?['type'] as String?) ==
                                      'Bank'
                                  ? tr(
                                      'Transaction/Reference ID (Optional)',
                                      'ট্রানজেকশন/রেফারেন্স আইডি (ঐচ্ছিক)',
                                    )
                                  : tr('Transaction ID (Optional)', 'ট্রানজেকশন আইডি (ঐচ্ছিক)'),
                              prefixIcon: Icon(
                                Icons.receipt_long_rounded,
                                color: AppColors.primaryC(context),
                              ),
                            ),
                            validator: (v) => null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _senderNumber,
                            keyboardType:
                                (selectedAccount?['type'] as String?) == 'Bank'
                                ? TextInputType.text
                                : TextInputType.phone,
                            decoration: InputDecoration(
                              labelText:
                                  (selectedAccount?['type'] as String?) ==
                                      'Bank'
                                  ? tr(
                                      'Sender Account/Phone',
                                      'প্রেরকের অ্যাকাউন্ট/ফোন',
                                    )
                                  : tr(
                                      'Sender Phone Number',
                                      'প্রেরকের ফোন নম্বর',
                                    ),
                              prefixIcon: Icon(
                                (selectedAccount?['type'] as String?) == 'Bank'
                                    ? Icons.account_circle_outlined
                                    : Icons.phone_rounded,
                                color: const Color(0xFF8E8E93),
                              ),
                            ),
                            validator: (v) {
                              final text = (v ?? '').trim();
                              if (text.isEmpty) {
                                return (selectedAccount?['type'] as String?) ==
                                        'Bank'
                                    ? tr(
                                        'Enter sender account or phone',
                                        'প্রেরকের অ্যাকাউন্ট বা ফোন নম্বর লিখুন',
                                      )
                                    : tr(
                                        'Enter phone number',
                                        'ফোন নম্বর লিখুন',
                                      );
                              }
                              // Allow 4-11 digits for both cases or specifically for mobile?
                              // User said "for 4 to 11 digit" specifically for sender number.
                              if (text.length < 4 || text.length > 11) {
                                return tr(
                                  'Enter a valid 4-11 digit number',
                                  'সঠিক ৪-১১ ডিজিটের নম্বর লিখুন',
                                );
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          PrimaryButton(
                            isLoading: _submitting,
                            onPressed: _submitting ? null : _submit,
                            label: _submitting
                                ? tr('Submitting...', 'জমা হচ্ছে...')
                                : tr('Submit Donation', 'অনুদান জমা দিন'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSuccess() {
    return Padding(
      padding: _pagePadding(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.successC(context), Color(0xFF34D399)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            tr('Pending Verification', 'যাচাইয়ের অপেক্ষায়'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryC(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tr(
              'Your donation has been submitted successfully. The admin will verify your payment and approve it shortly.',
              'আপনার অনুদান সফলভাবে জমা হয়েছে। অ্যাডমিন আপনার পেমেন্ট যাচাই করে শীঘ্রই অনুমোদন করবেন।',
            ),
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryC(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            onPressed: () => Navigator.of(context).pop(),
            label: tr('Done', 'সম্পন্ন'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_txForm.currentState?.validate() ?? false)) return;
    if (_selectedAccountId == null) return;
    setState(() => _submitting = true);
    try {
      final amount = double.parse(_amount.text.trim());
      final wasOffline = !ConnectivityService.instance.isOnline;
      final accounts = await DataService.instance.donationAccounts().first;
      final selected = accounts.firstWhere(
        (a) => a['id'] == _selectedAccountId,
        orElse: () => const <String, String>{},
      );
      final rawType = (selected['type'] ?? '').trim();
      if (rawType.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tr('Please select an account', 'একটি অ্যাকাউন্ট নির্বাচন করুন'),
            ),
          ),
        );
        return;
      }
      final selectedType = _normalizeMethodKey(rawType);
      final accountLabel = [
        if (selectedType.isNotEmpty) selectedType,
        if ((selected['number'] ?? '').isNotEmpty) selected['number']!,
      ].join(' - ');

      await DataService.instance.addDonation(
        amount: amount,
        paymentMethod: selectedType,
        transactionId: _transactionId.text.trim(),
        senderNumber: _senderNumber.text.trim(),
        receivedAccountId: _selectedAccountId,
        receivedAccountLabel: accountLabel,
      );
      if (!mounted) return;
      if (wasOffline) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tr(
                'Donation saved offline — will sync when online',
                'অনুদান অফলাইনে সংরক্ষিত — অনলাইনে এলে সিঙ্ক হবে',
              ),
            ),
            backgroundColor: const Color(0xFF8E8E93),
          ),
        );
      }
      setState(() => _submitted = true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${tr('Error', 'ত্রুটি')}: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
