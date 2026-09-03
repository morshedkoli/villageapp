package app.village.alislah.feature.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.village.alislah.data.AuthRepository
import app.village.alislah.data.DonationRepository
import app.village.alislah.data.ExpenseRepository
import app.village.alislah.data.NotificationRepository
import app.village.alislah.data.ProblemRepository
import app.village.alislah.data.ProjectRepository
import app.village.alislah.data.VillageRepository
import app.village.alislah.di.ServiceLocator
import app.village.alislah.model.Donation
import app.village.alislah.model.FundTransaction
import app.village.alislah.model.Problem
import app.village.alislah.model.Project
import app.village.alislah.model.UserProfile
import app.village.alislah.model.Village
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

data class HomeUiState(
    val isLoading: Boolean = true,
    val village: Village = Village(),
    val userProfile: UserProfile? = null,
    val recentDonations: List<Donation> = emptyList(),
    val allDonations: List<Donation> = emptyList(),
    val recentExpenses: List<FundTransaction> = emptyList(),
    val allExpenses: List<FundTransaction> = emptyList(),
    val activeProjects: List<Project> = emptyList(),
    val pendingProblems: List<Problem> = emptyList(),
    val unreadNotificationsCount: Int = 0
)

class HomeViewModel(
    private val authRepository: AuthRepository = ServiceLocator.authRepository,
    private val villageRepository: VillageRepository = ServiceLocator.villageRepository,
    private val donationRepository: DonationRepository = ServiceLocator.donationRepository,
    private val expenseRepository: ExpenseRepository = ServiceLocator.expenseRepository,
    private val projectRepository: ProjectRepository = ServiceLocator.projectRepository,
    private val problemRepository: ProblemRepository = ServiceLocator.problemRepository,
    private val notificationRepository: NotificationRepository = ServiceLocator.notificationRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(HomeUiState())
    val uiState: StateFlow<HomeUiState> = _uiState.asStateFlow()

    init {
        loadDashboardData()
    }

    private fun loadDashboardData() {
        val currentUid = authRepository.currentUserId

        viewModelScope.launch {
            villageRepository.getVillageFlow().collect { village ->
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    village = village
                )
            }
        }

        viewModelScope.launch {
            donationRepository.getDonationsFlow(limit = 50).collect { donations ->
                val approved = donations.filter { it.isApproved }
                _uiState.value = _uiState.value.copy(
                    allDonations = donations,
                    recentDonations = approved.take(5)
                )
            }
        }

        viewModelScope.launch {
            expenseRepository.getExpensesFlow(limit = 50).collect { expenses ->
                _uiState.value = _uiState.value.copy(
                    allExpenses = expenses,
                    recentExpenses = expenses.take(5)
                )
            }
        }

        viewModelScope.launch {
            projectRepository.getProjectsFlow().collect { projects ->
                _uiState.value = _uiState.value.copy(
                    activeProjects = projects.filter { !it.isCompleted }
                )
            }
        }

        viewModelScope.launch {
            problemRepository.getProblemsFlow(currentUid, limit = 20).collect { problems ->
                _uiState.value = _uiState.value.copy(
                    pendingProblems = problems.filter { it.isPending }
                )
            }
        }

        viewModelScope.launch {
            notificationRepository.getNotificationsFlow(currentUid).collect { notifications ->
                _uiState.value = _uiState.value.copy(
                    unreadNotificationsCount = notifications.count { !it.isRead }
                )
            }
        }

        if (currentUid != null) {
            viewModelScope.launch {
                authRepository.getUserProfileFlow(currentUid).collect { profile ->
                    _uiState.value = _uiState.value.copy(userProfile = profile)
                }
            }
        }
    }
}
