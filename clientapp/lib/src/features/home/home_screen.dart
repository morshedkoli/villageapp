import 'dart:ui';

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/transaction_tile.dart';
import '_widgets.dart';

/// Active (new-tree) Home screen — full Antigravity design language, in the
/// same visual family as the redesigned login page and profile screen.
///
/// Surface treatment (matches login + profile redesign):
///   * Tinted brand backdrop (deep forest → mint wash) with two ambient
///     orbs drifting behind the content.
///   * Top brand glow + bottom brand glow for vertical depth.
///   * Glassmorphic balance card (rounded 24, BackdropFilter blur, white
///     border) instead of the flat gradient block.
///   * Glass 4-up quick action grid with a tinted icon container.
///   * Recent transactions in a glass surface with the same hairline border
///     as the other cards.
///   * Decorative gradient hairline + bilingual footer band at the very
///     bottom.
///
/// Data wiring note:
///   The new feature tree imports `package:go_router/go_router.dart` in many
///   files, but the package is NOT in pubspec.yaml. The previous version of
///   this screen depended on `context.push()` for navigation and therefore
///   would not compile. The redesign uses a tiny `_openRoute` shim that
///   prefers go_router when it is wired up and falls back to
///   `Navigator.of(context).push` for the rest of the app, so the screen
///   compiles in either world.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  // -------- Entrance choreography -----------------------------------------
  late final AnimationController _enterController;
  late final Animation<double> _enterFade;
  late final Animation<Offset> _enterSlide;

  // -------- Orb drift (parallax-lite) -------------------------------------
  late final AnimationController _orbController;

  static const _enterDuration = Duration(milliseconds: 800);
  static const _orbDuration = Duration(seconds: 16);

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
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _enterController, curve: Curves.easeOutCubic),
    );

    _orbController = AnimationController(
      vsync: this,
      duration: _orbDuration,
    )..repeat();

    _enterController.forward();
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _orbController,
        builder: (context, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // ── Backdrop + orbs ────────────────────────────────
                  _HomeBackdrop(
                    orbT: _orbController.value,
                    showTopGlow: true,
                    showBottomGlow: true,
                  ),

                  // ── Foreground content ────────────────────────────
                  SafeArea(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.only(bottom: AppSpacing.x3),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: FadeTransition(
                            opacity: _enterFade,
                            child: SlideTransition(
                              position: _enterSlide,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Greeting header
                                  const _HomeHeader(),
                                  const SizedBox(height: AppSpacing.sm),

                                  // Glassmorphic balance card
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppSpacing.lg,
                                    ),
                                    child: _BalanceCard(),
                                  ),
                                  const SizedBox(height: AppSpacing.xl),

                                  // 4-up quick actions
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppSpacing.lg,
                                    ),
                                    child: _QuickActionGrid(),
                                  ),
                                  const SizedBox(height: AppSpacing.xl),

                                  // Recent transactions
                                  SectionHeader(
                                    title: 'Recent Transactions',
                                    actionLabel: 'See All',
                                    onAction: () =>
                                        openRoute(context, '/wallet'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.lg,
                                    ),
                                    child: GlassSurface(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: AppSpacing.sm,
                                      ),
                                      child: Column(
                                        children: const [
                                          _DemoTransaction(
                                            title: 'Sent to Sarah',
                                            subtitle: 'Today, 2:30 PM',
                                            amount: '৳2,500',
                                            isCredit: false,
                                            icon: Icons.arrow_upward_rounded,
                                            iconColor: AppColors.error,
                                          ),
                                          _DemoTransaction(
                                            title: 'Received from John',
                                            subtitle: 'Today, 11:20 AM',
                                            amount: '৳5,000',
                                            isCredit: true,
                                            icon: Icons
                                                .arrow_downward_rounded,
                                            iconColor: AppColors.success,
                                          ),
                                          _DemoTransaction(
                                            title: 'Service Payment',
                                            subtitle: 'Yesterday, 4:15 PM',
                                            amount: '৳1,200',
                                            isCredit: false,
                                            icon:
                                                Icons.shopping_bag_rounded,
                                            iconColor: AppColors.primaryBase,
                                            status: 'Pending',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xl),

                                  // Footer band — gradient hairline + caption.
                                  const _HomeFooterBand(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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

// ─── Backdrop + orbs (tinted brand wash with two drifting ambient orbs) ─────

class _HomeBackdrop extends StatelessWidget {
  const _HomeBackdrop({
    required this.orbT,
    required this.showTopGlow,
    required this.showBottomGlow,
  });

  final double orbT;
  final bool showTopGlow;
  final bool showBottomGlow;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Tinted base
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surfaceVariant,
                  AppColors.background,
                ],
              ),
            ),
          ),
          // Soft top brand glow
          if (showTopGlow)
            const Align(
              alignment: Alignment(-0.6, -0.95),
              child: FractionalTranslation(
                translation: Offset(-0.2, -0.3),
                child: GlowBlob(
                  size: 320,
                  colors: [AppColors.primaryMint, Color(0x00000000)],
                ),
              ),
            ),
          // Soft bottom brand glow
          if (showBottomGlow)
            const Align(
              alignment: Alignment(0.7, 0.95),
              child: FractionalTranslation(
                translation: Offset(0.2, 0.3),
                child: GlowBlob(
                  size: 360,
                  colors: [AppColors.primaryLight, Color(0x00000000)],
                ),
              ),
            ),
          // Drifting orb #1 (top-right)
          Align(
            alignment: const Alignment(0.85, -0.4),
            child: FractionalTranslation(
              translation: Offset(0.05 * (orbT - 0.5), 0.08 * (orbT - 0.5)),
              child: const AmbientOrb(
                size: 180,
                color: AppColors.primaryLight,
              ),
            ),
          ),
          // Drifting orb #2 (bottom-left)
          Align(
            alignment: const Alignment(-0.7, 0.55),
            child: FractionalTranslation(
              translation: Offset(-0.06 * (orbT - 0.5), -0.07 * (orbT - 0.5)),
              child: const AmbientOrb(
                size: 220,
                color: AppColors.primaryMint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Greeting header (avatar + name + notification + monogram pill) ────────

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Row(
        children: [
          // Brand monogram pill (matches login page)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBase,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            alignment: Alignment.center,
            child: const Text(
              'D',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greeting()},',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Morshed',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GlassIconButton(
            icon: Icons.notifications_none_rounded,
            onTap: () => openRoute(context, '/notifications'),
          ),
        ],
      ),
    );
  }
}

// ─── Glassmorphic balance card (replaces the flat gradient block) ─────────

class _BalanceCard extends StatefulWidget {
  const _BalanceCard();

  @override
  State<_BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<_BalanceCard> {
  bool _showBalance = true;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xCC2D5A47), // primary @ 80%
                Color(0xCC4CAF50), // primaryLight @ 80%
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBase.withValues(alpha: 0.25),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row (label + show/hide pill) ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Balance',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                  PressablePill(
                    onTap: () => setState(() => _showBalance = !_showBalance),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _showBalance
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _showBalance ? 'Hide' : 'Show',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // ── Balance amount (gradient masked) ──
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.white, Color(0xFFB2DFB2)],
                ).createShader(bounds),
                child: Text(
                  _showBalance ? '৳12,45,800' : '৳ • • • • •',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.4,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Action row (Add / Send / Request) ──
              Row(
                children: [
                  BalanceAction(
                    icon: Icons.add_rounded,
                    label: 'Add Money',
                    onTap: () => openRoute(context, '/wallet/add'),
                  ),
                  const SizedBox(width: 10),
                  BalanceAction(
                    icon: Icons.send_rounded,
                    label: 'Send',
                    onTap: () => openRoute(context, '/wallet/send'),
                  ),
                  const SizedBox(width: 10),
                  BalanceAction(
                    icon: Icons.download_rounded,
                    label: 'Request',
                    onTap: () => openRoute(context, '/wallet/request'),
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

// ─── Pill / balance action / quick action / glass surface have been
// extracted to `_widgets.dart` (PressablePill, BalanceAction,
// QuickActionTile, GlassSurface).

// ─── 4-up quick action grid (uses QuickActionTile from _widgets.dart) ─────

class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid();

  @override
  Widget build(BuildContext context) {
    final actions = <QuickActionTile>[
      QuickActionTile(
        icon: Icons.chat_rounded,
        label: 'Messages',
        color: AppColors.info,
        onTap: () => openRoute(context, '/chat'),
      ),
      QuickActionTile(
        icon: Icons.account_balance_wallet_rounded,
        label: 'Wallet',
        color: AppColors.primaryBase,
        onTap: () => openRoute(context, '/wallet'),
      ),
      QuickActionTile(
        icon: Icons.store_rounded,
        label: 'Marketplace',
        color: AppColors.warning,
        onTap: () => openRoute(context, '/marketplace'),
      ),
      QuickActionTile(
        icon: Icons.people_rounded,
        label: 'Village',
        color: AppColors.success,
        onTap: () => openRoute(context, '/village'),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppSpacing.md;
        final tileW = (constraints.maxWidth - spacing * 3) / 4;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final a in actions) SizedBox(width: tileW, child: a),
          ],
        );
      },
    );
  }
}


// ─── Demo transaction row — uses the shared TransactionTile, but as a
// SizedBox so dividers between rows are 0 and the parent glass surface
// visually owns the grouping.
class _DemoTransaction extends StatelessWidget {
  const _DemoTransaction({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
    required this.icon,
    required this.iconColor,
    this.status,
  });

  final String title;
  final String subtitle;
  final String amount;
  final bool isCredit;
  final IconData icon;
  final Color iconColor;
  final String? status;

  @override
  Widget build(BuildContext context) {
    return TransactionTile(
      title: title,
      subtitle: subtitle,
      amount: amount,
      isCredit: isCredit,
      icon: icon,
      iconColor: iconColor,
      status: status,
    );
  }
}

// ─── Footer band — gradient hairline + bilingual caption ───────────────────

class _HomeFooterBand extends StatelessWidget {
  const _HomeFooterBand();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
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
          const Text(
            'Powered by your village community',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
              letterSpacing: 0.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}