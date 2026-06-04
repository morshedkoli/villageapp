import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/motion.dart';
import '../../core/providers/providers.dart';
import '../../data_service.dart';
import '../../models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Root screen — switches between gate and profile
// ─────────────────────────────────────────────────────────────────────────────

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(isAuthenticatedProvider);
    final firebaseUser = ref.watch(currentFirebaseUserProvider).asData?.value;

    return authAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const _LoginGate(),
      data: (isAuthenticated) =>
          isAuthenticated ? _ProfileBody(firebaseUser: firebaseUser) : const _LoginGate(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NOT-LOGGED-IN GATE  — immersive, premium-feel CTA
// ─────────────────────────────────────────────────────────────────────────────

class _LoginGate extends StatefulWidget {
  const _LoginGate();

  @override
  State<_LoginGate> createState() => _LoginGateState();
}

class _LoginGateState extends State<_LoginGate> {
  bool _loading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      await DataService.instance.signInWithGoogle();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('লগইন ব্যর্থ: ${e.toString()}'),
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Gradient background ──────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [AppColors.darkCanvas, AppColors.darkSurface, AppColors.darkCanvas]
                    : [AppColors.primaryContainer, Colors.white, Colors.white],
                stops: const [0, 0.45, 1],
              ),
            ),
          ),

          // ── Decorative circles ────────────────────────────────────
          Positioned(
            top: -60,
            right: -60,
            child: _GlowCircle(size: 220, color: AppColors.primary, opacity: isDark ? 0.08 : 0.12),
          ),
          Positioned(
            top: 80,
            left: -40,
            child: _GlowCircle(size: 140, color: AppColors.primaryLight, opacity: isDark ? 0.06 : 0.10),
          ),

          // ── Content ───────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.08),

                  // Village icon
                  FadeSlideIn(
                    delay: 0,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primaryLight, AppColors.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.xxl),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.holiday_village_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  AppSpacing.hXxl,

                  // Headline
                  FadeSlideIn(
                    delay: 80,
                    child: Text(
                      'গ্রামবাসীতে স্বাগতম',
                      style: context.textTheme.headlineSmall?.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  AppSpacing.hSm,
                  FadeSlideIn(
                    delay: 130,
                    child: Text(
                      'আপনার প্রোফাইল দেখতে, সমস্যা রিপোর্ট করতে এবং গ্রামের উন্নয়নে অংশ নিতে লগইন করুন।',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.textSecondary,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  AppSpacing.hHuge,

                  // Feature chips
                  FadeSlideIn(
                    delay: 180,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: const [
                        _FeatureChip(icon: Icons.volunteer_activism_outlined, label: 'অনুদান ট্র্যাক'),
                        _FeatureChip(icon: Icons.report_outlined, label: 'সমস্যা রিপোর্ট'),
                        _FeatureChip(icon: Icons.people_alt_outlined, label: 'নাগরিক যোগাযোগ'),
                        _FeatureChip(icon: Icons.emoji_events_outlined, label: 'অর্জন দেখুন'),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Google sign-in button
                  FadeSlideIn(
                    delay: 250,
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _signInWithGoogle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
                          foregroundColor: context.textPrimary,
                          elevation: 0,
                          side: BorderSide(color: context.border, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                          ),
                        ),
                        child: _loading
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.primary,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                                    height: 22,
                                    errorBuilder: (_, _, _) =>
                                        const Icon(Icons.g_mobiledata, size: 26, color: AppColors.primary),
                                  ),
                                  AppSpacing.wMd,
                                  Text(
                                    'গুগল দিয়ে লগইন করুন',
                                    style: context.textTheme.labelLarge?.copyWith(
                                      color: context.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  AppSpacing.hMd,

                  // Full login page
                  FadeSlideIn(
                    delay: 300,
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _loading ? null : () => context.push('/login'),
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                          ),
                        ),
                        child: const Text(
                          'লগইন পেজে যান',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.hXxl,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AUTHENTICATED PROFILE BODY
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileBody extends ConsumerWidget {
  final dynamic firebaseUser;
  const _ProfileBody({this.firebaseUser});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider).asData?.value;
    final myDonations = ref.watch(myDonationsProvider).asData?.value ?? const <Donation>[];
    final myProblems = ref.watch(myProblemsProvider).asData?.value ?? const <ProblemReport>[];

    final name = (firebaseUser?.displayName as String?)?.isNotEmpty == true
        ? firebaseUser!.displayName as String
        : (profile?['name'] as String?) ?? 'ব্যবহারকারী';
    final email = (firebaseUser?.email as String?) ??
        (profile?['email'] as String?) ??
        '';
    final photoUrl = (firebaseUser?.photoURL as String?) ??
        (profile?['photoUrl'] as String?) ??
        '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final totalDonated = myDonations.fold<double>(0, (sum, item) => sum + item.amount);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Collapsible header ─────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            backgroundColor: context.isDark ? AppColors.darkSurface : Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
              background: _ProfileHeroBanner(
                name: name,
                email: email,
                photoUrl: photoUrl,
                initial: initial,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'প্রোফাইল সম্পাদনা',
                onPressed: () {},
              ),
            ],
          ),

          // ── Body content ───────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FadeSlideIn(delay: 0, child: _SectionLabel('পরিসংখ্যান')),
                AppSpacing.hMd,
                FadeSlideIn(
                  delay: 60,
                  child: _StatsRow(
                    totalDonated: totalDonated,
                    totalDonations: myDonations.length,
                    reportedProblems: myProblems.length,
                    village: (profile?['village'] as String?) ?? '',
                  ),
                ),

                AppSpacing.hXxl,

                FadeSlideIn(delay: 120, child: _SectionLabel('দ্রুত অ্যাকশন')),
                AppSpacing.hMd,
                FadeSlideIn(delay: 160, child: const _ActionMenu()),

                AppSpacing.hXxxl,
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO BANNER (SliverAppBar background)
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileHeroBanner extends StatelessWidget {
  final String name;
  final String email;
  final String photoUrl;
  final String initial;

  const _ProfileHeroBanner({
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.initial,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [AppColors.darkCard, AppColors.darkSurface]
                  : [AppColors.primaryContainer, Colors.white],
            ),
          ),
        ),

        // Decorative arc
        Positioned.fill(
          child: CustomPaint(painter: _ArcPainter(isDark: isDark)),
        ),

        // Avatar + info centred
        Center(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xxxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar with ring
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.primaryLight, AppColors.primaryDark],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(3),
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor:
                          isDark ? AppColors.darkCard : Colors.white,
                      foregroundImage:
                          photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                      child: photoUrl.isEmpty
                          ? Text(
                              initial,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                    ),
                  ),
                  AppSpacing.hMd,
                  Text(
                    name,
                    style: context.textTheme.titleLarge?.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  AppSpacing.hXs,
                  Text(
                    email,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  AppSpacing.hMd,
                  // Verified badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded,
                            size: 14, color: AppColors.primary),
                        AppSpacing.wXs,
                        Text(
                          'সক্রিয় সদস্য',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// decorative wavy arc behind the hero
class _ArcPainter extends CustomPainter {
  final bool isDark;
  _ArcPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: isDark ? 0.07 : 0.10)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, size.height * 0.55)
      ..quadraticBezierTo(
          size.width * 0.5, size.height * 0.35, size.width, size.height * 0.55)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
// STAT CARDS ROW
// ─────────────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final double totalDonated;
  final int totalDonations;
  final int reportedProblems;
  final String village;

  const _StatsRow({
    required this.totalDonated,
    required this.totalDonations,
    required this.reportedProblems,
    required this.village,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem('মোট দান', '৳ ${totalDonated.toStringAsFixed(0)}', Icons.volunteer_activism_outlined, AppColors.success),
      _StatItem('দান সংখ্যা', '$totalDonations টি', Icons.receipt_long_outlined, AppColors.info),
      _StatItem('রিপোর্ট', '$reportedProblems টি', Icons.report_outlined, AppColors.warning),
      _StatItem('গ্রাম', village.isNotEmpty ? village : 'উল্লেখ নেই', Icons.location_on_outlined, AppColors.primary),
    ];

    return Row(
      children: items
          .map((item) => Expanded(child: _StatCard(item: item)))
          .toList(),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  _StatItem(this.label, this.value, this.icon, this.color);
}

class _StatCard extends StatelessWidget {
  final _StatItem item;
  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md, horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.border),
        boxShadow: [
          BoxShadow(
              color: context.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(item.icon, size: 18, color: item.color),
          ),
          AppSpacing.hSm,
          Text(
            item.value,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          AppSpacing.hXs,
          Text(
            item.label,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.textTertiary,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUICK-ACTION MENU
// ─────────────────────────────────────────────────────────────────────────────

class _ActionMenu extends ConsumerWidget {
  const _ActionMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiles = [
      _TileData(Icons.volunteer_activism_outlined, 'আমার দান', AppColors.success, () => context.push('/all-donations')),
      _TileData(Icons.report_outlined, 'আমার রিপোর্ট', AppColors.warning, () => context.push('/problems')),
      _TileData(Icons.construction_outlined, 'সব প্রকল্প', AppColors.info, () => context.push('/projects')),
      _TileData(Icons.settings_outlined, 'সেটিংস', context.textSecondary, () => context.push('/settings')),
      _TileData(Icons.logout_rounded, 'লগআউট', AppColors.error, () => _confirmSignOut(context, ref)),
    ];

    return Column(
      children: tiles.indexed
          .map((entry) => Padding(
                padding: EdgeInsets.only(bottom: entry.$1 < tiles.length - 1 ? AppSpacing.sm : 0),
                child: _ActionTile(data: entry.$2),
              ))
          .toList(),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: const Text('লগআউট'),
        content: const Text('আপনি কি সত্যিই লগআউট করতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await DataService.instance.signOut();
            },
            child: const Text('লগআউট'),
          ),
        ],
      ),
    );
  }
}

class _TileData {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _TileData(this.icon, this.label, this.color, this.onTap);
}

class _ActionTile extends StatelessWidget {
  final _TileData data;
  const _ActionTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final isDestructive = data.color == AppColors.error;
    return GlassCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
      onTap: data.onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: isDestructive ? 0.08 : 0.10),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(data.icon, size: 22, color: data.color),
          ),
          AppSpacing.wMd,
          Expanded(
            child: Text(
              data.label,
              style: context.textTheme.bodyMedium?.copyWith(
                color: isDestructive ? AppColors.error : context.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              size: 20,
              color: isDestructive ? AppColors.error.withValues(alpha: 0.5) : context.textTertiary),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        AppSpacing.wSm,
        Text(
          text,
          style: context.textTheme.titleSmall?.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.isDark
            ? AppColors.darkCard
            : AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          AppSpacing.wXs,
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  const _GlowCircle(
      {required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [
          color.withValues(alpha: opacity),
          color.withValues(alpha: 0),
        ]),
      ),
    );
  }
}
