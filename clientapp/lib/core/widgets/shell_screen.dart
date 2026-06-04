import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

final List<ShellTab> _tabs = [
  ShellTab(
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'হোম',
    path: '/home',
  ),
  ShellTab(
    icon: Icons.volunteer_activism_outlined,
    activeIcon: Icons.volunteer_activism_rounded,
    label: 'দান',
    path: '/donate',
  ),
  ShellTab(
    icon: Icons.report_outlined,
    activeIcon: Icons.report_rounded,
    label: 'সমস্যা',
    path: '/problems',
  ),
  ShellTab(
    icon: Icons.people_outline_rounded,
    activeIcon: Icons.people_rounded,
    label: 'নাগরিক',
    path: '/citizens',
  ),
  ShellTab(
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
    label: 'প্রোফাইল',
    path: '/profile',
  ),
];

class ShellTab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;
  const ShellTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
  });
}

class ShellScreen extends StatelessWidget {
  final Widget child;

  const ShellScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _tabs.indexWhere((t) => location.startsWith(t.path));

    // ── Clamp unknown routes to 0
    final idx = currentIndex < 0 ? 0 : currentIndex;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: AppColors.darkSurface,
              systemNavigationBarIconBrightness: Brightness.light,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: AppColors.lightSurface,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
      child: Scaffold(
        extendBody: true,
        body: child,
        bottomNavigationBar: _PremiumNavBar(
          currentIndex: idx,
          onTap: (i) {
            if (i != idx) {
              HapticFeedback.selectionClick();
              context.go(_tabs[i].path);
            }
          },
          tabs: _tabs,
          isDark: isDark,
        ),
      ),
    );
  }
}

class _PremiumNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<ShellTab> tabs;
  final bool isDark;

  const _PremiumNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.tabs,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Wrapped in DecoratedBox for top-border divider
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        destinations: List.generate(tabs.length, (i) {
          final tab = tabs[i];
          return NavigationDestination(
            icon: Icon(tab.icon),
            selectedIcon: Icon(tab.activeIcon),
            label: tab.label,
          );
        }),
      ),
    );
  }
}
