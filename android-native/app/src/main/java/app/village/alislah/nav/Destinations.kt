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
    const val ALL_EXPENSES = "all_expenses"
    const val MY_DONATIONS = "my_donations"
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

    fun resolveNotificationRoute(
        type: String? = null,
        targetId: String? = null,
        customRoute: String? = null,
        title: String? = null,
        body: String? = null
    ): String? {
        if (!customRoute.isNullOrBlank()) {
            return customRoute
        }

        val cleanType = type?.trim()?.lowercase().orEmpty()
        val cleanTarget = targetId?.trim().orEmpty()
        val text = "${title.orEmpty()} ${body.orEmpty()} $cleanType".lowercase()

        // 1. Problems / Complaints
        val isProblem = cleanType in listOf("problem", "complaint", "issue") ||
                text.contains("সমস্যা") || text.contains("অভিযোগ")
        if (isProblem) {
            return if (cleanTarget.isNotBlank() && cleanTarget != "village_notif") {
                problemDetailsRoute(cleanTarget)
            } else {
                PROBLEMS
            }
        }

        // 2. Projects / Development
        val isProject = cleanType in listOf("project", "development") ||
                text.contains("প্রকল্প") || text.contains("উন্নয়ন") || text.contains("উন্নয়ন")
        if (isProject) {
            return if (cleanTarget.isNotBlank() && cleanTarget != "village_notif") {
                projectDetailsRoute(cleanTarget)
            } else {
                PROJECTS
            }
        }

        // 3. Expenses
        val isExpense = cleanType in listOf("expense", "cost") ||
                text.contains("ব্যয়") || text.contains("ব্যয়") || text.contains("খরচ")
        if (isExpense) {
            return ALL_EXPENSES
        }

        // 4. Donations & Funds
        val isDonation = cleanType in listOf("donation", "fund", "donate") ||
                text.contains("অনুদান") || text.contains("তহবিল") || text.contains("দান")
        if (isDonation) {
            return if (text.contains("আমার") || text.contains("আপনার")) {
                MY_DONATIONS
            } else {
                DONATIONS
            }
        }

        // 5. Citizens / Directory
        val isCitizen = cleanType in listOf("citizen", "citizens", "user", "member") ||
                text.contains("নাগরিক") || text.contains("সদস্য")
        if (isCitizen) {
            return if (cleanTarget.isNotBlank() && cleanTarget != "village_notif") {
                citizenProfileRoute(cleanTarget)
            } else {
                CITIZENS
            }
        }

        // 6. Leaders
        if (cleanType in listOf("leader", "leaders") || text.contains("নেতা") || text.contains("নেতৃবৃন্দ")) {
            return LEADERS
        }

        // 7. Reports
        if (cleanType in listOf("report", "reports") || text.contains("প্রতিবেদন") || text.contains("রিপোর্ট")) {
            return REPORTS
        }

        // 8. General Notification fallback
        if (cleanType.isNotBlank() || !title.isNullOrBlank() || !body.isNullOrBlank() || cleanTarget.isNotBlank()) {
            return NOTIFICATIONS
        }

        return null
    }
}
