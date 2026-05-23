part of '../screens.dart';


class ProblemsScreen extends StatefulWidget {
  const ProblemsScreen({super.key});

  @override
  State<ProblemsScreen> createState() => _ProblemsScreenState();
}

class _ProblemsScreenState extends State<ProblemsScreen> {
  String _filter = 'All';
  String _sortBy = 'date'; // 'date' or 'votes'

  PopupMenuItem<String> _buildFilterItem(String value, String label) {
    final isSelected = _filter == value;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
            size: 18,
            color: isSelected ? AppColors.primaryC(context) : AppColors.textTertiaryC(context),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.textPrimaryC(context) : AppColors.textSecondaryC(context),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pad = _pagePadding(context);
    return StreamBuilder<List<ProblemReport>>(
      stream: DataService.instance.problems(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const ProblemsSkeleton();
        }
        // Problems are already filtered by query (Approved/Completed only)
        final all = snap.data ?? const <ProblemReport>[];
        var list = _filter == 'All'
            ? all
            : all
                  .where((e) => e.status.toLowerCase() == _filter.toLowerCase())
                  .toList();
        // Apply sorting
        if (_sortBy == 'votes') {
          list = List.of(list)
            ..sort((a, b) => b.voteScore.compareTo(a.voteScore));
        }
        return ListView(
          padding: EdgeInsets.only(bottom: 100),
          children: [
            _AppHeader(
              showMenuButton: !_useDesktopSidebar(context),
              actions: [
                _HeaderActionButton(
                  icon: Icons.add_rounded,
                  onTap: () async {
                    final ok = await _ensureLogin(context);
                    if (!context.mounted || !ok) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ReportProblemScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad.left),
              child: _PageBanner(
                title: tr('Community Problems', 'কমিউনিটির সমস্যা'),
                subtitle: tr(
                  'Filter and review reported issues',
                  'রিপোর্ট করা সমস্যাগুলো ফিল্টার করে দেখুন',
                ),
                count: '${all.length} ${tr('reports', 'রিপোর্ট')}',
                icon: Icons.warning_amber_rounded,
                color: AppColors.errorC(context),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad.left),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariantC(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: PopupMenuButton<String>(
                        onSelected: (v) => setState(() => _filter = v),
                        offset: const Offset(0, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        itemBuilder: (_) => [
                          _buildFilterItem('All', tr('All Reports', 'সব রিপোর্ট')),
                          _buildFilterItem('Pending', tr('Pending', 'অপেক্ষমাণ')),
                          _buildFilterItem('Approved', tr('Approved', 'অনুমোদিত')),
                          _buildFilterItem('Completed', tr('Completed', 'সম্পন্ন')),
                        ],
                        child: SizedBox(
                          height: 40,
                          child: Row(
                            children: [
                              Icon(Icons.filter_list_rounded, size: 18, color: AppColors.primaryC(context)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _filter == 'All' ? tr('All Reports', 'সব রিপোর্ট') :
                                  _filter == 'Pending' ? tr('Pending', 'অপেক্ষমাণ') :
                                  _filter == 'Approved' ? tr('Approved', 'অনুমোদিত') :
                                  tr('Completed', 'সম্পন্ন'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimaryC(context),
                                  ),
                                ),
                              ),
                              Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textTertiaryC(context)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariantC(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: PopupMenuButton<String>(
                      icon: Icon(
                        _sortBy == 'votes'
                            ? Icons.how_to_vote_rounded
                            : Icons.schedule_rounded,
                        color: const Color(0xFF007AFF),
                      ),
                      tooltip: tr('Sort by', 'সাজান'),
                      onSelected: (v) => setState(() => _sortBy = v),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'date',
                          child: Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 18,
                                color: _sortBy == 'date'
                                    ? const Color(0xFF007AFF)
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Text(tr('Newest First', 'নতুন আগে')),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'votes',
                          child: Row(
                            children: [
                              Icon(
                                Icons.how_to_vote_rounded,
                                size: 18,
                                color: _sortBy == 'votes'
                                    ? const Color(0xFF007AFF)
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Text(tr('Most Voted', 'সর্বাধিক ভোট')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad.left),
              child: Column(
                children: [
                  if (list.isEmpty)
                    EmptyStateCard(
                      icon: Icons.filter_alt_off_outlined,
                      title: tr('No matching problems', 'মিলছে এমন সমস্যা নেই'),
                      message: tr(
                        'Try another filter or check again later.',
                        'অন্য ফিল্টার চেষ্টা করুন বা পরে আবার দেখুন।',
                      ),
                    )
                  else
                    ...list.map((e) => ProblemViewCard(item: e)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class ProblemViewCard extends StatelessWidget {
  const ProblemViewCard({super.key, required this.item, this.compact = false});

  final ProblemReport item;
  final bool compact;

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProblemDetailScreen(problem: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProblemCard(
      item: item,
      compact: compact,
      onTap: () => _openDetail(context),
      voteBar: compact ? null : _ProblemVoteBar(item: item),
    );
  }
}

// ─── Problem Detail Screen ──────────────────────────────────────────────────

class ProblemDetailScreen extends StatelessWidget {
  const ProblemDetailScreen({super.key, required this.problem});

  final ProblemReport problem;

  Color _statusColor(BuildContext context) {
    switch (problem.status.toLowerCase()) {
      case 'approved':
        return AppColors.successC(context);
      case 'completed':
        return AppColors.infoC(context);
      case 'pending':
        return AppColors.warningC(context);
      default:
        return AppColors.textSecondaryC(context);
    }
  }

  IconData _statusIcon() {
    switch (problem.status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle_rounded;
      case 'completed':
        return Icons.task_alt_rounded;
      case 'pending':
        return Icons.hourglass_empty_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(context);
    final pad = _pagePadding(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: _buildSidebarDrawer(context: context, selectedId: _MenuId.problems),
      body: _pageBackdrop(
        child: CustomScrollView(
          slivers: [
            // ── Sliver App Bar with hero image ──
            SliverAppBar(
              expandedHeight: problem.photoUrl.isNotEmpty ? 280 : 180,
              pinned: true,
              backgroundColor: AppColors.backgroundC(context),
              surfaceTintColor: Colors.transparent,
              foregroundColor: AppColors.textPrimaryC(context),
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: 'problem-image-${problem.id}',
                  child: problem.photoUrl.isNotEmpty
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              problem.photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _heroBanner(statusColor),
                            ),
                            // gradient overlay
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.5),
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

            // ── Body content ──
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(pad.left, 20, pad.right, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status + title row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_statusIcon(), size: 13, color: statusColor),
                              const SizedBox(width: 5),
                              Text(
                                problem.status,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Title
                    Text(
                      problem.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimaryC(context),
                        height: 1.3,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Meta chips row
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetaChip(
                          icon: Icons.location_on_rounded,
                          label: problem.location,
                          color: AppColors.errorC(context),
                        ),
                        _MetaChip(
                          icon: Icons.person_rounded,
                          label: problem.reportedBy,
                          color: AppColors.primaryC(context),
                        ),
                        _MetaChip(
                          icon: Icons.calendar_today_rounded,
                          label: shortDate.format(problem.createdAt),
                          color: AppColors.textSecondaryC(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Vote summary bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariantC(context),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _VoteStat(
                            icon: Icons.thumb_up_rounded,
                            count: problem.upvotes,
                            color: AppColors.successC(context),
                            label: tr('Yes', 'হ্যাঁ'),
                          ),
                          Container(width: 1, height: 36, color: AppColors.borderC(context)),
                          _VoteStat(
                            icon: Icons.thumb_down_rounded,
                            count: problem.downvotes,
                            color: AppColors.errorC(context),
                            label: tr('No', 'না'),
                          ),
                          Container(width: 1, height: 36, color: AppColors.borderC(context)),
                          _VoteStat(
                            icon: Icons.how_to_vote_rounded,
                            count: problem.voteScore,
                            color: problem.voteScore >= 0 ? AppColors.successC(context) : AppColors.errorC(context),
                            label: tr('Score', 'স্কোর'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Description section
                    _SectionLabel(label: tr('Description', 'বিবরণ')),
                    const SizedBox(height: 8),
                    AppCard(
                      child: Text(
                        problem.description,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondaryC(context),
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Voting section
                    _SectionLabel(label: tr('Cast your vote', 'আপনার ভোট দিন')),
                    const SizedBox(height: 8),
                    _ProblemVoteBar(item: problem),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning_amber_rounded, color: color, size: 38),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

class _VoteStat extends StatelessWidget {
  const _VoteStat({
    required this.icon,
    required this.count,
    required this.color,
    required this.label,
  });
  final IconData icon;
  final int count;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 5),
            Text(
              '$count',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textTertiaryC(context))),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textTertiaryC(context),
        letterSpacing: 0.5,
      ),
    );
  }
}



/// Voting bar for problem reports with upvote/downvote buttons.
class _ProblemVoteBar extends StatefulWidget {
  const _ProblemVoteBar({required this.item});

  final ProblemReport item;

  @override
  State<_ProblemVoteBar> createState() => _ProblemVoteBarState();
}

class _ProblemVoteBarState extends State<_ProblemVoteBar> {
  bool _voting = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int?>(
      stream: DataService.instance.myVoteOnProblem(widget.item.id),
      builder: (context, voteSnap) {
        final myVote = voteSnap.data;
        final hasUpvoted = myVote == 1;
        final hasDownvoted = myVote == -1;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariantC(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _VoteButton(
                      icon: Icons.thumb_up_rounded,
                      label: tr('Yes', 'হ্যাঁ'),
                      count: widget.item.upvotes,
                      isActive: hasUpvoted,
                      activeColor: AppColors.successC(context),
                      isLoading: _voting,
                      onTap: () => _vote(1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _VoteButton(
                      icon: Icons.thumb_down_rounded,
                      label: tr('No', 'না'),
                      count: widget.item.downvotes,
                      isActive: hasDownvoted,
                      activeColor: AppColors.errorC(context),
                      isLoading: _voting,
                      onTap: () => _vote(-1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              VoteBar(
                upvotes: widget.item.upvotes,
                downvotes: widget.item.downvotes,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _vote(int vote) async {
    if (_voting) return;

    final ok = await _ensureLogin(context);
    if (!ok || !mounted) return;

    setState(() => _voting = true);

    try {
      await DataService.instance.voteOnProblem(widget.item.id, vote);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('Failed to vote: $e', 'ভোট দিতে ব্যর্থ: $e')),
            backgroundColor: AppColors.errorC(context),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _voting = false);
      }
    }
  }
}

class _VoteButton extends StatelessWidget {
  const _VoteButton({
    required this.icon,
    required this.label,
    required this.count,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final String label;
  final int count;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(activeColor),
                  ),
                )
              else
                Icon(
                  icon,
                  size: 20,
                  color: isActive ? activeColor : const Color(0xFF8E8E93),
                ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isActive ? activeColor : AppColors.textSecondaryC(context),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isActive ? activeColor : const Color(0xFF8E8E93),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  File? _photo;
  bool _submitting = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: _buildSidebarDrawer(
        context: context,
        selectedId: _MenuId.problems,
      ),
      appBar: AppBar(
        title: Text(tr('Report a Problem', 'সমস্যা রিপোর্ট করুন')),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: _pageBackdrop(
        child: _constrainBodyWidth(
          context,
          ListView(
            padding: _pagePadding(
              context,
            ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 20),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.errorGradient,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.errorC(context).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.report_problem_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  tr('Report an Issue', 'একটি সমস্যা রিপোর্ট করুন'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryC(context),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  tr(
                    'Help improve your community',
                    'আপনার কমিউনিটি উন্নত করতে সাহায্য করুন',
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryC(context),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AppCard(
                child: Form(
                  key: _form,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      PremiumTextField(
                        controller: _title,
                        labelText: tr('Title', 'শিরোনাম'),
                        hintText: tr('What is the issue?', 'সমস্যাটি কী?'),
                        prefixIcon: Icons.title_rounded,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? tr('Required', 'প্রয়োজনীয়')
                            : null,
                      ),
                      const SizedBox(height: 14),
                      PremiumTextField(
                        controller: _description,
                        labelText: tr('Description', 'বিবরণ'),
                        hintText: tr(
                          'Describe the problem in a few lines',
                          'সমস্যাটি সংক্ষেপে লিখুন',
                        ),
                        prefixIcon: Icons.description_outlined,
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? tr('Required', 'প্রয়োজনীয়')
                            : null,
                      ),
                      const SizedBox(height: 14),
                      PremiumTextField(
                        controller: _location,
                        labelText: tr('Location', 'অবস্থান'),
                        hintText: tr(
                          'Road, area, or landmark',
                          'রাস্তা, এলাকা, বা চিহ্নিত স্থান',
                        ),
                        prefixIcon: Icons.location_on_outlined,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? tr('Required', 'প্রয়োজনীয়')
                            : null,
                      ),
                      const SizedBox(height: 14),
                      if (_photo != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              Image.file(
                                _photo!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Row(
                                  children: [
                                    _photoActionButton(
                                      icon: Icons.edit_outlined,
                                      onTap: _pickPhoto,
                                    ),
                                    const SizedBox(width: 8),
                                    _photoActionButton(
                                      icon: Icons.close_rounded,
                                      onTap: () =>
                                          setState(() => _photo = null),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _pickPhoto,
                            icon: const Icon(Icons.add_a_photo_outlined),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            label: Text(tr('Upload Photo', 'ছবি আপলোড করুন')),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          tr(
                            'Adding a clear photo helps faster verification.',
                            'স্পষ্ট ছবি দিলে দ্রুত যাচাই করা যায়।',
                          ),
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        isLoading: _submitting,
                        onPressed: _submitting ? null : _submit,
                        label: _submitting
                            ? tr('Submitting...', 'জমা দেওয়া হচ্ছে...')
                            : tr(
                                'Submit Problem Report',
                                'সমস্যা রিপোর্ট জমা দিন',
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final img = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1920,
      maxHeight: 1920,
    );
    if (img == null) return;
    setState(() => _photo = File(img.path));
  }

  Widget _photoActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      await DataService.instance.reportProblem(
        title: _title.text.trim(),
        description: _description.text.trim(),
        location: _location.text.trim(),
        photo: _photo,
      );
      if (!mounted) return;

      // Clear form after successful submission
      _title.clear();
      _description.clear();
      _location.clear();
      setState(() => _photo = null);

      final offlineQueued = !ConnectivityService.instance.isOnline;
      if (offlineQueued) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tr('Report saved offline', 'রিপোর্ট অফলাইনে সংরক্ষিত'),
            ),
            backgroundColor: const Color(0xFF8E8E93),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tr(
                'Problem reported successfully',
                'সমস্যা সফলভাবে রিপোর্ট করা হয়েছে',
              ),
            ),
          ),
        );
      }
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      // Provide user-friendly error messages
      String errorMessage;
      final errorStr = e.toString();

      if (errorStr.contains('Login required')) {
        errorMessage = tr(
          'Please login to report problems',
          'সমস্যা রিপোর্ট করতে লগইন করুন',
        );
      } else if (errorStr.contains('Image upload is not configured')) {
        errorMessage = tr(
          'Photo upload unavailable. Try without photo',
          'ফটো আপলোড উপলব্ধ নয়। ফটো ছাড়া চেষ্টা করুন',
        );
      } else if (errorStr.contains('Image size too large')) {
        errorMessage = tr(
          'Image too large. Select smaller image',
          'ছবি অনেক বড়। ছোট ছবি নির্বাচন করুন',
        );
      } else if (errorStr.contains('Cannot attach photos while offline')) {
        errorMessage = tr(
          'Cannot attach photos offline',
          'অফলাইনে ফটো সংযুক্ত করা যাবে না',
        );
      } else if (errorStr.contains('Image upload failed')) {
        errorMessage = tr(
          'Photo upload failed. Try again',
          'ফটো আপলোড ব্যর্থ। আবার চেষ্টা করুন',
        );
      } else {
        errorMessage = '${tr('Error', 'ত্রুটি')}: $errorStr';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.errorC(context),
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
