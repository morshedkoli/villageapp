import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../push_notification_service.dart';
import 'onboarding_pages.dart';
import 'widgets/feature_page_view.dart';
import 'widgets/notification_permission_page.dart';
import 'widgets/onboarding_footer.dart';
import 'widgets/onboarding_progress.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const Duration _pageTransition = Duration(milliseconds: 320);

  final _controller = PageController();
  int _currentPage = 0;
  bool _notifPermissionGranted = false;
  bool _notifRequesting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Marks onboarding as seen and hands over to sign-in. Reached from the skip
  /// action, the "later" button, and the final "start" button alike.
  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kOnboardingCompleteKey, true);
    if (!mounted) return;
    context.go('/login');
  }

  Future<void> _requestNotificationPermission() async {
    setState(() => _notifRequesting = true);
    final granted = await PushNotificationService.instance.requestPermission();
    if (!mounted) return;
    setState(() {
      _notifPermissionGranted = granted;
      _notifRequesting = false;
    });
  }

  void _goToNextPage() {
    _controller.nextPage(
      duration: _pageTransition,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Column(
          children: [
            OnboardingProgress(
              currentPage: _currentPage,
              onSkip: _complete,
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemCount: kOnboardingPageCount,
                itemBuilder: (context, index) {
                  if (isNotificationPage(index)) {
                    return NotificationPermissionPage(
                      granted: _notifPermissionGranted,
                    );
                  }
                  return FeaturePageView(page: kFeaturePages[index]);
                },
              ),
            ),
            OnboardingFooter(
              currentPage: _currentPage,
              permissionGranted: _notifPermissionGranted,
              requestingPermission: _notifRequesting,
              onNext: _goToNextPage,
              onRequestPermission: _requestNotificationPermission,
              onFinish: _complete,
            ),
          ],
        ),
      ),
    );
  }
}
