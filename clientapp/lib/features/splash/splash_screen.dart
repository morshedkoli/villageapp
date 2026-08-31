import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // Decorative background blobs — slow continuous breathing motion.
  late final AnimationController _blobController;

  // Logo badge scale/fade-in + one-shot ripple ring behind it.
  late final AnimationController _logoController;
  late final AnimationController _ringController;

  // Title/tagline block.
  late final AnimationController _contentController;

  // Bottom tagline + pulsing loading dots.
  late final AnimationController _bottomController;
  late final AnimationController _dotsController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;
  late final Animation<double> _contentOpacity;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _bottomOpacity;

  @override
  void initState() {
    super.initState();

    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _ringScale = Tween<double>(begin: 0.6, end: 1.7).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOut),
    );
    _ringOpacity = Tween<double>(begin: 0.35, end: 0.0).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOut),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(
          parent: _contentController,
          curve: Curves.easeOutCubic,
        ));

    _bottomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bottomOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bottomController, curve: Curves.easeOut),
    );

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    _logoController.forward();
    _ringController.forward();

    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    _contentController.forward();

    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    _bottomController.forward();

    await Future.delayed(const Duration(milliseconds: 1650));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

    // Check Firebase Auth state — never skip login for unauthenticated users.
    final user = DataService.instance.currentUser;

    if (!mounted) return;
    if (user != null) {
      // Already signed in → go home.
      context.go('/home');
    } else if (onboardingComplete) {
      // Seen onboarding before → go straight to login.
      context.go('/login');
    } else {
      // First launch → show onboarding.
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _blobController.dispose();
    _logoController.dispose();
    _ringController.dispose();
    _contentController.dispose();
    _bottomController.dispose();
    _dotsController.dispose();
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
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: _buildBlobLayer()),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  _buildLogoBadge(),
                  AppSpacing.hXxl,
                  _buildTitleBlock(),
                  const Spacer(flex: 3),
                  _buildBottomBlock(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Decorative drifting blobs ─────────────────────
  Widget _buildBlobLayer() {
    return AnimatedBuilder(
      animation: _blobController,
      builder: (context, _) {
        final t = _blobController.value;
        return Stack(
          children: [
            _blob(
              top: -60,
              left: -40,
              size: 220,
              color: AppColors.accentGold,
              scale: 0.9 + (t * 0.2),
            ),
            _blob(
              top: 140,
              right: -70,
              size: 260,
              color: AppColors.accentTerracotta,
              scale: 1.1 - (t * 0.15),
            ),
            _blob(
              bottom: -50,
              left: 20,
              size: 200,
              color: AppColors.primaryLight,
              scale: 0.85 + (t * 0.25),
            ),
          ],
        );
      },
    );
  }

  Widget _blob({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double size,
    required Color color,
    required double scale,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Transform.scale(
        scale: scale,
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Logo badge + ripple ring ──────────────────────
  Widget _buildLogoBadge() {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _ringController,
            builder: (context, _) => Opacity(
              opacity: _ringOpacity.value,
              child: Transform.scale(
                scale: _ringScale.value,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _logoController,
            builder: (context, child) => Opacity(
              opacity: _logoOpacity.value,
              child: Transform.scale(scale: _logoScale.value, child: child),
            ),
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.volunteer_activism_rounded,
                size: 68,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Title + tagline ───────────────────────────────
  Widget _buildTitleBlock() {
    return SlideTransition(
      position: _contentSlide,
      child: FadeTransition(
        opacity: _contentOpacity,
        child: Column(
          children: [
            const Text(
              'আল ইসলাহ',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
            AppSpacing.hSm,
            Text(
              'আপনার গ্রামের ডিজিটাল কমিউনিটি',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tagline + pulsing dots ────────────────────────
  Widget _buildBottomBlock() {
    return FadeTransition(
      opacity: _bottomOpacity,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.huge),
        child: Column(
          children: [
            _buildDots(),
            AppSpacing.hMd,
            Text(
              'সবার জন্য, সবার দ্বারা',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDots() {
    const intervals = [
      Interval(0.0, 0.7, curve: Curves.easeInOut),
      Interval(0.15, 0.85, curve: Curves.easeInOut),
      Interval(0.3, 1.0, curve: Curves.easeInOut),
    ];
    return AnimatedBuilder(
      animation: _dotsController,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final opacity = 0.3 +
                (0.7 * intervals[i].transform(_dotsController.value));
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Opacity(
                opacity: opacity.clamp(0.3, 1.0),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
