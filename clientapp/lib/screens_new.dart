import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'data_service.dart';
import 'models.dart';
import 'ui/accessibility.dart';
import 'ui/components.dart';

bool _isCompactLayout(BuildContext context) {
  return MediaQuery.of(context).size.width <= 360;
}

EdgeInsets _pagePadding(BuildContext context) {
  final compact = _isCompactLayout(context);
  return EdgeInsets.fromLTRB(compact ? 14 : 20, compact ? 12 : 16, compact ? 14 : 20, compact ? 12 : 16);
}

void _openRootTab(BuildContext context, int index) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => RootShell(initialIndex: index)),
    (route) => false,
  );
}

// ─── Spendly-style custom app header ───────────────────────────────

class _AppHeader extends StatelessWidget {
  const _AppHeader({this.actions});
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        _isCompactLayout(context) ? 14 : 20,
        MediaQuery.of(context).padding.top + 12,
        _isCompactLayout(context) ? 14 : 20,
        8,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.location_city_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('Doulatpara', 'দৌলতপাড়া'),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), letterSpacing: -0.3),
                ),
                Text(
                  tr('Your village companion', 'আপনার গ্রাম সহচর'),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}

// ─── Sidebar ────────────────────────────────────────────────────────

Drawer _buildSidebarMenu(BuildContext context) {
  return Drawer(
    backgroundColor: Colors.white,
    child: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.location_city_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 14),
                Text(tr('Doulatpara', 'দৌলতপাড়া'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  tr('Village development platform', 'গ্রাম উন্নয়ন প্ল্যাটফর্ম'),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SidebarItem(
            icon: Icons.people_outline,
            label: tr('Citizens', 'নাগরিক'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CitizensPage()));
            },
          ),
          _SidebarItem(
            icon: Icons.leaderboard_outlined,
            label: tr('Leaderboard', 'লিডারবোর্ড'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LeaderboardPage()));
            },
          ),
          _SidebarItem(
            icon: Icons.notifications_outlined,
            label: tr('Notifications', 'নোটিফিকেশন'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationScreen()));
            },
          ),
          _SidebarItem(
            icon: Icons.account_circle_outlined,
            label: tr('Profile', 'প্রোফাইল'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
        ],
      ),
    ),
  );
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF64748B), size: 22),
        title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF334155))),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}

// ─── Bottom navigation ──────────────────────────────────────────────

Widget _buildBottomTabBar(BuildContext context, {required int index, required ValueChanged<int> onTap}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF94A3B8).withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, -4),
        ),
      ],
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavIcon(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: tr('Home', 'হোম'), active: index == 0, onTap: () => onTap(0)),
            _NavIcon(icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet_rounded, label: tr('Fund', 'তহবিল'), active: index == 1, onTap: () => onTap(1)),
            _NavIcon(icon: Icons.construction_outlined, activeIcon: Icons.construction_rounded, label: tr('Projects', 'প্রকল্প'), active: index == 2, onTap: () => onTap(2)),
            _NavIcon(icon: Icons.warning_amber_outlined, activeIcon: Icons.warning_amber_rounded, label: tr('Problems', 'সমস্যা'), active: index == 3, onTap: () => onTap(3)),
            _NavIcon(icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, label: tr('Settings', 'সেটিংস'), active: index == 4, onTap: () => onTap(4)),
          ],
        ),
      ),
    ),
  );
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.icon, required this.activeIcon, required this.label, required this.active, required this.onTap});
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: active ? const Color(0xFFEFF6FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                active ? activeIcon : icon,
                color: active ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Root shell ─────────────────────────────────────────────────────

class RootShell extends StatefulWidget {
  const RootShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  late int _index;

  final _screens = const [
    HomeScreen(),
    VillageFundScreen(),
    ProjectsScreen(),
    ProblemsScreen(),
    _SettingsTab(),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildSidebarMenu(context),
      body: _screens[_index],
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ok = await _ensureLogin(context);
          if (!context.mounted || !ok) return;
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReportProblemScreen()));
        },
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      bottomNavigationBar: _buildBottomTabBar(
        context,
        index: _index,
        onTap: (v) => setState(() => _index = v),
      ),
    );
  }
}

// ─── Settings tab (5th bottom nav item) ─────────────────────────────

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    final data = DataService.instance;
    return StreamBuilder(
      stream: data.authState(),
      builder: (context, _) {
        final user = data.currentUser;
        return ListView(
          padding: EdgeInsets.only(top: 0, bottom: 100),
          children: [
            _AppHeader(
              actions: [
                IconButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationScreen())),
                  icon: const Icon(Icons.notifications_outlined, color: Color(0xFF64748B)),
                ),
              ],
            ),
            Padding(
              padding: _pagePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  if (user == null)
                    AppCard(
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.person_outline_rounded, color: Color(0xFF2563EB), size: 28),
                          ),
                          const SizedBox(height: 12),
                          Text(tr('Welcome!', 'স্বাগতম!'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF0F172A))),
                          const SizedBox(height: 4),
                          Text(tr('Login to access all features', 'সব ফিচার ব্যবহার করতে লগইন করুন'), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
                              child: Text(tr('Login', 'লগইন')),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    AppCard(
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.person_rounded, color: Color(0xFF2563EB), size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.email?.split('@').first ?? tr('Citizen', 'নাগরিক'), style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                                const SizedBox(height: 2),
                                Text(user.email ?? '', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: data.signOut,
                            child: Text(tr('Logout', 'লগআউট'), style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(tr('Preferences', 'পছন্দসমূহ'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF0F172A))),
                  const SizedBox(height: 8),
                  ValueListenableBuilder(
                    valueListenable: accessibilityController,
                    builder: (context, AccessibilitySettings settings, _) {
                      return AppCard(
                        child: Column(
                          children: [
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              activeColor: const Color(0xFF2563EB),
                              title: Text(tr('Large text mode', 'বড় লেখা মোড'), style: const TextStyle(color: Color(0xFF334155))),
                              value: settings.largeText,
                              onChanged: accessibilityController.setLargeText,
                            ),
                            const Divider(),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              activeColor: const Color(0xFF2563EB),
                              title: Text(tr('High contrast mode', 'উচ্চ কনট্রাস্ট মোড'), style: const TextStyle(color: Color(0xFF334155))),
                              value: settings.highContrast,
                              onChanged: accessibilityController.setHighContrast,
                            ),
                            const Divider(),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(tr('Language', 'ভাষা'), style: const TextStyle(color: Color(0xFF334155))),
                              trailing: SegmentedButton<String>(
                                showSelectedIcon: false,
                                selected: {settings.languageCode},
                                onSelectionChanged: (v) => accessibilityController.setLanguageCode(v.first),
                                segments: [
                                  ButtonSegment(value: 'en', label: Text(tr('EN', 'EN'))),
                                  ButtonSegment(value: 'bn', label: Text(tr('বা', 'বা'))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Home screen ────────────────────────────────────────────────────

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = DataService.instance;
    return StreamBuilder<VillageOverview>(
      stream: data.villageOverview(),
      builder: (context, snap) {
        final overview = snap.data ?? const VillageOverview(name: 'Our Village', totalCitizens: 0, totalFundCollected: 0, totalSpent: 0);
        return RefreshIndicator(
          color: const Color(0xFF2563EB),
          onRefresh: () async {
            await Future.wait([
              data.villageOverview().first,
              data.donations(limit: 8).first,
              data.problems(limit: 8).first,
              data.projects(limit: 8).first,
            ]);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              _AppHeader(
                actions: [
                  IconButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationScreen())),
                    icon: const Icon(Icons.notifications_outlined, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              Padding(
                padding: _pagePadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroCard(
                      title: overview.name,
                      subtitle: tr('Transparent village fund & development updates', 'স্বচ্ছ গ্রাম তহবিল ও উন্নয়ন আপডেট'),
                      chips: [
                        '${overview.totalCitizens} ${tr('citizens', 'নাগরিক')}',
                        '${currency.format(overview.availableBalance)} ${tr('available', 'উপলব্ধ')}',
                      ],
                    ),
                    const SizedBox(height: 20),
                    _HomeSectionTitle(
                      title: tr('Money Cashflow', 'অর্থ প্রবাহ'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: tr('Collected', 'সংগৃহীত'),
                            value: currency.format(overview.totalFundCollected),
                            color: const Color(0xFF059669),
                            icon: Icons.arrow_upward_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: tr('Spent', 'ব্যয়'),
                            value: currency.format(overview.totalSpent),
                            color: const Color(0xFFDC2626),
                            icon: Icons.arrow_downward_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _StatCard(
                      label: tr('Registered Citizens', 'নিবন্ধিত নাগরিক'),
                      value: '${overview.totalCitizens}',
                      color: const Color(0xFF2563EB),
                      icon: Icons.people_rounded,
                    ),
                    const SizedBox(height: 20),
                    _HomeSectionTitle(title: tr('Recent Donations', 'সাম্প্রতিক অনুদান')),
                    const SizedBox(height: 8),
                    StreamBuilder<List<Donation>>(
                      stream: data.donations(limit: 8),
                      builder: (context, ds) => _HorizontalDonationList(items: ds.data ?? const []),
                    ),
                    const SizedBox(height: 20),
                    _HomeSectionTitle(title: tr('Latest Problems', 'সাম্প্রতিক সমস্যা')),
                    const SizedBox(height: 8),
                    StreamBuilder<List<ProblemReport>>(
                      stream: data.problems(limit: 8),
                      builder: (context, ps) => _HorizontalProblemList(items: ps.data ?? const []),
                    ),
                    const SizedBox(height: 20),
                    _HomeSectionTitle(title: tr('Active Projects', 'চলমান প্রকল্প')),
                    const SizedBox(height: 8),
                    StreamBuilder<List<DevelopmentProject>>(
                      stream: data.projects(limit: 8),
                      builder: (context, pr) {
                        final items = (pr.data ?? const <DevelopmentProject>[]).where((e) => e.status != 'Completed').toList();
                        return _HorizontalProjectList(items: items);
                      },
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Village Fund screen ────────────────────────────────────────────

class VillageFundScreen extends StatelessWidget {
  const VillageFundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = DataService.instance;
    return StreamBuilder<VillageOverview>(
      stream: data.villageOverview(),
      builder: (context, snap) {
        final overview = snap.data ?? const VillageOverview(name: 'Our Village', totalCitizens: 0, totalFundCollected: 0, totalSpent: 0);
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            _AppHeader(
              actions: [
                IconButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationScreen())),
                  icon: const Icon(Icons.notifications_outlined, color: Color(0xFF64748B)),
                ),
              ],
            ),
            Padding(
              padding: _pagePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FundProgressCard(overview: overview),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final ok = await _ensureLogin(context);
                        if (!context.mounted || !ok) return;
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DonateScreen()));
                      },
                      icon: const Icon(Icons.volunteer_activism_rounded, size: 20),
                      label: Text(tr('Donate Now', 'এখন অনুদান দিন')),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _HomeSectionTitle(title: tr('Fund Growth', 'তহবিলের বৃদ্ধি'), trailing: Text(tr('Last 6 months', 'গত ৬ মাস'), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13))),
                  const SizedBox(height: 8),
                  StreamBuilder<List<Donation>>(
                    stream: data.donations(limit: 60),
                    builder: (context, ds) => _FundGrowthChart(donations: ds.data ?? const []),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Donate screen ──────────────────────────────────────────────────

class DonateScreen extends StatefulWidget {
  const DonateScreen({super.key});

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  String _method = 'bKash';
  bool _submitting = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('Donate to Fund', 'তহবিলে অনুদান'))),
      body: ListView(
        padding: _pagePadding(context),
        children: [
          AppCard(
            child: Form(
              key: _form,
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.volunteer_activism_rounded, color: Color(0xFF2563EB), size: 28),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amount,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: tr('Donation Amount', 'অনুদানের পরিমাণ'),
                      prefixIcon: const Icon(Icons.attach_money_rounded),
                    ),
                    validator: (v) {
                      final n = double.tryParse((v ?? '').trim());
                      if (n == null || n <= 0) return tr('Enter a valid donation amount', 'সঠিক অনুদানের পরিমাণ লিখুন');
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _method,
                    items: const [
                      DropdownMenuItem(value: 'bKash', child: Text('bKash')),
                      DropdownMenuItem(value: 'Nagad', child: Text('Nagad')),
                      DropdownMenuItem(value: 'Rocket', child: Text('Rocket')),
                      DropdownMenuItem(value: 'Manual Transfer', child: Text('Manual Transfer')),
                    ],
                    onChanged: (v) => setState(() => _method = v ?? 'bKash'),
                    decoration: InputDecoration(
                      labelText: tr('Payment Method', 'পেমেন্ট পদ্ধতি'),
                      prefixIcon: const Icon(Icons.payment_rounded),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: Text(_submitting ? tr('Processing...', 'প্রসেস করা হচ্ছে...') : tr('Confirm Donation', 'অনুদান নিশ্চিত করুন')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      final amount = double.parse(_amount.text.trim());
      await DataService.instance.addDonation(amount: amount, paymentMethod: _method);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${tr('Donation added', 'অনুদান যুক্ত হয়েছে')}: ${currency.format(amount)}')));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${tr('Error', 'ত্রুটি')}: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

// ─── Projects screen ────────────────────────────────────────────────

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DevelopmentProject>>(
      stream: DataService.instance.projects(),
      builder: (context, snap) {
        final items = snap.data ?? const <DevelopmentProject>[];
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            _AppHeader(
              actions: [
                IconButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationScreen())),
                  icon: const Icon(Icons.notifications_outlined, color: Color(0xFF64748B)),
                ),
              ],
            ),
            Padding(
              padding: _pagePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroCard(
                    title: tr('Development Projects', 'উন্নয়ন প্রকল্প'),
                    subtitle: tr('Track planning and execution updates', 'পরিকল্পনা ও বাস্তবায়নের আপডেট দেখুন'),
                    chips: ['${items.length} ${tr('projects', 'প্রকল্প')}'],
                  ),
                  const SizedBox(height: 16),
                  if (items.isEmpty)
                    EmptyStateCard(
                      icon: Icons.construction_outlined,
                      title: tr('No projects available', 'কোনো প্রকল্প নেই'),
                      message: tr('Upcoming development projects will appear here.', 'আসন্ন উন্নয়ন প্রকল্পগুলো এখানে দেখাবে।'),
                    )
                  else
                    ...items.map(
                      (p) => ProjectCard(
                        item: p,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: p))),
                      ),
                    ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key, required this.project});

  final DevelopmentProject project;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(project.title)),
      body: ListView(
        padding: _pagePadding(context),
        children: [
          ProjectCard(item: project),
          const SizedBox(height: 8),
          AppCard(child: Text(project.description, style: const TextStyle(color: Color(0xFF334155), height: 1.5))),
          const SizedBox(height: 16),
          _HomeSectionTitle(title: tr('Progress Timeline', 'অগ্রগতির টাইমলাইন')),
          const SizedBox(height: 8),
          if (project.updates.isEmpty)
            EmptyStateCard(
              icon: Icons.timeline_outlined,
              title: tr('No updates yet', 'এখনও কোনো আপডেট নেই'),
              message: tr('Progress updates will be added by project admins.', 'প্রকল্প অ্যাডমিনরা অগ্রগতির আপডেট যোগ করবেন।'),
            )
          else
            ...project.updates.map((e) => AppCard(child: Text(e, style: const TextStyle(color: Color(0xFF334155))))),
        ],
      ),
    );
  }
}

// ─── Problems screen ────────────────────────────────────────────────

class ProblemsScreen extends StatefulWidget {
  const ProblemsScreen({super.key});

  @override
  State<ProblemsScreen> createState() => _ProblemsScreenState();
}

class _ProblemsScreenState extends State<ProblemsScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProblemReport>>(
      stream: DataService.instance.problems(),
      builder: (context, snap) {
        final all = snap.data ?? const <ProblemReport>[];
        final list = _filter == 'All' ? all : all.where((e) => e.status.toLowerCase() == _filter.toLowerCase()).toList();
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            _AppHeader(
              actions: [
                IconButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationScreen())),
                  icon: const Icon(Icons.notifications_outlined, color: Color(0xFF64748B)),
                ),
              ],
            ),
            Padding(
              padding: _pagePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroCard(
                    title: tr('Community Problems', 'কমিউনিটির সমস্যা'),
                    subtitle: tr('Filter and review reported issues', 'রিপোর্ট করা সমস্যাগুলো ফিল্টার করে দেখুন'),
                    chips: ['${all.length} ${tr('reports', 'রিপোর্ট')}'],
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    showSelectedIcon: false,
                    selected: {_filter},
                    onSelectionChanged: (v) => setState(() => _filter = v.first),
                    segments: [
                      ButtonSegment(value: 'All', label: Text(tr('All', 'সব'))),
                      ButtonSegment(value: 'Pending', label: Text(tr('Pending', 'মুলতুবি'))),
                      ButtonSegment(value: 'Approved', label: Text(tr('Approved', 'অনুমোদিত'))),
                      ButtonSegment(value: 'Completed', label: Text(tr('Done', 'সম্পন্ন'))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (list.isEmpty)
                    EmptyStateCard(
                      icon: Icons.filter_alt_off_outlined,
                      title: tr('No matching problems', 'মিলছে এমন সমস্যা নেই'),
                      message: tr('Try another filter or check again later.', 'অন্য ফিল্টার চেষ্টা করুন বা পরে আবার দেখুন।'),
                    )
                  else
                    ...list.map((e) => ProblemViewCard(item: e)),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class ProblemViewCard extends StatelessWidget {
  const ProblemViewCard({super.key, required this.item, this.compact = false});

  final ProblemReport item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: compact ? 320 : null,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A)))),
                const SizedBox(width: 8),
                StatusBadge(text: item.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Text(item.location, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              ],
            ),
            const SizedBox(height: 6),
            Text(item.description, maxLines: compact ? 2 : 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// ─── Report problem screen ──────────────────────────────────────────

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  File? _photo;
  bool _submitting = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('Report a Problem', 'সমস্যা রিপোর্ট করুন'))),
      body: ListView(
        padding: _pagePadding(context),
        children: [
          AppCard(
            child: Form(
              key: _form,
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.report_problem_outlined, color: Color(0xFFDC2626), size: 28),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _title,
                    decoration: InputDecoration(labelText: tr('Title', 'শিরোনাম'), prefixIcon: const Icon(Icons.title_rounded)),
                    validator: (v) => (v == null || v.trim().isEmpty) ? tr('Required', 'প্রয়োজনীয়') : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _description,
                    minLines: 3,
                    maxLines: 6,
                    decoration: InputDecoration(labelText: tr('Description', 'বিবরণ'), prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 40), child: Icon(Icons.description_outlined))),
                    validator: (v) => (v == null || v.trim().isEmpty) ? tr('Required', 'প্রয়োজনীয়') : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _location,
                    decoration: InputDecoration(labelText: tr('Location', 'অবস্থান'), prefixIcon: const Icon(Icons.location_on_outlined)),
                    validator: (v) => (v == null || v.trim().isEmpty) ? tr('Required', 'প্রয়োজনীয়') : null,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _pickPhoto,
                      icon: const Icon(Icons.add_a_photo_outlined),
                      label: Text(_photo == null ? tr('Upload Photo', 'ছবি আপলোড করুন') : tr('Photo selected ✓', 'ছবি নির্বাচন করা হয়েছে ✓')),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: Text(_submitting ? tr('Submitting...', 'জমা দেওয়া হচ্ছে...') : tr('Submit Report', 'রিপোর্ট জমা দিন')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (img == null) return;
    setState(() => _photo = File(img.path));
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      await DataService.instance.reportProblem(title: _title.text.trim(), description: _description.text.trim(), location: _location.text.trim(), photo: _photo);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('Problem reported successfully', 'সমস্যা সফলভাবে রিপোর্ট করা হয়েছে'))));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${tr('Error', 'ত্রুটি')}: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

// ─── Citizens page ──────────────────────────────────────────────────

class CitizensPage extends StatelessWidget {
  const CitizensPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('Citizens', 'নাগরিক'))),
      body: const CitizensScreen(),
    );
  }
}

class CitizensScreen extends StatefulWidget {
  const CitizensScreen({super.key});

  @override
  State<CitizensScreen> createState() => _CitizensScreenState();
}

class _CitizensScreenState extends State<CitizensScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Citizen>>(
      stream: DataService.instance.citizens(),
      builder: (context, snap) {
        final all = snap.data ?? const <Citizen>[];
        final q = _search.text.trim().toLowerCase();
        final filtered = all.where((c) => c.name.toLowerCase().contains(q) || c.profession.toLowerCase().contains(q)).toList();

        return ListView(
          padding: _pagePadding(context),
          children: [
            TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: tr('Search name or profession', 'নাম বা পেশা লিখে খুঁজুন'),
                prefixIcon: const Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 12),
            if (filtered.isEmpty)
              EmptyStateCard(
                icon: Icons.search_off,
                title: tr('No matching citizens', 'মিলছে এমন নাগরিক নেই'),
                message: tr('Try a different name or profession keyword.', 'অন্য নাম বা পেশার কীওয়ার্ড চেষ্টা করুন।'),
              )
            else
              ...filtered.map(
                (c) => AppCard(
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            c.name.isEmpty ? '?' : c.name[0].toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2563EB), fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                            const SizedBox(height: 2),
                            Text(c.profession, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─── Leaderboard page ───────────────────────────────────────────────

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('Leaderboard', 'লিডারবোর্ড'))),
      body: const LeaderboardScreen(),
    );
  }
}

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  bool _monthly = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Donation>>(
      stream: DataService.instance.donations(limit: 500),
      builder: (context, snap) {
        var donations = snap.data ?? const <Donation>[];
        if (_monthly) {
          final now = DateTime.now();
          donations = donations.where((d) => d.createdAt.year == now.year && d.createdAt.month == now.month).toList();
        }
        final totals = <String, double>{};
        for (final d in donations) {
          totals[d.donorName] = (totals[d.donorName] ?? 0) + d.amount;
        }
        final ranking = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

        return ListView(
          padding: _pagePadding(context),
          children: [
            SegmentedButton<bool>(
              showSelectedIcon: false,
              selected: {_monthly},
              onSelectionChanged: (v) => setState(() => _monthly = v.first),
              segments: [
                ButtonSegment(value: false, label: Text(tr('All Time', 'সর্বমোট'))),
                ButtonSegment(value: true, label: Text(tr('Monthly', 'মাসিক'))),
              ],
            ),
            const SizedBox(height: 12),
            if (ranking.isEmpty)
              EmptyStateCard(
                icon: Icons.leaderboard_outlined,
                title: tr('No leaderboard data', 'লিডারবোর্ড ডেটা নেই'),
                message: tr('Donor ranking will appear when donations are made.', 'অনুদান এলে দাতার র‌্যাংকিং এখানে দেখাবে।'),
              )
            else
              ...ranking.asMap().entries.map(
                (e) {
                  final rank = e.key + 1;
                  final isTop3 = rank <= 3;
                  final colors = [const Color(0xFFFBBF24), const Color(0xFF94A3B8), const Color(0xFFCD7F32)];
                  return AppCard(
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isTop3 ? colors[rank - 1].withValues(alpha: 0.15) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '$rank',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isTop3 ? colors[rank - 1] : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(e.value.key, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF0F172A)))),
                        Text(currency.format(e.value.value), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF059669))),
                      ],
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

// ─── Profile screen (now accessed from sidebar) ─────────────────────

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = DataService.instance;
    return Scaffold(
      appBar: AppBar(title: Text(tr('Profile', 'প্রোফাইল'))),
      body: StreamBuilder(
        stream: data.authState(),
        builder: (context, _) {
          final user = data.currentUser;
          return ListView(
            padding: _pagePadding(context),
            children: [
              if (user == null)
                AppCard(
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.person_outline_rounded, color: Color(0xFF2563EB), size: 28),
                      ),
                      const SizedBox(height: 12),
                      Text(tr('Not logged in', 'লগইন করা হয়নি'), style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
                          child: Text(tr('Login with Email', 'ইমেইল দিয়ে লগইন')),
                        ),
                      ),
                    ],
                  ),
                )
              else
                AppCard(
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.person_rounded, color: Color(0xFF2563EB)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.email?.split('@').first ?? tr('Citizen', 'নাগরিক'), style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                            Text(user.email ?? '', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                          ],
                        ),
                      ),
                      TextButton(onPressed: data.signOut, child: Text(tr('Logout', 'লগআউট'), style: const TextStyle(color: Color(0xFFDC2626)))),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Login screen — Modern Spendly style ────────────────────────────

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _link = TextEditingController();
  bool _loading = false;
  bool _otpSent = false;

  @override
  void dispose() {
    _email.dispose();
    _link.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 40),
            // Logo
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.location_city_rounded, color: Colors.white, size: 36),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                tr('Welcome Back', 'স্বাগতম'),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), letterSpacing: -0.5),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                tr('Login to your village account', 'আপনার গ্রাম অ্যাকাউন্টে লগইন করুন'),
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              ),
            ),
            const SizedBox(height: 32),
            // Card
            AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('Email Address', 'ইমেইল ঠিকানা'),
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155), fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: tr('you@example.com', 'you@example.com'),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _loading ? null : _sendLink,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_loading)
                            const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                            ),
                          Text(_otpSent
                            ? tr('Resend OTP Link', 'OTP লিংক পুনরায় পাঠান')
                            : tr('Send OTP Link', 'OTP লিংক পাঠান')),
                        ],
                      ),
                    ),
                  ),
                  if (_otpSent) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              tr('Check your email inbox and paste the login link below.', 'আপনার ইমেইল ইনবক্স চেক করুন এবং নীচে লগইন লিংক পেস্ট করুন।'),
                              style: const TextStyle(color: Color(0xFF2563EB), fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      tr('Verification Link', 'যাচাইকরণ লিংক'),
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155), fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _link,
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: tr('Paste the link from your email', 'ইমেইল থেকে লিংক পেস্ট করুন'),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: Icon(Icons.link_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _loading ? null : _verify,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_loading)
                              const Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                              ),
                            Text(tr('Verify & Login', 'যাচাই করে লগইন')),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(tr('Back to app', 'অ্যাপে ফিরে যান'), style: const TextStyle(color: Color(0xFF64748B))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendLink() async {
    if (!_email.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('Enter a valid email address', 'সঠিক ইমেইল ঠিকানা দিন'))));
      return;
    }
    setState(() => _loading = true);
    try {
      await DataService.instance.sendLoginLink(_email.text.trim());
      if (!mounted) return;
      setState(() => _otpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('Email OTP link sent!', 'ইমেইল OTP লিংক পাঠানো হয়েছে!'))));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${tr('Error', 'ত্রুটি')}: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verify() async {
    setState(() => _loading = true);
    try {
      await DataService.instance.signInWithEmailLink(email: _email.text.trim(), emailLink: _link.text.trim());
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${tr('Error', 'ত্রুটি')}: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

// ─── Notifications screen ───────────────────────────────────────────

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _filter = 'All';

  IconData _iconFor(String type) {
    switch (type) {
      case 'donation':
        return Icons.volunteer_activism_outlined;
      case 'problem':
        return Icons.report_problem_outlined;
      default:
        return Icons.construction_outlined;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'donation':
        return const Color(0xFF059669);
      case 'problem':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF2563EB);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = DataService.instance;
    return StreamBuilder<List<AppNotification>>(
      stream: data.notifications(limit: 120),
      builder: (context, notifSnap) {
        final notifications = notifSnap.data ?? const <AppNotification>[];
        return StreamBuilder<Set<String>>(
          stream: data.myReadNotificationIds(),
          builder: (context, readSnap) {
            final readIds = readSnap.data ?? <String>{};
            final filtered = notifications.where((n) {
              if (_filter == 'Read') return readIds.contains(n.id);
              if (_filter == 'Unread') return !readIds.contains(n.id);
              return true;
            }).toList();

            return Scaffold(
              appBar: AppBar(
                title: Text(tr('Notifications', 'নোটিফিকেশন')),
                actions: [
                  IconButton(
                    onPressed: () async {
                      final ok = await _ensureLogin(context);
                      if (!context.mounted || !ok) return;
                      await data.markAllNotificationsRead(notifications.map((e) => e.id));
                    },
                    icon: const Icon(Icons.done_all_rounded),
                  ),
                ],
              ),
              body: ListView(
                padding: _pagePadding(context),
                children: [
                  SegmentedButton<String>(
                    showSelectedIcon: false,
                    selected: {_filter},
                    onSelectionChanged: (v) => setState(() => _filter = v.first),
                    segments: [
                      ButtonSegment(value: 'All', label: Text(tr('All', 'সব'))),
                      ButtonSegment(value: 'Unread', label: Text(tr('Unread', 'অপঠিত'))),
                      ButtonSegment(value: 'Read', label: Text(tr('Read', 'পঠিত'))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (filtered.isEmpty)
                    EmptyStateCard(
                      icon: Icons.notifications_off_outlined,
                      title: tr('No notifications', 'কোনো নোটিফিকেশন নেই'),
                      message: tr('There are no updates in this filter right now.', 'এই ফিল্টারে এখন কোনো আপডেট নেই।'),
                    )
                  else
                    ...filtered.map(
                      (n) {
                        final isRead = readIds.contains(n.id);
                        final color = _colorFor(n.type);
                        return AppCard(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(_iconFor(n.type), color: color, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n.message,
                                      style: TextStyle(
                                        fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
                                        color: const Color(0xFF0F172A),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('dd MMM, hh:mm a').format(n.createdAt),
                                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  final ok = await _ensureLogin(context);
                                  if (!context.mounted || !ok) return;
                                  if (isRead) {
                                    await data.markNotificationUnread(n.id);
                                  } else {
                                    await data.markNotificationRead(n.id);
                                  }
                                },
                                icon: Icon(
                                  isRead ? Icons.mark_email_read_outlined : Icons.mark_email_unread_outlined,
                                  color: isRead ? const Color(0xFF94A3B8) : const Color(0xFF2563EB),
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Shared widgets ─────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.title, required this.subtitle, required this.chips});

  final String title;
  final String subtitle;
  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDBEAFE), Color(0xFFEFF6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFDBFE).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E3A5F), letterSpacing: -0.3)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips
                .map((e) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Text(e, style: const TextStyle(color: Color(0xFF2563EB), fontSize: 12, fontWeight: FontWeight.w600)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.color, required this.icon});

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeSectionTitle extends StatelessWidget {
  const _HomeSectionTitle({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), letterSpacing: -0.2)),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _HorizontalDonationList extends StatelessWidget {
  const _HorizontalDonationList({required this.items});

  final List<Donation> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyStateCard(
        icon: Icons.volunteer_activism_outlined,
        title: tr('No donations available', 'কোনো অনুদান পাওয়া যায়নি'),
        message: tr('Recent donation records will be visible here.', 'সাম্প্রতিক অনুদানের রেকর্ড এখানে দেখাবে।'),
      );
    }
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) => DonationCard(item: items[i], compact: true),
      ),
    );
  }
}

class _HorizontalProblemList extends StatelessWidget {
  const _HorizontalProblemList({required this.items});

  final List<ProblemReport> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyStateCard(
        icon: Icons.warning_amber_outlined,
        title: tr('No reported problems', 'কোনো রিপোর্ট করা সমস্যা নেই'),
        message: tr('Problem reports from citizens will appear here.', 'নাগরিকদের সমস্যা রিপোর্ট এখানে দেখাবে।'),
      );
    }
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) => ProblemViewCard(item: items[i], compact: true),
      ),
    );
  }
}

class _HorizontalProjectList extends StatelessWidget {
  const _HorizontalProjectList({required this.items});

  final List<DevelopmentProject> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyStateCard(
        icon: Icons.construction_outlined,
        title: tr('No active projects', 'কোনো সক্রিয় প্রকল্প নেই'),
        message: tr('New development initiatives will be listed here.', 'নতুন উন্নয়ন উদ্যোগগুলো এখানে তালিকাভুক্ত হবে।'),
      );
    }
    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) => ProjectCard(item: items[i], compact: true),
      ),
    );
  }
}

// ─── Fund growth chart ──────────────────────────────────────────────

class _FundGrowthChart extends StatelessWidget {
  const _FundGrowthChart({required this.donations});

  final List<Donation> donations;

  @override
  Widget build(BuildContext context) {
    if (donations.isEmpty) {
      return EmptyStateCard(
        icon: Icons.show_chart,
        title: tr('No chart data yet', 'এখনও চার্টের তথ্য নেই'),
        message: tr('Fund growth chart will appear after donations are recorded.', 'অনুদানের রেকর্ড যোগ হলে তহবিল বৃদ্ধির চার্ট দেখাবে।'),
      );
    }
    final grouped = <String, double>{};
    for (final d in donations) {
      final key = DateFormat('MMM').format(d.createdAt);
      grouped[key] = (grouped[key] ?? 0) + d.amount;
    }
    final entries = grouped.entries.toList();

    return AppCard(
      child: SizedBox(
        height: 190,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    final i = value.toInt();
                    if (i < 0 || i >= entries.length) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(entries[i].key, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                color: const Color(0xFF2563EB),
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                    radius: 3,
                    color: const Color(0xFF2563EB),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2563EB).withValues(alpha: 0.15),
                      const Color(0xFF2563EB).withValues(alpha: 0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                spots: List.generate(entries.length, (i) => FlSpot(i.toDouble(), entries[i].value)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Login gate ─────────────────────────────────────────────────────

Future<bool> _ensureLogin(BuildContext context) async {
  if (DataService.instance.currentUser != null) {
    return true;
  }

  final proceed = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.lock_outline_rounded, color: Color(0xFF2563EB), size: 28),
            ),
            const SizedBox(height: 16),
            Text(tr('Login Required', 'লগইন প্রয়োজন'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            Text(
              tr('Please login to continue with this action.', 'এই কাজটি চালিয়ে যেতে লগইন করুন।'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(tr('Continue to Login', 'লগইনে এগিয়ে যান')),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  if (proceed != true || !context.mounted) {
    return false;
  }

  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
  return DataService.instance.currentUser != null;
}
