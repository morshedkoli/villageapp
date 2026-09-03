package app.village.alislah.feature.citizens

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.village.alislah.data.CitizenRepository
import app.village.alislah.di.ServiceLocator
import app.village.alislah.model.Citizen
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

data class CitizensUiState(
    val isLoading: Boolean = true,
    val citizens: List<Citizen> = emptyList()
)

class CitizenViewModel(
    private val citizenRepository: CitizenRepository = ServiceLocator.citizenRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(CitizensUiState())
    val uiState: StateFlow<CitizensUiState> = _uiState.asStateFlow()

    init {
        loadCitizens()
    }

    private fun loadCitizens() {
        viewModelScope.launch {
            citizenRepository.getCitizensFlow().collect { citizens ->
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    citizens = citizens
                )
            }
        }
    }
}
