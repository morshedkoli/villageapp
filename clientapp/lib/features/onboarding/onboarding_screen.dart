import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../push_notification_service.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;
  bool _notifPermissionGranted = false;
  bool _notifRequesting = false;

  static const _totalPages = 5;

  static const _featurePages = [
    _OnboardingPage(
      icon: Icons.account_balance_wallet_rounded,
      titleBn: 'স্বচ্ছ গ্রাম তহবিল',
      descBn: 'প্রতিটি অনুদান ও খরচ রিয়েল-টাইমে ট্র্যাক করুন। গ্রামের তহবিল কিভাবে ব্যবহার হচ্ছে তা দেখুন।',
    ),
    _OnboardingPage(
      icon: Icons.construction_rounded,
      titleBn: 'উন্নয়ন প্রকল্প',
      descBn: 'গ্রাম উন্নয়ন প্রকল্প, তাদের অগ্রগতি এবং খরচের রিপোর্ট পর্যবেক্ষণ করুন।',
    ),
    _OnboardingPage(
      icon: Icons.report_problem_rounded,
      titleBn: 'সমস্যা রিপোর্ট',
      descBn: 'ছবি ও অবস্থান সহ গ্রামের সমস্যা রিপোর্ট করুন। সমাধানের অগ্রগতি ট্র্যাক করুন।',
    ),
    _OnboardingPage(
      icon: Icons.people_rounded,
      titleBn: 'জনগণের অংশগ্রহণ',
      descBn: 'আপনার গ্রামের কমিউনিটিতে যোগ দিন। অনুদান দিন, অংশগ্রহণ করুন এবং একসাথে পরিবর্তন আনুন।',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
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

  bool get _isLastPage => _currentPage == _totalPages - 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: List.generate(_totalPages, (i) {
                        final active = i == _currentPage;
                        final visited = i < _currentPage;
                        return Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutCubic,
                            margin: EdgeInsets.only(
                              right: i == _totalPages - 1 ? 0 : 6,
                            ),
                            height: 3,
                            decoration: BoxDecoration(
                              color: active || visited
                                  ? context.primary
                                  : context.border,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: _complete,
                    style: TextButton.styleFrom(
                      foregroundColor: context.textTertiary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'এড়িয়ে যান',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _totalPages,
                itemBuilder: (context, i) {
                  if (i < _featurePages.length) {
                    return _FeaturePageView(page: _featurePages[i]);
                  }
                  return _NotificationPermissionPageView(
                    granted: _notifPermissionGranted,
                    requesting: _notifRequesting,
                    onRequestPermission: _requestNotificationPermission,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 52,
                    child: _isLastPage
                        ? _buildNotificationButton()
                        : FilledButton(
                            onPressed: () => _controller.nextPage(
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeOutCubic,
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: context.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'পরবর্তী',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.1,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                          ),
                  ),
                  if (!_isLastPage) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        '${_currentPage + 1} / $_totalPages',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textTertiary,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationButton() {
    if (_notifPermissionGranted) {
      return FilledButton(
        onPressed: _complete,
        style: FilledButton.styleFrom(
          backgroundColor: context.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'শুরু করুন',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _notifRequesting ? null : _complete,
            style: OutlinedButton.styleFrom(
              foregroundColor: context.textSecondary,
              backgroundColor: context.surface,
              side: BorderSide(color: context.border, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(
              'পরে হবে',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton(
            onPressed: _notifRequesting ? null : _requestNotificationPermission,
            style: FilledButton.styleFrom(
              backgroundColor: context.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: context.primary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              minimumSize: const Size.fromHeight(52),
              elevation: 0,
            ),
            child: _notifRequesting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'অনুমতি দিন',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _FeaturePageView extends StatelessWidget {
  const _FeaturePageView({required this.page});

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              color: context.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: context.primary.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Icon(page.icon, color: context.primary, size: 56),
          ),
          const SizedBox(height: 40),
          Text(
            page.titleBn,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
              letterSpacing: -0.4,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            page.descBn,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: context.textSecondary,
              height: 1.55,
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

class _NotificationPermissionPageView extends StatelessWidget {
  const _NotificationPermissionPageView({
    required this.granted,
    required this.requesting,
    required this.onRequestPermission,
  });

  final bool granted;
  final bool requesting;
  final VoidCallback onRequestPermission;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 1),
          SizedBox(
            width: 132,
            height: 132,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    color: granted
                        ? context.success.withValues(alpha: 0.10)
                        : context.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(
                      color: (granted ? context.success : context.primary)
                          .withValues(alpha: 0.12),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    granted
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_rounded,
                    color: granted ? context.success : context.primary,
                    size: 56,
                  ),
                ),
                if (granted)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: context.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.surface, width: 3),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          Text(
            granted ? 'নোটিফিকেশন সক্রিয়' : 'আপডেট থাকুন',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
              letterSpacing: -0.4,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            granted
                ? 'আপনি নতুন অনুদান, প্রকল্প আপডেট এবং কমিউনিটি সতর্কতার জন্য নোটিফিকেশন পাবেন।'
                : 'গ্রামের তহবিল আপডেট, নতুন অনুদান, উন্নয়ন প্রকল্প এবং কমিউনিটি সতর্কতা সম্পর্কে নোটিফিকেশন পান।',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: context.textSecondary,
              height: 1.55,
            ),
          ),
          if (!granted) ...[
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: context.border, width: 1),
              ),
              child: Column(
                children: [
                  _NotificationPreviewRow(
                    icon: Icons.volunteer_activism_rounded,
                    color: context.success,
                    title: 'নতুন অনুদান',
                    subtitle: 'রহিম ৳৫,০০০ অনুদান দিয়েছেন',
                  ),
                  Divider(
                    color: context.divider,
                    height: 18,
                    thickness: 1,
                  ),
                  _NotificationPreviewRow(
                    icon: Icons.construction_rounded,
                    color: context.info,
                    title: 'প্রকল্প আপডেট',
                    subtitle: 'রাস্তা মেরামত ৭০% সম্পূর্ণ',
                  ),
                ],
              ),
            ),
          ],
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _NotificationPreviewRow extends StatelessWidget {
  const _NotificationPreviewRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: TextStyle(
                  color: context.textTertiary,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.titleBn,
    required this.descBn,
  });

  final IconData icon;
  final String titleBn;
  final String descBn;
}
