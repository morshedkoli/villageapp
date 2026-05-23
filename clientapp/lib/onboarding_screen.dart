import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'push_notification_service.dart';
import 'ui/accessibility.dart';
import 'ui/design_system.dart';

/// Multi-page onboarding shown only once for first-time users.
/// The final page asks for push notification permission.
///
/// Design: modern minimal — solid surfaces, hairline borders, single accent.
/// Adapts cleanly to both light and dark themes.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  /// 4 feature pages + 1 notification permission page.
  static const _totalPages = 5;

  static const _featurePages = [
    _OnboardingPage(
      icon: Icons.account_balance_wallet_rounded,
      titleEn: 'Transparent village fund',
      titleBn: 'স্বচ্ছ গ্রাম তহবিল',
      descEn:
          'Track every donation and expense in real time. See exactly how the village fund is being used.',
      descBn:
          'প্রতিটি অনুদান ও খরচ রিয়েল-টাইমে ট্র্যাক করুন। গ্রামের তহবিল কিভাবে ব্যবহার হচ্ছে তা দেখুন।',
    ),
    _OnboardingPage(
      icon: Icons.construction_rounded,
      titleEn: 'Development projects',
      titleBn: 'উন্নয়ন প্রকল্প',
      descEn:
          'Monitor village projects, follow their progress, and review spending reports.',
      descBn:
          'গ্রাম উন্নয়ন প্রকল্প, তাদের অগ্রগতি এবং খরচের রিপোর্ট পর্যবেক্ষণ করুন।',
    ),
    _OnboardingPage(
      icon: Icons.report_problem_rounded,
      titleEn: 'Report problems',
      titleBn: 'সমস্যা রিপোর্ট',
      descEn:
          'Report village issues with photos and location. Track resolution progress.',
      descBn:
          'ছবি ও অবস্থান সহ গ্রামের সমস্যা রিপোর্ট করুন। সমাধানের অগ্রগতি ট্র্যাক করুন।',
    ),
    _OnboardingPage(
      icon: Icons.people_rounded,
      titleEn: 'Community participation',
      titleBn: 'জনগণের অংশগ্রহণ',
      descEn:
          'Join your village community. Donate, participate, and make a difference together.',
      descBn:
          'আপনার গ্রামের কমিউনিটিতে যোগ দিন। অনুদান দিন, অংশগ্রহণ করুন এবং একসাথে পরিবর্তন আনুন।',
    ),
  ];

  bool _notifPermissionGranted = false;
  bool _notifRequesting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    widget.onComplete();
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
      backgroundColor: AppColors.backgroundC(context),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar: progress + skip ──
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
                                  ? AppColors.primaryC(context)
                                  : AppColors.borderC(context),
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
                      foregroundColor: AppColors.textTertiaryC(context),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      tr('Skip', 'এড়িয়ে যান'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Pages ──
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
                  );
                },
              ),
            ),

            // ── Bottom action area ──
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
                            onPressed: _next,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primaryC(context),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  tr('Continue', 'পরবর্তী'),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                  ),
                  // Page count caption
                  if (!_isLastPage) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        '${_currentPage + 1} / $_totalPages',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiaryC(context),
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

  void _next() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  /// Bottom button for the notification permission page.
  Widget _buildNotificationButton() {
    if (_notifPermissionGranted) {
      return FilledButton(
        onPressed: _complete,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryC(context),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tr('Get started', 'শুরু করুন'),
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
              foregroundColor: AppColors.textSecondaryC(context),
              backgroundColor: AppColors.surfaceC(context),
              side: BorderSide(color: AppColors.borderC(context), width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(
              tr('Not now', 'পরে হবে'),
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
              backgroundColor: AppColors.primaryC(context),
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  AppColors.primaryC(context).withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
                    tr('Allow', 'অনুমতি দিন'),
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

// ────────────────────────────────────────────────────────────────────────────
// Feature page — minimal hero illustration + copy
// ────────────────────────────────────────────────────────────────────────────

class _FeaturePageView extends StatelessWidget {
  const _FeaturePageView({required this.page});

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.primaryC(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          // Illustration: large flat tinted square with an icon — matches the
          // minimal aesthetic of the rest of the app.
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              color: AppColors.primaryMutedC(context),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: accent.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Icon(page.icon, color: accent, size: 56),
          ),
          const SizedBox(height: 40),
          Text(
            tr(page.titleEn, page.titleBn),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryC(context),
              letterSpacing: -0.4,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            tr(page.descEn, page.descBn),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondaryC(context),
              height: 1.55,
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Notification permission page
// ────────────────────────────────────────────────────────────────────────────

class _NotificationPermissionPageView extends StatelessWidget {
  const _NotificationPermissionPageView({required this.granted});

  final bool granted;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.primaryC(context);
    final surface = AppColors.surfaceC(context);
    final border = AppColors.borderC(context);
    final success = AppColors.successC(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 1),
          // Illustration with optional success badge
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
                        ? success.withValues(alpha: 0.10)
                        : AppColors.primaryMutedC(context),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: (granted ? success : accent)
                          .withValues(alpha: 0.12),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    granted
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_rounded,
                    color: granted ? success : accent,
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
                        color: success,
                        shape: BoxShape.circle,
                        border: Border.all(color: surface, width: 3),
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
            granted
                ? tr('Notifications enabled', 'নোটিফিকেশন সক্রিয়')
                : tr('Stay updated', 'আপডেট থাকুন'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryC(context),
              letterSpacing: -0.4,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            granted
                ? tr(
                    'You will receive updates for new donations, project progress, and community alerts.',
                    'আপনি নতুন অনুদান, প্রকল্প আপডেট এবং কমিউনিটি সতর্কতার জন্য নোটিফিকেশন পাবেন।',
                  )
                : tr(
                    'Get notified about fund updates, donations, projects, and community alerts.',
                    'গ্রামের তহবিল আপডেট, নতুন অনুদান, উন্নয়ন প্রকল্প এবং কমিউনিটি সতর্কতা সম্পর্কে নোটিফিকেশন পান।',
                  ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondaryC(context),
              height: 1.55,
            ),
          ),
          if (!granted) ...[
            const SizedBox(height: 28),
            // Notification preview — clean hairline-border surface.
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border, width: 1),
              ),
              child: Column(
                children: [
                  _NotificationPreviewRow(
                    icon: Icons.volunteer_activism_rounded,
                    color: success,
                    title: tr('New donation', 'নতুন অনুদান'),
                    subtitle: tr(
                      'Rahim donated ৳5,000',
                      'রহিম ৳৫,০০০ অনুদান দিয়েছেন',
                    ),
                  ),
                  Divider(
                    color: AppColors.borderLightC(context),
                    height: 18,
                    thickness: 1,
                  ),
                  _NotificationPreviewRow(
                    icon: Icons.construction_rounded,
                    color: AppColors.infoC(context),
                    title: tr('Project update', 'প্রকল্প আপডেট'),
                    subtitle: tr(
                      'Road repair 70% complete',
                      'রাস্তা মেরামত ৭০% সম্পূর্ণ',
                    ),
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
            borderRadius: BorderRadius.circular(10),
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
                  color: AppColors.textPrimaryC(context),
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
                  color: AppColors.textTertiaryC(context),
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
    required this.titleEn,
    required this.titleBn,
    required this.descEn,
    required this.descBn,
  });

  final IconData icon;
  final String titleEn;
  final String titleBn;
  final String descEn;
  final String descBn;
}

/// Check if onboarding has been completed.
Future<bool> isOnboardingComplete() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboarding_complete') ?? false;
}
