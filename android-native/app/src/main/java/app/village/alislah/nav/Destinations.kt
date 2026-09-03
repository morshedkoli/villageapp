package app.village.alislah.nav

object Destinations {
    const val SPLASH = "splash"
    const val ONBOARDING = "onboarding"
    const val LOGIN = "login"
    const val REGISTER = "register"

    // Bottom Navigation Main Tabs
    const val HOME = "home"
    const val DONATIONS = "donations"
    const val PROBLEMS = "problems"
    const val CITIZENS = "citizens"
    const val PROFILE = "profile"

    // Sub-screens & Details
    const val ALL_DONATIONS = "all_donations"
    const val ALL_EXPENSES = "all_expenses"
    const val DONATION_CHECKOUT = "donation_checkout"
    const val REPORT_PROBLEM = "report_problem"
    const val PROBLEM_DETAILS = "problem_details/{problemId}"
    const val PROJECTS = "projects"
    const val PROJECT_DETAILS = "project_details/{projectId}"
    const val CITIZEN_PROFILE = "citizen_profile/{citizenId}"
    const val LEADERS = "leaders"
    const val NOTIFICATIONS = "notifications"
    const val REPORTS = "reports"
    const val EDIT_PROFILE = "edit_profile"
    const val SETTINGS = "settings"

    fun problemDetailsRoute(problemId: String) = "problem_details/$problemId"
    fun projectDetailsRoute(projectId: String) = "project_details/$projectId"
    fun citizenProfileRoute(citizenId: String) = "citizen_profile/$citizenId"
}
