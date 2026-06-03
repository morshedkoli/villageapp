part of '../screens.dart';

/// Home screen — full-bleed glassmorphic surface, designed to match the
/// login page's "Antigravity" visual language.
///
/// Visual ingredients (same as the login page):
///   * Tinted brand backdrop (the global _pageBackdrop) with two ambient
///     orbs drifting behind the content.
///   * Glassmorphic hero balance card (echoes the login lottie hero).
///   * Glass quick-action chips + glass stat grid (matches the login trust
///     strip treatment).
///   * Horizontal carousel cards for Donations / Problems / Projects, each
///     in a glass surface with a soft brand-tinted shadow.
///   * Decorative gradient hairline + bilingual footer band at the very
///     bottom — exact replica of the login screen's footer band.
///
/// Data wiring is preserved from the previous design:
///   * `villageOverview()` stream drives the hero card and stat grid.
///   * `donations / problems / projects` streams drive the three carousels.
///   * Pull-to-refresh with a confirm haptic on success.
///   * Loading skeleton and offline error state are kept verbatim.
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
      begin: const Offset(0, 0.10),
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
    final data = DataService.instance;
    final pad = _pagePadding(context);
    final media = MediaQuery.of(context);

    return StreamBuilder<VillageOverview>(
      stream: data.villageOverview(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const _HomeSkeleton();
        }
        if (snap.hasError && !snap.hasData) {
          return _HomeErrorState();
        }

        final overview = snap.data ??
            const VillageOverview(
              name: 'Our Village',
              totalCitizens: 0,
              totalFundCollected: 0,
              totalSpent: 0,
            );

        return RefreshIndicator(
          color: AppColors.primaryC(context),
          backgroundColor: AppColors.surfaceC(context),
          onRefresh: () async {
            Haptics.tap();
            await Future.wait([
              data.villageOverview().first,
              data.donations(limit: 8).first,
              data.problems(limit: 8).first,
              data.projects(limit: 8).first,
            ]);
            Haptics.confirm();
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return _constrainBodyWidth(
                context,
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.only(bottom: 24),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header (greeting + actions)
                              _AppHeader(
                                showMenuButton: !_useDesktopSidebar(context),
                                actions: [
                                  _HeaderActionButton(
                                    icon: Icons.search_rounded,
                                    onTap: () => Navigator.of(context).push(
                                      FadeThroughPageRoute(
                                        page: const CitizensPage(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const _NotificationButton(),
                                ],
                              ),
                              const SizedBox(height: 4),

                              // Hero balance card
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: pad.left),
                                child: StreamBuilder<int>(
                                  stream: data.citizenCount(),
                                  builder: (context, citizenSnap) {
                                    return _HeroCard(
                                      title: overview.name,
                                      balance:
                                          currency.format(overview.availableBalance),
                                      expense:
                                          currency.format(overview.totalSpent),
                                      citizens: citizenSnap.data ??
                                          overview.totalCitizens,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Quick actions row (3-up)
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: pad.left),
                                child: _QuickActionRow(
                                  actions: [
                                    _QuickActionData(
                                      icon: Icons.volunteer_activism_rounded,
                                      label: tr('Donate', 'অনুদান'),
                                      color: AppColors.primaryC(context),
                                      onTap: () async {
                                        final ok = await _ensureLogin(context);
                                        if (!context.mounted || !ok) return;
                                        Haptics.tap();
                                        Navigator.of(context).push(
                                          FadeThroughPageRoute(
                                            page: const DonateScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                    _QuickActionData(
                                      icon: Icons.people_alt_rounded,
                                      label: tr('Citizens', 'নাগরিক'),
                                      color: AppColors.infoC(context),
                                      onTap: () {
                                        Haptics.tap();
                                        Navigator.of(context).push(
                                          FadeThroughPageRoute(
                                            page: const CitizensPage(),
                                          ),
                                        );
                                      },
                                    ),
                                    _QuickActionData(
                                      icon: Icons.emoji_events_rounded,
                                      label: tr('Leaders', 'লিডার'),
                                      color: AppColors.warningC(context),
                                      onTap: () {
                                        Haptics.tap();
                                        Navigator.of(context).push(
                                          FadeThroughPageRoute(
                                            page: const LeaderboardPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Stat grid (4 numbers, animated counts)
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: pad.left),
                                child: _StatGrid(overview: overview),
                              ),
                              const SizedBox(height: 22),

                              // Recent Donations
                              _Section(
                                title: tr('Donations', 'অনুদান'),
                                onSeeAll: () => Navigator.of(context).push(
                                  FadeThroughPageRoute(
                                    page: const VillageFundScreen(),
                                  ),
                                ),
                                padding: pad.left,
                                child: StreamBuilder<List<Donation>>(
                                  stream: data.donations(limit: 8),
                                  builder: (context, ds) =>
                                      _HorizontalDonationList(
                                    items: ds.data ?? const [],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 22),

                              // Latest Problems
                              _Section(
                                title: tr('Problems', 'সমস্যা'),
                                onSeeAll: () => _openRootTab(context, 1),
                                padding: pad.left,
                                child: StreamBuilder<List<ProblemReport>>(
                                  stream: data.problems(limit: 8),
                                  builder: (context, ps) =>
                                      _HorizontalProblemList(
                                    items: ps.data ?? const [],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 22),

                              // Active Projects
                              _Section(
                                title: tr('Projects', 'প্রকল্প'),
                                onSeeAll: () => Navigator.of(context).push(
                                  FadeThroughPageRoute(
                                    page: const ProjectsScreen(),
                                  ),
                                ),
                                padding: pad.left,
                                child:
                                    StreamBuilder<List<DevelopmentProject>>(
                                  stream: data.projects(limit: 8),
                                  builder: (context, pr) {
                                    final items =
                                        (pr.data ?? const <DevelopmentProject>[])
                                            .where((e) => e.status != 'Completed')
                                            .toList();
                                    return _HorizontalProjectList(items: items);
                                  },
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Footer band — gradient hairline + caption.
                              const _HomeFooterBand(),
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
        );
      },
    );
  }
}

// =============================================================================
// SUB-WIDGETS
// =============================================================================

// ─── Quick Action Row — 3 glass chips with a tinted icon container ─────────

class _QuickActionData {
  const _QuickActionData({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

class _QuickActionRow extends StatelessWidget {
  const _QuickActionRow({required this.actions});

  final List<_QuickActionData> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: _QuickActionTile(data: actions[i])),
        ],
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.data});

  final _QuickActionData data;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: data.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceC(context).withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.55),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryC(context).withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: data.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(data.icon, color: data.color, size: 20),
                ),
                const SizedBox(height: 10),
                Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryC(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Stat grid — 4 glass tiles with animated counts ───────────────────────

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.overview});

  final VillageOverview overview;

  @override
  Widget build(BuildContext context) {
    final data = DataService.instance;
    return StreamBuilder<int>(
      stream: data.projectsCount(),
      builder: (context, projectSnap) {
        return StreamBuilder<int>(
          stream: data.problems(limit: 1000).map((l) => l.length),
          builder: (context, problemSnap) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        icon: Icons.account_balance_wallet_rounded,
                        label: tr('Fund', 'তহবিল'),
                        value: overview.totalFundCollected,
                        formatter: (v) => currency.format(v),
                        color: AppColors.primaryC(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatTile(
                        icon: Icons.pie_chart_rounded,
                        label: tr('Balance', 'ব্যালেন্স'),
                        value: overview.availableBalance,
                        formatter: (v) => currency.format(v),
                        color: AppColors.successC(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        icon: Icons.construction_rounded,
                        label: tr('Projects', 'প্রকল্প'),
                        value: projectSnap.data ?? 0,
                        color: AppColors.warningC(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatTile(
                        icon: Icons.warning_amber_rounded,
                        label: tr('Problems', 'সমস্যা'),
                        value: problemSnap.data ?? 0,
                        color: AppColors.errorC(context),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.formatter,
  });

  final IconData icon;
  final String label;
  final num value;
  final Color color;
  final String Function(num)? formatter;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceC(context).withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.55),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryC(context).withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(height: 12),
              AnimatedCount(
                value: value,
                formatter: formatter,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryC(context),
                  letterSpacing: -0.3,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiaryC(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section header — title + see-all, used 3× on home ────────────────────

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.onSeeAll,
    required this.padding,
    required this.child,
  });

  final String title;
  final VoidCallback onSeeAll;
  final double padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: title,
          onSeeAll: onSeeAll,
          padding: padding,
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

// ─── Footer band — gradient hairline + bilingual caption ───────────────────

/// Decorative brand band at the very bottom — exact replica of the login
/// screen's footer band so the end-of-page story is consistent across
/// surfaces.
class _HomeFooterBand extends StatelessWidget {
  const _HomeFooterBand();

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

// ─── Loading skeleton — shimmer-only, no text (unchanged shape) ───────────

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    final pad = _pagePadding(context);
    return ListView(
      padding: EdgeInsets.fromLTRB(pad.left, pad.top + 40, pad.right, 24),
      children: [
        // Header row
        Row(
          children: [
            const Shimmer(width: 38, height: 38, borderRadius: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Shimmer(width: 80, height: 12),
                  SizedBox(height: 6),
                  Shimmer(width: 140, height: 16),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        // Hero card
        Shimmer(
          width: double.infinity,
          height: 180,
          borderRadius: AppRadius.xxl,
        ),
        const SizedBox(height: 16),
        // Quick actions
        Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: Shimmer(height: 92, borderRadius: AppRadius.xxl),
              ),
            ],
          ],
        ),
        const SizedBox(height: 18),
        // Stat grid
        for (var r = 0; r < 2; r++) ...[
          if (r > 0) const SizedBox(height: 10),
          Row(
            children: [
              for (var c = 0; c < 2; c++) ...[
                if (c > 0) const SizedBox(width: 10),
                Expanded(
                  child: Shimmer(height: 100, borderRadius: AppRadius.xxl),
                ),
              ],
            ],
          ),
        ],
        const SizedBox(height: 22),
        Shimmer(width: 100, height: 16),
        const SizedBox(height: 12),
        Shimmer(height: 110, borderRadius: AppRadius.xxl),
        const SizedBox(height: 16),
        Shimmer(width: 100, height: 16),
        const SizedBox(height: 12),
        Shimmer(height: 110, borderRadius: AppRadius.xxl),
      ],
    );
  }
}

class _HomeErrorState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariantC(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 28,
                color: AppColors.textTertiaryC(context),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              tr('No connection', 'কোনো সংযোগ নেই'),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: AppColors.textPrimaryC(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tr('Pull to retry', 'রিফ্রেশ করতে টানুন'),
              style: TextStyle(
                color: AppColors.textTertiaryC(context),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
