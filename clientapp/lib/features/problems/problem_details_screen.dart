import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/timeline_item.dart';
import '../../core/widgets/avatar_widget.dart';
import '../../core/widgets/motion.dart';

class ProblemDetailsScreen extends ConsumerStatefulWidget {
  final String problemId;

  const ProblemDetailsScreen({super.key, required this.problemId});

  @override
  ConsumerState<ProblemDetailsScreen> createState() => _ProblemDetailsScreenState();
}

class _ProblemDetailsScreenState extends ConsumerState<ProblemDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  int _voteCount = 24;
  bool _hasUpvoted = false;
  bool _hasDownvoted = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final problem = _sampleProblem;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.xxxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeSlideIn(delay: 0, child: _buildAppBar(problem.title)),
              AppSpacing.hLg,
              FadeSlideIn(delay: 80, child: _buildHeroImage()),
              AppSpacing.hXxl,
              FadeSlideIn(delay: 120, child: _buildProblemInfo(problem)),
              AppSpacing.hXxl,
              FadeSlideIn(delay: 160, child: _buildStatusTimeline()),
              AppSpacing.hXxl,
              FadeSlideIn(delay: 200, child: _buildVotingSection()),
              AppSpacing.hXxl,
              FadeSlideIn(delay: 240, child: _buildCommentsSection()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(String title) {
    return Row(
      children: [
        PressScale(
          scale: 0.92,
          onTap: () => context.pop(),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.card,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 22),
          ),
        ),
        AppSpacing.wMd,
        Expanded(
          child: Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withValues(alpha: 0.3),
            AppColors.error.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Icon(
            Icons.report_problem_rounded,
            size: 36,
            color: AppColors.warning,
          ),
        ),
      ),
    );
  }

  Widget _buildProblemInfo(_ProblemData problem) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  problem.title,
                  style: context.textTheme.headlineSmall?.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              AppSpacing.wSm,
              StatusBadge.fromString(problem.status, fontSize: 10),
            ],
          ),
          AppSpacing.hLg,
          Text(
            problem.description,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.textSecondary,
              height: 1.6,
            ),
          ),
          AppSpacing.hLg,
          Row(
            children: [
              StatusBadge(status: BadgeStatus.info, fontSize: 10),
              AppSpacing.wSm,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  problem.category,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.hLg,
          const Divider(),
          AppSpacing.hSm,
          Row(
            children: [
              AvatarWidget(initials: problem.reporter[0], size: 32),
              AppSpacing.wSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      problem.reporter,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      problem.date,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'স্থিতি কালক্রম',
              style: context.textTheme.titleSmall?.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          AppSpacing.hSm,
          TimelineItem(
            title: 'রিপোর্ট জমা দেওয়া হয়েছে',
            description: 'প্রতিবেদক সমস্যাটি রিপোর্ট করেছেন',
            icon: Icons.assignment_outlined,
            iconColor: AppColors.success,
            isCompleted: true,
            timestamp: DateTime.now().subtract(const Duration(days: 5)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Divider(),
          ),
          TimelineItem(
            title: 'পর্যালোচনা চলছে',
            description: 'কমিটি সমস্যাটি পর্যালোচনা করছে',
            icon: Icons.rate_review_outlined,
            iconColor: AppColors.info,
            isCompleted: true,
            timestamp: DateTime.now().subtract(const Duration(days: 3)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Divider(),
          ),
          TimelineItem(
            title: 'প্রক্রিয়াধীন',
            description: 'সমস্যা সমাধানের কাজ শুরু হয়েছে',
            icon: Icons.sync_outlined,
            iconColor: AppColors.warning,
            isCompleted: true,
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Divider(),
          ),
          TimelineItem(
            title: 'সমাধানকৃত',
            description: 'সমস্যার সমাধান সম্পন্ন',
            icon: Icons.verified_outlined,
            iconColor: AppColors.textTertiary,
            isCompleted: false,
            timestamp: null,
          ),
        ],
      ),
    );
  }

  Widget _buildVotingSection() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ভোট',
                style: context.textTheme.titleSmall?.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$_voteCount ভোট',
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          AppSpacing.hXxl,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PressScale(
                scale: 0.92,
                onTap: _handleUpvote,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _hasUpvoted
                        ? AppColors.success.withValues(alpha: 0.12)
                        : (context.isDark ? AppColors.darkBorder : AppColors.lightBackground),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: _hasUpvoted
                          ? AppColors.success.withValues(alpha: 0.3)
                          : Colors.transparent,
                    ),
                  ),
                  child: Icon(
                    Icons.thumb_up_rounded,
                    color: _hasUpvoted ? AppColors.success : context.textTertiary,
                    size: 24,
                  ),
                ),
              ),
              AppSpacing.wXxl,
              Column(
                children: [
                  Text(
                    '$_voteCount',
                    style: GoogleFonts.notoSansBengali(
                      textStyle: context.textTheme.headlineMedium?.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    'ভোট দিন',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              AppSpacing.wXxl,
              PressScale(
                scale: 0.92,
                onTap: _handleDownvote,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _hasDownvoted
                        ? AppColors.error.withValues(alpha: 0.12)
                        : (context.isDark ? AppColors.darkBorder : AppColors.lightBackground),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: _hasDownvoted
                          ? AppColors.error.withValues(alpha: 0.3)
                          : Colors.transparent,
                    ),
                  ),
                  child: Icon(
                    Icons.thumb_down_rounded,
                    color: _hasDownvoted ? AppColors.error : context.textTertiary,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleUpvote() {
    setState(() {
      if (_hasUpvoted) {
        _voteCount--;
        _hasUpvoted = false;
      } else {
        if (_hasDownvoted) {
          _voteCount++;
          _hasDownvoted = false;
        }
        _voteCount++;
        _hasUpvoted = true;
      }
    });
  }

  void _handleDownvote() {
    setState(() {
      if (_hasDownvoted) {
        _voteCount++;
        _hasDownvoted = false;
      } else {
        if (_hasUpvoted) {
          _voteCount--;
          _hasUpvoted = false;
        }
        _voteCount--;
        _hasDownvoted = true;
      }
    });
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'মন্তব্য',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        AppSpacing.hMd,
        GlassCard(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            children: _comments.map((c) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AvatarWidget(initials: c.name[0], size: 32),
                        AppSpacing.wSm,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    c.name,
                                    style: context.textTheme.labelMedium?.copyWith(
                                      color: context.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    c.time,
                                    style: context.textTheme.labelSmall?.copyWith(
                                      color: context.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                              AppSpacing.hXs,
                              Text(
                                c.text,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (c != _comments.last)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Divider(),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
        AppSpacing.hLg,
        Container(
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'মন্তব্য লিখুন...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.lg,
                    ),
                  ),
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.textPrimary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: PressScale(
                  scale: 0.92,
                  onTap: () {
                    if (_commentController.text.isNotEmpty) {
                      _commentController.clear();
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProblemData {
  final String title;
  final String description;
  final String status;
  final String category;
  final String reporter;
  final String date;
  const _ProblemData({
    required this.title,
    required this.description,
    required this.status,
    required this.category,
    required this.reporter,
    required this.date,
  });
}

class _Comment {
  final String name;
  final String text;
  final String time;
  const _Comment({
    required this.name,
    required this.text,
    required this.time,
  });
}

const _sampleProblem = _ProblemData(
  title: 'প্রধান সড়কের রাস্তা ভেঙে গেছে',
  description:
      'গ্রামের প্রধান সড়কের বেশ কিছু অংশ ভেঙে গেছে যা যানবাহন চলাচলের জন্য অত্যন্ত ঝুঁকিপূর্ণ। '
      'বিশেষ করে বর্ষা মৌসুমে এই রাস্তা দিয়ে চলাচল করা প্রায় অসম্ভব হয়ে পড়ে। '
      'স্থানীয় বাসিন্দাদের দীর্ঘদিনের দাবি এই রাস্তাটি দ্রুত মেরামতের। '
      'অনুগ্রহ করে দ্রুত পদক্ষেপ নিন।',
  status: 'প্রক্রিয়াধীন',
  category: 'রাস্তা',
  reporter: 'রহিম সাহেব',
  date: '৩ জুন, ২০২৬',
);

const _comments = [
  _Comment(
    name: 'করিম সাহেব',
    text: 'আমিও এই সমস্যাটি সমর্থন করি। রাস্তাটি真的 খুব খারাপ অবস্থায় আছে।',
    time: '২ ঘণ্টা আগে',
  ),
  _Comment(
    name: 'নাসরিন বেগম',
    text: 'গত সপ্তাহে আমার গাড়ির চাকা নষ্ট হয়ে গেছে এই রাস্তার কারণে। দ্রুত মেরামত প্রয়োজন।',
    time: '৫ ঘণ্টা আগে',
  ),
  _Comment(
    name: 'হাসান আলী',
    text: 'আমি ইউনিয়ন পরিষদে কথা বলেছি। তারা শিগগিরই কাজ শুরু করবে বলে জানিয়েছে।',
    time: '১ দিন আগে',
  ),
];
