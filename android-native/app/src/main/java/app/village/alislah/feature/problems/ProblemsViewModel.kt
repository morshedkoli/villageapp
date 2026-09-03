package app.village.alislah.feature.problems

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.village.alislah.data.AuthRepository
import app.village.alislah.data.ProblemRepository
import app.village.alislah.di.ServiceLocator
import app.village.alislah.model.Problem
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

data class ProblemsUiState(
    val isLoading: Boolean = true,
    val isSubmitting: Boolean = false,
    val problems: List<Problem> = emptyList(),
    val reportSuccess: Boolean = false,
    val errorMessage: String? = null
)

class ProblemsViewModel(
    private val authRepository: AuthRepository = ServiceLocator.authRepository,
    private val problemRepository: ProblemRepository = ServiceLocator.problemRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(ProblemsUiState())
    val uiState: StateFlow<ProblemsUiState> = _uiState.asStateFlow()

    init {
        loadProblems()
    }

    private fun loadProblems() {
        val currentUserId = authRepository.currentUserId
        viewModelScope.launch {
            problemRepository.getProblemsFlow(currentUserId).collect { problems ->
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    problems = problems
                )
            }
        }
    }

    fun toggleUpvote(problemId: String) {
        val userId = authRepository.currentUserId ?: return
        viewModelScope.launch {
            problemRepository.toggleVote(problemId, userId)
        }
    }

    fun reportProblem(
        title: String,
        description: String,
        photoUrl: String = "",
        location: String = "",
        reportedByName: String = ""
    ) {
        if (title.isBlank() || description.isBlank()) {
            _uiState.value = _uiState.value.copy(errorMessage = "শিরোনাম এবং বিস্তারিত বিবরণ আবশ্যক")
            return
        }

        val currentUserId = authRepository.currentUserId ?: ""
        val authorName = if (reportedByName.isNotBlank()) reportedByName else "গ্রামবাসী"

        val problem = Problem(
            title = title.trim(),
            description = description.trim(),
            photoUrl = photoUrl.trim(),
            location = location.trim(),
            reportedBy = currentUserId,
            reportedByName = authorName,
            status = "Pending"
        )

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isSubmitting = true, errorMessage = null)
            val result = problemRepository.reportProblem(problem)

            result.fold(
                onSuccess = {
                    _uiState.value = _uiState.value.copy(
                        isSubmitting = false,
                        reportSuccess = true,
                        errorMessage = null
                    )
                },
                onFailure = { error ->
                    _uiState.value = _uiState.value.copy(
                        isSubmitting = false,
                        errorMessage = error.localizedMessage ?: "সমস্যা রিপোর্ট জমা দেওয়া সম্ভব হয়নি"
                    )
                }
            )
        }
    }

    fun resetReportState() {
        _uiState.value = _uiState.value.copy(reportSuccess = false, errorMessage = null)
    }
}
