part of '../screens.dart';


class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SidebarPageScaffold(
      title: tr('Projects', 'প্রকল্প'),
      subtitle: tr(
        'Track planning, budget, and execution updates',
        'পরিকল্পনা, বাজেট, এবং বাস্তবায়নের আপডেট দেখুন',
      ),
      selectedId: _MenuId.projects,
      actions: const [_NotificationButton()],
      body: StreamBuilder<List<DevelopmentProject>>(
        stream: DataService.instance.projects(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting &&
              !snap.hasData) {
            return const ProjectsSkeleton();
          }
          final items = snap.data ?? const <DevelopmentProject>[];
          return ListView(
            padding: _pagePadding(context),
            children: [
              _PageBanner(
                title: tr('Development Projects', 'উন্নয়ন প্রকল্প'),
                subtitle: tr(
                  'Track planning and execution updates',
                  'পরিকল্পনা ও বাস্তবায়নের আপডেট দেখুন',
                ),
                count: '${items.length} ${tr('projects', 'প্রকল্প')}',
                icon: Icons.construction_rounded,
                color: AppColors.infoC(context),
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                EmptyStateCard(
                  icon: Icons.construction_outlined,
                  title: tr('No projects available', 'কোনো প্রকল্প নেই'),
                  message: tr(
                    'Upcoming development projects will appear here.',
                    'আসন্ন উন্নয়ন প্রকল্পগুলো এখানে দেখাবে।',
                  ),
                )
              else
                ...items.map(
                  (p) => ProjectCard(
                    item: p,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProjectDetailScreen(project: p),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key, required this.project});

  final DevelopmentProject project;

  Color _statusColor(BuildContext context) {
    switch (project.status.toLowerCase()) {
      case 'completed':
        return AppColors.successC(context);
      case 'in progress':
        return AppColors.infoC(context);
      case 'planning':
        return AppColors.secondary;
      case 'urgent':
        return AppColors.errorC(context);
      default:
        return AppColors.warningC(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = project.estimatedCost > 0
        ? (project.allocatedFunds / project.estimatedCost).clamp(0.0, 1.0)
        : 0.0;
    final statusColor = _statusColor(context);
    final pad = _pagePadding(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: _buildSidebarDrawer(
        context: context,
        selectedId: _MenuId.projects,
      ),
      body: _pageBackdrop(
        child: CustomScrollView(
          slivers: [
            // ── Sliver App Bar with gradient hero ──
            SliverAppBar(
              expandedHeight: project.photos.isNotEmpty ? 280 : 200,
              pinned: true,
              backgroundColor: AppColors.backgroundC(context),
              surfaceTintColor: Colors.transparent,
              foregroundColor: AppColors.textPrimaryC(context),
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: 'project-icon-${project.id}',
                  child: project.photos.isNotEmpty
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              project.photos.first,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _heroBanner(statusColor),
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.55),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : _heroBanner(statusColor),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(pad.left, 20, pad.right, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge
                    StatusBadge(text: project.status),
                    const SizedBox(height: 12),

                    // Title
                    Text(
                      project.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimaryC(context),
                        height: 1.3,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Progress section
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                tr('Budget Progress', 'বাজেটের অগ্রগতি'),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textTertiaryC(context),
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${(progress * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            child: SizedBox(
                              height: 10,
                              child: Stack(
                                children: [
                                  Container(color: AppColors.surfaceVariantC(context)),
                                  AnimatedFractionallySizedBox(
                                    duration: const Duration(milliseconds: 700),
                                    curve: Curves.easeOutCubic,
                                    widthFactor: progress,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [statusColor, statusColor.withValues(alpha: 0.7)],
                                        ),
                                        borderRadius: BorderRadius.circular(AppRadius.pill),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _FinanceStat(
                                  label: tr('Allocated', 'বরাদ্দ'),
                                  value: currency.format(project.allocatedFunds),
                                  color: statusColor,
                                ),
                              ),
                              Container(width: 1, height: 40, color: AppColors.borderC(context)),
                              Expanded(
                                child: _FinanceStat(
                                  label: tr('Estimated', 'আনুমানিক'),
                                  value: currency.format(project.estimatedCost),
                                  color: AppColors.textSecondaryC(context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Description
                    _SectionLabel(label: tr('About This Project', 'এই প্রকল্প সম্পর্কে')),
                    const SizedBox(height: 8),
                    AppCard(
                      child: Text(
                        project.description,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondaryC(context),
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Updates timeline
                    _SectionLabel(label: tr('Progress Updates', 'অগ্রগতি আপডেট')),
                    const SizedBox(height: 8),
                    if (project.updates.isEmpty)
                      EmptyStateCard(
                        icon: Icons.timeline_outlined,
                        title: tr('No updates yet', 'এখনও কোনো আপডেট নেই'),
                        message: tr(
                          'Progress updates will be added by project admins.',
                          'প্রকল্প অ্যাডমিনরা অগ্রগতির আপডেট যোগ করবেন।',
                        ),
                      )
                    else
                      ...project.updates.asMap().entries.map(
                        (e) => _TimelineItem(
                          index: e.key,
                          text: e.value,
                          isLast: e.key == project.updates.length - 1,
                          color: statusColor,
                        ),
                      ),

                    // Spending report
                    if (project.spendingReport.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _SectionLabel(label: tr('Spending Report', 'ব্যয়ের প্রতিবেদন')),
                      const SizedBox(height: 8),
                      AppCard(
                        child: Column(
                          children: project.spendingReport.asMap().entries.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.only(top: 6, right: 10),
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      e.value,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondaryC(context),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroBanner(Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.06)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.construction_rounded, color: color, size: 42),
        ),
      ),
    );
  }
}

class _FinanceStat extends StatelessWidget {
  const _FinanceStat({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textTertiaryC(context))),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.index,
    required this.text,
    required this.isLast,
    required this.color,
  });
  final int index;
  final String text;
  final bool isLast;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
                shape: BoxShape.circle,
                boxShadow: AppShadows.colorGlow(color, 0.3),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: AppColors.onGradient, fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: color.withValues(alpha: 0.2),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 12),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryC(context),
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

