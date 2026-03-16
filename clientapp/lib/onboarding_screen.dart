import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'push_notification_service.dart';
import 'ui/accessibility.dart';

/// Multi-page onboarding shown only once for first-time users.
/// The final page asks for push notification permission.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  /// Total pages = 4 feature pages + 1 notification permission page.
  static const _totalPages = 5;

  static const _featurePages = [
    _OnboardingPage(
      icon: Icons.account_balance_wallet_rounded,
      titleEn: 'Transparent Village Fund',
      titleBn: 'স্বচ্ছ গ্রাম তহবিল',
      descEn: 'Track every donation and expense in real-time. See exactly how the village fund is being used.',
      descBn: 'প্রতিটি অনুদান ও খরচ রিয়েল-টাইমে ট্র্যাক করুন। গ্রামের তহবিল কিভাবে ব্যবহার হচ্ছে তা দেখুন।',
      gradient: [Color(0xFFFF9500), Color(0xFFFF6B00)],
    ),
    _OnboardingPage(
      icon: Icons.construction_rounded,
      titleEn: 'Development Projects',
      titleBn: 'উন্নয়ন প্রকল্প',
      descEn: 'Monitor village development projects, their progress, and spending reports.',
      descBn: 'গ্রাম উন্নয়ন প্রকল্প, তাদের অগ্রগতি এবং খরচের রিপোর্ট পর্যবেক্ষণ করুন।',
      gradient: [Color(0xFF007AFF), Color(0xFF5856D6)],
    ),
    _OnboardingPage(
      icon: Icons.report_problem_rounded,
      titleEn: 'Report Problems',
      titleBn: 'সমস্যা রিপোর্ট',
      descEn: 'Report village issues with photos and location. Track resolution progress.',
      descBn: 'ছবি ও অবস্থান সহ গ্রামের সমস্যা রিপোর্ট করুন। সমাধানের অগ্রগতি ট্র্যাক করুন।',
      gradient: [Color(0xFFFF3B30), Color(0xFFFF6259)],
    ),
    _OnboardingPage(
      icon: Icons.people_rounded,
      titleEn: 'Community Participation',
      titleBn: 'জনগণের অংশগ্রহণ',
      descEn: 'Join your village community. Donate, participate, and make a difference together.',
      descBn: 'আপনার গ্রামের কমিউনিটিতে যোগ দিন। অনুদান দিন, অংশগ্রহণ করুন এবং একসাথে পরিবর্তন আনুন।',
      gradient: [Color(0xFF34C759), Color(0xFF30D158)],
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

  bool get _isNotificationPage => _currentPage == _totalPages - 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1C1C1E), Color(0xFF2C2C2E), Color(0xFF1C1C1E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20, top: 12),
                  child: TextButton(
                    onPressed: _complete,
                    child: Text(
                      tr('Skip', 'এড়িয়ে যান'),
                      style: const TextStyle(
                        color: Color(0xFF8E8E93),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _totalPages,
                  itemBuilder: (context, i) {
                    if (i < _featurePages.length) {
                      return _buildFeaturePage(_featurePages[i]);
                    }
                    // Notification permission page (last page)
                    return _buildNotificationPermissionPage();
                  },
                ),
              ),

              // Dot indicators
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _totalPages,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == i ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == i
                            ? const Color(0xFFFF9500)
                            : const Color(0xFF48484A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: _isNotificationPage
                      ? _buildNotificationButton()
                      : FilledButton(
                          onPressed: () {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutCubic,
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9500),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            tr('Next', 'পরবর্তী'),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Button for the notification permission page. Changes state based on
  /// whether permission has been requested/granted.
  Widget _buildNotificationButton() {
    if (_notifPermissionGranted) {
      // Permission granted — show "Get Started" to finish onboarding.
      return FilledButton(
        onPressed: _complete,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF34C759),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          tr('Get Started', 'শুরু করুন'),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: _notifRequesting ? null : _requestNotificationPermission,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF9500),
              disabledBackgroundColor:
                  const Color(0xFFFF9500).withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_notifRequesting)
                  const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                Text(
                  _notifRequesting
                      ? tr('Requesting...', 'অনুরোধ করা হচ্ছে...')
                      : tr('Allow Notifications', 'নোটিফিকেশন অনুমতি দিন'),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _complete,
          child: Text(
            tr('Maybe later', 'পরে হবে'),
            style: const TextStyle(
              color: Color(0xFF8E8E93),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a feature page (pages 1–4).
  Widget _buildFeaturePage(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: page.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: page.gradient[0].withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(page.icon, color: Colors.white, size: 52),
          ),
          const SizedBox(height: 40),
          Text(
            tr(page.titleEn, page.titleBn),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            tr(page.descEn, page.descBn),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF8E8E93),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the notification permission page (page 5).
  Widget _buildNotificationPermissionPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated bell icon container
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9500), Color(0xFFFF6B00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9500).withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  _notifPermissionGranted
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_rounded,
                  color: Colors.white,
                  size: 52,
                ),
                if (_notifPermissionGranted)
                  Positioned(
                    right: 24,
                    top: 20,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34C759),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Text(
            _notifPermissionGranted
                ? tr('Notifications Enabled!', 'নোটিফিকেশন সক্রিয়!')
                : tr('Stay Updated', 'আপডেট থাকুন'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _notifPermissionGranted
                ? tr(
                    'You will receive notifications for new donations, project updates, and community alerts.',
                    'আপনি নতুন অনুদান, প্রকল্প আপডেট এবং কমিউনিটি সতর্কতার জন্য নোটিফিকেশন পাবেন।',
                  )
                : tr(
                    'Get instant notifications about village fund updates, new donations, development projects, and community alerts.',
                    'গ্রামের তহবিল আপডেট, নতুন অনুদান, উন্নয়ন প্রকল্প এবং কমিউনিটি সতর্কতা সম্পর্কে তাৎক্ষণিক নোটিফিকেশন পান।',
                  ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF8E8E93),
              height: 1.5,
            ),
          ),
          if (!_notifPermissionGranted) ...[
            const SizedBox(height: 32),
            // Notification preview cards
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  _notifPreviewRow(
                    Icons.volunteer_activism_rounded,
                    const Color(0xFFFF9500),
                    tr('New Donation', 'নতুন অনুদান'),
                    tr('Rahim donated ৳5,000', 'রহিম ৳৫,০০০ অনুদান দিয়েছেন'),
                  ),
                  Divider(
                      color: Colors.white.withValues(alpha: 0.1),
                      height: 20),
                  _notifPreviewRow(
                    Icons.construction_rounded,
                    const Color(0xFF007AFF),
                    tr('Project Update', 'প্রকল্প আপডেট'),
                    tr('Road repair 70% complete', 'রাস্তা মেরামত ৭০% সম্পূর্ণ'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _notifPreviewRow(
      IconData icon, Color color, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(
                      color: Color(0xFF8E8E93), fontSize: 12)),
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
    required this.gradient,
  });

  final IconData icon;
  final String titleEn;
  final String titleBn;
  final String descEn;
  final String descBn;
  final List<Color> gradient;
}

/// Check if onboarding has been completed.
Future<bool> isOnboardingComplete() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboarding_complete') ?? false;
}
