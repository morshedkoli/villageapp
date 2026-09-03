package app.village.alislah.feature.projects

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.village.alislah.data.ProjectRepository
import app.village.alislah.di.ServiceLocator
import app.village.alislah.model.Project
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

data class ProjectsUiState(
    val isLoading: Boolean = true,
    val projects: List<Project> = emptyList()
)

class ProjectsViewModel(
    private val projectRepository: ProjectRepository = ServiceLocator.projectRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(ProjectsUiState())
    val uiState: StateFlow<ProjectsUiState> = _uiState.asStateFlow()

    init {
        loadProjects()
    }

    private fun loadProjects() {
        viewModelScope.launch {
            projectRepository.getProjectsFlow().collect { projects ->
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    projects = projects
                )
            }
        }
    }
}
