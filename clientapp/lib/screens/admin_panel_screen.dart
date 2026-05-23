part of '../screens.dart';


class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(tr('Admin Panel', 'অ্যাডমিন প্যানেল')),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: const Color(0xFFFF9500),
          unselectedLabelColor: const Color(0xFF8E8E93),
          indicatorColor: const Color(0xFFFF9500),
          tabs: [
            Tab(text: tr('Pending Donations', 'মুলতুবি অনুদান')),
            Tab(text: tr('Payment Settings', 'পেমেন্ট সেটিংস')),
          ],
        ),
      ),
      body: _pageBackdrop(
        child: TabBarView(
          controller: _tabCtrl,
          children: const [
            _AdminPendingDonationsTab(),
            _AdminPaymentSettingsTab(),
          ],
        ),
      ),
    );
  }
}

class _AdminPendingDonationsTab extends StatelessWidget {
  const _AdminPendingDonationsTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Donation>>(
      stream: DataService.instance.pendingDonations(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: _pagePadding(context),
            child: const ListSkeleton(itemCount: 4, itemHeight: 100),
          );
        }
        final donations = snap.data ?? [];
        if (donations.isEmpty) {
          return Center(
            child: EmptyStateCard(
              icon: Icons.check_circle_outline_rounded,
              title: tr('No Pending Donations', 'কোনো মুলতুবি অনুদান নেই'),
              message: tr(
                'All donations have been reviewed',
                'সমস্ত অনুদান পর্যালোচনা করা হয়েছে',
              ),
            ),
          );
        }
        return ListView.separated(
          padding: _pagePadding(context),
          itemCount: donations.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, i) =>
              _AdminDonationCard(donation: donations[i]),
        );
      },
    );
  }
}

class _AdminDonationCard extends StatefulWidget {
  const _AdminDonationCard({required this.donation});
  final Donation donation;

  @override
  State<_AdminDonationCard> createState() => _AdminDonationCardState();
}

class _AdminDonationCardState extends State<_AdminDonationCard> {
  bool _processing = false;

  Future<void> _approve() async {
    setState(() => _processing = true);
    try {
      await DataService.instance.approveDonation(widget.donation.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('Donation approved', 'অনুদান অনুমোদিত হয়েছে')),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${tr('Error', 'ত্রুটি')}: $e')));
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _reject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(tr('Reject Donation?', 'অনুদান প্রত্যাখ্যান করবেন?')),
        content: Text(
          tr(
            'This action cannot be undone.',
            'এই কাজটি পূর্বাবস্থায় ফেরানো যাবে না।',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr('Cancel', 'বাতিল')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              tr('Reject', 'প্রত্যাখ্যান'),
              style: TextStyle(color: AppColors.errorC(context)),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _processing = true);
    try {
      await DataService.instance.rejectDonation(widget.donation.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('Donation rejected', 'অনুদান প্রত্যাখ্যাত হয়েছে')),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${tr('Error', 'ত্রুটি')}: $e')));
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.donation;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryC(context).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.volunteer_activism,
                  color: AppColors.primaryC(context),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.donorName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryC(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${d.paymentMethod} · ${shortDate.format(d.createdAt)}',
                      style: TextStyle(
                        color: AppColors.textSecondaryC(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                currency.format(d.amount),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryC(context),
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow(
                  tr('Transaction ID', 'ট্রানজেকশন আইডি'),
                  d.transactionId,
                ),
                const SizedBox(height: 6),
                _infoRow(tr('Sender Number', 'প্রেরকের নম্বর'), d.senderNumber),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: _processing ? null : _reject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.errorC(context),
                      side: BorderSide(color: AppColors.errorC(context)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      tr('Reject', 'প্রত্যাখ্যান'),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  isLoading: _processing,
                  onPressed: _processing ? null : _approve,
                  gradient: AppColors.successGradient,
                  label: _processing
                      ? tr('Processing...', 'প্রসেস হচ্ছে...')
                      : tr('Approve', 'অনুমোদন'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondaryC(context)),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '-' : value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryC(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminPaymentSettingsTab extends StatefulWidget {
  const _AdminPaymentSettingsTab();

  @override
  State<_AdminPaymentSettingsTab> createState() =>
      _AdminPaymentSettingsTabState();
}

class _AdminPaymentSettingsTabState extends State<_AdminPaymentSettingsTab> {
  final _bkashNum = TextEditingController();
  final _bkashName = TextEditingController();
  final _nagadNum = TextEditingController();
  final _nagadName = TextEditingController();
  final _rocketNum = TextEditingController();
  final _rocketName = TextEditingController();
  final _bankNum = TextEditingController();
  final _bankName = TextEditingController();
  final _bankBankName = TextEditingController();
  final _bankBranch = TextEditingController();
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _bkashNum.dispose();
    _bkashName.dispose();
    _nagadNum.dispose();
    _nagadName.dispose();
    _rocketNum.dispose();
    _rocketName.dispose();
    _bankNum.dispose();
    _bankName.dispose();
    _bankBankName.dispose();
    _bankBranch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, Map<String, String>>>(
      stream: DataService.instance.paymentAccounts(),
      builder: (context, snap) {
        if (!_loaded && snap.hasData) {
          final accounts = snap.data!;
          _bkashNum.text = accounts['bKash']?['number'] ?? '';
          _bkashName.text = accounts['bKash']?['name'] ?? '';
          _nagadNum.text = accounts['Nagad']?['number'] ?? '';
          _nagadName.text = accounts['Nagad']?['name'] ?? '';
          _rocketNum.text = accounts['Rocket']?['number'] ?? '';
          _rocketName.text = accounts['Rocket']?['name'] ?? '';
          _bankNum.text = accounts['Bank']?['number'] ?? '';
          _bankName.text = accounts['Bank']?['name'] ?? '';
          _bankBankName.text = accounts['Bank']?['bankName'] ?? '';
          _bankBranch.text = accounts['Bank']?['branch'] ?? '';
          _loaded = true;
        }
        return ListView(
          padding: _pagePadding(context),
          children: [
            // Header info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryC(context).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primaryC(context).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primaryC(context),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tr(
                        'Citizens will see these account details when donating',
                        'নাগরিকরা অনুদান দেওয়ার সময় এই অ্যাকাউন্টের তথ্য দেখবেন',
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondaryC(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // bKash card
            _buildAccountCard(
              title: tr('bKash', 'বিকাশ'),
              color: const Color(0xFFE2136E),
              numCtrl: _bkashNum,
              nameCtrl: _bkashName,
            ),
            const SizedBox(height: 14),

            // Nagad card
            _buildAccountCard(
              title: tr('Nagad', 'নগদ'),
              color: const Color(0xFFFF6A00),
              numCtrl: _nagadNum,
              nameCtrl: _nagadName,
            ),
            const SizedBox(height: 14),

            // Rocket card
            _buildAccountCard(
              title: tr('Rocket', 'রকেট'),
              color: const Color(0xFF8B2FA0),
              numCtrl: _rocketNum,
              nameCtrl: _rocketName,
            ),
            const SizedBox(height: 14),

            // Bank card
            _buildBankAccountCard(),
            const SizedBox(height: 24),

            // Save button
            PrimaryButton(
              isLoading: _saving,
              onPressed: _saving ? null : _save,
              icon: Icons.save_rounded,
              label: _saving
                  ? tr('Saving...', 'সংরক্ষণ হচ্ছে...')
                  : tr('Save All Settings', 'সকল সেটিংস সংরক্ষণ করুন'),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildAccountCard({
    required String title,
    required Color color,
    required TextEditingController numCtrl,
    required TextEditingController nameCtrl,
  }) {
    final hasData = numCtrl.text.trim().isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          // Header strip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.phone_android_rounded,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: hasData
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    hasData
                        ? tr('Active', 'সক্রিয়')
                        : tr('Not Set', 'সেট নেই'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: hasData ? AppColors.successC(context) : AppColors.errorC(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Fields
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                PremiumTextField(
                  controller: numCtrl,
                  keyboardType: TextInputType.phone,
                  onChanged: (_) => setState(() {}),
                  labelText: tr('Account Number', 'অ্যাকাউন্ট নম্বর'),
                  hintText: tr('e.g. 01XXXXXXXXX', 'যেমন ০১XXXXXXXXX'),
                  prefixIcon: Icons.dialpad_rounded,
                ),
                const SizedBox(height: 12),
                PremiumTextField(
                  controller: nameCtrl,
                  labelText: tr('Account Holder Name', 'অ্যাকাউন্ট ধারকের নাম'),
                  hintText: tr('e.g. Mohammad Ali', 'যেমন মোহাম্মদ আলী'),
                  prefixIcon: Icons.person_outline_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccountCard() {
    const color = Color(0xFF1E40AF);
    final hasData = _bankNum.text.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.account_balance_rounded,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  tr('Bank Account', 'ব্যাংক অ্যাকাউন্ট'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: hasData
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    hasData
                        ? tr('Active', 'সক্রিয়')
                        : tr('Not Set', 'সেট নেই'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: hasData ? AppColors.successC(context) : AppColors.errorC(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                PremiumTextField(
                  controller: _bankBankName,
                  onChanged: (_) => setState(() {}),
                  labelText: tr('Bank Name', 'ব্যাংকের নাম'),
                  hintText: tr('e.g. Sonali Bank', 'যেমন সোনালী ব্যাংক'),
                  prefixIcon: Icons.account_balance_rounded,
                ),
                const SizedBox(height: 12),
                PremiumTextField(
                  controller: _bankBranch,
                  onChanged: (_) => setState(() {}),
                  labelText: tr('Branch Name', 'শাখার নাম'),
                  hintText: tr('e.g. Main Branch', 'যেমন প্রধান শাখা'),
                  prefixIcon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 12),
                PremiumTextField(
                  controller: _bankNum,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  labelText: tr('Account Number', 'অ্যাকাউন্ট নম্বর'),
                  hintText: tr('e.g. 1234567890', 'যেমন ১২৩৪৫৬৭৮৯০'),
                  prefixIcon: Icons.dialpad_rounded,
                ),
                const SizedBox(height: 12),
                PremiumTextField(
                  controller: _bankName,
                  labelText: tr('Account Holder Name', 'অ্যাকাউন্ট ধারকের নাম'),
                  hintText: tr('e.g. Mohammad Ali', 'যেমন মোহাম্মদ আলী'),
                  prefixIcon: Icons.person_outline_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await DataService.instance.updatePaymentAccounts({
        'bKash': {
          'number': _bkashNum.text.trim(),
          'name': _bkashName.text.trim(),
        },
        'Nagad': {
          'number': _nagadNum.text.trim(),
          'name': _nagadName.text.trim(),
        },
        'Rocket': {
          'number': _rocketNum.text.trim(),
          'name': _rocketName.text.trim(),
        },
        'Bank': {
          'number': _bankNum.text.trim(),
          'name': _bankName.text.trim(),
          'bankName': _bankBankName.text.trim(),
          'branch': _bankBranch.text.trim(),
        },
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr('Settings saved successfully', 'সেটিংস সফলভাবে সংরক্ষিত হয়েছে'),
          ),
          backgroundColor: AppColors.successC(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${tr('Error', 'ত্রুটি')}: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
