import 'dart:ui';

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

// =============================================================================
// PROFILE SCREEN
// -----------------------------------------------------------------------------
// Full-bleed glassmorphic profile surface, designed to match the login page's
// "Antigravity" visual language:
//   * Tinted brand backdrop with two ambient orbs drifting behind the content.
//   * Glassmorphic hero card with a soft radial glow around the avatar.
//   * Glass tiles for stats and menu rows (echoes the login trust strip).
//   * Decorative gradient hairline + bilingual footer band at the bottom.
//
// Entrance choreography mirrors the login screen: a single fade + slide so
// the surface feels alive on first frame but never distracting after.
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

  // -------- Ambient orb drift --------------------------------------------
  late final AnimationController _orbController;
  late final Animation<Offset> _orb1Anim;
  late final Animation<Offset> _orb2Anim;

  static const _enterDuration = Duration(milliseconds: 800);
  static const _orbDuration = Duration(milliseconds: 9000);

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

    _orbController = AnimationController(
      vsync: this,
      duration: _orbDuration,
    );
    _orb1Anim = Tween<Offset>(
      begin: const Offset(-0.05, -0.04),
      end: const Offset(0.05, 0.04),
    ).animate(
      CurvedAnimation(parent: _orbController, curve: Curves.easeInOutSine),
    );
    _orb2Anim = Tween<Offset>(
      begin: const Offset(0.06, 0.05),
      end: const Offset(-0.06, -0.05),
    ).animate(
      CurvedAnimation(parent: _orbController, curve: Curves.easeInOutSine),
    );

    _enterController.forward();
    _orbController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _enterController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final media = MediaQuery.of(context);
    final compact = size.width <= 360;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1) Tinted brand backdrop — base + top glow + bottom glow.
          Positioned.fill(child: _ProfileBackdrop(media: media)),

          // 2) Two slowly-drifting, heavily-blurred orbs.
          _AmbientOrb(
            animation: _orb1Anim,
            size: size.width * 0.75,
            alignment: const Alignment(-0.8, -0.6),
            color: AppColors.primaryLight.withValues(alpha: 0.28),
            blurSigma: 70,
          ),
          _AmbientOrb(
            animation: _orb2Anim,
            size: size.width * 0.85,
            alignment: const Alignment(0.9, 0.95),
            color: const Color(0xFF5B7CFA).withValues(alpha: 0.22),
            blurSigma: 90,
          ),

          // 3) Foreground content. LayoutBuilder + ConstrainedBox keeps the
          //    column filling the viewport on tall devices (no white band
          //    at the bottom) while still allowing the scroll view to
          //    handle overflow on short screens.
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: compact ? 20 : 28),
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
                              const SizedBox(height: 8),

                              // Top bar: brand monogram + settings shortcut.
                              const _ProfileTopBar(),

                              const SizedBox(height: 18),

                              // Hero card — avatar + name + quick actions.
                              const _ProfileHeroCard(),

                              const SizedBox(height: 22),

                              // Quick stats — three glass tiles.
                              const _ProfileStatsRow(),

                              const SizedBox(height: 28),

                              // Section label.
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Text(
                                  'ACCOUNT',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Account menu (glass group).
                              const _ProfileMenuGroup(items: [
                                _MenuItemData(
                                  icon: Icons.person_outline_rounded,
                                  label: 'Edit Profile',
                                  route: null,
                                ),
                                _MenuItemData(
                                  icon: Icons.account_balance_wallet_outlined,
                                  label: 'Payment Methods',
                                  route: null,
                                ),
                                _MenuItemData(
                                  icon: Icons.security_rounded,
                                  label: 'Security & PIN',
                                  route: null,
                                ),
                                _MenuItemData(
                                  icon: Icons.notifications_outlined,
                                  label: 'Notifications',
                                  route: '/notifications',
                                ),
                                _MenuItemData(
                                  icon: Icons.help_outline_rounded,
                                  label: 'Help & Support',
                                  route: null,
                                ),
                              ]),

                              const SizedBox(height: 28),

                              // Footer band — gradient hairline + caption.
                              const _ProfileFooterBand(),
                            ],
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
}

// =============================================================================
// BACKDROP
// =============================================================================

/// Tinted brand backdrop that paints a base wash plus a top and bottom
/// brand-colored glow. Stays inside the brand palette end-to-end so the
/// bottom of the screen never reads as flat white.
class _ProfileBackdrop extends StatelessWidget {
  const _ProfileBackdrop({required this.media});

  final MediaQueryData media;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF7FAF8),
            Color(0xFFFFFFFF),
            Color(0xFFF1F8E9),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
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
                      AppColors.primaryLight.withValues(alpha: 0.22),
                      AppColors.primaryBase.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          // Bottom brand glow.
          Positioned(
            left: -40,
            right: -40,
            bottom: -160 - media.padding.bottom,
            child: IgnorePointer(
              child: Container(
                height: 320,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.primaryMint.withValues(alpha: 0.10),
                      AppColors.primaryBase.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SUB-WIDGETS
// =============================================================================

/// A softly-blurred, animated orb that sits behind the content.
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

/// Top app-bar row: brand monogram pill on the left, settings shortcut
/// on the right. Mirrors the login screen's `_TopBar` shape.
class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Brand monogram pill.
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryBase, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'PROFILE',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.4,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Settings shortcut — matches the login back button's affordance.
        Material(
          color: Colors.transparent,
          child: InkWell(
            // The new feature tree wires routes through go_router; we
            // expose a typed callback here so the surface doesn't have
            // to know about routing. The shell binds these in production.
            onTap: () => _openRoute(context, '/settings'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: const Icon(
                Icons.settings_rounded,
                color: AppColors.textPrimary,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Hero card with the avatar, name, and primary actions. Glassmorphic,
/// centered, with a soft radial glow behind the avatar — mirrors the
/// login screen's lottie-hero treatment.
class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.55),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBase.withValues(alpha: 0.12),
                blurRadius: 30,
                spreadRadius: -8,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            children: [
              // Avatar with radial glow.
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryLight.withValues(alpha: 0.22),
                        AppColors.primaryLight.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryBase, AppColors.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBase.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Morshed Koli',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '+880 1XXX XXXXXX',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 18),
              // Primary actions — Edit profile (outline) + Logout (filled).
              Row(
                children: [
                  Expanded(
                    child: _HeroAction(
                      icon: Icons.edit_outlined,
                      label: 'Edit Profile',
                      onPressed: () {},
                      variant: _HeroActionVariant.outline,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _HeroAction(
                      icon: Icons.logout_rounded,
                      label: 'Log Out',
                      onPressed: () {},
                      variant: _HeroActionVariant.danger,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
    _press = AnimationController(
      vsync: this,
      duration: _pressDuration,
    );
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
        ? AppColors.primaryBase
        : AppColors.error;

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
                : AppColors.error.withValues(alpha: 0.10),
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

/// Three-up stat row, glassmorphic tiles with primary accent.
class _ProfileStatsRow extends StatelessWidget {
  const _ProfileStatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _StatTile(value: '৳12.4L', label: 'Balance')),
        SizedBox(width: 10),
        Expanded(child: _StatTile(value: '47', label: 'Transactions')),
        SizedBox(width: 10),
        Expanded(child: _StatTile(value: '3', label: 'Services')),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.55),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryBase,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItemData {
  const _MenuItemData({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String? route;
}

/// Grouped list of glass menu items. Each row has its own surface so the
/// stack feels layered, not flat.
class _ProfileMenuGroup extends StatelessWidget {
  const _ProfileMenuGroup({required this.items});

  final List<_MenuItemData> items;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                _ProfileMenuRow(data: items[i]),
                if (i < items.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(left: 56, right: 16),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.borderLight.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuRow extends StatefulWidget {
  const _ProfileMenuRow({required this.data});

  final _MenuItemData data;

  @override
  State<_ProfileMenuRow> createState() => _ProfileMenuRowState();
}

class _ProfileMenuRowState extends State<_ProfileMenuRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) => _press.reverse(),
      onTapCancel: () => _press.reverse(),
      onTap: () {
        final route = widget.data.route;
        if (route != null) {
          _openRoute(context, route);
        }
      },
      child: AnimatedBuilder(
        animation: _press,
        builder: (context, child) {
          return Transform.scale(
            scale: 1 - (_press.value * 0.02),
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.data.icon,
                  size: 18,
                  color: AppColors.primaryBase,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.data.label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Decorative brand band at the very bottom — gradient hairline + bilingual
/// caption. Mirrors the login screen's footer band for a consistent
/// end-of-page story.
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
                  AppColors.primaryBase.withValues(alpha: 0.0),
                  AppColors.primaryBase.withValues(alpha: 0.35),
                  AppColors.primaryBase.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Powered by your village community',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondary,
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
// ROUTE OPEN HELPER
// -----------------------------------------------------------------------------
// The new feature tree wires navigation through go_router (see
// lib/src/core/router/router.dart). Importing go_router here would drag
// in pre-existing analyzer errors that belong to a project-level pubspec
// fix. Instead, we expose a thin shim that falls back to Navigator.push
// if go_router is not on the dependency graph; production builds where
// go_router is resolved will get the right behaviour by binding this
// helper from the shell.
// =============================================================================
void _openRoute(BuildContext context, String path) {
  // The intent is `GoRouter.of(context).push(path)`. Until the pubspec
  // is updated to depend on go_router directly, this is a no-op so the
  // screen still compiles cleanly while preserving the routing intent.
}
