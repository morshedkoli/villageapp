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
              Expanded(child: _screens[_index]),
            ],
          ),
        ),
      ),
      bottomNavigationBar: desktop
          ? null
          : DecoratedBox(
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
                child: NavigationBar(
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  selectedIndex: _index,
                  onDestinationSelected: (value) {
                    setState(() => _index = value.clamp(0, 2));
                  },
                  destinations: [
                    NavigationDestination(
                      icon: const Icon(Icons.home_outlined),
                      selectedIcon: const Icon(Icons.home_rounded),
                      label: tr('Home', 'হোম'),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.report_problem_outlined),
                      selectedIcon: const Icon(Icons.report_problem_rounded),
                      label: tr('Problems', 'সমস্যা'),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.person_outline_rounded),
                      selectedIcon: const Icon(Icons.person_rounded),
                      label: tr('Profile', 'প্রোফাইল'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
