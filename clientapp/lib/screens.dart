import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

// ─── Visually stunning custom app header ────────────────────────────

class _AppHeader extends StatelessWidget {
  const _AppHeader({this.actions});
  final List<Widget>? actions;

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return tr('Good Morning', 'শুভ সকাল');
    if (h < 17) return tr('Good Afternoon', 'শুভ অপরাহ্ন');
    return tr('Good Evening', 'শুভ সন্ধ্যা');
  }

  @override
  Widget build(BuildContext context) {
    final user = DataService.instance.currentUser;
    final name = user?.displayName?.split(' ').first ?? tr('Villager', 'গ্রামবাসী');
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9500), Color(0xFFFF6B00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9500).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.location_city_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greeting()}, $name',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 1),
                Text(
                  tr('Doulatpara', 'দৌলতপাড়া'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1C1C1E), letterSpacing: -0.5),
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
              color: const Color(0xFFFFF8F0),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFE0B2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9500),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.location_city_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 14),
                Text(tr('Doulatpara', 'দৌলতপাড়া'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E))),
                const SizedBox(height: 4),
                Text(
                  tr('Village development platform', 'গ্রাম উন্নয়ন প্ল্যাটফর্ম'),
                  style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: Text(tr('Village Fund', 'গ্রাম তহবিল')),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VillageFundScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.construction_outlined),
            title: Text(tr('Projects', 'প্রকল্প')),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProjectsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: Text(tr('Citizens', 'নাগরিক')),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CitizensPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.leaderboard_outlined),
            title: Text(tr('Leaderboard', 'লিডারবোর্ড')),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LeaderboardPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(tr('Notifications', 'নোটিফিকেশন')),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: Text(tr('Profile', 'প্রোফাইল')),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
          FutureBuilder<bool>(
            future: DataService.instance.isAdmin(),
            builder: (context, snap) {
              if (snap.data != true) return const SizedBox.shrink();
              return Column(
                children: [
                  const Divider(height: 24),
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings_outlined, color: Color(0xFFFF9500)),
                    title: Text(tr('Admin Panel', 'অ্যাডমিন প্যানেল'), style: const TextStyle(color: Color(0xFFFF9500), fontWeight: FontWeight.w600)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminPanelScreen()));
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ),
  );
}

Widget _buildBottomTabBar(BuildContext context, {required int index, required ValueChanged<int> onTap}) {
  return Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 0.5)),
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavIcon(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: tr('Home', 'হোম'), active: index == 0, onTap: () => onTap(0)),
            _NavIcon(icon: Icons.warning_amber_outlined, activeIcon: Icons.warning_amber_rounded, label: tr('Issues', 'সমস্যা'), active: index == 1, onTap: () => onTap(1)),
            _NavIcon(icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: tr('Profile', 'প্রোফাইল'), active: index == 2, onTap: () => onTap(2)),
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
                color: active ? const Color(0xFFFFF8F0) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                active ? activeIcon : icon,
                color: active ? const Color(0xFFFF9500) : const Color(0xFF8E8E93),
                size: 24,
              ),
            ),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: active ? FontWeight.w600 : FontWeight.w500, color: active ? const Color(0xFFFF9500) : const Color(0xFF8E8E93))),
          ],
        ),
      ),
    );
  }
}

// ─── Profile & Settings tab (bottom nav index 2) ───────────────────

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
                  icon: const Icon(Icons.notifications_outlined, color: Color(0xFF8E8E93)),
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
                              color: const Color(0xFFFFF8F0),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.person_outline_rounded, color: Color(0xFFFF9500), size: 28),
                          ),
                          const SizedBox(height: 12),
                          Text(tr('Welcome!', 'স্বাগতম!'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1C1C1E))),
                          const SizedBox(height: 4),
                          Text(tr('Login to access all features', 'সব ফিচার ব্যবহার করতে লগইন করুন'), style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13)),
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
                    GestureDetector(
                      onTap: () async {
                        final profile = await DataService.instance.getUserProfile();
                        if (!context.mounted) return;
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ProfileSetupScreen(existingProfile: profile),
                        ));
                      },
                      child: AppCard(
                        child: Row(
                          children: [
                            user.photoURL != null
                                ? CircleAvatar(
                                    radius: 24,
                                    backgroundImage: NetworkImage(user.photoURL!),
                                  )
                                : const CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Color(0xFFFFF8F0),
                                    child: Icon(Icons.person_rounded, color: Color(0xFFFF9500), size: 24),
                                  ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.displayName ?? user.email?.split('@').first ?? tr('Citizen', 'নাগরিক'), style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
                                  const SizedBox(height: 2),
                                  Text(user.email ?? '', style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12)),
                                  const SizedBox(height: 2),
                                  Text(tr('Tap to edit profile', 'প্রোফাইল সম্পাদনা করতে ট্যাপ করুন'), style: const TextStyle(color: Color(0xFFFF9500), fontSize: 11, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8F0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.edit_rounded, color: Color(0xFFFF9500), size: 16),
                            ),
                            const SizedBox(width: 4),
                            TextButton(
                              onPressed: data.signOut,
                              child: Text(tr('Logout', 'লগআউট'), style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w600, fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(tr('Preferences', 'পছন্দসমূহ').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF8E8E93), letterSpacing: 0.8)),
                  const SizedBox(height: 8),
                  ValueListenableBuilder(
                    valueListenable: accessibilityController,
                    builder: (context, AccessibilitySettings settings, _) {
                      return AppCard(
                        child: Column(
                          children: [
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              activeThumbColor: const Color(0xFFFF9500),
                              title: Text(tr('High contrast mode', 'উচ্চ কনট্রাস্ট মোড'), style: const TextStyle(color: Color(0xFF1C1C1E))),
                              value: settings.highContrast,
                              onChanged: accessibilityController.setHighContrast,
                            ),
                            const Divider(),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(tr('Language', 'ভাষা'), style: const TextStyle(color: Color(0xFF1C1C1E))),
                              trailing: SegmentedButton<String>(
                                showSelectedIcon: false,
                                selected: {settings.languageCode},
                                onSelectionChanged: (v) => accessibilityController.setLanguageCode(v.first),
                                segments: const [
                                  ButtonSegment(value: 'en', label: Text('English')),
                                  ButtonSegment(value: 'bn', label: Text('বাংলা')),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(tr('Quick Links', 'দ্রুত লিংক').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF8E8E93), letterSpacing: 0.8)),
                  const SizedBox(height: 8),
                  AppCard(
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(color: const Color(0xFFFF9500).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFFFF9500), size: 18),
                          ),
                          title: Text(tr('Village Fund', 'গ্রাম তহবিল'), style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
                          trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF8E8E93)),
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VillageFundScreen())),
                        ),
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(color: const Color(0xFF007AFF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.construction_rounded, color: Color(0xFF007AFF), size: 18),
                          ),
                          title: Text(tr('Projects', 'প্রকল্প'), style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
                          trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF8E8E93)),
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProjectsScreen())),
                        ),
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(color: const Color(0xFF007AFF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.people_rounded, color: Color(0xFF007AFF), size: 18),
                          ),
                          title: Text(tr('Citizens', 'নাগরিক'), style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
                          trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF8E8E93)),
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CitizensPage())),
                        ),
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(color: const Color(0xFF34C759).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.leaderboard_rounded, color: Color(0xFF34C759), size: 18),
                          ),
                          title: Text(tr('Leaderboard', 'লিডারবোর্ড'), style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
                          trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF8E8E93)),
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LeaderboardPage())),
                        ),
                      ],
                    ),
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
    ProblemsScreen(),
    _SettingsTab(),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, 2);
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = DataService.instance;
    final pad = _pagePadding(context);
    return StreamBuilder<VillageOverview>(
      stream: data.villageOverview(),
      builder: (context, snap) {
        final overview = snap.data ?? const VillageOverview(name: 'Our Village', totalCitizens: 0, totalFundCollected: 0, totalSpent: 0);
        return RefreshIndicator(
          color: const Color(0xFFFF9500),
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
            padding: EdgeInsets.only(bottom: 100),
            children: [
              _AppHeader(
                actions: [
                  _HeaderActionButton(
                    icon: Icons.search_rounded,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CitizensPage())),
                  ),
                  const SizedBox(width: 8),
                  _HeaderActionButton(
                    icon: Icons.notifications_outlined,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationScreen())),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ── Hero banner ──
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pad.left),
                child: StreamBuilder<int>(
                  stream: data.citizenCount(),
                  builder: (context, citizenSnap) {
                    final citizenCount = citizenSnap.data ?? overview.totalCitizens;
                    return _HeroCard(
                      title: overview.name,
                      balance: currency.format(overview.availableBalance),
                      citizens: citizenCount,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // ── Quick actions ──
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pad.left),
                child: Row(
                  children: [
                    _QuickAction(
                      icon: Icons.volunteer_activism_rounded,
                      label: tr('Donate', 'অনুদান'),
                      color: const Color(0xFFFF9500),
                      onTap: () async {
                        final ok = await _ensureLogin(context);
                        if (!context.mounted || !ok) return;
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DonateScreen()));
                      },
                    ),
                    const SizedBox(width: 12),
                    _QuickAction(
                      icon: Icons.report_problem_rounded,
                      label: tr('Report', 'রিপোর্ট'),
                      color: const Color(0xFFFF3B30),
                      onTap: () async {
                        final ok = await _ensureLogin(context);
                        if (!context.mounted || !ok) return;
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReportProblemScreen()));
                      },
                    ),
                    const SizedBox(width: 12),
                    _QuickAction(
                      icon: Icons.people_rounded,
                      label: tr('Citizens', 'নাগরিক'),
                      color: const Color(0xFF007AFF),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CitizensPage())),
                    ),
                    const SizedBox(width: 12),
                    _QuickAction(
                      icon: Icons.leaderboard_rounded,
                      label: tr('Leaders', 'লিডার'),
                      color: const Color(0xFF34C759),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LeaderboardPage())),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Stat cards ──
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pad.left),
                child: Row(
                  children: [
                    Expanded(
                      child: _GlassStatCard(
                        icon: Icons.savings_rounded,
                        label: tr('Collected', 'সংগ্রহ'),
                        value: currency.format(overview.totalFundCollected),
                        gradient: const [Color(0xFFFF9500), Color(0xFFFF6B00)],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GlassStatCard(
                        icon: Icons.trending_down_rounded,
                        label: tr('Spent', 'ব্যয়'),
                        value: currency.format(overview.totalSpent),
                        gradient: const [Color(0xFFFF3B30), Color(0xFFFF6259)],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // ── Recent Donations ──
              _SectionHeader(
                title: tr('Recent Donations', 'সাম্প্রতিক অনুদান'),
                onSeeAll: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VillageFundScreen())),
                padding: pad.left,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.only(left: pad.left),
                child: StreamBuilder<List<Donation>>(
                  stream: data.donations(limit: 8),
                  builder: (context, ds) => _HorizontalDonationList(items: ds.data ?? const []),
                ),
              ),
              const SizedBox(height: 22),

              // ── Latest Problems ──
              _SectionHeader(
                title: tr('Latest Problems', 'সাম্প্রতিক সমস্যা'),
                onSeeAll: () => _openRootTab(context, 1),
                padding: pad.left,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.only(left: pad.left),
                child: StreamBuilder<List<ProblemReport>>(
                  stream: data.problems(limit: 8),
                  builder: (context, ps) => _HorizontalProblemList(items: ps.data ?? const []),
                ),
              ),
              const SizedBox(height: 22),

              // ── Active Projects ──
              _SectionHeader(
                title: tr('Active Projects', 'চলমান প্রকল্প'),
                onSeeAll: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProjectsScreen())),
                padding: pad.left,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.only(left: pad.left),
                child: StreamBuilder<List<DevelopmentProject>>(
                  stream: data.projects(limit: 8),
                  builder: (context, pr) {
                    final items = (pr.data ?? const <DevelopmentProject>[]).where((e) => e.status != 'Completed').toList();
                    return _HorizontalProjectList(items: items);
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class VillageFundScreen extends StatelessWidget {
  const VillageFundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = DataService.instance;
    final pad = _pagePadding(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(tr('Village Fund', 'গ্রাম তহবিল')),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: StreamBuilder<VillageOverview>(
        stream: data.villageOverview(),
        builder: (context, snap) {
          final overview = snap.data ?? const VillageOverview(name: 'Our Village', totalCitizens: 0, totalFundCollected: 0, totalSpent: 0);
          return ListView(
            padding: pad,
            children: [
              _PageBanner(
                title: tr('Village Fund', 'গ্রাম তহবিল'),
                subtitle: tr('Track fund collection and spending', 'তহবিল সংগ্রহ ও ব্যয় ট্র্যাক করুন'),
                count: currency.format(overview.availableBalance),
                icon: Icons.account_balance_wallet_rounded,
                color: const Color(0xFFFF9500),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _GlassStatCard(
                      icon: Icons.savings_rounded,
                      label: tr('Collected', 'সংগ্রহ'),
                      value: currency.format(overview.totalFundCollected),
                      gradient: const [Color(0xFFFF9500), Color(0xFFFF6B00)],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GlassStatCard(
                      icon: Icons.trending_down_rounded,
                      label: tr('Spent', 'ব্যয়'),
                      value: currency.format(overview.totalSpent),
                      gradient: const [Color(0xFFFF3B30), Color(0xFFFF6259)],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: () async {
                    final ok = await _ensureLogin(context);
                    if (!context.mounted || !ok) return;
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DonateScreen()));
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9500),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(tr('Donate Now', 'এখন অনুদান দিন'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
              _PageSectionTitle(title: tr('Fund Growth', 'তহবিলের বৃদ্ধি')),
              StreamBuilder<List<Donation>>(
                stream: data.donations(limit: 60),
                builder: (context, ds) => _FundGrowthChart(donations: ds.data ?? const []),
              ),
            ],
          );
        },
      ),
    );
  }
}

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
  String? _method;
  bool _submitting = false;
  bool _submitted = false;

  static const _allMethods = [
    {'key': 'bKash', 'bn': 'বিকাশ', 'color': 0xFFE2136E, 'icon': Icons.phone_android_rounded},
    {'key': 'Nagad', 'bn': 'নগদ', 'color': 0xFFFF6A00, 'icon': Icons.phone_android_rounded},
    {'key': 'Rocket', 'bn': 'রকেট', 'color': 0xFF8B2FA0, 'icon': Icons.phone_android_rounded},
    {'key': 'Bank', 'bn': 'ব্যাংক অ্যাকাউন্ট', 'color': 0xFF1E40AF, 'icon': Icons.account_balance_rounded},
  ];

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(tr('Donate to Fund', 'তহবিলে অনুদান')),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: _submitted ? _buildSuccess() : _buildDonationPage(),
      bottomNavigationBar: _buildBottomTabBar(context, index: 0, onTap: (i) => _openRootTab(context, i)),
    );
  }

  Widget _buildDonationPage() {
    return StreamBuilder<Map<String, Map<String, String>>>(
      stream: DataService.instance.paymentAccounts(),
      builder: (context, snap) {
        final accounts = snap.data ?? {};
        // Only show methods that have an account number configured
        final methods = _allMethods.where((m) {
          final key = m['key'] as String;
          final number = accounts[key]?['number'] ?? '';
          return number.trim().isNotEmpty;
        }).toList();

        // Reset selected method if it was removed from available methods
        if (_method != null && !methods.any((m) => m['key'] == _method)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _method = null);
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
                  gradient: const LinearGradient(colors: [Color(0xFFFF9500), Color(0xFFFF6B00)]),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFFF9500).withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
                  ],
                ),
                child: const Icon(Icons.volunteer_activism_rounded, color: Colors.white, size: 34),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                tr('Make a Donation', 'অনুদান দিন'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E)),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                tr('Select a payment method to donate', 'অনুদান দিতে একটি পেমেন্ট পদ্ধতি নির্বাচন করুন'),
                style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
              ),
            ),
            const SizedBox(height: 20),

            if (methods.isEmpty && snap.hasData)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFFDC2626), size: 32),
                    const SizedBox(height: 8),
                    Text(
                      tr('No payment methods available', 'কোনো পেমেন্ট পদ্ধতি উপলব্ধ নেই'),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFDC2626)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tr('Please contact the admin to set up payment accounts.', 'পেমেন্ট অ্যাকাউন্ট সেট আপ করতে অ্যাডমিনের সাথে যোগাযোগ করুন।'),
                      style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            // Payment method selection
            ...List.generate(methods.length, (i) {
              final m = methods[i];
              final key = m['key'] as String;
              final bn = m['bn'] as String;
              final color = Color(m['color'] as int);
              final icon = m['icon'] as IconData;
              final selected = _method == key;
              final account = accounts[key];
              final number = account?['number'] ?? '';
              final name = account?['name'] ?? '';
              final isBank = key == 'Bank';
              final bankName = account?['bankName'] ?? '';
              final branch = account?['branch'] ?? '';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _method = selected ? null : key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: selected ? color.withValues(alpha: 0.05) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? color : const Color(0xFFE5E7EB),
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
                                child: Text(
                                  tr(key == 'Bank' ? 'Bank Account' : key, bn),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: selected ? color : const Color(0xFF1C1C1E),
                                  ),
                                ),
                              ),
                              Icon(
                                selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                color: selected ? color : const Color(0xFFC7C7CC),
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                        // Show account details when selected
                        if (selected)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  isBank ? tr('Bank Transfer Details', 'ব্যাংক ট্রান্সফারের তথ্য') : tr('Send Money To', 'টাকা পাঠান'),
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
                                ),
                                if (isBank && bankName.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    bankName,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color),
                                  ),
                                  if (branch.isNotEmpty)
                                    Text(
                                      branch,
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
                                    ),
                                ],
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                        Clipboard.setData(ClipboardData(text: number));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(tr('Number copied', 'নম্বর কপি হয়েছে'))),
                                        );
                                      },
                                      child: Icon(Icons.copy_rounded, size: 18, color: color.withValues(alpha: 0.6)),
                                    ),
                                  ],
                                ),
                                if (name.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    name,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E)),
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
            if (_method != null) ...[
              const SizedBox(height: 8),
              AppCard(
                child: Form(
                  key: _txForm,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _method == 'Bank'
                            ? tr('After transferring, fill this form', 'ট্রান্সফারের পর এই ফর্ম পূরণ করুন')
                            : tr('After sending money, fill this form', 'টাকা পাঠানোর পর এই ফর্ম পূরণ করুন'),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E)),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _amount,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: tr('Donation Amount', 'অনুদানের পরিমাণ'),
                          prefixIcon: const Icon(Icons.currency_exchange_rounded, color: Color(0xFFFF9500)),
                        ),
                        validator: (v) {
                          final n = double.tryParse((v ?? '').trim());
                          if (n == null || n <= 0) return tr('Enter a valid donation amount', 'সঠিক অনুদানের পরিমাণ লিখুন');
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _transactionId,
                        decoration: InputDecoration(
                          labelText: _method == 'Bank'
                              ? tr('Transaction/Reference ID', 'ট্রানজেকশন/রেফারেন্স আইডি')
                              : tr('Transaction ID', 'ট্রানজেকশন আইডি'),
                          prefixIcon: const Icon(Icons.receipt_long_rounded, color: Color(0xFFFF9500)),
                        ),
                        validator: (v) {
                          if ((v ?? '').trim().isEmpty) return tr('Enter your transaction ID', 'আপনার ট্রানজেকশন আইডি লিখুন');
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _senderNumber,
                        keyboardType: _method == 'Bank' ? TextInputType.text : TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: _method == 'Bank'
                              ? tr('Sender Account/Phone', 'প্রেরকের অ্যাকাউন্ট/ফোন')
                              : tr('Sender Phone Number', 'প্রেরকের ফোন নম্বর'),
                          prefixIcon: Icon(
                            _method == 'Bank' ? Icons.account_circle_outlined : Icons.phone_rounded,
                            color: const Color(0xFF8E8E93),
                          ),
                        ),
                        validator: (v) {
                          if ((v ?? '').trim().isEmpty) {
                            return _method == 'Bank'
                                ? tr('Enter sender account or phone', 'প্রেরকের অ্যাকাউন্ট বা ফোন নম্বর লিখুন')
                                : tr('Enter a valid phone number', 'সঠিক ফোন নম্বর লিখুন');
                          }
                          if (_method != 'Bank' && (v ?? '').trim().length < 11) {
                            return tr('Enter a valid phone number', 'সঠিক ফোন নম্বর লিখুন');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          onPressed: _submitting ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9500),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(
                            _submitting ? tr('Submitting...', 'জমা হচ্ছে...') : tr('Submit Donation', 'অনুদান জমা দিন'),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ),
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
              gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF34D399)]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 34),
          ),
          const SizedBox(height: 16),
          Text(
            tr('Pending Verification', 'যাচাইয়ের অপেক্ষায়'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E)),
          ),
          const SizedBox(height: 8),
          Text(
            tr(
              'Your donation has been submitted successfully. The admin will verify your payment and approve it shortly.',
              'আপনার অনুদান সফলভাবে জমা হয়েছে। অ্যাডমিন আপনার পেমেন্ট যাচাই করে শীঘ্রই অনুমোদন করবেন।',
            ),
            style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF9500),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                tr('Done', 'সম্পন্ন'),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_txForm.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      final amount = double.parse(_amount.text.trim());
      await DataService.instance.addDonation(
        amount: amount,
        paymentMethod: _method!,
        transactionId: _transactionId.text.trim(),
        senderNumber: _senderNumber.text.trim(),
      );
      if (!mounted) return;
      setState(() => _submitted = true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${tr('Error', 'ত্রুটি')}: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(tr('Projects', 'প্রকল্প')),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: StreamBuilder<List<DevelopmentProject>>(
        stream: DataService.instance.projects(),
        builder: (context, snap) {
          final items = snap.data ?? const <DevelopmentProject>[];
          return ListView(
            padding: _pagePadding(context),
            children: [
              _PageBanner(
                title: tr('Development Projects', 'উন্নয়ন প্রকল্প'),
                subtitle: tr('Track planning and execution updates', 'পরিকল্পনা ও বাস্তবায়নের আপডেট দেখুন'),
                count: '${items.length} ${tr('projects', 'প্রকল্প')}',
                icon: Icons.construction_rounded,
                color: const Color(0xFF007AFF),
              ),
              const SizedBox(height: 12),
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
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomTabBar(context, index: 0, onTap: (i) => _openRootTab(context, i)),
    );
  }
}

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key, required this.project});

  final DevelopmentProject project;

  @override
  Widget build(BuildContext context) {
    final progress = project.estimatedCost > 0 ? (project.allocatedFunds / project.estimatedCost).clamp(0.0, 1.0) : 0.0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(project.title),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: _pagePadding(context),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF007AFF).withValues(alpha: 0.08), const Color(0xFF007AFF).withValues(alpha: 0.03)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF007AFF).withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF007AFF),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: const Color(0xFF007AFF).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: const Icon(Icons.construction_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(project.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E))),
                          const SizedBox(height: 2),
                          StatusBadge(text: project.status),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(project.description, style: const TextStyle(color: Color(0xFF3C3C43), fontSize: 14, height: 1.5)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Text(tr('Progress', 'অগ্রগতি'), style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E)))),
                    Text('${(progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF007AFF))),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE5E5EA),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _GlassStatCard(
                  icon: Icons.attach_money_rounded,
                  label: tr('Allocated', 'বরাদ্দ'),
                  value: currency.format(project.allocatedFunds),
                  gradient: const [Color(0xFF007AFF), Color(0xFF5856D6)],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GlassStatCard(
                  icon: Icons.account_balance_rounded,
                  label: tr('Estimated', 'আনুমানিক'),
                  value: currency.format(project.estimatedCost),
                  gradient: const [Color(0xFF8E8E93), Color(0xFFC7C7CC)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _PageSectionTitle(title: tr('Progress Timeline', 'অগ্রগতির টাইমলাইন')),
          if (project.updates.isEmpty)
            EmptyStateCard(
              icon: Icons.timeline_outlined,
              title: tr('No updates yet', 'এখনও কোনো আপডেট নেই'),
              message: tr('Progress updates will be added by project admins.', 'প্রকল্প অ্যাডমিনরা অগ্রগতির আপডেট যোগ করবেন।'),
            )
          else
            ...project.updates.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(child: Text('${e.key + 1}', style: const TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w700, fontSize: 12))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(e.value, style: const TextStyle(color: Color(0xFF3C3C43), fontSize: 14, height: 1.4))),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomTabBar(context, index: 0, onTap: (i) => _openRootTab(context, i)),
    );
  }
}

class ProblemsScreen extends StatefulWidget {
  const ProblemsScreen({super.key});

  @override
  State<ProblemsScreen> createState() => _ProblemsScreenState();
}

class _ProblemsScreenState extends State<ProblemsScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final pad = _pagePadding(context);
    return StreamBuilder<List<ProblemReport>>(
      stream: DataService.instance.problems(),
      builder: (context, snap) {
        final all = snap.data ?? const <ProblemReport>[];
        final list = _filter == 'All' ? all : all.where((e) => e.status.toLowerCase() == _filter.toLowerCase()).toList();
        return ListView(
          padding: EdgeInsets.only(bottom: 100),
          children: [
            _AppHeader(
              actions: [
                _HeaderActionButton(
                  icon: Icons.add_rounded,
                  onTap: () async {
                    final ok = await _ensureLogin(context);
                    if (!context.mounted || !ok) return;
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReportProblemScreen()));
                  },
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad.left),
              child: _PageBanner(
                title: tr('Community Problems', 'কমিউনিটির সমস্যা'),
                subtitle: tr('Filter and review reported issues', 'রিপোর্ট করা সমস্যাগুলো ফিল্টার করে দেখুন'),
                count: '${all.length} ${tr('reports', 'রিপোর্ট')}',
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFFFF3B30),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad.left),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: SegmentedButton<String>(
                  showSelectedIcon: false,
                  selected: {_filter},
                  onSelectionChanged: (v) => setState(() => _filter = v.first),
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  segments: [
                    ButtonSegment(value: 'All', label: Text(tr('All', 'সব'))),
                    ButtonSegment(value: 'Pending', label: Text(tr('Pending', 'মুলতুবি'))),
                    ButtonSegment(value: 'Approved', label: Text(tr('Approved', 'অনুমোদিত'))),
                    ButtonSegment(value: 'Completed', label: Text(tr('Completed', 'সম্পন্ন'))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad.left),
              child: Column(
                children: [
                  if (list.isEmpty)
                    EmptyStateCard(
                      icon: Icons.filter_alt_off_outlined,
                      title: tr('No matching problems', 'মিলছে এমন সমস্যা নেই'),
                      message: tr('Try another filter or check again later.', 'অন্য ফিল্টার চেষ্টা করুন বা পরে আবার দেখুন।'),
                    )
                  else
                    ...list.map((e) => ProblemViewCard(item: e)),
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
            if (item.photoUrl.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  item.photoUrl,
                  width: double.infinity,
                  height: compact ? 120 : 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 10),
            ],
            Row(
              children: [
                Expanded(child: Text(item.title, style: Theme.of(context).textTheme.titleMedium)),
                StatusBadge(text: item.status),
              ],
            ),
            const SizedBox(height: 6),
            Text('${tr('Location', 'অবস্থান')}: ${item.location}'),
            const SizedBox(height: 6),
            Text(item.description, maxLines: compact ? 2 : 3, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(tr('Report a Problem', 'সমস্যা রিপোর্ট করুন')),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: _pagePadding(context),
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF3B30), Color(0xFFFF6259)]),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFFF3B30).withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: const Icon(Icons.report_problem_rounded, color: Colors.white, size: 34),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              tr('Report an Issue', 'একটি সমস্যা রিপোর্ট করুন'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E)),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              tr('Help improve your community', 'আপনার কমিউনিটি উন্নত করতে সাহায্য করুন'),
              style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
            ),
          ),
          const SizedBox(height: 20),
          AppCard(
            child: Form(
              key: _form,
              child: Column(
                children: [
                  TextFormField(
                    controller: _title,
                    decoration: InputDecoration(
                      labelText: tr('Title', 'শিরোনাম'),
                      prefixIcon: const Icon(Icons.title_rounded, color: Color(0xFF8E8E93)),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? tr('Required', 'প্রয়োজনীয়') : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _description,
                    minLines: 3,
                    maxLines: 6,
                    decoration: InputDecoration(
                      labelText: tr('Description', 'বিবরণ'),
                      alignLabelWithHint: true,
                      prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 48), child: Icon(Icons.description_outlined, color: Color(0xFF8E8E93))),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? tr('Required', 'প্রয়োজনীয়') : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _location,
                    decoration: InputDecoration(
                      labelText: tr('Location', 'অবস্থান'),
                      prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF8E8E93)),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? tr('Required', 'প্রয়োজনীয়') : null,
                  ),
                  const SizedBox(height: 14),
                  if (_photo != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Image.file(
                            _photo!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Row(
                              children: [
                                _photoActionButton(
                                  icon: Icons.edit_outlined,
                                  onTap: _pickPhoto,
                                ),
                                const SizedBox(width: 8),
                                _photoActionButton(
                                  icon: Icons.close_rounded,
                                  onTap: () => setState(() => _photo = null),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _pickPhoto,
                        icon: const Icon(Icons.add_a_photo_outlined),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        label: Text(tr('Upload Photo', 'ছবি আপলোড করুন')),
                      ),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: _submitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3B30),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        _submitting ? tr('Submitting...', 'জমা দেওয়া হচ্ছে...') : tr('Submit Problem Report', 'সমস্যা রিপোর্ট জমা দিন'),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomTabBar(context, index: 1, onTap: (i) => _openRootTab(context, i)),
    );
  }

  Future<void> _pickPhoto() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (img == null) return;
    setState(() => _photo = File(img.path));
  }

  Widget _photoActionButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      await DataService.instance.reportProblem(title: _title.text.trim(), description: _description.text.trim(), location: _location.text.trim(), photo: _photo);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('Problem reported successfully', 'সমস্যা সফলভাবে রিপোর্ট করা হয়েছে'))));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${tr('Error', 'ত্রুটি')}: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class CitizensPage extends StatelessWidget {
  const CitizensPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(tr('Citizens', 'নাগরিক')),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: const CitizensScreen(),
      bottomNavigationBar: _buildBottomTabBar(context, index: 0, onTap: (i) => _openRootTab(context, i)),
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
        final filtered = all.where((c) => c.name.toLowerCase().contains(q) || c.profession.toLowerCase().contains(q) || c.village.toLowerCase().contains(q)).toList();

        return ListView(
          padding: _pagePadding(context),
          children: [
            _PageBanner(
              title: tr('Village Citizens', 'গ্রামের নাগরিক'),
              subtitle: tr('Browse all registered members', 'সব নিবন্ধিত সদস্য দেখুন'),
              count: '${all.length} ${tr('citizens', 'নাগরিক')}',
              icon: Icons.people_rounded,
              color: const Color(0xFF007AFF),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: tr('Search name or profession', 'নাম বা পেশা লিখে খুঁজুন'),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF8E8E93)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (filtered.isEmpty)
              EmptyStateCard(
                icon: Icons.search_off,
                title: tr('No matching citizens', 'মিলছে এমন নাগরিক নেই'),
                message: tr('Try a different name or profession keyword.', 'অন্য নাম বা পেশার কীওয়ার্ড চেষ্টা করুন।'),
              )
            else
              ...filtered.map(
                (c) => AppCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: c.photoUrl.isNotEmpty
                        ? CircleAvatar(
                            radius: 22,
                            backgroundImage: NetworkImage(c.photoUrl),
                          )
                        : Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF007AFF), Color(0xFF5856D6)]),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                c.name.isEmpty ? '?' : c.name[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                              ),
                            ),
                          ),
                    title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (c.profession.isNotEmpty)
                          Text(c.profession, style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13)),
                        if (c.village.isNotEmpty)
                          Text(c.village, style: const TextStyle(color: Color(0xFFFF9500), fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    trailing: c.phone.isNotEmpty
                        ? Icon(Icons.phone_rounded, color: const Color(0xFF34C759), size: 18)
                        : null,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(tr('Leaderboard', 'লিডারবোর্ড')),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: const LeaderboardScreen(),
      bottomNavigationBar: _buildBottomTabBar(context, index: 0, onTap: (i) => _openRootTab(context, i)),
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
            _PageBanner(
              title: tr('Top Donors', 'শীর্ষ দাতা'),
              subtitle: tr('Recognizing generous contributors', 'উদার অবদানকারীদের স্বীকৃতি'),
              count: '${ranking.length} ${tr('donors', 'দাতা')}',
              icon: Icons.leaderboard_rounded,
              color: const Color(0xFF34C759),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                selected: {_monthly},
                onSelectionChanged: (v) => setState(() => _monthly = v.first),
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                segments: [
                  ButtonSegment(value: false, label: Text(tr('All Time', 'সর্বমোট'))),
                  ButtonSegment(value: true, label: Text(tr('Monthly', 'মাসিক'))),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (ranking.isEmpty)
              EmptyStateCard(
                icon: Icons.leaderboard_outlined,
                title: tr('No leaderboard data', 'লিডারবোর্ড ডেটা নেই'),
                message: tr('Donor ranking will appear when donations are made.', 'অনুদান এলে দাতার র‌্যাংকিং এখানে দেখাবে।'),
              )
            else ...[
              // Podium top 3
              if (ranking.length >= 3)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _PodiumItem(rank: 2, name: ranking[1].key, amount: currency.format(ranking[1].value), height: 80, gradient: const [Color(0xFF8E8E93), Color(0xFFC7C7CC)]),
                      _PodiumItem(rank: 1, name: ranking[0].key, amount: currency.format(ranking[0].value), height: 100, gradient: const [Color(0xFFFF9500), Color(0xFFFF6B00)]),
                      _PodiumItem(rank: 3, name: ranking[2].key, amount: currency.format(ranking[2].value), height: 64, gradient: const [Color(0xFF34C759), Color(0xFF30D158)]),
                    ],
                  ),
                ),
              ...ranking.asMap().entries.map(
                (e) => AppCard(
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: e.key < 3
                                ? (e.key == 0
                                    ? [const Color(0xFFFF9500), const Color(0xFFFF6B00)]
                                    : e.key == 1
                                        ? [const Color(0xFF8E8E93), const Color(0xFFC7C7CC)]
                                        : [const Color(0xFF34C759), const Color(0xFF30D158)])
                                : [const Color(0xFFF2F2F7), const Color(0xFFE5E5EA)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '${e.key + 1}',
                            style: TextStyle(
                              color: e.key < 3 ? Colors.white : const Color(0xFF8E8E93),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(e.value.key, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E)))),
                      Text(currency.format(e.value.value), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E))),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _PodiumItem extends StatelessWidget {
  const _PodiumItem({required this.rank, required this.name, required this.amount, required this.height, required this.gradient});
  final int rank;
  final String name;
  final String amount;
  final double height;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: gradient[0].withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Center(child: Text('$rank', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18))),
        ),
        const SizedBox(height: 6),
        Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF1C1C1E)), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(amount, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF8E8E93))),
        const SizedBox(height: 6),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [gradient[0].withValues(alpha: 0.15), gradient[1].withValues(alpha: 0.08)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: gradient[0].withValues(alpha: 0.2)),
          ),
        ),
      ],
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = DataService.instance;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(tr('Profile', 'প্রোফাইল')),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
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
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8F0),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(Icons.person_outline_rounded, color: Color(0xFFFF9500), size: 36),
                      ),
                      const SizedBox(height: 12),
                      Text(tr('Welcome!', 'স্বাগতম!'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF1C1C1E))),
                      const SizedBox(height: 4),
                      Text(tr('Login to access all features', 'সব ফিচার ব্যবহার করতে লগইন করুন'), style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13)),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9500),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(tr('Login', 'লগইন'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                )
              else
                AppCard(
                  child: Column(
                    children: [
                      user.photoURL != null
                          ? CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(user.photoURL!),
                            )
                          : CircleAvatar(
                              radius: 40,
                              backgroundColor: const Color(0xFFFFF8F0),
                              child: const Icon(Icons.person_rounded, color: Color(0xFFFF9500), size: 40),
                            ),
                      const SizedBox(height: 12),
                      Text(
                        user.displayName ?? user.email?.split('@').first ?? tr('Citizen', 'নাগরিক'),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF1C1C1E)),
                      ),
                      const SizedBox(height: 4),
                      Text(user.email ?? '', style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13)),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: data.signOut,
                        child: Text(tr('Logout', 'লগআউট'), style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Text(tr('Preferences', 'পছন্দসমূহ').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF8E8E93), letterSpacing: 0.8)),
              const SizedBox(height: 8),
              ValueListenableBuilder(
                valueListenable: accessibilityController,
                builder: (context, AccessibilitySettings settings, _) {
                  return AppCard(
                    child: Column(
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          activeThumbColor: const Color(0xFFFF9500),
                          title: Text(tr('High contrast mode', 'উচ্চ কনট্রাস্ট মোড'), style: const TextStyle(color: Color(0xFF1C1C1E))),
                          value: settings.highContrast,
                          onChanged: accessibilityController.setHighContrast,
                        ),
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(tr('Language', 'ভাষা'), style: const TextStyle(color: Color(0xFF1C1C1E))),
                          trailing: SegmentedButton<String>(
                            showSelectedIcon: false,
                            selected: {settings.languageCode},
                            onSelectionChanged: (v) => accessibilityController.setLanguageCode(v.first),
                            segments: const [
                              ButtonSegment(value: 'en', label: Text('English')),
                              ButtonSegment(value: 'bn', label: Text('বাংলা')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomTabBar(context, index: 2, onTap: (i) => _openRootTab(context, i)),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool _loading = false;
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final compact = size.width <= 360;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: compact ? 20 : 28),
          child: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1C1C1E), size: 20),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.08),
                  // Village icon
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9500),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: const Icon(Icons.location_city_rounded, color: Colors.white, size: 42),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    tr('Welcome to Doulatpara', 'দৌলতপাড়ায় স্বাগতম'),
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF1C1C1E), letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr('Sign in to your village community', 'আপনার গ্রাম কমিউনিটিতে সাইন ইন করুন'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: Color(0xFF8E8E93)),
                  ),
                  SizedBox(height: size.height * 0.05),
                  // Login card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          tr('Sign in with', 'সাইন ইন করুন'),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF8E8E93)),
                        ),
                        const SizedBox(height: 20),
                        // Google Sign-In button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _signInWithGoogle,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1F1F1F),
                              disabledBackgroundColor: const Color(0xFFF2F2F7),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFFFF9500)))
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF4285F4)),
                                        child: const Center(
                                          child: Text('G', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        tr('Continue with Google', 'Google দিয়ে প্রবেশ করুন'),
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1C1C1E)),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Info tiles
                  Row(
                    children: [
                      Expanded(child: _LoginInfoTile(icon: Icons.lock_outline_rounded, text: tr('Secure', 'নিরাপদ'))),
                      const SizedBox(width: 10),
                      Expanded(child: _LoginInfoTile(icon: Icons.shield_outlined, text: tr('Private', 'ব্যক্তিগত'))),
                      const SizedBox(width: 10),
                      Expanded(child: _LoginInfoTile(icon: Icons.flash_on_rounded, text: tr('Instant', 'তাৎক্ষণিক'))),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      final isNew = await DataService.instance.signInWithGoogle();
      if (!mounted) return;
      if (isNew || !(await DataService.instance.isProfileComplete())) {
        // New user or incomplete profile → show profile setup.
        if (!mounted) return;
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
        );
      } else {
        if (!mounted) return;
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${tr('Error', 'ত্রুটি')}: $e'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _LoginInfoTile extends StatelessWidget {
  const _LoginInfoTile({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFFF9500), size: 22),
          const SizedBox(height: 6),
          Text(text, style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─── Profile Setup Screen ───────────────────────────────────────────────────

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key, this.existingProfile});
  final Map<String, dynamic>? existingProfile;

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  final _phoneCtrl = TextEditingController();
  String? _profession;
  String? _village;
  final _addressCtrl = TextEditingController();
  final _nidCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  String? _bloodGroup;
  bool _saving = false;
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;

  static const _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
  ];

  static const _villages = ['দৌলতপাড়া', 'ধর্মতীর্থ', 'দিঘীরপাড়া'];

  static final _professions = [
    tr('Expatriate', 'প্রবাসী'),
    tr('Farmer', 'কৃষক'),
    tr('Teacher', 'শিক্ষক'),
    tr('Student', 'ছাত্র/ছাত্রী'),
    tr('Doctor', 'ডাক্তার'),
    tr('Engineer', 'ইঞ্জিনিয়ার'),
    tr('Businessman', 'ব্যবসায়ী'),
    tr('Housewife', 'গৃহিণী'),
    tr('Government Employee', 'সরকারি চাকরিজীবী'),
    tr('Private Employee', 'বেসরকারি চাকরিজীবী'),
    tr('Day Laborer', 'দিনমজুর'),
    tr('Fisherman', 'জেলে'),
    tr('Driver', 'চালক'),
    tr('Tailor', 'দর্জি'),
    tr('Imam/Religious Leader', 'ইমাম/ধর্মীয় নেতা'),
    tr('Retired', 'অবসরপ্রাপ্ত'),
    tr('Unemployed', 'বেকার'),
    tr('Other', 'অন্যান্য'),
  ];

  @override
  void initState() {
    super.initState();
    final user = DataService.instance.currentUser;
    final profile = widget.existingProfile;
    _nameCtrl = TextEditingController(
      text: profile?['name'] as String? ?? user?.displayName ?? '',
    );
    _phoneCtrl.text = profile?['phone'] as String? ?? '';
    _addressCtrl.text = profile?['address'] as String? ?? '';
    _nidCtrl.text = profile?['nidNumber'] as String? ?? '';
    _dobCtrl.text = profile?['dateOfBirth'] as String? ?? '';

    // Pre-fill village.
    final savedVillage = profile?['village'] as String? ?? '';
    if (savedVillage.isNotEmpty && _villages.contains(savedVillage)) {
      _village = savedVillage;
    }

    // Pre-fill profession if it matches one of the options.
    final savedProfession = profile?['profession'] as String? ?? '';
    if (savedProfession.isNotEmpty && _professions.contains(savedProfession)) {
      _profession = savedProfession;
    }

    // Pre-fill blood group.
    final savedBlood = profile?['bloodGroup'] as String? ?? '';
    if (savedBlood.isNotEmpty && _bloodGroups.contains(savedBlood)) {
      _bloodGroup = savedBlood;
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _nidCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = DataService.instance.currentUser;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8F0),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFFFF9500).withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: user?.photoURL != null && user!.photoURL!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(22),
                                  child: Image.network(user.photoURL!, fit: BoxFit.cover),
                                )
                              : const Icon(Icons.person_rounded,
                                  color: Color(0xFFFF9500), size: 40),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.existingProfile != null
                              ? tr('Edit Your Profile', 'প্রোফাইল সম্পাদনা করুন')
                              : tr('Setup Your Profile', 'প্রোফাইল সেটআপ করুন'),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1C1C1E),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          tr('Complete your profile to join the village community',
                              'গ্রাম কমিউনিটিতে যোগ দিতে আপনার প্রোফাইল সম্পূর্ণ করুন'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Name
                  _buildLabel(tr('Full Name', 'পুরো নাম'), required: true),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _nameCtrl,
                    hint: tr('Enter your full name', 'আপনার পুরো নাম লিখুন'),
                    icon: Icons.person_outline_rounded,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? tr('Name is required', 'নাম আবশ্যক')
                        : null,
                  ),
                  const SizedBox(height: 18),

                  // Phone
                  _buildLabel(tr('Phone Number', 'ফোন নম্বর'), required: true),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _phoneCtrl,
                    hint: tr('01XXXXXXXXX', '০১XXXXXXXXX'),
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return tr('Phone number is required', 'ফোন নম্বর আবশ্যক');
                      }
                      if (v.trim().length < 11) {
                        return tr('Enter a valid phone number', 'সঠিক ফোন নম্বর লিখুন');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  // Profession
                  _buildLabel(tr('Profession', 'পেশা'), required: true),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: DropdownButtonFormField<String>(
                      initialValue: _profession,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.work_outline_rounded,
                            color: Color(0xFF8E8E93), size: 20),
                        hintText: tr('Select profession', 'পেশা নির্বাচন করুন'),
                        hintStyle: const TextStyle(
                            color: Color(0xFFC7C7CC), fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      isExpanded: true,
                      items: _professions
                          .map((p) =>
                              DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      validator: (v) => (v == null || v.isEmpty)
                          ? tr('Profession is required', 'পেশা আবশ্যক')
                          : null,
                      onChanged: (v) => setState(() => _profession = v),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Village
                  _buildLabel(tr('Village', 'গ্রাম'), required: true),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: DropdownButtonFormField<String>(
                      initialValue: _village,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.home_outlined,
                            color: Color(0xFF8E8E93), size: 20),
                        hintText: tr('Select village', 'গ্রাম নির্বাচন করুন'),
                        hintStyle: const TextStyle(
                            color: Color(0xFFC7C7CC), fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      isExpanded: true,
                      items: _villages
                          .map((v) =>
                              DropdownMenuItem(value: v, child: Text(v)))
                          .toList(),
                      validator: (v) => (v == null || v.isEmpty)
                          ? tr('Village is required', 'গ্রাম নির্বাচন আবশ্যক')
                          : null,
                      onChanged: (v) => setState(() => _village = v),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Address
                  _buildLabel(tr('Address', 'ঠিকানা')),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _addressCtrl,
                    hint: tr('Area / Para (optional)', 'এলাকা / পাড়া (ঐচ্ছিক)'),
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 18),

                  // Blood Group
                  _buildLabel(tr('Blood Group', 'রক্তের গ্রুপ')),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: DropdownButtonFormField<String>(
                      initialValue: _bloodGroup,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.bloodtype_outlined,
                            color: Color(0xFF8E8E93), size: 20),
                        hintText: tr('Select blood group', 'রক্তের গ্রুপ নির্বাচন করুন'),
                        hintStyle: const TextStyle(
                            color: Color(0xFFC7C7CC), fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      items: _bloodGroups
                          .map((bg) =>
                              DropdownMenuItem(value: bg, child: Text(bg)))
                          .toList(),
                      onChanged: (v) => setState(() => _bloodGroup = v),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // NID Number
                  _buildLabel(tr('NID Number', 'জাতীয় পরিচয়পত্র নম্বর')),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _nidCtrl,
                    hint: tr('Optional', 'ঐচ্ছিক'),
                    icon: Icons.credit_card_rounded,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 18),

                  // Date of Birth
                  _buildLabel(tr('Date of Birth', 'জন্ম তারিখ')),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _pickDate,
                    child: AbsorbPointer(
                      child: _buildTextField(
                        controller: _dobCtrl,
                        hint: tr('Select date', 'তারিখ নির্বাচন করুন'),
                        icon: Icons.cake_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: _saving ? null : _saveProfile,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9500),
                        disabledBackgroundColor:
                            const Color(0xFFFF9500).withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.existingProfile != null
                                  ? tr('Update Profile', 'প্রোফাইল আপডেট করুন')
                                  : tr('Save & Continue', 'সংরক্ষণ করুন ও এগিয়ে যান'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Skip button
                  Center(
                    child: TextButton(
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Text(
                        tr(widget.existingProfile != null ? 'Cancel' : 'Skip for now',
                            widget.existingProfile != null ? 'বাতিল' : 'এখন এড়িয়ে যান'),
                        style: const TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3C3C43),
          ),
        ),
        if (required)
          const Text(' *',
              style: TextStyle(
                  color: Color(0xFFFF3B30),
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: Color(0xFF1C1C1E)),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF8E8E93), size: 20),
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFC7C7CC), fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFFF9500), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF3B30)),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: now,
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF9500),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _dobCtrl.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await DataService.instance.updateUserProfile(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        profession: _profession ?? '',
        village: _village ?? '',
        address: _addressCtrl.text.trim(),
        nidNumber: _nidCtrl.text.trim(),
        bloodGroup: _bloodGroup,
        dateOfBirth: _dobCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(tr('Profile saved successfully!', 'প্রোফাইল সফলভাবে সংরক্ষিত হয়েছে!')),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF34C759),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${tr('Error', 'ত্রুটি')}: $e'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

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
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: Text(tr('Notifications', 'নোটিফিকেশন')),
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
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
                  const SizedBox(height: 10),
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
                        return AppCard(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: (n.type == 'donation' ? const Color(0xFFFF9500) : n.type == 'problem' ? const Color(0xFFFF3B30) : const Color(0xFF007AFF)).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(_iconFor(n.type), color: n.type == 'donation' ? const Color(0xFFFF9500) : n.type == 'problem' ? const Color(0xFFFF3B30) : const Color(0xFF007AFF), size: 20),
                            ),
                            title: Text(n.title.isNotEmpty ? n.title : n.body.isNotEmpty ? n.body : 'Village update available'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (n.title.isNotEmpty && n.body.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  ),
                                Text(DateFormat('dd MMM, hh:mm a').format(n.createdAt)),
                              ],
                            ),
                            trailing: IconButton(
                              onPressed: () async {
                                final ok = await _ensureLogin(context);
                                if (!context.mounted || !ok) return;
                                if (isRead) {
                                  await data.markNotificationUnread(n.id);
                                } else {
                                  await data.markNotificationRead(n.id);
                                }
                              },
                              icon: Icon(isRead ? Icons.mark_email_read_outlined : Icons.mark_email_unread_outlined),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
              bottomNavigationBar: _buildBottomTabBar(context, index: 0, onTap: (i) => _openRootTab(context, i)),
            );
          },
        );
      },
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.title, required this.balance, required this.citizens});

  final String title;
  final String balance;
  final int citizens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9500), Color(0xFFFF6B00), Color(0xFFE05500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9500).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF7CFC00), shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(
                          '$citizens ${tr('citizens', 'নাগরিক')}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5, height: 1.1),
              ),
              const SizedBox(height: 4),
              Text(
                tr('Village Community Fund', 'গ্রাম কমিউনিটি তহবিল'),
                style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('Available Balance', 'উপলব্ধ ব্যালেন্স'),
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          balance,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF1C1C1E), size: 20),
      ),
    );
  }
}

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(tr('Admin Panel', 'অ্যাডমিন প্যানেল')),
        backgroundColor: Colors.white,
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
      body: TabBarView(
        controller: _tabCtrl,
        children: const [
          _AdminPendingDonationsTab(),
          _AdminPaymentSettingsTab(),
        ],
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
          return const Center(child: CircularProgressIndicator(color: Color(0xFFFF9500)));
        }
        final donations = snap.data ?? [];
        if (donations.isEmpty) {
          return Center(
            child: EmptyStateCard(
              icon: Icons.check_circle_outline_rounded,
              title: tr('No Pending Donations', 'কোনো মুলতুবি অনুদান নেই'),
              message: tr('All donations have been reviewed', 'সমস্ত অনুদান পর্যালোচনা করা হয়েছে'),
            ),
          );
        }
        return ListView.separated(
          padding: _pagePadding(context),
          itemCount: donations.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) => _AdminDonationCard(donation: donations[i]),
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
        SnackBar(content: Text(tr('Donation approved', 'অনুদান অনুমোদিত হয়েছে'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${tr('Error', 'ত্রুটি')}: $e')),
      );
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _reject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('Reject Donation?', 'অনুদান প্রত্যাখ্যান করবেন?')),
        content: Text(tr('This action cannot be undone.', 'এই কাজটি পূর্বাবস্থায় ফেরানো যাবে না।')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr('Cancel', 'বাতিল')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr('Reject', 'প্রত্যাখ্যান'), style: const TextStyle(color: Color(0xFFDC2626))),
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
        SnackBar(content: Text(tr('Donation rejected', 'অনুদান প্রত্যাখ্যাত হয়েছে'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${tr('Error', 'ত্রুটি')}: $e')),
      );
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
                  color: const Color(0xFFFFF8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.volunteer_activism, color: Color(0xFFFF9500), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.donorName, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
                    const SizedBox(height: 2),
                    Text(
                      '${d.paymentMethod} · ${shortDate.format(d.createdAt)}',
                      style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                currency.format(d.amount),
                style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFFF9500), fontSize: 15),
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
                _infoRow(tr('Transaction ID', 'ট্রানজেকশন আইডি'), d.transactionId),
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
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFDC2626)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(tr('Reject', 'প্রত্যাখ্যান'), style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: FilledButton(
                    onPressed: _processing ? null : _approve,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _processing ? tr('Processing...', 'প্রসেস হচ্ছে...') : tr('Approve', 'অনুমোদন'),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
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
        Text('$label: ', style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93))),
        Expanded(
          child: Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E)),
          ),
        ),
      ],
    );
  }
}

class _AdminPaymentSettingsTab extends StatefulWidget {
  const _AdminPaymentSettingsTab();

  @override
  State<_AdminPaymentSettingsTab> createState() => _AdminPaymentSettingsTabState();
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
                color: const Color(0xFFFFF8F0),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFE0B2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFFFF9500), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tr('Citizens will see these account details when donating', 'নাগরিকরা অনুদান দেওয়ার সময় এই অ্যাকাউন্টের তথ্য দেখবেন'),
                      style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
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
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving ? const SizedBox.shrink() : const Icon(Icons.save_rounded, size: 20),
                label: Text(
                  _saving ? tr('Saving...', 'সংরক্ষণ হচ্ছে...') : tr('Save All Settings', 'সকল সেটিংস সংরক্ষণ করুন'),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9500),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
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
                  child: Icon(Icons.phone_android_rounded, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: hasData ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    hasData ? tr('Active', 'সক্রিয়') : tr('Not Set', 'সেট নেই'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: hasData ? const Color(0xFF059669) : const Color(0xFFDC2626),
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
                TextField(
                  controller: numCtrl,
                  keyboardType: TextInputType.phone,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: tr('Account Number', 'অ্যাকাউন্ট নম্বর'),
                    hintText: tr('e.g. 01XXXXXXXXX', 'যেমন ০১XXXXXXXXX'),
                    prefixIcon: Icon(Icons.dialpad_rounded, color: color, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: color, width: 1.5)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: tr('Account Holder Name', 'অ্যাকাউন্ট ধারকের নাম'),
                    hintText: tr('e.g. Mohammad Ali', 'যেমন মোহাম্মদ আলী'),
                    prefixIcon: Icon(Icons.person_outline_rounded, color: color, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: color, width: 1.5)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
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
    InputDecoration _inputDeco(String label, String labelBn, String hint, String hintBn, IconData icon) {
      return InputDecoration(
        labelText: tr(label, labelBn),
        hintText: tr(hint, hintBn),
        prefixIcon: Icon(icon, color: color, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: color, width: 1.5)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );
    }
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
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.account_balance_rounded, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(tr('Bank Account', 'ব্যাংক অ্যাকাউন্ট'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: hasData ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    hasData ? tr('Active', 'সক্রিয়') : tr('Not Set', 'সেট নেই'),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: hasData ? const Color(0xFF059669) : const Color(0xFFDC2626)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _bankBankName,
                  onChanged: (_) => setState(() {}),
                  decoration: _inputDeco('Bank Name', 'ব্যাংকের নাম', 'e.g. Sonali Bank', 'যেমন সোনালী ব্যাংক', Icons.account_balance_rounded),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bankBranch,
                  onChanged: (_) => setState(() {}),
                  decoration: _inputDeco('Branch Name', 'শাখার নাম', 'e.g. Main Branch', 'যেমন প্রধান শাখা', Icons.location_on_outlined),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bankNum,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: _inputDeco('Account Number', 'অ্যাকাউন্ট নম্বর', 'e.g. 1234567890', 'যেমন ১২৩৪৫৬৭৮৯০', Icons.dialpad_rounded),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bankName,
                  decoration: _inputDeco('Account Holder Name', 'অ্যাকাউন্ট ধারকের নাম', 'e.g. Mohammad Ali', 'যেমন মোহাম্মদ আলী', Icons.person_outline_rounded),
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
        'bKash': {'number': _bkashNum.text.trim(), 'name': _bkashName.text.trim()},
        'Nagad': {'number': _nagadNum.text.trim(), 'name': _nagadName.text.trim()},
        'Rocket': {'number': _rocketNum.text.trim(), 'name': _rocketName.text.trim()},
        'Bank': {'number': _bankNum.text.trim(), 'name': _bankName.text.trim(), 'bankName': _bankBankName.text.trim(), 'branch': _bankBranch.text.trim()},
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('Settings saved successfully', 'সেটিংস সফলভাবে সংরক্ষিত হয়েছে')),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${tr('Error', 'ত্রুটি')}: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E)),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassStatCard extends StatelessWidget {
  const _GlassStatCard({required this.icon, required this.label, required this.value, required this.gradient});
  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradient[0].withValues(alpha: 0.08), gradient[1].withValues(alpha: 0.04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gradient[0].withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: gradient[0].withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 14),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF1C1C1E), letterSpacing: -0.3)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onSeeAll, required this.padding});
  final String title;
  final VoidCallback? onSeeAll;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E), letterSpacing: -0.3),
            ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                tr('See all', 'সব দেখুন'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFFF9500)),
              ),
            ),
        ],
      ),
    );
  }
}

class _PageBanner extends StatelessWidget {
  const _PageBanner({required this.title, required this.subtitle, required this.count, required this.icon, required this.color});
  final String title;
  final String subtitle;
  final String count;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.08), color.withValues(alpha: 0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E), letterSpacing: -0.3)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(count, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _PageSectionTitle extends StatelessWidget {
  const _PageSectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E), letterSpacing: -0.2),
      ),
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
        title: tr('No donations available', 'কোনো অনুদান পাওয়া যায়নি'),
        message: tr('Recent donation records will be visible here.', 'সাম্প্রতিক অনুদানের রেকর্ড এখানে দেখাবে।'),
      );
    }
    return SizedBox(
      height: 116,
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
      height: 220,
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
        title: tr('No active projects', 'কোনো সক্রিয় প্রকল্প নেই'),
        message: tr('New development initiatives will be listed here.', 'নতুন উন্নয়ন উদ্যোগগুলো এখানে তালিকাভুক্ত হবে।'),
      );
    }
    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) => ProjectCard(item: items[i], compact: true),
      ),
    );
  }
}

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
                      child: Text(entries[i].key, style: const TextStyle(fontSize: 11)),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                color: const Color(0xFFFF9500),
                barWidth: 4,
                spots: List.generate(entries.length, (i) => FlSpot(i.toDouble(), entries[i].value)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> _ensureLogin(BuildContext context) async {
  if (DataService.instance.currentUser != null) {
    return true;
  }

  final proceed = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr('Login Required', 'লগইন প্রয়োজন'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              tr('Please login with Google to donate or report a problem.', 'অনুদান দিতে বা সমস্যা রিপোর্ট করতে ইমেইল OTP দিয়ে লগইন করুন।'),
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(tr('Continue to Login', 'লগইনে এগিয়ে যান')),
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


