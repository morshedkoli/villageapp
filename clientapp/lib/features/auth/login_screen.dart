import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/motion.dart';
import '../../data_service.dart';

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
      await DataService.instance.signInWithPhoneAndPassword(
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
      await DataService.instance.signInWithGoogle();
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
            _HeroBackground(height: heroHeight, isDark: isDark),

            // ── 2. Geometric decoration ────────────────────────────────
            _GeometricDecoration(height: heroHeight),

            // ── 3. Main scrollable content ─────────────────────────────
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  // Hero section
                  SizedBox(
                    height: heroHeight,
                    child: _HeroContent(
                      pulseAnim: _pulseAnim,
                      heroAnim: _heroAnim,
                    ),
                  ),

                  // Card section
                  _LoginCard(
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

class _HeroBackground extends StatelessWidget {
  final double height;
  final bool isDark;
  const _HeroBackground({required this.height, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0F2518),
                    const Color(0xFF16A34A),
                    const Color(0xFF15803D),
                  ]
                : [
                    const Color(0xFF166534),
                    const Color(0xFF16A34A),
                    const Color(0xFF22C55E),
                  ],
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Geometric decoration — subtle Islamic-pattern circles
// ─────────────────────────────────────────────────────────────────────────────

class _GeometricDecoration extends StatelessWidget {
  final double height;
  const _GeometricDecoration({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _CirclePatternPainter()),
    );
  }
}

class _CirclePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Large arc top-right
    canvas.drawCircle(Offset(size.width + 20, -30), 180, paint);
    canvas.drawCircle(Offset(size.width + 20, -30), 130, paint);

    // Small circles bottom-left
    final fill = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(-40, size.height * 0.7), 120, fill);
    canvas.drawCircle(Offset(-40, size.height * 0.7), 80, paint);

    // Dotted grid pattern
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    const spacing = 32.0;
    for (double x = spacing; x < size.width - 40; x += spacing) {
      for (double y = spacing; y < size.height * 0.6; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero content — logo + title
// ─────────────────────────────────────────────────────────────────────────────

class _HeroContent extends StatelessWidget {
  final Animation<double> pulseAnim;
  final Animation<double> heroAnim;

  const _HeroContent({
    required this.pulseAnim,
    required this.heroAnim,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pulsing glow ring + icon
            FadeTransition(
              opacity: heroAnim,
              child: AnimatedBuilder(
                animation: pulseAnim,
                builder: (_, child) => Transform.scale(
                  scale: pulseAnim.value,
                  child: child,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow ring
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.20),
                          width: 1.5,
                        ),
                      ),
                    ),
                    // Inner icon container
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.holiday_village_rounded,
                            size: 36,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            AppSpacing.hXxl,

            // App title
            FadeSlideIn(
              delay: 150,
              child: Text(
                'আল ইসলাহ',
                style: context.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),

            AppSpacing.hSm,

            // Subtitle
            FadeSlideIn(
              delay: 230,
              child: Text(
                'গ্রামের ডিজিটাল কমিউনিটি প্ল্যাটফর্ম',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            AppSpacing.hXxl,

            // Feature pills
            FadeSlideIn(
              delay: 320,
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: const [
                  _PillChip(icon: Icons.volunteer_activism_rounded, label: 'তহবিল'),
                  _PillChip(icon: Icons.construction_rounded, label: 'প্রকল্প'),
                  _PillChip(icon: Icons.people_rounded, label: 'নাগরিক'),
                  _PillChip(icon: Icons.campaign_rounded, label: 'নোটিশ'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PillChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          AppSpacing.wXs,
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Login Card — bottom sheet style card
// ─────────────────────────────────────────────────────────────────────────────

class _LoginCard extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChange;
  final bool loading;
  final bool obscurePassword;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final FocusNode phoneFocus;
  final FocusNode passwordFocus;
  final VoidCallback onTogglePassword;
  final VoidCallback onPhoneLogin;
  final VoidCallback onGoogleLogin;

  const _LoginCard({
    required this.selectedTab,
    required this.onTabChange,
    required this.loading,
    required this.obscurePassword,
    required this.phoneController,
    required this.passwordController,
    required this.phoneFocus,
    required this.passwordFocus,
    required this.onTogglePassword,
    required this.onPhoneLogin,
    required this.onGoogleLogin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return FadeSlideIn(
      delay: 380,
      offset: 30,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xxxl),
            topRight: Radius.circular(AppRadius.xxxl),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.10),
              blurRadius: 40,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.xxl,
            right: AppSpacing.xxl,
            top: AppSpacing.xxl,
            bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),

              // Heading
              Text(
                'লগইন করুন',
                style: context.textTheme.headlineSmall?.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              AppSpacing.hXs,
              Text(
                'আপনার অ্যাকাউন্টে প্রবেশ করুন',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.textSecondary,
                ),
              ),

              AppSpacing.hXxl,

              // Segmented tab switcher
              _SegmentedSwitcher(
                selected: selectedTab,
                onSelect: onTabChange,
              ),

              AppSpacing.hXxl,

              // Animated tab content
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: selectedTab == 0
                    ? _PhoneForm(
                        key: const ValueKey('phone'),
                        phoneController: phoneController,
                        passwordController: passwordController,
                        phoneFocus: phoneFocus,
                        passwordFocus: passwordFocus,
                        obscurePassword: obscurePassword,
                        onTogglePassword: onTogglePassword,
                        onLogin: onPhoneLogin,
                        loading: loading,
                      )
                    : _GoogleForm(
                        key: const ValueKey('google'),
                        onLogin: onGoogleLogin,
                        loading: loading,
                      ),
              ),

              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md),
                      child: Text(
                        selectedTab == 0 ? 'অথবা' : 'অথবা',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.textTertiary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
              ),

              // Alternate sign-in option
              if (selectedTab == 0)
                _GoogleQuickButton(onTap: onGoogleLogin, loading: loading)
              else
                _PhoneQuickButton(
                  onTap: () => onTabChange(0),
                ),

              AppSpacing.hXl,

              // Terms
              Text(
                'লগইন করার মাধ্যমে আপনি আমাদের ব্যবহারের শর্তাবলী ও গোপনীয়তা নীতিতে সম্মত হচ্ছেন।',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.textTertiary,
                  fontSize: 11,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Segmented tab switcher
// ─────────────────────────────────────────────────────────────────────────────

class _SegmentedSwitcher extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  const _SegmentedSwitcher({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final tabs = [
      (Icons.phone_android_rounded, 'ফোন নম্বর'),
      (Icons.g_mobiledata, 'Google'),
    ];

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCanvas,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final i = entry.key;
          final (icon, label) = entry.value;
          final isActive = selected == i;

          return Expanded(
            child: PressScale(
              scale: 0.96,
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: isActive ? Colors.white : context.textSecondary,
                    ),
                    AppSpacing.wXs,
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Phone + Password form
// ─────────────────────────────────────────────────────────────────────────────

class _PhoneForm extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final FocusNode phoneFocus;
  final FocusNode passwordFocus;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;
  final bool loading;

  const _PhoneForm({
    super.key,
    required this.phoneController,
    required this.passwordController,
    required this.phoneFocus,
    required this.passwordFocus,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onLogin,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Phone field
        _FieldLabel(label: 'ফোন নম্বর'),
        AppSpacing.hXs,
        _StyledTextField(
          controller: phoneController,
          focusNode: phoneFocus,
          hint: '01XXXXXXXXX',
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.next,
          onEditingComplete: () => passwordFocus.requestFocus(),
          prefix: Container(
            margin: const EdgeInsets.only(left: 14, right: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bangladesh flag emoji
                const Text('🇧🇩', style: TextStyle(fontSize: 16)),
                AppSpacing.wXs,
                Text(
                  '+880',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.textSecondary,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 1,
                  height: 18,
                  color: context.border,
                ),
              ],
            ),
          ),
        ),

        AppSpacing.hLg,

        // Password field
        _FieldLabel(label: 'পাসওয়ার্ড'),
        AppSpacing.hXs,
        _StyledTextField(
          controller: passwordController,
          focusNode: passwordFocus,
          hint: '••••••••',
          obscureText: obscurePassword,
          textInputAction: TextInputAction.done,
          onEditingComplete: loading ? null : onLogin,
          prefixIcon: Icons.lock_outline_rounded,
          suffix: GestureDetector(
            onTap: onTogglePassword,
            child: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Icon(
                obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: context.textTertiary,
              ),
            ),
          ),
        ),

        AppSpacing.hXxl,

        // Login button
        _PrimaryButton(
          label: 'লগইন করুন',
          icon: Icons.arrow_forward_rounded,
          loading: loading,
          onTap: loading ? null : onLogin,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Google form
// ─────────────────────────────────────────────────────────────────────────────

class _GoogleForm extends StatelessWidget {
  final VoidCallback onLogin;
  final bool loading;

  const _GoogleForm({super.key, required this.onLogin, required this.loading});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Illustration / info box
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.05),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              AppSpacing.wMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'নিরাপদ সাইন-ইন',
                      style: context.textTheme.labelLarge?.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppSpacing.hXs,
                    Text(
                      'আপনার Google অ্যাকাউন্ট দিয়ে তাৎক্ষণিকভাবে যোগ দিন।',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        AppSpacing.hXxl,

        // Google button
        PressScale(
          onTap: loading ? null : onLogin,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 54,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.primary,
                    ),
                  )
                else
                  Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                    height: 22,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.g_mobiledata, size: 28, color: AppColors.primary),
                  ),
                AppSpacing.wMd,
                Text(
                  loading ? 'অপেক্ষা করুন...' : 'Google দিয়ে লগইন করুন',
                  style: context.textTheme.labelLarge?.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick alternate buttons
// ─────────────────────────────────────────────────────────────────────────────

class _GoogleQuickButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool loading;
  const _GoogleQuickButton({required this.onTap, required this.loading});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return PressScale(
      onTap: loading ? null : onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCanvas,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
              height: 18,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.g_mobiledata, size: 22, color: AppColors.primary),
            ),
            AppSpacing.wSm,
            Text(
              'Google দিয়ে লগইন করুন',
              style: context.textTheme.labelMedium?.copyWith(
                color: context.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneQuickButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PhoneQuickButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: context.isDark ? AppColors.darkCard : AppColors.lightCanvas,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: context.isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phone_android_rounded,
                size: 18, color: AppColors.primary),
            AppSpacing.wSm,
            Text(
              'ফোন নম্বর দিয়ে লগইন করুন',
              style: context.textTheme.labelMedium?.copyWith(
                color: context.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable field components
// ─────────────────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: context.textTheme.labelMedium?.copyWith(
        color: context.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction textInputAction;
  final VoidCallback? onEditingComplete;
  final IconData? prefixIcon;
  final Widget? prefix;
  final Widget? suffix;

  const _StyledTextField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.textInputAction = TextInputAction.done,
    this.onEditingComplete,
    this.prefixIcon,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      style: context.textTheme.bodyMedium?.copyWith(
        color: context.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: context.textTertiary,
          fontSize: 14,
        ),
        filled: true,
        fillColor: isDark ? AppColors.darkCard : AppColors.lightCanvas,
        prefix: prefix,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 20, color: context.textSecondary)
            : null,
        suffixIcon: suffix,
        contentPadding: EdgeInsets.symmetric(
          vertical: 15,
          horizontal: prefix != null ? 0 : AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: context.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: context.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Primary action button with gradient
// ─────────────────────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool loading;
  final VoidCallback? onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.loading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressScale(
      scale: 0.97,
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: onTap == null
                ? [AppColors.primary.withValues(alpha: 0.4), AppColors.primaryDark.withValues(alpha: 0.4)]
                : [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.40),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: -4,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading) ...[
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              ),
              AppSpacing.wMd,
              const Text(
                'অপেক্ষা করুন...',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ] else ...[
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.2,
                ),
              ),
              AppSpacing.wSm,
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
