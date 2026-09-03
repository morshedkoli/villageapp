package app.village.alislah.feature.auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.village.alislah.data.AuthRepository
import app.village.alislah.di.ServiceLocator
import com.google.firebase.auth.FirebaseUser
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

data class AuthUiState(
    val isLoading: Boolean = false,
    val errorMessage: String? = null,
    val successUser: FirebaseUser? = null,
    val isPhoneMode: Boolean = true,
    val isPasswordVisible: Boolean = false
)

class LoginViewModel(
    private val authRepository: AuthRepository = ServiceLocator.authRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(AuthUiState())
    val uiState: StateFlow<AuthUiState> = _uiState.asStateFlow()

    fun toggleAuthMode() {
        _uiState.value = _uiState.value.copy(
            isPhoneMode = !_uiState.value.isPhoneMode,
            errorMessage = null
        )
    }

    fun togglePasswordVisibility() {
        _uiState.value = _uiState.value.copy(
            isPasswordVisible = !_uiState.value.isPasswordVisible
        )
    }

    fun clearError() {
        _uiState.value = _uiState.value.copy(errorMessage = null)
    }

    fun setErrorMessage(message: String) {
        _uiState.value = _uiState.value.copy(errorMessage = message, isLoading = false)
    }

    fun signIn(identifier: String, password: String) {
        if (identifier.isBlank() || password.isBlank()) {
            _uiState.value = _uiState.value.copy(errorMessage = "সকল তথ্য সঠিকভাবে পূরণ করুন")
            return
        }

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)
            val result = if (_uiState.value.isPhoneMode) {
                authRepository.signInWithPhone(identifier.trim(), password)
            } else {
                authRepository.signInWithEmail(identifier.trim(), password)
            }

            result.fold(
                onSuccess = { user ->
                    _uiState.value = _uiState.value.copy(isLoading = false, successUser = user)
                },
                onFailure = { error ->
                    val message = when {
                        error.message?.contains("invalid-credential", ignoreCase = true) == true ||
                                error.message?.contains("wrong-password", ignoreCase = true) == true ||
                                error.message?.contains("user-not-found", ignoreCase = true) == true ->
                            "ফোন/ইমেইল অথবা পাসওয়ার্ড সঠিক নয়"
                        error.message?.contains("network", ignoreCase = true) == true ->
                            "ইন্টারনেট সংযোগ চেক করুন"
                        else -> error.localizedMessage ?: "লগইন ব্যর্থ হয়েছে"
                    }
                    _uiState.value = _uiState.value.copy(isLoading = false, errorMessage = message)
                }
            )
        }
    }

    fun signUp(
        name: String,
        identifier: String,
        password: String,
        village: String = "গ্রামবাসী",
        profession: String = ""
    ) {
        if (name.isBlank() || identifier.isBlank() || password.isBlank()) {
            _uiState.value = _uiState.value.copy(errorMessage = "সকল তথ্য সঠিকভাবে পূরণ করুন")
            return
        }

        if (password.length < 6) {
            _uiState.value = _uiState.value.copy(errorMessage = "পাসওয়ার্ড অন্তত ৬ অক্ষরের হতে হবে")
            return
        }

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)
            val result = if (_uiState.value.isPhoneMode) {
                authRepository.signUpWithPhone(
                    phone = identifier.trim(),
                    password = password,
                    name = name.trim(),
                    village = village.trim(),
                    profession = profession.trim()
                )
            } else {
                authRepository.signUpWithEmail(
                    email = identifier.trim(),
                    password = password,
                    name = name.trim(),
                    village = village.trim()
                )
            }

            result.fold(
                onSuccess = { user ->
                    _uiState.value = _uiState.value.copy(isLoading = false, successUser = user)
                },
                onFailure = { error ->
                    val message = when {
                        error.message?.contains("email-already-in-use", ignoreCase = true) == true ->
                            "এই নাম্বার/ইমেইল দিয়ে ইতিমধ্যে একাউন্ট রয়েছে"
                        else -> error.localizedMessage ?: "রেজিস্ট্রেশন ব্যর্থ হয়েছে"
                    }
                    _uiState.value = _uiState.value.copy(isLoading = false, errorMessage = message)
                }
            )
        }
    }

    fun signInWithGoogle(idToken: String) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)
            val result = authRepository.signInWithGoogleCredential(idToken)
            result.fold(
                onSuccess = { user ->
                    _uiState.value = _uiState.value.copy(isLoading = false, successUser = user)
                },
                onFailure = { error ->
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        errorMessage = error.localizedMessage ?: "গুগল সাইন-ইন ব্যর্থ হয়েছে"
                    )
                }
            )
        }
    }
}
