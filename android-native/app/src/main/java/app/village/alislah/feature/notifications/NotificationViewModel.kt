package app.village.alislah.feature.notifications

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.village.alislah.data.AuthRepository
import app.village.alislah.data.NotificationRepository
import app.village.alislah.di.ServiceLocator
import app.village.alislah.model.AppNotification
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

data class NotificationsUiState(
    val isLoading: Boolean = true,
    val notifications: List<AppNotification> = emptyList()
)

class NotificationViewModel(
    private val authRepository: AuthRepository = ServiceLocator.authRepository,
    private val notificationRepository: NotificationRepository = ServiceLocator.notificationRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(NotificationsUiState())
    val uiState: StateFlow<NotificationsUiState> = _uiState.asStateFlow()

    init {
        loadNotifications()
    }

    private fun loadNotifications() {
        val uid = authRepository.currentUserId
        viewModelScope.launch {
            notificationRepository.getNotificationsFlow(uid).collect { notifications ->
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    notifications = notifications
                )
            }
        }
    }

    fun markAsRead(notificationId: String) {
        val uid = authRepository.currentUserId ?: return
        viewModelScope.launch {
            notificationRepository.markAsRead(notificationId, uid)
        }
    }
}
