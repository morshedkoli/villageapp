part of '../screens.dart';

/// Home screen — production-polished, minimal copy, animated.
///
/// Layout philosophy:
///   • Numbers and icons over paragraphs
///   • Single hero metric (available balance) with secondary line
///   • Quick actions as 2-up chips with concise verbs
///   • Stat grid: 4 numbers, no labels-as-sentences
///   • Sectioned scroll: Donations → Problems → Projects, each compact
///
/// Motion:
///   • Staggered entrance via [StaggeredColumn]
///   • Animated stat counts via [AnimatedCount]
///   • Pull-to-refresh with adequate haptic on success
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = DataService.instance;
    final pad = _pagePadding(context);

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
          child: _constrainBodyWidth(
            context,
            ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                // Header (greeting + actions)
                _AppHeader(
                  showMenuButton: !_useDesktopSidebar(context),
                  actions: [
                    _HeaderActionButton(
                      icon: Icons.search_rounded,
                      onTap: () => Navigator.of(context).push(
                        FadeThroughPageRoute(page: const CitizensPage()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const _NotificationButton(),
                  ],
                ),
                const SizedBox(height: 4),

                // Hero balance card
                FadeSlideIn(
                  duration: const Duration(milliseconds: 380),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: pad.left),
                    child: StreamBuilder<int>(
                      stream: data.citizenCount(),
                      builder: (context, citizenSnap) {
                        return _HeroCard(
                          title: overview.name,
                          balance: currency.format(overview.availableBalance),
                          expense: currency.format(overview.totalSpent),
                          citizens: citizenSnap.data ?? overview.totalCitizens,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Quick actions row (3-up, no wrap)
                FadeSlideIn(
                  delay: const Duration(milliseconds: 60),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: pad.left),
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
                              FadeThroughPageRoute(page: const DonateScreen()),
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
                              FadeThroughPageRoute(page: const CitizensPage()),
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
                ),
                const SizedBox(height: 18),

                // Stat grid — 4 numbers, animated counts
                FadeSlideIn(
                  delay: const Duration(milliseconds: 120),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: pad.left),
                    child: _StatGrid(overview: overview),
                  ),
                ),
                const SizedBox(height: 22),

                // Recent Donations
                FadeSlideIn(
                  delay: const Duration(milliseconds: 180),
                  child: _Section(
                    title: tr('Donations', 'অনুদান'),
                    onSeeAll: () => Navigator.of(context).push(
                      FadeThroughPageRoute(page: const VillageFundScreen()),
                    ),
                    padding: pad.left,
                    child: StreamBuilder<List<Donation>>(
                      stream: data.donations(limit: 8),
                      builder: (context, ds) => _HorizontalDonationList(
                        items: ds.data ?? const [],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // Latest Problems
                FadeSlideIn(
                  delay: const Duration(milliseconds: 220),
                  child: _Section(
                    title: tr('Problems', 'সমস্যা'),
                    onSeeAll: () => _openRootTab(context, 1),
                    padding: pad.left,
                    child: StreamBuilder<List<ProblemReport>>(
                      stream: data.problems(limit: 8),
                      builder: (context, ps) =>
                          _HorizontalProblemList(items: ps.data ?? const []),
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // Active Projects
                FadeSlideIn(
                  delay: const Duration(milliseconds: 260),
                  child: _Section(
                    title: tr('Projects', 'প্রকল্প'),
                    onSeeAll: () => Navigator.of(context).push(
                      FadeThroughPageRoute(page: const ProjectsScreen()),
                    ),
                    padding: pad.left,
                    child: StreamBuilder<List<DevelopmentProject>>(
                      stream: data.projects(limit: 8),
                      builder: (context, pr) {
                        final items = (pr.data ?? const <DevelopmentProject>[])
                            .where((e) => e.status != 'Completed')
                            .toList();
                        return _HorizontalProjectList(items: items);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Quick Action Row — 3 chips, no labels overflow, square icons
// ────────────────────────────────────────────────────────────────────────────

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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceC(context),
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          border: Border.all(color: AppColors.borderC(context), width: 1),
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.md),
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
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Stat grid — 4-up with animated counts and icon chips
// ────────────────────────────────────────────────────────────────────────────

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
          stream: data.problems().map((l) => l.length),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceC(context),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.borderC(context), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.md),
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
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Section — title + see-all link, used 3× on home
// ────────────────────────────────────────────────────────────────────────────

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
      children: [
        _SectionHeader(
          title: title,
          onSeeAll: onSeeAll,
          padding: padding,
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Loading skeleton — shimmer-only, no text
// ────────────────────────────────────────────────────────────────────────────

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
