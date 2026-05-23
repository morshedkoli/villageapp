part of '../screens.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = DataService.instance;
    final pad = _pagePadding(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth >= 640 ? 560.0 : screenWidth;
    final actionWidth = ((contentWidth - (pad.left * 2) - 12) / 2)
        .clamp(136.0, 220.0)
        .toDouble();
    return StreamBuilder<VillageOverview>(
      stream: data.villageOverview(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return Padding(
            padding: _pagePadding(context),
            child: const ListSkeleton(itemCount: 4, itemHeight: 120),
          );
        }
        if (snap.hasError && !snap.hasData) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_off_rounded,
                    size: 48,
                    color: AppColors.textSecondaryC(context),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tr('Could not load data', 'ডেটা লোড করা যায়নি'),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryC(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tr('Pull down to retry', 'রিফ্রেশ করতে টানুন'),
                    style: TextStyle(
                      color: AppColors.textSecondaryC(context),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final overview =
            snap.data ??
            const VillageOverview(
              name: 'Our Village',
              totalCitizens: 0,
              totalFundCollected: 0,
              totalSpent: 0,
            );
        return RefreshIndicator(
          color: AppColors.primaryC(context),
          onRefresh: () async {
            await Future.wait([
              data.villageOverview().first,
              data.donations(limit: 8).first,
              data.problems(limit: 8).first,
              data.projects(limit: 8).first,
            ]);
          },
          child: _constrainBodyWidth(
            context,
            ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: _AppHeader(
                    showMenuButton: !_useDesktopSidebar(context),
                    actions: [
                      _HeaderActionButton(
                        icon: Icons.search_rounded,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CitizensPage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const _NotificationButton(),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // ── Hero banner ──
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: pad.left),
                    child: StreamBuilder<int>(
                      stream: data.citizenCount(),
                      builder: (context, citizenSnap) {
                        final citizenCount =
                            citizenSnap.data ?? overview.totalCitizens;
                        return _HeroCard(
                          title: overview.name,
                          balance: currency.format(overview.availableBalance),
                          expense: currency.format(overview.totalSpent),
                          citizens: citizenCount,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  duration: const Duration(milliseconds: 600),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: pad.left),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariantC(context),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.campaign_outlined,
                            color: AppColors.textSecondaryC(context),
                            size: 16,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              tr(
                                'Important community updates appear at the top of each section.',
                                'গুরুত্বপূর্ণ কমিউনিটি আপডেট প্রতিটি সেকশনের শুরুতে দেখানো হয়।',
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondaryC(context),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Quick actions ──
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  duration: const Duration(milliseconds: 600),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: pad.left),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: actionWidth,
                          child: _QuickAction(
                            icon: Icons.volunteer_activism_rounded,
                            label: tr('Donate', 'অনুদান'),
                            color: AppColors.primaryC(context),
                            onTap: () async {
                              final ok = await _ensureLogin(context);
                              if (!context.mounted || !ok) return;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const DonateScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: actionWidth,
                          child: _QuickAction(
                            icon: Icons.people_rounded,
                            label: tr('Citizens', 'নাগরিক'),
                            color: AppColors.secondary,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CitizensPage(),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: actionWidth,
                          child: _QuickAction(
                            icon: Icons.leaderboard_rounded,
                            label: tr('Leaders', 'লিডার'),
                            color: AppColors.successC(context),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const LeaderboardPage(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Stat cards ──
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  duration: const Duration(milliseconds: 600),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: pad.left),
                    child: StreamBuilder<int>(
                      stream: data.projectsCount(),
                      builder: (context, projectSnap) {
                        final projectCount = projectSnap.data ?? 0;
                        return StreamBuilder<int>(
                          stream: data.problems().map((list) => list.length),
                          builder: (context, problemSnap) {
                            final problemCount = problemSnap.data ?? 0;
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: StatCard(
                                        icon: Icons
                                            .account_balance_wallet_rounded,
                                        label: tr('Fund', 'তহবিল'),
                                        value: currency.format(
                                          overview.totalFundCollected,
                                        ),
                                        gradient: AppColors.primaryGradient,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: StatCard(
                                        icon: Icons.pie_chart_rounded,
                                        label: tr('Balance', 'ব্যালেন্স'),
                                        value: currency.format(
                                          overview.availableBalance,
                                        ),
                                        gradient: AppColors.secondaryGradient,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: StatCard(
                                        icon: Icons.construction_rounded,
                                        label: tr('Projects', 'প্রকল্প'),
                                        value: '$projectCount',
                                        gradient: AppColors.warningGradient,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: StatCard(
                                        icon: Icons.warning_amber_rounded,
                                        label: tr('Problems', 'সমস্যা'),
                                        value: '$problemCount',
                                        gradient: AppColors.errorGradient,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                _SoftSectionDivider(padding: pad.left),
                const SizedBox(height: 14),

                // ── Recent Donations ──
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  duration: const Duration(milliseconds: 600),
                  child: Column(
                    children: [
                      _SectionHeader(
                        title: tr('Recent Donations', 'সাম্প্রতিক অনুদান'),
                        onSeeAll: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const VillageFundScreen(),
                          ),
                        ),
                        padding: pad.left,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.only(left: pad.left),
                        child: StreamBuilder<List<Donation>>(
                          stream: data.donations(limit: 8),
                          builder: (context, ds) => _HorizontalDonationList(
                            items: ds.data ?? const [],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                _SoftSectionDivider(padding: pad.left),
                const SizedBox(height: 14),

                // ── Latest Problems ──
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  duration: const Duration(milliseconds: 600),
                  child: Column(
                    children: [
                      _SectionHeader(
                        title: tr('Latest Problems', 'সাম্প্রতিক সমস্যা'),
                        onSeeAll: () => _openRootTab(context, 1),
                        padding: pad.left,
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<List<ProblemReport>>(
                        stream: data.problems(limit: 8),
                        builder: (context, ps) {
                          final items = ps.data ?? const <ProblemReport>[];
                          return _HorizontalProblemList(items: items);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                _SoftSectionDivider(padding: pad.left),
                const SizedBox(height: 14),

                // ── Active Projects ──
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  duration: const Duration(milliseconds: 600),
                  child: Column(
                    children: [
                      _SectionHeader(
                        title: tr('Active Projects', 'চলমান প্রকল্প'),
                        onSeeAll: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ProjectsScreen(),
                          ),
                        ),
                        padding: pad.left,
                      ),
                      const SizedBox(height: 8),
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
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
