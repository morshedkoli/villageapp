part of '../screens.dart';


// =============================================================================
// PROFILE SCREEN
// -----------------------------------------------------------------------------
// Full-bleed glassmorphic profile surface, designed to match the login page's
// "Antigravity" visual language:
//   * Tinted brand backdrop (the global _pageBackdrop) with two ambient
//     orbs drifting behind the content.
//   * Glassmorphic hero card with a soft radial glow around the avatar —
//     echoes the login lottie hero.
//   * Glass tiles for the stat strip and the menu rows (matches the login
//     trust strip treatment).
//   * Decorative gradient hairline + bilingual footer band at the very
//     bottom — exact replica of the login screen's footer band.
//
// All copy is bilingual (English / বাংলা) via the global tr() helper.
// The body fills the viewport (LayoutBuilder + ConstrainedBox +
// IntrinsicHeight) so the screen never ends in a flat-white band, and
// falls back to a scroll view on short devices / large accessibility
// text.
// =============================================================================

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  // -------- Entrance choreography -----------------------------------------
  late final AnimationController _enterController;
  late final Animation<double> _enterFade;
  late final Animation<Offset> _enterSlide;

  static const _enterDuration = Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();

    _enterController = AnimationController(
      vsync: this,
      duration: _enterDuration,
    );
    _enterFade = CurvedAnimation(
      parent: _enterController,
      curve: Curves.easeOutCubic,
    );
    _enterSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _enterController, curve: Curves.easeOutCubic),
    );

    _enterController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final data = DataService.instance;

    return _SidebarPageScaffold(
      title: tr('Profile', 'প্রোফাইল'),
      subtitle: tr(
        'Manage account details and accessibility preferences',
        'অ্যাকাউন্ট ও অ্যাক্সেসিবিলিটি পছন্দগুলো পরিচালনা করুন',
      ),
      selectedId: _MenuId.profile,
      actions: const [_NotificationButton()],
      body: LayoutBuilder(
        builder: (context, constraints) {
          return StreamBuilder(
            stream: data.authState(),
            builder: (context, _) {
              final user = data.currentUser;
              return _constrainBodyWidth(
                context,
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: _pagePadding(context).copyWith(
                    bottom: media.padding.bottom + 20,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight -
                          media.padding.top -
                          media.padding.bottom -
                          40,
                    ),
                    child: IntrinsicHeight(
                      child: FadeTransition(
                        opacity: _enterFade,
                        child: SlideTransition(
                          position: _enterSlide,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Decorative top: full-bleed glow + orbs
                              // behind the content. Lives inside the
                              // sidebar's body container so the sidebar
                              // chrome (dark surface) stays on top, but
                              // the body itself keeps the brand gradient.
                              const _ProfileContentFrame(),
                              const SizedBox(height: 16),

                              if (user == null) const _LoggedOutHero()
                              else const _LoggedInHero(),

                              const SizedBox(height: 24),
                              _ProfileSectionLabel(
                                text: tr('Preferences', 'পছন্দসমূহ'),
                              ),
                              const SizedBox(height: 10),
                              const _PreferencesCard(),
                              const SizedBox(height: 16),
                              const _ProfileFooterBand(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// =============================================================================
// SUB-WIDGETS
// =============================================================================

/// Full-bleed tint layer painted behind the body content. Holds a soft
/// top glow and two ambient orbs so the profile body matches the login
/// page's atmospheric feel — without breaking the sidebar chrome.
class _ProfileContentFrame extends StatelessWidget {
  const _ProfileContentFrame();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final primary = AppColors.primaryC(context);
    return SizedBox(
      // Reserve enough vertical space for the orbs to live in. The actual
      // visible content is shorter; this just gives the orbs room to
      // breathe at the top of the body container.
      height: 220,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Top brand glow.
          Positioned(
            top: -120,
            left: -40,
            right: -40,
            child: IgnorePointer(
              child: Container(
                height: 280,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primary.withValues(alpha: 0.22),
                      primary.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          // Ambient orbs — same treatment as the login screen.
          _ProfileOrb(
            size: size.width * 0.6,
            alignment: const Alignment(-0.8, -0.4),
            color: primary.withValues(alpha: 0.28),
            blurSigma: 70,
          ),
          _ProfileOrb(
            size: size.width * 0.7,
            alignment: const Alignment(0.9, 0.5),
            color: const Color(0xFF5B7CFA).withValues(alpha: 0.22),
            blurSigma: 90,
          ),
        ],
      ),
    );
  }
}

/// One blurred, slowly-positioned orb. Used in the static (non-animated)
/// case here so we don't have to thread the AnimationController through
/// the frame. The orbs are decorative — they don't need to move once
/// the body is open, the entrance choreography already makes the page
/// feel alive.
class _ProfileOrb extends StatelessWidget {
  const _ProfileOrb({
    required this.size,
    required this.alignment,
    required this.color,
    required this.blurSigma,
  });

  final double size;
  final Alignment alignment;
  final Color color;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
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
    );
  }
}

// ── Hero (logged out) ──────────────────────────────────────────────────────

class _LoggedOutHero extends StatelessWidget {
  const _LoggedOutHero();

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        children: [
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryC(context).withValues(alpha: 0.22),
                    AppColors.primaryC(context).withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryC(context).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: AppColors.primaryC(context).withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.primaryC(context),
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            tr('Welcome!', 'স্বাগতম!'),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: AppColors.textPrimaryC(context),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tr(
              'Login to access all features',
              'সব ফিচার ব্যবহার করতে লগইন করুন',
            ),
            style: TextStyle(
              color: AppColors.textSecondaryC(context),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              label: tr('Login', 'লগইন'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero (logged in) ───────────────────────────────────────────────────────

class _LoggedInHero extends StatelessWidget {
  const _LoggedInHero();

  @override
  Widget build(BuildContext context) {
    final user = DataService.instance.currentUser;
    return _GlassCard(
      child: Column(
        children: [
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryC(context).withValues(alpha: 0.22),
                    AppColors.primaryC(context).withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
              child: Center(
                child: user?.photoURL != null
                    ? ClipOval(
                        child: Image.network(
                          user!.photoURL!,
                          width: 84,
                          height: 84,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryC(context),
                              AppColors.primaryC(context).withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryC(context)
                                  .withValues(alpha: 0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user?.displayName ??
                user?.email?.split('@').first ??
                tr('Citizen', 'নাগরিক'),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: AppColors.textPrimaryC(context),
              letterSpacing: -0.3,
            ),
          ),
          if (user?.email != null) ...[
            const SizedBox(height: 4),
            Text(
              user!.email!,
              style: TextStyle(
                color: AppColors.textSecondaryC(context),
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _HeroAction(
                  icon: Icons.edit_outlined,
                  label: tr('Edit Profile', 'প্রোফাইল সম্পাদনা'),
                  onPressed: () async {
                    final profile =
                        await DataService.instance.getUserProfile();
                    if (!context.mounted) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProfileSetupScreen(
                          existingProfile: profile,
                        ),
                      ),
                    );
                  },
                  variant: _HeroActionVariant.outline,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroAction(
                  icon: Icons.logout_rounded,
                  label: tr('Logout', 'লগআউট'),
                  onPressed: DataService.instance.signOut,
                  variant: _HeroActionVariant.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _HeroActionVariant { outline, danger }

class _HeroAction extends StatefulWidget {
  const _HeroAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.variant,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final _HeroActionVariant variant;

  @override
  State<_HeroAction> createState() => _HeroActionState();
}

class _HeroActionState extends State<_HeroAction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  static const _pressDuration = Duration(milliseconds: 120);

  @override
  void initState() {
    super.initState();
    _press = AnimationController(vsync: this, duration: _pressDuration);
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOutline = widget.variant == _HeroActionVariant.outline;
    final accent = isOutline
        ? AppColors.primaryC(context)
        : AppColors.errorC(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) => _press.reverse(),
      onTapCancel: () => _press.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _press,
        builder: (context, child) {
          return Transform.scale(
            scale: 1 - (_press.value * 0.04),
            child: child,
          );
        },
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isOutline
                ? Colors.transparent
                : AppColors.errorC(context).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: accent.withValues(alpha: isOutline ? 0.6 : 0.45),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: accent, size: 18),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Preferences card (high contrast, language, theme) ──────────────────────

class _PreferencesCard extends StatelessWidget {
  const _PreferencesCard();

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: ValueListenableBuilder<AccessibilitySettings>(
        valueListenable: accessibilityController,
        builder: (context, settings, _) {
          return Column(
            children: [
              _PrefRow(
                title: tr('High contrast mode', 'উচ্চ কনট্রাস্ট মোড'),
                trailing: Switch(
                  value: settings.highContrast,
                  activeThumbColor: AppColors.primaryC(context),
                  onChanged: accessibilityController.setHighContrast,
                ),
              ),
              const _Hairline(),
              _PrefRow(
                title: tr('Language', 'ভাষা'),
                trailing: SegmentedButton<String>(
                  showSelectedIcon: false,
                  selected: {settings.languageCode},
                  onSelectionChanged: (v) =>
                      accessibilityController.setLanguageCode(v.first),
                  segments: const [
                    ButtonSegment(value: 'en', label: Text('English')),
                    ButtonSegment(value: 'bn', label: Text('বাংলা')),
                  ],
                ),
              ),
              const _Hairline(),
              _PrefRow(
                title: tr('Theme', 'থিম'),
                trailing: SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  selected: {settings.themeMode},
                  onSelectionChanged: (v) =>
                      accessibilityController.setThemeMode(v.first),
                  segments: const [
                    ButtonSegment(value: ThemeMode.system, label: Text('System')),
                    ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                    ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PrefRow extends StatelessWidget {
  const _PrefRow({required this.title, required this.trailing});

  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimaryC(context),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.borderLightC(context).withValues(alpha: 0.0),
            AppColors.borderLightC(context).withValues(alpha: 0.7),
            AppColors.borderLightC(context).withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

// ── Section label ──────────────────────────────────────────────────────────

class _ProfileSectionLabel extends StatelessWidget {
  const _ProfileSectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 11.5,
          color: AppColors.textSecondaryC(context),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Glass card primitive ───────────────────────────────────────────────────

/// Reusable glassmorphic surface, mirrors the login screen's `_LoginCard`
/// treatment: 22px blur, semi-transparent surface, white border, primary
/// shadow.
class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          decoration: BoxDecoration(
            color: AppColors.surfaceC(context).withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.55),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryC(context).withValues(alpha: 0.10),
                blurRadius: 30,
                spreadRadius: -8,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── Footer band ────────────────────────────────────────────────────────────

/// Decorative brand band at the very bottom — gradient hairline +
/// bilingual caption. Exact replica of the login screen's footer band so
/// the end-of-page story is consistent across surfaces.
class _ProfileFooterBand extends StatelessWidget {
  const _ProfileFooterBand();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryC(context).withValues(alpha: 0.0),
                  AppColors.primaryC(context).withValues(alpha: 0.35),
                  AppColors.primaryC(context).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
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
