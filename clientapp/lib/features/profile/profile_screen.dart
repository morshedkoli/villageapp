import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/motion.dart';
import '../../core/widgets/loading_shimmer.dart';
import '../../core/providers/providers.dart';
import '../../models.dart';
import 'widgets/edit_profile_sheet.dart';
import 'widgets/login_gate.dart';
import 'widgets/profile_action_menu.dart';
import 'widgets/profile_hero_banner.dart';
import 'widgets/profile_stats.dart';

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
      loading: () => Scaffold(
        backgroundColor: context.canvas,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: const [
                CardSkeleton(height: 180),
                SizedBox(height: AppSpacing.lg),
                Expanded(child: ListSkeleton(itemCount: 5)),
              ],
            ),
          ),
        ),
      ),
      error: (_, __) => const LoginGate(),
      data: (isAuthenticated) =>
          isAuthenticated ? _ProfileBody(firebaseUser: firebaseUser) : const LoginGate(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NOT-LOGGED-IN GATE  — immersive, premium-feel CTA
// ─────────────────────────────────────────────────────────────────────────────

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
              background: ProfileHeroBanner(
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
                onPressed: () => showEditProfileSheet(
                  context,
                  ref,
                  profile,
                  firebaseUser as User?,
                ),
              ),
            ],
          ),

          // ── Body content ───────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FadeSlideIn(delay: 0, child: SectionLabel('পরিসংখ্যান')),
                AppSpacing.hMd,
                FadeSlideIn(
                  delay: 60,
                  child: StatsRow(
                    totalDonated: totalDonated,
                    totalDonations: myDonations.length,
                    reportedProblems: myProblems.length,
                    village: (profile?['village'] as String?) ?? '',
                  ),
                ),

                AppSpacing.hXxl,

                FadeSlideIn(delay: 120, child: SectionLabel('দ্রুত অ্যাকশন')),
                AppSpacing.hMd,
                FadeSlideIn(delay: 160, child: const ActionMenu()),

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

// ─────────────────────────────────────────────────────────────────────────────
// STAT CARDS ROW
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// QUICK-ACTION MENU
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────


