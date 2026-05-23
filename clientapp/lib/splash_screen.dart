import 'package:flutter/material.dart';

import 'onboarding_screen.dart';
import 'screens.dart';
import 'ui/design_system.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _contentController;
  late final AnimationController _shimmerController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _contentOpacity;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _featuresOpacity;
  late final Animation<Offset> _featuresSlide;
  late final Animation<double> _bottomOpacity;

  @override
  void initState() {
    super.initState();

    // Logo: scale up + fade in (0 → 800ms)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Content: slide up + fade in (400ms → 1200ms)
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _contentController,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
          ),
        );
    _featuresOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );
    _featuresSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
          ),
        );
    _bottomOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    // Shimmer on logo
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _contentController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _shimmerController.repeat();

    // Check onboarding status while user sees splash.
    final onboardingDone = await isOnboardingComplete();

    // Wait for remaining animation time.
    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;

    if (onboardingDone) {
      _navigateToRoot();
    } else {
      _navigateToOnboarding();
    }
  }

  void _navigateToRoot() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RootShell(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _navigateToOnboarding() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            OnboardingScreen(
              onComplete: () {
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const RootShell(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                  ),
                );
              },
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PatternBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Animated logo ──
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.borderC(context),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── App name & tagline ──
              SlideTransition(
                position: _contentSlide,
                child: FadeTransition(
                  opacity: _contentOpacity,
                  child: Column(
                    children: [
                      Text(
                        'AL ISLAH',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryC(context),
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Juba Forum Community Platform',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textTertiaryC(context),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // ── Feature highlights ──
              SlideTransition(
                position: _featuresSlide,
                child: FadeTransition(
                  opacity: _featuresOpacity,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        _FeatureRow(
                          icon: Icons.account_balance_wallet_outlined,
                          text: 'গ্রামের তহবিল ব্যবস্থাপনা',
                        ),
                        SizedBox(height: 16),
                        _FeatureRow(
                          icon: Icons.construction_outlined,
                          text: 'উন্নয়ন প্রকল্প পর্যবেক্ষণ',
                        ),
                        SizedBox(height: 16),
                        _FeatureRow(
                          icon: Icons.people_outline,
                          text: 'জনগণের অংশগ্রহণ ও স্বচ্ছতা',
                        ),
                        SizedBox(height: 16),
                        _FeatureRow(
                          icon: Icons.report_problem_outlined,
                          text: 'সমস্যা রিপোর্ট ও সমাধান',
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // ── Bottom text ──
              FadeTransition(
                opacity: _bottomOpacity,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Column(
                    children: [
                      Text(
                        'For Everyone, By Everyone',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryC(context),
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'AL ISLAH Juba Community Platform',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiaryC(context),
                        ),
                      ),
                    ],
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

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryMutedC(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryC(context), size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimaryC(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
