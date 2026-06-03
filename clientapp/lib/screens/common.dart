part of '../screens.dart';

bool _isCompactLayout(BuildContext context) {
  return MediaQuery.of(context).size.width <= 360;
}

EdgeInsets _pagePadding(BuildContext context) {
  final compact = _isCompactLayout(context);
  return EdgeInsets.fromLTRB(
    compact ? 14 : 20,
    compact ? 12 : 16,
    compact ? 14 : 20,
    compact ? 12 : 16,
  );
}

Widget _constrainBodyWidth(
  BuildContext context,
  Widget child, {
  double maxWidth = 560,
}) {
  if (MediaQuery.of(context).size.width < 640) {
    return child;
  }
  return Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}



void _openRootTab(BuildContext context, int index) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => RootShell(initialIndex: index)),
    (route) => false,
  );
}

// ─── Visually stunning custom app header ────────────────────────────

class _AppHeader extends StatelessWidget {
  const _AppHeader({this.actions, this.showMenuButton = false});
  final List<Widget>? actions;
  final bool showMenuButton;

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return tr('Good Morning', 'শুভ সকাল');
    if (h < 17) return tr('Good Afternoon', 'শুভ অপরাহ্ন');
    return tr('Good Evening', 'শুভ সন্ধ্যা');
  }

  @override
  Widget build(BuildContext context) {
    final user = DataService.instance.currentUser;
    final name =
        user?.displayName?.split(' ').first ?? tr('Villager', 'গ্রামবাসী');
    return Padding(
      padding: EdgeInsets.fromLTRB(
        _isCompactLayout(context) ? 14 : 20,
        MediaQuery.of(context).padding.top + 14,
        _isCompactLayout(context) ? 14 : 20,
        12,
      ),
      child: Row(
        children: [
          if (showMenuButton) ...[
            Builder(
              builder: (context) => _ShellIconButton(
                icon: Icons.menu_rounded,
                onTap: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            const SizedBox(width: 10),
          ],
          user?.photoURL != null
              ? CircleAvatar(
                  radius: 19,
                  backgroundColor: AppColors.surfaceVariantC(context),
                  backgroundImage: NetworkImage(user!.photoURL!),
                )
              : Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariantC(context),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: AppColors.textSecondaryC(context),
                    size: 20,
                  ),
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiaryC(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryC(context),
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

bool _useDesktopSidebar(BuildContext context) {
  return MediaQuery.of(context).size.width >= 1100;
}

class _MenuId {
  static const String home = 'home';
  static const String problems = 'problems';
  static const String profile = 'profile';
  static const String fund = 'fund';
  static const String projects = 'projects';
  static const String citizens = 'citizens';
  static const String leaderboard = 'leaderboard';
  static const String notifications = 'notifications';
  static const String admin = 'admin';
}

class _ShellIconButton extends StatelessWidget {
  const _ShellIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surfaceC(context),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: AppColors.borderC(context),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.textPrimaryC(context),
          ),
        ),
      ),
    );
  }
}

class _SidebarDestination {
  _SidebarDestination({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accent = AppColors.primary,
  });

  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color accent;
}

void _handleSidebarNavigation(
  BuildContext context, {
  required bool closeDrawerOnTap,
  required VoidCallback action,
}) {
  if (!closeDrawerOnTap) {
    action();
    return;
  }
  Navigator.of(context).pop();
  Future<void>.delayed(Duration.zero, action);
}

List<_SidebarDestination> _sidebarDestinations(
  BuildContext context, {
  required String selectedId,
  ValueChanged<int>? onRootSelected,
  required bool closeDrawerOnTap,
}) {
  void openRoot(int index, String id) {
    if (selectedId == id) {
      if (closeDrawerOnTap) {
        Navigator.of(context).pop();
      }
      return;
    }
    _handleSidebarNavigation(
      context,
      closeDrawerOnTap: closeDrawerOnTap,
      action: () {
        if (onRootSelected != null) {
          onRootSelected(index);
        } else {
          _openRootTab(context, index);
        }
      },
    );
  }

  void openPage(String id, Widget page) {
    if (selectedId == id) {
      if (closeDrawerOnTap) {
        Navigator.of(context).pop();
      }
      return;
    }
    _handleSidebarNavigation(
      context,
      closeDrawerOnTap: closeDrawerOnTap,
      action: () =>
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => page)),
    );
  }

  return [
    _SidebarDestination(
      id: _MenuId.home,
      icon: Icons.home_rounded,
      title: tr('Home', 'হোম'),
      subtitle: tr('Overview and key activity', 'সারসংক্ষেপ ও মূল কার্যক্রম'),
      onTap: () => openRoot(0, _MenuId.home),
    ),
    _SidebarDestination(
      id: _MenuId.problems,
      icon: Icons.warning_amber_rounded,
      title: tr('Problems', 'সমস্যা'),
      subtitle: tr(
        'Reports, priorities, and updates',
        'রিপোর্ট, অগ্রাধিকার, ও আপডেট',
      ),
      accent: AppColors.warningC(context),
      onTap: () => openRoot(1, _MenuId.problems),
    ),
    _SidebarDestination(
      id: _MenuId.profile,
      icon: Icons.account_circle_rounded,
      title: tr('Profile', 'প্রোফাইল'),
      subtitle: tr(
        'Preferences and account access',
        'পছন্দ ও অ্যাকাউন্ট সেটিংস',
      ),
      accent: AppColors.secondary,
      onTap: () => openRoot(2, _MenuId.profile),
    ),
    _SidebarDestination(
      id: _MenuId.fund,
      icon: Icons.account_balance_wallet_rounded,
      title: tr('Village Fund', 'গ্রাম তহবিল'),
      subtitle: tr(
        'Collections, balance, and donations',
        'সংগ্রহ, ব্যালেন্স, এবং অনুদান',
      ),
      onTap: () => openPage(_MenuId.fund, const VillageFundScreen()),
    ),
    _SidebarDestination(
      id: _MenuId.projects,
      icon: Icons.construction_rounded,
      title: tr('Projects', 'প্রকল্প'),
      subtitle: tr('Development work in progress', 'চলমান উন্নয়ন কার্যক্রম'),
      accent: AppColors.infoC(context),
      onTap: () => openPage(_MenuId.projects, const ProjectsScreen()),
    ),
    _SidebarDestination(
      id: _MenuId.citizens,
      icon: Icons.groups_2_rounded,
      title: tr('Citizens', 'নাগরিক'),
      subtitle: tr(
        'People, professions, and directory',
        'মানুষ, পেশা, এবং তালিকা',
      ),
      accent: AppColors.secondary,
      onTap: () => openPage(_MenuId.citizens, const CitizensPage()),
    ),
    _SidebarDestination(
      id: _MenuId.leaderboard,
      icon: Icons.leaderboard_rounded,
      title: tr('Leaderboard', 'লিডারবোর্ড'),
      subtitle: tr(
        'Top contributors and rankings',
        'শীর্ষ অবদানকারী ও র‌্যাংকিং',
      ),
      accent: AppColors.accent,
      onTap: () => openPage(_MenuId.leaderboard, const LeaderboardPage()),
    ),
    _SidebarDestination(
      id: _MenuId.notifications,
      icon: Icons.notifications_active_rounded,
      title: tr('Notifications', 'নোটিফিকেশন'),
      subtitle: tr(
        'Unread updates and recent events',
        'অপঠিত আপডেট ও সাম্প্রতিক খবর',
      ),
      accent: AppColors.primaryC(context),
      onTap: () => openPage(_MenuId.notifications, const NotificationScreen()),
    ),
  ];
}

Widget _buildSidebarMenu({
  required BuildContext context,
  required String selectedId,
  ValueChanged<int>? onRootSelected,
  required bool closeDrawerOnTap,
}) {
  final menuItems = _sidebarDestinations(
    context,
    selectedId: selectedId,
    onRootSelected: onRootSelected,
    closeDrawerOnTap: closeDrawerOnTap,
  );

  return Container(
    decoration: BoxDecoration(
      color: AppColors.surfaceC(context),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryC(context).withValues(alpha: 0.14),
          blurRadius: 34,
          offset: const Offset(0, 20),
        ),
      ],
    ),
    child: Stack(
      children: [
        Positioned(
          top: -40,
          right: -30,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceVariantC(context),
            ),
          ),
        ),
        Positioned(
          bottom: -60,
          left: -30,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryMutedC(context),
            ),
          ),
        ),
        ListView(
          padding: const EdgeInsets.all(20),
          children: [
            StreamBuilder<VillageOverview>(
              stream: DataService.instance.villageOverview(),
              builder: (context, snapshot) {
                final user = DataService.instance.currentUser;
                final overview =
                    snapshot.data ??
                    const VillageOverview(
                      name: 'AL ISLAH',
                      totalCitizens: 0,
                      totalFundCollected: 0,
                      totalSpent: 0,
                    );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        user?.photoURL != null
                            ? CircleAvatar(
                                radius: 24,
                                backgroundImage: NetworkImage(user!.photoURL!),
                              )
                            : Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primaryLight,
                                      AppColors.primaryC(context),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Center(
                                  child: Text(
                                    (user?.displayName?.trim().isNotEmpty ??
                                            false)
                                        ? user!.displayName!
                                              .trim()[0]
                                              .toUpperCase()
                                        : 'A',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (user?.displayName ??
                                        tr('AL ISLAH HUB', 'আল ইসলাহ হাব'))
                                    .toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.textPrimaryC(context),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tr(
                                  'Village account and community services',
                                  'গ্রাম অ্যাকাউন্ট ও কমিউনিটি সেবা',
                                ),
                                style: TextStyle(
                                  color: AppColors.textSecondaryC(context),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundC(context),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.verified_rounded,
                              color: AppColors.accent,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tr(
                                'Complete your profile for full village access',
                                'সম্পূর্ণ সুবিধা পেতে প্রোফাইল সম্পন্ন করুন',
                              ),
                              style: TextStyle(
                                color: AppColors.textPrimaryC(context),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textSecondaryC(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _SidebarKpiChip(
                            icon: Icons.savings_rounded,
                            label: currency.format(overview.availableBalance),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StreamBuilder<int>(
                            stream: DataService.instance.citizenCount(),
                            builder: (context, citizenSnap) {
                              final liveCitizenCount =
                                  citizenSnap.data ?? overview.totalCitizens;
                              return _SidebarKpiChip(
                                icon: Icons.groups_rounded,
                                label:
                                    '$liveCitizenCount ${tr('citizens', 'নাগরিক')}',
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 26),
            ...menuItems.map((item) {
              // Special handling for problems badge - use dynamic count
              if (item.id == _MenuId.problems) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: StreamBuilder<int>(
                    stream: DataService.instance.pendingProblemsCount(),
                    builder: (context, badgeSnap) {
                      final badgeCount = badgeSnap.data ?? 0;
                      final badgeText = badgeCount > 0
                          ? badgeCount.toString()
                          : null;

                      return _SidebarMenuTile(
                        title: item.title,
                        subtitle: item.subtitle,
                        icon: item.icon,
                        accent: item.accent,
                        selected: item.id == selectedId,
                        badgeText: badgeText,
                        onTap: item.onTap,
                      );
                    },
                  ),
                );
              }

              // Projects badge — shows total project count
              if (item.id == _MenuId.projects) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: StreamBuilder<int>(
                    stream: DataService.instance.projectsCount(),
                    builder: (context, badgeSnap) {
                      final badgeCount = badgeSnap.data ?? 0;
                      final badgeText = badgeCount > 0
                          ? badgeCount.toString()
                          : null;

                      return _SidebarMenuTile(
                        title: item.title,
                        subtitle: item.subtitle,
                        icon: item.icon,
                        accent: item.accent,
                        selected: item.id == selectedId,
                        badgeText: badgeText,
                        onTap: item.onTap,
                      );
                    },
                  ),
                );
              }

              // Regular menu items without dynamic badges
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SidebarMenuTile(
                  title: item.title,
                  subtitle: item.subtitle,
                  icon: item.icon,
                  accent: item.accent,
                  selected: item.id == selectedId,
                  onTap: item.onTap,
                ),
              );
            }),
            const SizedBox(height: 12),
            FutureBuilder<bool>(
              future: DataService.instance.isAdmin(),
              builder: (context, snapshot) {
                if (snapshot.data != true) {
                  return const SizedBox.shrink();
                }
                return _SidebarMenuTile(
                  title: tr('Admin Panel', 'অ্যাডমিন প্যানেল'),
                  subtitle: tr(
                    'Moderate content and operations',
                    'কনটেন্ট ও কার্যক্রম পরিচালনা করুন',
                  ),
                  icon: Icons.admin_panel_settings_rounded,
                  accent: const Color(0xFFEF4444),
                  selected: selectedId == _MenuId.admin,
                  onTap: () {
                    if (selectedId == _MenuId.admin) {
                      if (closeDrawerOnTap) {
                        Navigator.of(context).pop();
                      }
                      return;
                    }
                    _handleSidebarNavigation(
                      context,
                      closeDrawerOnTap: closeDrawerOnTap,
                      action: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AdminPanelScreen(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ],
    ),
  );
}

Drawer _buildSidebarDrawer({
  required BuildContext context,
  required String selectedId,
  ValueChanged<int>? onRootSelected,
}) {
  return Drawer(
    width: 320,
    backgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 18, 0),
      child: _buildSidebarMenu(
        context: context,
        selectedId: selectedId,
        onRootSelected: onRootSelected,
        closeDrawerOnTap: true,
      ),
    ),
  );
}

Widget _buildShellSurface({
  required BuildContext context,
  required String selectedId,
  required Widget child,
  ValueChanged<int>? onRootSelected,
}) {
  final desktop = _useDesktopSidebar(context);
  final media = MediaQuery.of(context);

  final content = desktop
      ? Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceC(context).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(
              color: AppColors.overlayLight.withValues(alpha: 0.85),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryC(context).withValues(alpha: 0.12),
                blurRadius: 34,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        )
      : child;

  return PatternBackdrop(
    child: Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: desktop ? 250 : 320,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryLight.withValues(alpha: 0.24),
                    AppColors.primaryDark.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),
        if (!desktop)
          child
        else
          Padding(
            padding: EdgeInsets.fromLTRB(
              18 + media.padding.left,
              18 + media.padding.top,
              18 + media.padding.right,
              18 + media.padding.bottom,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 304,
                  child: _buildSidebarMenu(
                    context: context,
                    selectedId: selectedId,
                    onRootSelected: onRootSelected,
                    closeDrawerOnTap: false,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(child: content),
              ],
            ),
          ),
      ],
    ),
  );
}

Widget _pageBackdrop({required Widget child, bool safeArea = false}) {
  final content = safeArea ? SafeArea(child: child) : child;
  return PatternBackdrop(
    child: Stack(
      children: [
        // Top glow — matches the existing brand-coloured halo.
        Positioned(
          top: -120,
          left: -40,
          right: -40,
          child: IgnorePointer(
            child: Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.pageTopGlowGradient,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),
        // Bottom glow — ensures the gradient extends past the scroll content
        // so the bottom of the screen never looks flat/white on tall devices
        // (notably the login screen, where the scroll view can be shorter
        // than the viewport).
        Positioned(
          left: -40,
          right: -40,
          bottom: -160,
          child: IgnorePointer(
            child: Container(
              height: 320,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.pageTopGlowGradient,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(child: content),
      ],
    ),
  );
}

class _SidebarPageScaffold extends StatelessWidget {
  const _SidebarPageScaffold({
    required this.title,
    required this.subtitle,
    required this.selectedId,
    required this.body,
    this.actions = const <Widget>[],
  });

  final String title;
  final String subtitle;
  final String selectedId;
  final Widget body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final desktop = _useDesktopSidebar(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: desktop
          ? null
          : _buildSidebarDrawer(context: context, selectedId: selectedId),
      body: _buildShellSurface(
        context: context,
        selectedId: selectedId,
        child: Column(
          children: [
            _PageHeader(
              title: title,
              subtitle: subtitle,
              actions: actions,
              showMenuButton: !desktop,
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.subtitle,
    required this.actions,
    required this.showMenuButton,
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;
  final bool showMenuButton;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, topInset + 18, 20, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showMenuButton) ...[
            Builder(
              builder: (context) => _ShellIconButton(
                icon: Icons.menu_rounded,
                onTap: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryC(context),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryC(context),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (actions.isNotEmpty) ...[const SizedBox(width: 12), ...actions],
        ],
      ),
    );
  }
}

class _SidebarKpiChip extends StatelessWidget {
  const _SidebarKpiChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final title = icon == Icons.savings_rounded
        ? tr('Balance', 'ব্যালেন্স')
        : tr('Citizens', 'নাগরিক');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryLight, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryC(context).withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.accent),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarMenuTile extends StatelessWidget {
  const _SidebarMenuTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.selected,
    this.badgeText,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final bool selected;
  final String? badgeText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    colors: [AppColors.primaryLight, AppColors.primaryC(context)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: selected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.18)
                      : accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: selected ? Colors.white : accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.textPrimaryC(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (badgeText != null)
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.errorC(context),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badgeText!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
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
        return _constrainBodyWidth(
          context,
          ListView(
            padding: EdgeInsets.only(top: 0, bottom: 100),
            children: [
              _AppHeader(
                showMenuButton: !_useDesktopSidebar(context),
                actions: [const _NotificationButton()],
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
                                color: AppColors.primaryC(context).withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.person_outline_rounded,
                                color: AppColors.primaryC(context),
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              tr('Welcome!', 'স্বাগতম!'),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: AppColors.textPrimaryC(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tr(
                                'Login to access all features',
                                'সব ফিচার ব্যবহার করতে লগইন করুন',
                              ),
                              style: TextStyle(
                                color: AppColors.textSecondaryC(context),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 16),
                            PrimaryButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              ),
                              label: tr('Login', 'লগইন'),
                            ),
                          ],
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () async {
                          final profile = await DataService.instance
                              .getUserProfile();
                          if (!context.mounted) return;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProfileSetupScreen(existingProfile: profile),
                            ),
                          );
                        },
                        child: AppCard(
                          child: Row(
                            children: [
                              user.photoURL != null
                                  ? CircleAvatar(
                                      radius: 24,
                                      backgroundImage: NetworkImage(
                                        user.photoURL!,
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 24,
                                      backgroundColor: AppColors.primaryC(context)
                                          .withValues(alpha: 0.08),
                                      child: Icon(
                                        Icons.person_rounded,
                                        color: AppColors.primaryC(context),
                                        size: 24,
                                      ),
                                    ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.displayName ??
                                          user.email?.split('@').first ??
                                          tr('Citizen', 'নাগরিক'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimaryC(context),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      user.email ?? '',
                                      style: TextStyle(
                                        color: AppColors.textSecondaryC(context),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      tr(
                                        'Tap to edit profile',
                                        'প্রোফাইল সম্পাদনা করতে ট্যাপ করুন',
                                      ),
                                      style: TextStyle(
                                        color: AppColors.primaryC(context),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryC(context).withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.edit_rounded,
                                  color: AppColors.primaryC(context),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 4),
                              TextButton(
                                onPressed: data.signOut,
                                child: Text(
                                  tr('Logout', 'লগআউট'),
                                  style: TextStyle(
                                    color: AppColors.errorC(context),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      tr('Preferences', 'পছন্দসমূহ').toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppColors.textSecondaryC(context),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder(
                      valueListenable: accessibilityController,
                      builder: (context, AccessibilitySettings settings, _) {
                        return AppCard(
                          child: Column(
                            children: [
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                activeThumbColor: AppColors.primaryC(context),
                                title: Text(
                                  tr(
                                    'High contrast mode',
                                    'উচ্চ কনট্রাস্ট মোড',
                                  ),
                                  style: TextStyle(
                                    color: AppColors.textPrimaryC(context),
                                  ),
                                ),
                                value: settings.highContrast,
                                onChanged:
                                    accessibilityController.setHighContrast,
                              ),
                              const Divider(),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  tr('Language', 'ভাষা'),
                                  style: TextStyle(
                                    color: AppColors.textPrimaryC(context),
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SegmentedButton<String>(
                                      showSelectedIcon: false,
                                      selected: {settings.languageCode},
                                      onSelectionChanged: (v) =>
                                          accessibilityController
                                              .setLanguageCode(v.first),
                                      segments: const [
                                        ButtonSegment(
                                          value: 'en',
                                          label: Text('English'),
                                        ),
                                        ButtonSegment(
                                          value: 'bn',
                                          label: Text('বাংলা'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      tr('Quick Links', 'দ্রুত লিংক').toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppColors.textSecondaryC(context),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppCard(
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primaryC(context).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.account_balance_wallet_rounded,
                                color: AppColors.primaryC(context),
                                size: 18,
                              ),
                            ),
                            title: Text(
                              tr('Village Fund', 'গ্রাম তহবিল'),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimaryC(context),
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textSecondaryC(context),
                            ),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const VillageFundScreen(),
                              ),
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.infoC(context).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.construction_rounded,
                                color: AppColors.infoC(context),
                                size: 18,
                              ),
                            ),
                            title: Text(
                              tr('Projects', 'প্রকল্প'),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimaryC(context),
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textSecondaryC(context),
                            ),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ProjectsScreen(),
                              ),
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.people_rounded,
                                color: AppColors.secondary,
                                size: 18,
                              ),
                            ),
                            title: Text(
                              tr('Citizens', 'নাগরিক'),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimaryC(context),
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textSecondaryC(context),
                            ),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CitizensPage(),
                              ),
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.successC(context).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.leaderboard_rounded,
                                color: AppColors.successC(context),
                                size: 18,
                              ),
                            ),
                            title: Text(
                              tr('Leaderboard', 'লিডারবোর্ড'),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimaryC(context),
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textSecondaryC(context),
                            ),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const LeaderboardPage(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
