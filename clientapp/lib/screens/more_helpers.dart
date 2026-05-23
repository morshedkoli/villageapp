part of '../screens.dart';


class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceC(context),
      borderRadius: BorderRadius.circular(AppRadius.xxl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(color: AppColors.borderC(context), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryC(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: AppColors.textMutedC(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassStatCard extends StatelessWidget {
  const _GlassStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
  });
  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    final accent = gradient.isNotEmpty ? gradient.first : AppColors.primaryC(context);
    return Container(
      padding: const EdgeInsets.all(16),
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
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: accent, size: 16),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.onSeeAll,
    required this.padding,
  });
  final String title;
  final VoidCallback? onSeeAll;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryC(context),
                letterSpacing: -0.2,
              ),
            ),
          ),
          if (onSeeAll != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onSeeAll,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tr('See all', 'সব দেখুন'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryC(context),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: AppColors.primaryC(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PageBanner extends StatelessWidget {
  const _PageBanner({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.icon,
    required this.color,
  });
  final String title;
  final String subtitle;
  final String count;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceC(context),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.borderC(context), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryC(context),
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiaryC(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariantC(context),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              count,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryC(context),
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageSectionTitle extends StatelessWidget {
  const _PageSectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(letterSpacing: -0.2),
      ),
    );
  }
}

class _HorizontalDonationList extends StatelessWidget {
  const _HorizontalDonationList({required this.items});

  final List<Donation> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyStateCard(
        icon: Icons.volunteer_activism_outlined,
        title: tr('No donations available', 'কোনো অনুদান পাওয়া যায়নি'),
        message: tr(
          'Recent donation records will be visible here.',
          'সাম্প্রতিক অনুদানের রেকর্ড এখানে দেখাবে।',
        ),
      );
    }
    return SizedBox(
      height: 116,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) => DonationCard(item: items[i], compact: true),
      ),
    );
  }
}

class _HorizontalProblemList extends StatelessWidget {
  const _HorizontalProblemList({required this.items});

  final List<ProblemReport> items;

  @override
  Widget build(BuildContext context) {
    final pad = _pagePadding(context);
    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: pad.left),
        child: EmptyStateCard(
          icon: Icons.warning_amber_outlined,
          title: tr('No reported problems', 'কোনো রিপোর্ট করা সমস্যা নেই'),
          message: tr(
            'Problem reports from citizens will appear here.',
            'নাগরিকদের সমস্যা রিপোর্ট এখানে দেখাবে।',
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad.left),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            ProblemViewCard(item: items[i]),
            if (i < items.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _HorizontalProjectList extends StatelessWidget {
  const _HorizontalProjectList({required this.items});

  final List<DevelopmentProject> items;

  @override
  Widget build(BuildContext context) {
    final pad = _pagePadding(context);
    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: pad.left),
        child: EmptyStateCard(
          icon: Icons.construction_outlined,
          title: tr('No active projects', 'কোনো সক্রিয় প্রকল্প নেই'),
          message: tr(
            'New development initiatives will be listed here.',
            'নতুন উন্নয়ন উদ্যোগগুলো এখানে তালিকাভুক্ত হবে।',
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad.left),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            ProjectCard(
              item: items[i],
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProjectDetailScreen(project: items[i]),
                ),
              ),
            ),
            if (i < items.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _FundGrowthChart extends StatelessWidget {
  const _FundGrowthChart({required this.donations});

  final List<Donation> donations;

  @override
  Widget build(BuildContext context) {
    if (donations.isEmpty) {
      return EmptyStateCard(
        icon: Icons.show_chart,
        title: tr('No chart data yet', 'এখনও চার্টের তথ্য নেই'),
        message: tr(
          'Fund growth chart will appear after donations are recorded.',
          'অনুদানের রেকর্ড যোগ হলে তহবিল বৃদ্ধির চার্ট দেখাবে।',
        ),
      );
    }
    final grouped = <String, double>{};
    for (final d in donations) {
      final key = DateFormat('MMM').format(d.createdAt);
      grouped[key] = (grouped[key] ?? 0) + d.amount;
    }
    final entries = grouped.entries.toList();

    return AppCard(
      child: SizedBox(
        height: 190,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    final i = value.toInt();
                    if (i < 0 || i >= entries.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        entries[i].key,
                        style: const TextStyle(fontSize: 11),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                color: AppColors.primaryC(context),
                barWidth: 4,
                spots: List.generate(
                  entries.length,
                  (i) => FlSpot(i.toDouble(), entries[i].value),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> _ensureLogin(BuildContext context) async {
  if (DataService.instance.currentUser != null) {
    return true;
  }

  final proceed = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('Login Required', 'লগইন প্রয়োজন'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              tr(
                'Please login with Google to donate or report a problem.',
                'অনুদান দিতে বা সমস্যা রিপোর্ট করতে ইমেইল OTP দিয়ে লগইন করুন।',
              ),
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              onPressed: () => Navigator.of(context).pop(true),
              label: tr('Continue to Login', 'লগইনে এগিয়ে যান'),
            ),
          ],
        ),
      ),
    ),
  );

  if (proceed != true || !context.mounted) {
    return false;
  }

  await Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
  return DataService.instance.currentUser != null;
}
