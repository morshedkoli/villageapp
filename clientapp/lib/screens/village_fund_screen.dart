part of '../screens.dart';


class VillageFundScreen extends StatelessWidget {
  const VillageFundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = DataService.instance;
    final pad = _pagePadding(context);
    return _SidebarPageScaffold(
      title: tr('Village Fund', 'গ্রাম তহবিল'),
      subtitle: tr(
        'Track collections, spending, and real-time balance',
        'সংগ্রহ, ব্যয়, এবং তাৎক্ষণিক ব্যালেন্স দেখুন',
      ),
      selectedId: _MenuId.fund,
      actions: const [_NotificationButton()],
      body: StreamBuilder<VillageOverview>(
        stream: data.villageOverview(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting &&
              !snap.hasData) {
            return const FundSkeleton();
          }
          final overview =
              snap.data ??
              const VillageOverview(
                name: 'Our Village',
                totalCitizens: 0,
                totalFundCollected: 0,
                totalSpent: 0,
              );
          return ListView(
            padding: pad,
            children: [
              _PageBanner(
                title: tr('Village Fund', 'গ্রাম তহবিল'),
                subtitle: tr(
                  'Track fund collection and spending',
                  'তহবিল সংগ্রহ ও ব্যয় ট্র্যাক করুন',
                ),
                count: currency.format(overview.availableBalance),
                icon: Icons.account_balance_wallet_rounded,
                color: AppColors.primaryC(context),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _GlassStatCard(
                      icon: Icons.savings_rounded,
                      label: tr('Collected', 'সংগ্রহ'),
                      value: currency.format(overview.totalFundCollected),
                      gradient: AppColors.primaryGradient,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GlassStatCard(
                      icon: Icons.trending_down_rounded,
                      label: tr('Spent', 'ব্যয়'),
                      value: currency.format(overview.totalSpent),
                      gradient: AppColors.errorGradient,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: tr('Donate Now', 'এখন অনুদান দিন'),
                icon: Icons.volunteer_activism_rounded,
                onPressed: () async {
                  final ok = await _ensureLogin(context);
                  if (!context.mounted || !ok) return;
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DonateScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _PageSectionTitle(title: tr('Fund Growth', 'তহবিলের বৃদ্ধি')),
              StreamBuilder<List<Donation>>(
                stream: data.donations(limit: 60),
                builder: (context, ds) =>
                    _FundGrowthChart(donations: ds.data ?? const []),
              ),
            ],
          );
        },
      ),
    );
  }
}
