import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/home/all_donations_screen.dart';
import '../../features/home/all_expenses_screen.dart';
import '../../features/donation/donation_screen.dart';
import '../../features/donation/donation_checkout_screen.dart';
import '../../features/problems/problems_screen.dart';
import '../../features/problems/problem_details_screen.dart';
import '../../features/problems/report_problem_screen.dart';
import '../../features/citizens/citizen_directory_screen.dart';
import '../../features/citizens/citizen_profile_screen.dart';
import '../../features/projects/projects_screen.dart';
import '../../features/leaders/leaders_screen.dart';
import '../../features/notifications/notification_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../widgets/shell_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => ShellScreen(child: child),
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/donate',
          name: 'donate',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const DonationScreen(),
          ),
        ),
        GoRoute(
          path: '/problems',
          name: 'problems',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const ProblemsScreen(),
          ),
        ),
        GoRoute(
          path: '/citizens',
          name: 'citizens',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const CitizenDirectoryScreen(),
          ),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const ProfileScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/donate/checkout',
      name: 'donate-checkout',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const DonationCheckoutScreen(),
    ),
    GoRoute(
      path: '/problems/:id',
      name: 'problem-details',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => ProblemDetailsScreen(
        problemId: state.pathParameters['id'] ?? '',
      ),
    ),
    GoRoute(
      path: '/problems/report',
      name: 'report-problem',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ReportProblemScreen(),
    ),
    GoRoute(
      path: '/citizens/:id',
      name: 'citizen-profile',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => CitizenProfileScreen(
        citizenId: state.pathParameters['id'] ?? '',
      ),
    ),
    GoRoute(
      path: '/projects',
      name: 'projects',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ProjectsScreen(),
    ),
    GoRoute(
      path: '/leaders',
      name: 'leaders',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LeadersScreen(),
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const NotificationScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/all-donations',
      name: 'all-donations',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AllDonationsScreen(),
    ),
    GoRoute(
      path: '/all-expenses',
      name: 'all-expenses',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AllExpensesScreen(),
    ),
    GoRoute(
      path: '/all-citizens',
      name: 'all-citizens',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CitizenDirectoryScreen(),
    ),
  ],
);
