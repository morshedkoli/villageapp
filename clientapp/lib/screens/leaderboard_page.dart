part of '../screens.dart';


class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _SidebarPageScaffold(
      title: tr('Leaderboard', 'লিডারবোর্ড'),
      subtitle: tr(
        'Recognize top contributors across the village',
        'গ্রামের শীর্ষ অবদানকারীদের দেখুন',
      ),
      selectedId: _MenuId.leaderboard,
      actions: const [_NotificationButton()],
      body: const LeaderboardScreen(),
    );
  }
}

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  bool _monthly = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Donation>>(
      stream: DataService.instance.donations(limit: 500),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const LeaderboardSkeleton();
        }
        var donations = snap.data ?? const <Donation>[];
        if (_monthly) {
          final now = DateTime.now();
          donations = donations
              .where(
                (d) =>
                    d.createdAt.year == now.year &&
                    d.createdAt.month == now.month,
              )
              .toList();
        }
        final totals = <String, double>{};
        for (final d in donations) {
          totals[d.donorName] = (totals[d.donorName] ?? 0) + d.amount;
        }
        final ranking = totals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return ListView(
          padding: _pagePadding(context),
          children: [
            _PageBanner(
              title: tr('Top Donors', 'শীর্ষ দাতা'),
              subtitle: tr(
                'Recognizing generous contributors',
                'উদার অবদানকারীদের স্বীকৃতি',
              ),
              count: '${ranking.length} ${tr('donors', 'দাতা')}',
              icon: Icons.leaderboard_rounded,
              color: AppColors.successC(context),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariantC(context),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                selected: {_monthly},
                onSelectionChanged: (v) => setState(() => _monthly = v.first),
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                segments: [
                  ButtonSegment(
                    value: false,
                    label: Text(tr('All Time', 'সর্বমোট')),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text(tr('Monthly', 'মাসিক')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (ranking.isEmpty)
              EmptyStateCard(
                icon: Icons.leaderboard_outlined,
                title: tr('No leaderboard data', 'লিডারবোর্ড ডেটা নেই'),
                message: tr(
                  'Donor ranking will appear when donations are made.',
                  'অনুদান এলে দাতার র‌্যাংকিং এখানে দেখাবে।',
                ),
              )
            else ...[
              // Podium top 3
              if (ranking.length >= 3)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _PodiumItem(
                        rank: 2,
                        name: ranking[1].key,
                        amount: currency.format(ranking[1].value),
                        height: 80,
                        gradient: const [Color(0xFF8E8E93), Color(0xFFC7C7CC)],
                      ),
                      _PodiumItem(
                        rank: 1,
                        name: ranking[0].key,
                        amount: currency.format(ranking[0].value),
                        height: 100,
                        gradient: AppColors.primaryGradient,
                      ),
                      _PodiumItem(
                        rank: 3,
                        name: ranking[2].key,
                        amount: currency.format(ranking[2].value),
                        height: 64,
                        gradient: const [Color(0xFF34C759), Color(0xFF30D158)],
                      ),
                    ],
                  ),
                ),
              ...ranking.asMap().entries.map(
                (e) => AppCard(
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: e.key < 3
                                ? (e.key == 0
                                      ? [
                                          const Color(0xFFFF9500),
                                          const Color(0xFFFF6B00),
                                        ]
                                      : e.key == 1
                                      ? [
                                          const Color(0xFF8E8E93),
                                          const Color(0xFFC7C7CC),
                                        ]
                                      : [
                                          const Color(0xFF34C759),
                                          const Color(0xFF30D158),
                                        ])
                                : [
                                    AppColors.surfaceVariantC(context),
                                    const Color(0xFFE5E5EA),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '${e.key + 1}',
                            style: TextStyle(
                              color: e.key < 3
                                  ? Colors.white
                                  : const Color(0xFF8E8E93),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          e.value.key,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimaryC(context),
                          ),
                        ),
                      ),
                      Text(
                        currency.format(e.value.value),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryC(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _PodiumItem extends StatelessWidget {
  const _PodiumItem({
    required this.rank,
    required this.name,
    required this.amount,
    required this.height,
    required this.gradient,
  });
  final int rank;
  final String name;
  final String amount;
  final double height;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$rank',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: AppColors.textPrimaryC(context),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 11,
            color: AppColors.textSecondaryC(context),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                gradient[0].withValues(alpha: 0.15),
                gradient[1].withValues(alpha: 0.08),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: gradient[0].withValues(alpha: 0.2)),
          ),
        ),
      ],
    );
  }
}
