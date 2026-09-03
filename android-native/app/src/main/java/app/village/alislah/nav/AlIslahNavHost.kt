package app.village.alislah.nav

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import app.village.alislah.components.BottomNavTab
import app.village.alislah.components.AlIslahBottomNav
import app.village.alislah.data.AuthRepository
import app.village.alislah.di.ServiceLocator
import app.village.alislah.feature.auth.LoginScreen
import app.village.alislah.feature.auth.RegisterScreen
import app.village.alislah.feature.citizens.CitizenDirectoryScreen
import app.village.alislah.feature.citizens.CitizenProfileScreen
import app.village.alislah.feature.donation.DonationCheckoutScreen
import app.village.alislah.feature.donation.DonationScreen
import app.village.alislah.feature.home.AllDonationsScreen
import app.village.alislah.feature.home.AllExpensesScreen
import app.village.alislah.feature.home.HomeScreen
import app.village.alislah.feature.leaders.LeadersScreen
import app.village.alislah.feature.notifications.NotificationScreen
import app.village.alislah.feature.onboarding.OnboardingScreen
import app.village.alislah.feature.problems.ProblemDetailsScreen
import app.village.alislah.feature.problems.ProblemsScreen
import app.village.alislah.feature.problems.ReportProblemScreen
import app.village.alislah.feature.profile.EditProfileScreen
import app.village.alislah.feature.profile.ProfileScreen
import app.village.alislah.feature.projects.ProjectDetailsScreen
import app.village.alislah.feature.projects.ProjectsScreen
import app.village.alislah.feature.reports.ReportsScreen
import app.village.alislah.feature.settings.SettingsScreen
import app.village.alislah.feature.splash.SplashScreen

@Composable
fun AlIslahNavHost(
    navController: NavHostController = rememberNavController(),
    authRepository: AuthRepository = ServiceLocator.authRepository
) {
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.route ?: Destinations.SPLASH

    val mainTabs = setOf(
        Destinations.HOME,
        Destinations.DONATIONS,
        Destinations.PROBLEMS,
        Destinations.CITIZENS,
        Destinations.PROFILE
    )
    val showBottomNav = currentRoute in mainTabs

    val isUserLoggedIn = authRepository.currentUser != null

    Scaffold(
        modifier = Modifier.fillMaxSize(),
        bottomBar = {
            AnimatedVisibility(
                visible = showBottomNav,
                enter = slideInVertically(initialOffsetY = { it }),
                exit = slideOutVertically(targetOffsetY = { it })
            ) {
                AlIslahBottomNav(
                    currentRoute = currentRoute,
                    onTabSelected = { tab ->
                        navController.navigate(tab.route) {
                            popUpTo(Destinations.HOME) { saveState = true }
                            launchSingleTop = true
                            restoreState = true
                        }
                    }
                )
            }
        }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = Destinations.SPLASH,
            modifier = Modifier.padding(innerPadding)
        ) {
            // Splash & Onboarding
            composable(Destinations.SPLASH) {
                SplashScreen(
                    onNavigateToHome = {
                        navController.navigate(Destinations.HOME) {
                            popUpTo(Destinations.SPLASH) { inclusive = true }
                        }
                    },
                    onNavigateToOnboarding = {
                        navController.navigate(Destinations.ONBOARDING) {
                            popUpTo(Destinations.SPLASH) { inclusive = true }
                        }
                    },
                    isUserLoggedIn = isUserLoggedIn
                )
            }

            composable(Destinations.ONBOARDING) {
                OnboardingScreen(
                    onFinish = {
                        navController.navigate(Destinations.LOGIN) {
                            popUpTo(Destinations.ONBOARDING) { inclusive = true }
                        }
                    }
                )
            }

            // Auth
            composable(Destinations.LOGIN) {
                LoginScreen(
                    onLoginSuccess = {
                        navController.navigate(Destinations.HOME) {
                            popUpTo(Destinations.LOGIN) { inclusive = true }
                        }
                    },
                    onNavigateToRegister = {
                        navController.navigate(Destinations.REGISTER)
                    }
                )
            }

            composable(Destinations.REGISTER) {
                RegisterScreen(
                    onRegisterSuccess = {
                        navController.navigate(Destinations.HOME) {
                            popUpTo(Destinations.LOGIN) { inclusive = true }
                        }
                    },
                    onNavigateToLogin = {
                        navController.popBackStack()
                    }
                )
            }

            // Primary Tab 0: Home
            composable(Destinations.HOME) {
                HomeScreen(
                    onNavigateToDonationCheckout = { navController.navigate(Destinations.DONATION_CHECKOUT) },
                    onNavigateToAllDonations = { navController.navigate(Destinations.ALL_DONATIONS) },
                    onNavigateToAllExpenses = { navController.navigate(Destinations.ALL_EXPENSES) },
                    onNavigateToProblems = { navController.navigate(Destinations.PROBLEMS) },
                    onNavigateToReportProblem = { navController.navigate(Destinations.REPORT_PROBLEM) },
                    onNavigateToProjects = { navController.navigate(Destinations.PROJECTS) },
                    onNavigateToProjectDetails = { projectId ->
                        navController.navigate(Destinations.projectDetailsRoute(projectId))
                    },
                    onNavigateToCitizens = { navController.navigate(Destinations.CITIZENS) },
                    onNavigateToLeaders = { navController.navigate(Destinations.LEADERS) },
                    onNavigateToReports = { navController.navigate(Destinations.REPORTS) },
                    onNavigateToNotifications = { navController.navigate(Destinations.NOTIFICATIONS) }
                )
            }

            // Primary Tab 1: Donations
            composable(Destinations.DONATIONS) {
                DonationScreen(
                    onNavigateToCheckout = { navController.navigate(Destinations.DONATION_CHECKOUT) }
                )
            }

            // Primary Tab 2: Problems
            composable(Destinations.PROBLEMS) {
                ProblemsScreen(
                    onNavigateToReportProblem = { navController.navigate(Destinations.REPORT_PROBLEM) },
                    onNavigateToProblemDetails = { problemId ->
                        navController.navigate(Destinations.problemDetailsRoute(problemId))
                    }
                )
            }

            // Primary Tab 3: Citizens
            composable(Destinations.CITIZENS) {
                CitizenDirectoryScreen(
                    onNavigateToCitizenProfile = { citizenId ->
                        navController.navigate(Destinations.citizenProfileRoute(citizenId))
                    }
                )
            }

            // Primary Tab 4: Profile
            composable(Destinations.PROFILE) {
                ProfileScreen(
                    onNavigateToEditProfile = { navController.navigate(Destinations.EDIT_PROFILE) },
                    onNavigateToSettings = { navController.navigate(Destinations.SETTINGS) },
                    onNavigateToAllDonations = { navController.navigate(Destinations.ALL_DONATIONS) },
                    onNavigateToProblems = { navController.navigate(Destinations.PROBLEMS) },
                    onSignOut = {
                        navController.navigate(Destinations.LOGIN) {
                            popUpTo(Destinations.HOME) { inclusive = true }
                        }
                    }
                )
            }

            // Secondary Screens
            composable(Destinations.ALL_DONATIONS) {
                AllDonationsScreen(onBackClick = { navController.popBackStack() })
            }

            composable(Destinations.ALL_EXPENSES) {
                AllExpensesScreen(onBackClick = { navController.popBackStack() })
            }

            composable(Destinations.DONATION_CHECKOUT) {
                DonationCheckoutScreen(onBackClick = { navController.popBackStack() })
            }

            composable(Destinations.REPORT_PROBLEM) {
                ReportProblemScreen(onBackClick = { navController.popBackStack() })
            }

            composable(
                route = Destinations.PROBLEM_DETAILS,
                arguments = listOf(navArgument("problemId") { type = NavType.StringType })
            ) { backStackEntry ->
                val problemId = backStackEntry.arguments?.getString("problemId") ?: ""
                ProblemDetailsScreen(
                    problemId = problemId,
                    onBackClick = { navController.popBackStack() }
                )
            }

            composable(Destinations.PROJECTS) {
                ProjectsScreen(
                    onNavigateToProjectDetails = { projectId ->
                        navController.navigate(Destinations.projectDetailsRoute(projectId))
                    },
                    onBackClick = { navController.popBackStack() }
                )
            }

            composable(
                route = Destinations.PROJECT_DETAILS,
                arguments = listOf(navArgument("projectId") { type = NavType.StringType })
            ) { backStackEntry ->
                val projectId = backStackEntry.arguments?.getString("projectId") ?: ""
                ProjectDetailsScreen(
                    projectId = projectId,
                    onBackClick = { navController.popBackStack() }
                )
            }

            composable(
                route = Destinations.CITIZEN_PROFILE,
                arguments = listOf(navArgument("citizenId") { type = NavType.StringType })
            ) { backStackEntry ->
                val citizenId = backStackEntry.arguments?.getString("citizenId") ?: ""
                CitizenProfileScreen(
                    citizenId = citizenId,
                    onBackClick = { navController.popBackStack() }
                )
            }

            composable(Destinations.LEADERS) {
                LeadersScreen(onBackClick = { navController.popBackStack() })
            }

            composable(Destinations.NOTIFICATIONS) {
                NotificationScreen(onBackClick = { navController.popBackStack() })
            }

            composable(Destinations.REPORTS) {
                ReportsScreen(onBackClick = { navController.popBackStack() })
            }

            composable(Destinations.EDIT_PROFILE) {
                EditProfileScreen(onBackClick = { navController.popBackStack() })
            }

            composable(Destinations.SETTINGS) {
                SettingsScreen(onBackClick = { navController.popBackStack() })
            }
        }
    }
}
