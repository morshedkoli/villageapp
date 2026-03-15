import 'package:flutter/material.dart';

import 'screens.dart';

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
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
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
    _featuresSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
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

    // Navigate after splash completes
    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => const RootShell(),
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1C1C1E),
              Color(0xFF2C2C2E),
              Color(0xFF1C1C1E),
            ],
          ),
        ),
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
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF9500).withValues(alpha: 0.3),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── App name & tagline ──
              SlideTransition(
                position: _contentSlide,
                child: FadeTransition(
                  opacity: _contentOpacity,
                  child: const Column(
                    children: [
                      Text(
                        'দৌলতপাড়া',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'স্বচ্ছ গ্রাম তহবিল ও উন্নয়ন অংশগ্রহণ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFFF9500),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

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
                        SizedBox(height: 14),
                        _FeatureRow(
                          icon: Icons.construction_outlined,
                          text: 'উন্নয়ন প্রকল্প পর্যবেক্ষণ',
                        ),
                        SizedBox(height: 14),
                        _FeatureRow(
                          icon: Icons.people_outline,
                          text: 'জনগণের অংশগ্রহণ ও স্বচ্ছতা',
                        ),
                        SizedBox(height: 14),
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
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  child: Column(
                    children: [
                      Text(
                        'সবার জন্য, সবার দ্বারা',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF9500),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'দৌলতপাড়া গ্রামের ডিজিটাল প্ল্যাটফর্ম',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8E8E93),
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFFF9500).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFFFF9500), size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }
}
