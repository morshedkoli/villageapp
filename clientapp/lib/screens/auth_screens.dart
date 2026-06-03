part of '../screens.dart';


// =============================================================================
// GOOGLE LOGIN SCREEN
// -----------------------------------------------------------------------------
// Modern, glassmorphic, animation-rich Google sign-in flow.
//
// Design notes:
//  - Uses a deep, dual-orb radial gradient (dark by default, light-friendly
//    through AppColors) so it never feels "default template".
//  - Lottie hero (assets/login_animation.json) floats continuously; the
//    title/subtitle and the sign-in card fade-and-slide in on first frame.
//  - The "Continue with Google" button is a custom widget that:
//      * Presses down with a tactile scale animation (HapticFeedback included).
//      * Cross-fades the Google logo + label into a CircularProgressIndicator
//        while the auth request is in-flight.
//      * Resets cleanly when isLoading flips back to false.
//  - All copy goes through tr() (English / বাংলা) to match the rest of the app.
//  - Layout is responsive: a single scroll view, SafeArea-wrapped, with a
//    max-width clamp on tablets/web so the card never looks stretched.
// =============================================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // -------- Loading state for the Google sign-in flow ---------------------
  bool _loading = false;

  // -------- Animations ----------------------------------------------------
  /// Entrance choreography: header (lottie + title) + card slide/fade in.
  late final AnimationController _enterController;
  late final Animation<double> _enterFade;
  late final Animation<Offset> _enterSlide;

  /// Continuous, gentle floating motion for the Lottie hero.
  late final AnimationController _floatController;
  late final Animation<Offset> _floatAnim;

  /// Two ambient orbs that drift slowly behind the card to add depth.
  late final AnimationController _orbController;
  late final Animation<Offset> _orb1Anim;
  late final Animation<Offset> _orb2Anim;

  // -------- Stagger timings (kept as named constants for clarity) --------
  static const _enterDuration = Duration(milliseconds: 1200);
  static const _floatDuration = Duration(milliseconds: 4200);
  static const _orbDuration = Duration(milliseconds: 9000);

  @override
  void initState() {
    super.initState();

    // One-shot entrance — header and card rise + fade in.
    _enterController = AnimationController(
      vsync: this,
      duration: _enterDuration,
    );
    _enterFade = CurvedAnimation(
      parent: _enterController,
      curve: Curves.easeOutCubic,
    );
    _enterSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _enterController, curve: Curves.easeOutCubic),
    );

    // Lottie bobbing — symmetric sine, plays forever.
    _floatController = AnimationController(
      vsync: this,
      duration: _floatDuration,
    );
    _floatAnim = Tween<Offset>(
      begin: const Offset(0, -0.015),
      end: const Offset(0, 0.015),
    ).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    // Background orbs — counter-phase drift to feel alive, not gimmicky.
    _orbController = AnimationController(
      vsync: this,
      duration: _orbDuration,
    );
    _orb1Anim = Tween<Offset>(
      begin: const Offset(-0.04, -0.03),
      end: const Offset(0.04, 0.03),
    ).animate(
      CurvedAnimation(parent: _orbController, curve: Curves.easeInOutSine),
    );
    _orb2Anim = Tween<Offset>(
      begin: const Offset(0.05, 0.04),
      end: const Offset(-0.05, -0.04),
    ).animate(
      CurvedAnimation(parent: _orbController, curve: Curves.easeInOutSine),
    );

    _enterController.forward();
    _floatController.repeat(reverse: true);
    _orbController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _enterController.dispose();
    _floatController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final compact = size.width <= 360;
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      // Use a custom body to control the layered backdrop + orbs + content.
      body: Stack(
        children: [
          // 1) Base gradient / mesh backdrop (defined globally).
          Positioned.fill(
            child: _pageBackdrop(
              safeArea: false,
              child: const SizedBox.expand(),
            ),
          ),

          // 2) Two slowly-drifting, heavily-blurred orbs (depth + light).
          _AmbientOrb(
            animation: _orb1Anim,
            size: size.width * 0.7,
            alignment: Alignment(-0.8, -0.6),
            color: AppColors.primaryC(context).withValues(alpha: 0.32),
            blurSigma: 70,
          ),
          _AmbientOrb(
            animation: _orb2Anim,
            size: size.width * 0.85,
            alignment: const Alignment(0.9, 0.95),
            color: const Color(0xFF5B7CFA).withValues(alpha: 0.32),
            blurSigma: 90,
          ),

          // 3) Foreground content. The LayoutBuilder makes the scroll view
          //    take the full available height, so when content is shorter
          //    than the viewport the column expands to fill it (no white
          //    band at the bottom) and only scrolls when it actually has
          //    to (small phones / large accessibility text).
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return _constrainBodyWidth(
                  context,
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 20 : 28,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight -
                            media.padding.top -
                            media.padding.bottom,
                      ),
                      child: IntrinsicHeight(
                        child: FadeTransition(
                          opacity: _enterFade,
                          child: SlideTransition(
                            position: _enterSlide,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 12),

                                // Top app-bar row: brand + back button.
                                _TopBar(
                                  onBack: () => Navigator.of(context).pop(),
                                ),

                                SizedBox(height: size.height * 0.02),

                                // Lottie hero (continuously floating).
                                SlideTransition(
                                  position: _floatAnim,
                                  child: _LottieHero(
                                    height: size.height * 0.28,
                                    maxWidth: 320,
                                    lottieAsset: 'assets/login_animation.json',
                                    glowColor: AppColors.primaryC(context),
                                  ),
                                ),

                                const SizedBox(height: 28),

                                // Header text.
                                _LoginHeader(),

                                SizedBox(height: size.height * 0.05),

                                // The Google sign-in card (glassmorphic, focused).
                                _LoginCard(
                                  isLoading: _loading,
                                  onGooglePressed: _signInWithGoogle,
                                ),

                                const SizedBox(height: 28),

                                // Trust strip.
                                _TrustStrip(),

                                // Flexible spacer pushes the decorative
                                // band to the bottom on tall devices, and
                                // collapses to zero on short ones.
                                const Spacer(),

                                // Decorative brand band — keeps the bottom
                                // of the screen inside the gradient palette
                                // instead of revealing the page background.
                                const _LoginFooterBand(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Sign-in flow
  // -------------------------------------------------------------------------
  Future<void> _signInWithGoogle() async {
    if (_loading) return;
    setState(() => _loading = true);

    // Light haptic for tactile feedback (iOS only — Android no-op on older
    // API levels; this is the modern, supported path).
    HapticFeedback.lightImpact();

    try {
      final isNew = await DataService.instance.signInWithGoogle();
      if (!mounted) return;

      final needsProfile = isNew || !(await DataService.instance.isProfileComplete());
      if (needsProfile) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
        );
      } else {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_googleSignInErrorMessage(e)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Surface a helpful, human-readable error for the most common
  // misconfiguration (missing SHA in Firebase for Android builds).
  String _googleSignInErrorMessage(Object error) {
    if (error is PlatformException) {
      final raw = '${error.code} ${error.message ?? ''} ${error.details ?? ''}';
      final normalized = raw.toLowerCase();
      final isConfigError = normalized.contains('sign_in_failed') &&
          (normalized.contains('api: 10') ||
              normalized.contains('api:10') ||
              normalized.contains('developer_error') ||
              normalized.contains('common.api.j: 10') ||
              normalized.contains('common.api.j:10'));
      if (isConfigError) {
        return tr(
          'Google login is not configured for this app build yet. Please contact support/admin to add Android SHA keys in Firebase and update google-services.json.',
          'এই অ্যাপ বিল্ডের জন্য Google লগইন এখনো কনফিগার করা হয়নি। Firebase-এ Android SHA key যোগ করে google-services.json আপডেট করতে অ্যাডমিন/সাপোর্টের সাথে যোগাযোগ করুন।',
        );
      }
    }
    return '${tr('Error', 'ত্রুটি')}: $error';
  }
}

// =============================================================================
// SUB-WIDGETS
// =============================================================================

/// A softly-blurred, animated orb that sits behind the content.
///
/// Uses [ImageFiltered] + [SlideTransition] so the GPU compositor handles the
/// transform and blur cheaply — no layout thrash.
class _AmbientOrb extends StatelessWidget {
  const _AmbientOrb({
    required this.animation,
    required this.size,
    required this.alignment,
    required this.color,
    required this.blurSigma,
  });

  final Animation<Offset> animation;
  final double size;
  final Alignment alignment;
  final Color color;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: FractionalTranslation(
          translation: animation.value,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Top app-bar row: brand mark on the left, optional back chevron.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Brand mark — small monogram pill.
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceC(context).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderC(context)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryC(context),
                      AppColors.primaryC(context).withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(
                  Icons.home_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                tr('AL ISLAH', 'আল ইসলাহ'),
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Back button (only meaningful when the route was pushed).
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceC(context).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderC(context)),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimaryC(context),
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Lottie hero with a soft radial glow behind it. Continuously floats via
/// the parent SlideTransition.
class _LottieHero extends StatelessWidget {
  const _LottieHero({
    required this.height,
    required this.maxWidth,
    required this.lottieAsset,
    required this.glowColor,
  });

  final double height;
  final double maxWidth;
  final String lottieAsset;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: height,
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              glowColor.withValues(alpha: 0.18),
              glowColor.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 1.0],
          ),
        ),
        child: Lottie.asset(
          lottieAsset,
          fit: BoxFit.contain,
          repeat: true,
          // Defer load-error quietly to a tasteful fallback so a missing asset
          // never breaks the entire screen.
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.lock_open_rounded,
              size: height * 0.4,
              color: glowColor,
            );
          },
        ),
      ),
    );
  }
}

/// The two-line header under the Lottie hero.
class _LoginHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          tr('Welcome Back', 'স্বাগতম'),
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineLarge.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          tr(
            'Sign in to continue your journey',
            'আপনার যাত্রা চালিয়ে যেতে সাইন ইন করুন',
          ),
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondaryC(context),
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

/// Glassmorphic card that wraps the Google sign-in button.
class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.isLoading,
    required this.onGooglePressed,
  });

  final bool isLoading;
  final VoidCallback onGooglePressed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 26),
          decoration: BoxDecoration(
            color: AppColors.surfaceC(context).withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryC(context).withValues(alpha: 0.18),
                blurRadius: 40,
                spreadRadius: -10,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                tr('Sign in to continue', 'চালিয়ে যেতে সাইন ইন করুন'),
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryC(context),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                tr(
                  'Use your Google account to get started in seconds.',
                  'শুরু করতে আপনার Google অ্যাকাউন্ট ব্যবহার করুন — মাত্র কয়েক সেকেন্ডে।',
                ),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondaryC(context),
                ),
              ),
              const SizedBox(height: 22),

              // The star of the show.
              GoogleSignInButton(
                isLoading: isLoading,
                onPressed: onGooglePressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Three-up trust strip under the card.
class _TrustStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TrustTile(
            icon: Icons.lock_outline_rounded,
            label: tr('Secure', 'নিরাপদ'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _TrustTile(
            icon: Icons.shield_outlined,
            label: tr('Private', 'ব্যক্তিগত'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _TrustTile(
            icon: Icons.bolt_rounded,
            label: tr('Instant', 'তাৎক্ষণিক'),
          ),
        ),
      ],
    );
  }
}

class _TrustTile extends StatelessWidget {
  const _TrustTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceC(context).withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderC(context)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryC(context), size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondaryC(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// A small, decorative brand band that anchors the bottom of the login
/// screen inside the gradient palette. Without it, when the scroll content
/// is shorter than the viewport on tall devices, the page background
/// (`PatternBackdrop`) peeks through and the bottom of the screen reads as
/// flat white. This band keeps the visual story consistent end-to-end.
class _LoginFooterBand extends StatelessWidget {
  const _LoginFooterBand();

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryC(context);
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thin gradient hairline — a quiet echo of the top glow.
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primary.withValues(alpha: 0.0),
                  primary.withValues(alpha: 0.35),
                  primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Caption — small, secondary, multi-lingual.
          Text(
            tr(
              'Powered by your village community',
              'আপনার গ্রামীণ কমিউনিটি দ্বারা পরিচালিত',
            ),
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondaryC(context),
              letterSpacing: 0.3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// GOOGLE SIGN-IN BUTTON
// -----------------------------------------------------------------------------
// A self-contained, premium-feeling button that:
//   * Animates a tactile scale-down on press (HapticFeedback included).
//   * Cross-fades the Google logo + label into a CircularProgressIndicator
//     while the parent is in a loading state.
//   * Keeps an even-press surface and respects the loading state by ignoring
//     additional taps while busy.
// =============================================================================
class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton>
    with SingleTickerProviderStateMixin {
  // Drives the press-down / release-up micro-animation.
  late final AnimationController _pressController;
  late final Animation<double> _pressScale;
  late final Animation<double> _pressElevation;

  static const _pressDuration = Duration(milliseconds: 140);

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: _pressDuration,
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOutCubic),
    );
    _pressElevation = Tween<double>(begin: 18, end: 6).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handlePressDown() {
    if (widget.isLoading) return;
    _pressController.forward();
  }

  void _handlePressUp() {
    if (widget.isLoading) return;
    _pressController.reverse();
  }

  Future<void> _handleTap() async {
    if (widget.isLoading) return;
    HapticFeedback.selectionClick();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tr('Continue with Google', 'Google দিয়ে প্রবেশ করুন'),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _handlePressDown(),
        onTapUp: (_) => _handlePressUp(),
        onTapCancel: _handlePressUp,
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _pressController,
          builder: (context, child) {
            return Transform.scale(
              scale: _pressScale.value,
              child: child,
            );
          },
          // The child never depends on AnimatedBuilder, so the rebuild
          // surface is small.
          child: _buildButtonSurface(context),
        ),
      ),
    );
  }

  /// The actual painted button surface. Static within the press animation.
  Widget _buildButtonSurface(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _pressController,
      builder: (context, _) {
        return Container(
          height: 56,
          decoration: BoxDecoration(
            color: dark ? Colors.white : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.06),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: _pressElevation.value,
                spreadRadius: -2,
                offset: Offset(0, _pressElevation.value / 3),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Layer A: Google logo + label (visible when idle).
              AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                opacity: widget.isLoading ? 0.0 : 1.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // The official Google "G" — multi-color, vector-style.
                    // Using a hand-rolled widget instead of a PNG keeps the
                    // build slim and the colors brand-accurate at any DPR.
                    const _GoogleLogo(size: 22),
                    const SizedBox(width: 12),
                    Text(
                      tr('Continue with Google', 'Google দিয়ে প্রবেশ করুন'),
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F1F1F),
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),

              // Layer B: spinner (visible while loading).
              AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                opacity: widget.isLoading ? 1.0 : 0.0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF1A73E8), // Google Blue
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      tr('Signing you in…', 'লগইন হচ্ছে…'),
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F1F1F),
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Hand-rolled Google "G" logo using CustomPaint so we don't ship a PNG asset.
///
/// Uses the four official Google brand colors:
///   #4285F4 (blue), #34A853 (green), #FBBC04 (yellow), #EA4335 (red).
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final r = w * 0.45;

    // Outer ring composed of four arcs (clockwise from top).
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    const stroke = 0.18; // proportional to radius
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * stroke
      ..strokeCap = StrokeCap.butt;

    // Blue: top → right (270° → 360°/0°)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -1.5708, 1.5708, false, paint);
    // Green: right → bottom (0° → 90°)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0, 1.5708, false, paint);
    // Yellow: bottom → left (90° → 180°)
    paint.color = const Color(0xFFFBBC04);
    canvas.drawArc(rect, 1.5708, 1.5708, false, paint);
    // Red: left → top (180° → 270°)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 3.1416, 1.5708, false, paint);

    // Inner horizontal bar (the "G" cross-stroke) — drawn as a short line
    // from the center to the right edge.
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * stroke
      ..strokeCap = StrokeCap.butt;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + r * 0.92, cy),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Profile Setup Screen ───────────────────────────────────────────────────

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key, this.existingProfile});
  final Map<String, dynamic>? existingProfile;

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  final _phoneCtrl = TextEditingController();
  String? _profession;
  String? _village;
  final _addressCtrl = TextEditingController();
  final _nidCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  String? _bloodGroup;
  bool _saving = false;
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;

  static const _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];

  static const _villages = ['দৌলতপাড়া', 'ধর্মতীর্থ', 'দিঘীরপাড়া'];

  static final _professions = [
    tr('Expatriate', 'প্রবাসী'),
    tr('Farmer', 'কৃষক'),
    tr('Teacher', 'শিক্ষক'),
    tr('Student', 'ছাত্র/ছাত্রী'),
    tr('Doctor', 'ডাক্তার'),
    tr('Engineer', 'ইঞ্জিনিয়ার'),
    tr('Businessman', 'ব্যবসায়ী'),
    tr('Housewife', 'গৃহিণী'),
    tr('Government Employee', 'সরকারি চাকরিজীবী'),
    tr('Private Employee', 'বেসরকারি চাকরিজীবী'),
    tr('Day Laborer', 'দিনমজুর'),
    tr('Fisherman', 'জেলে'),
    tr('Driver', 'চালক'),
    tr('Tailor', 'দর্জি'),
    tr('Imam/Religious Leader', 'ইমাম/ধর্মীয় নেতা'),
    tr('Retired', 'অবসরপ্রাপ্ত'),
    tr('Unemployed', 'বেকার'),
    tr('Other', 'অন্যান্য'),
  ];

  @override
  void initState() {
    super.initState();
    final user = DataService.instance.currentUser;
    final profile = widget.existingProfile;
    _nameCtrl = TextEditingController(
      text: profile?['name'] as String? ?? user?.displayName ?? '',
    );
    _phoneCtrl.text = profile?['phone'] as String? ?? '';
    _addressCtrl.text = profile?['address'] as String? ?? '';
    _nidCtrl.text = profile?['nidNumber'] as String? ?? '';
    _dobCtrl.text = profile?['dateOfBirth'] as String? ?? '';

    // Pre-fill village.
    final savedVillage = profile?['village'] as String? ?? '';
    if (savedVillage.isNotEmpty && _villages.contains(savedVillage)) {
      _village = savedVillage;
    }

    // Pre-fill profession if it matches one of the options.
    final savedProfession = profile?['profession'] as String? ?? '';
    if (savedProfession.isNotEmpty && _professions.contains(savedProfession)) {
      _profession = savedProfession;
    }

    // Pre-fill blood group.
    final savedBlood = profile?['bloodGroup'] as String? ?? '';
    if (savedBlood.isNotEmpty && _bloodGroups.contains(savedBlood)) {
      _bloodGroup = savedBlood;
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _nidCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = DataService.instance.currentUser;
    final pad = _pagePadding(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _pageBackdrop(
        safeArea: true,
        child: FadeTransition(
          opacity: _fadeIn,
          child: _constrainBodyWidth(
            context,
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(pad.left, 16, pad.right, 24),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Header
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.primaryC(context).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColors.primaryC(context).withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child:
                                user?.photoURL != null &&
                                    user!.photoURL!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(22),
                                    child: Image.network(
                                      user.photoURL!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    Icons.person_rounded,
                                    color: AppColors.primaryC(context),
                                    size: 40,
                                  ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.existingProfile != null
                                ? tr(
                                    'Edit Your Profile',
                                    'প্রোফাইল সম্পাদনা করুন',
                                  )
                                : tr(
                                    'Setup Your Profile',
                                    'প্রোফাইল সেটআপ করুন',
                                  ),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimaryC(context),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tr(
                              'Complete your profile to join the village community',
                              'গ্রাম কমিউনিটিতে যোগ দিতে আপনার প্রোফাইল সম্পূর্ণ করুন',
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondaryC(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Name
                    _buildLabel(tr('Full Name', 'পুরো নাম'), required: true),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _nameCtrl,
                      hint: tr('Enter your full name', 'আপনার পুরো নাম লিখুন'),
                      icon: Icons.person_outline_rounded,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? tr('Name is required', 'নাম আবশ্যক')
                          : null,
                    ),
                    const SizedBox(height: 18),

                    // Phone
                    _buildLabel(
                      tr('Phone Number', 'ফোন নম্বর'),
                      required: true,
                    ),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _phoneCtrl,
                      hint: tr('01XXXXXXXXX', '০১XXXXXXXXX'),
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return tr(
                            'Phone number is required',
                            'ফোন নম্বর আবশ্যক',
                          );
                        }
                        if (v.trim().length < 11) {
                          return tr(
                            'Enter a valid phone number',
                            'সঠিক ফোন নম্বর লিখুন',
                          );
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Profession
                    _buildLabel(tr('Profession', 'পেশা'), required: true),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderC(context)),
                      ),
                      child: DropdownButtonFormField<String>(
                        initialValue: _profession,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.work_outline_rounded,
                            color: AppColors.textSecondaryC(context),
                            size: 20,
                          ),
                          hintText: tr(
                            'Select profession',
                            'পেশা নির্বাচন করুন',
                          ),
                          hintStyle: const TextStyle(
                            color: Color(0xFFC7C7CC),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        isExpanded: true,
                        items: _professions
                            .map(
                              (p) => DropdownMenuItem(value: p, child: Text(p)),
                            )
                            .toList(),
                        validator: (v) => (v == null || v.isEmpty)
                            ? tr('Profession is required', 'পেশা আবশ্যক')
                            : null,
                        onChanged: (v) => setState(() => _profession = v),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Village
                    _buildLabel(tr('Village', 'গ্রাম'), required: true),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderC(context)),
                      ),
                      child: DropdownButtonFormField<String>(
                        initialValue: _village,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.home_outlined,
                            color: AppColors.textSecondaryC(context),
                            size: 20,
                          ),
                          hintText: tr('Select village', 'গ্রাম নির্বাচন করুন'),
                          hintStyle: const TextStyle(
                            color: Color(0xFFC7C7CC),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        isExpanded: true,
                        items: _villages
                            .map(
                              (v) => DropdownMenuItem(value: v, child: Text(v)),
                            )
                            .toList(),
                        validator: (v) => (v == null || v.isEmpty)
                            ? tr('Village is required', 'গ্রাম নির্বাচন আবশ্যক')
                            : null,
                        onChanged: (v) => setState(() => _village = v),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Address
                    _buildLabel(tr('Address', 'ঠিকানা')),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _addressCtrl,
                      hint: tr(
                        'Area / Para (optional)',
                        'এলাকা / পাড়া (ঐচ্ছিক)',
                      ),
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 18),

                    // Blood Group
                    _buildLabel(tr('Blood Group', 'রক্তের গ্রুপ')),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderC(context)),
                      ),
                      child: DropdownButtonFormField<String>(
                        initialValue: _bloodGroup,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.bloodtype_outlined,
                            color: AppColors.textSecondaryC(context),
                            size: 20,
                          ),
                          hintText: tr(
                            'Select blood group',
                            'রক্তের গ্রুপ নির্বাচন করুন',
                          ),
                          hintStyle: const TextStyle(
                            color: Color(0xFFC7C7CC),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        items: _bloodGroups
                            .map(
                              (bg) =>
                                  DropdownMenuItem(value: bg, child: Text(bg)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _bloodGroup = v),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // NID Number
                    _buildLabel(tr('NID Number', 'জাতীয় পরিচয়পত্র নম্বর')),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _nidCtrl,
                      hint: tr('Optional', 'ঐচ্ছিক'),
                      icon: Icons.credit_card_rounded,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 18),

                    // Date of Birth
                    _buildLabel(tr('Date of Birth', 'জন্ম তারিখ')),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: _buildTextField(
                          controller: _dobCtrl,
                          hint: tr('Select date', 'তারিখ নির্বাচন করুন'),
                          icon: Icons.cake_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save button
                    PrimaryButton(
                      isLoading: _saving,
                      onPressed: _saving ? null : _saveProfile,
                      label: widget.existingProfile != null
                          ? tr(
                              'Update Profile',
                              'প্রোফাইল আপডেট করুন',
                            )
                          : tr(
                              'Save & Continue',
                              'সংরক্ষণ করুন ও এগিয়ে যান',
                            ),
                    ),
                    const SizedBox(height: 12),

                    // Skip button
                    Center(
                      child: TextButton(
                        onPressed: _saving
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: Text(
                          tr(
                            widget.existingProfile != null
                                ? 'Cancel'
                                : 'Skip for now',
                            widget.existingProfile != null
                                ? 'বাতিল'
                                : 'এখন এড়িয়ে যান',
                          ),
                          style: TextStyle(
                            color: AppColors.textSecondaryC(context),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(
          text,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimaryC(context),
          ),
        ),
        if (required)
          Text(
            ' *',
            style: AppTextStyles.labelLarge.copyWith(color: AppColors.errorC(context)),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return PremiumTextField(
      controller: controller,
      labelText: null,
      hintText: hint,
      prefixIcon: icon,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: now,
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryC(context),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _dobCtrl.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await DataService.instance.updateUserProfile(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        profession: _profession ?? '',
        village: _village ?? '',
        address: _addressCtrl.text.trim(),
        nidNumber: _nidCtrl.text.trim(),
        bloodGroup: _bloodGroup,
        dateOfBirth: _dobCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'Profile saved successfully!',
              'প্রোফাইল সফলভাবে সংরক্ষিত হয়েছে!',
            ),
          ),
          backgroundColor: AppColors.successC(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${tr('Error', 'ত্রুটি')}: $e'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
