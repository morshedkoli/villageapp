part of '../screens.dart';


class RootShell extends StatefulWidget {
  const RootShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  late int _index;

  final _screens = const [HomeScreen(), ProblemsScreen(), _SettingsTab()];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, 2);
    // Process pending offline writes when connectivity returns.
    ConnectivityService.instance.addListener(_onConnectivityChanged);
  }

  @override
  void dispose() {
    ConnectivityService.instance.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  void _onConnectivityChanged() {
    if (mounted) setState(() {});
    if (ConnectivityService.instance.isOnline) {
      DataService.instance.processPendingWrites();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOffline = !ConnectivityService.instance.isOnline;
    final desktop = _useDesktopSidebar(context);
    const selectedIds = [_MenuId.home, _MenuId.problems, _MenuId.profile];
    final selectedId = selectedIds[_index];
    return Scaffold(
      backgroundColor: AppColors.backgroundC(context),
      drawer: desktop
          ? null
          : _buildSidebarDrawer(
              context: context,
              selectedId: selectedId,
              onRootSelected: (value) =>
                  setState(() => _index = value.clamp(0, 2)),
            ),
      body: _buildShellSurface(
        context: context,
        selectedId: selectedId,
        onRootSelected: (value) => setState(() => _index = value.clamp(0, 2)),
        child: _NotificationBannerHost(
          child: Column(
            children: [
              if (isOffline)
                Builder(
                  builder: (context) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 6,
                        bottom: 8,
                        left: 16,
                        right: 16,
                      ),
                      color: AppColors.surfaceVariantC(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_off_rounded,
                            color: AppColors.textSecondaryC(context),
                            size: 14,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            tr(
                              'You are offline — showing cached data',
                              'আপনি অফলাইন — ক্যাশ করা ডেটা দেখানো হচ্ছে',
                            ),
                            style: TextStyle(
                              color: AppColors.textSecondaryC(context),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, anim) {
                    final slide = Tween<Offset>(
                      begin: const Offset(0, 0.02),
                      end: Offset.zero,
                    ).animate(anim);
                    return FadeTransition(
                      opacity: anim,
                      child: SlideTransition(position: slide, child: child),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey<int>(_index),
                    child: _screens[_index],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: desktop ? null : _PolishedBottomNav(
        index: _index,
        onChange: (value) {
          if (value == _index) return;
          Haptics.tap();
          setState(() => _index = value.clamp(0, 2));
        },
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// _PolishedBottomNav — bespoke nav bar with animated indicator + haptics
// ────────────────────────────────────────────────────────────────────────────

class _PolishedBottomNav extends StatelessWidget {
  const _PolishedBottomNav({
    required this.index,
    required this.onChange,
  });

  final int index;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    final items = <_NavItem>[
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: tr('Home', 'হোম'),
      ),
      _NavItem(
        icon: Icons.report_problem_outlined,
        activeIcon: Icons.report_problem_rounded,
        label: tr('Problems', 'সমস্যা'),
      ),
      _NavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: tr('Profile', 'প্রোফাইল'),
      ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceC(context),
        border: Border(
          top: BorderSide(
            color: AppColors.borderLightC(context),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(items.length, (i) {
              return Expanded(
                child: _NavTab(
                  item: items[i],
                  active: i == index,
                  onTap: () => onChange(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final muted = AppColors.textTertiaryC(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: cs.primary.withValues(alpha: 0.06),
        highlightColor: cs.primary.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  active ? item.activeIcon : item.icon,
                  key: ValueKey<bool>(active),
                  size: 22,
                  color: active ? cs.primary : muted,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: active ? cs.primary : muted,
                ),
                child: Text(item.label),
              ),
              const SizedBox(height: 4),
              AnimatedDot(active: active),
            ],
          ),
        ),
      ),
    );
  }
}
