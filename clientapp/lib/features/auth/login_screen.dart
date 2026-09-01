import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../services/auth_service.dart';
import 'widgets/login_card.dart';
import 'widgets/login_hero.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Login Screen — full redesign
// Layout: Gradient hero (top 42%) + bottom sheet card (remaining)
// ─────────────────────────────────────────────────────────────────────────────

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  // Auth mode: 0 = phone, 1 = google
  int _selectedTab = 0;
  bool _loading = false;

  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;

  // Hero animation controller
  late final AnimationController _heroCtrl;
  late final Animation<double> _heroAnim;

  // Shimmer / pulse on the icon
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _heroAnim = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic);
    _heroCtrl.forward();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _pulseCtrl.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ── Auth actions ─────────────────────────────────────────────────────

  Future<void> _signInWithPhone() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (phone.isEmpty) { _showError('ফোন নম্বর লিখুন।'); return; }
    if (password.isEmpty) { _showError('পাসওয়ার্ড লিখুন।'); return; }

    _dismissKeyboard();
    setState(() => _loading = true);
    try {
      await AuthService.instance.signInWithPhoneAndPassword(
        phone: phone,
        password: password,
      );
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    _dismissKeyboard();
    setState(() => _loading = true);
    try {
      await AuthService.instance.signInWithGoogle();
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _dismissKeyboard() {
    _phoneFocus.unfocus();
    _passwordFocus.unfocus();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
            AppSpacing.wSm,
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.error,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = context.isDark;
    final heroHeight = size.height * 0.42;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.lightCanvas,
      body: GestureDetector(
        onTap: _dismissKeyboard,
        child: Stack(
          children: [
            // ── 1. Background gradient ──────────────────────────────────
            HeroBackground(height: heroHeight, isDark: isDark),

            // ── 2. Geometric decoration ────────────────────────────────
            GeometricDecoration(height: heroHeight),

            // ── 3. Main scrollable content ─────────────────────────────
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  // Hero section
                  SizedBox(
                    height: heroHeight,
                    child: HeroContent(
                      pulseAnim: _pulseAnim,
                      heroAnim: _heroAnim,
                    ),
                  ),

                  // Card section
                  LoginCard(
                    selectedTab: _selectedTab,
                    onTabChange: (i) => setState(() => _selectedTab = i),
                    loading: _loading,
                    obscurePassword: _obscurePassword,
                    phoneController: _phoneController,
                    passwordController: _passwordController,
                    phoneFocus: _phoneFocus,
                    passwordFocus: _passwordFocus,
                    onTogglePassword: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    onPhoneLogin: _signInWithPhone,
                    onGoogleLogin: _signInWithGoogle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Background — animated gradient
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Geometric decoration — subtle Islamic-pattern circles
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Hero content — logo + title
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Login Card — bottom sheet style card
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Segmented tab switcher
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Phone + Password form
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Google form
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Quick alternate buttons
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Reusable field components
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Primary action button with gradient
// ─────────────────────────────────────────────────────────────────────────────


