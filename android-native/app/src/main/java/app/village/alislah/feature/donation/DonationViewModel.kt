package app.village.alislah.feature.donation

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.village.alislah.data.AuthRepository
import app.village.alislah.data.DonationRepository
import app.village.alislah.data.VillageRepository
import app.village.alislah.di.ServiceLocator
import app.village.alislah.model.Donation
import app.village.alislah.model.PaymentAccount
import app.village.alislah.model.UserProfile
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

import app.village.alislah.model.Village

data class DonationUiState(
    val isLoading: Boolean = false,
    val isSubmitting: Boolean = false,
    val paymentAccounts: List<PaymentAccount> = emptyList(),
    val donations: List<Donation> = emptyList(),
    val userDonations: List<Donation> = emptyList(),
    val userProfile: UserProfile? = null,
    val village: Village = Village(),
    val submissionSuccess: Boolean = false,
    val errorMessage: String? = null
)

class DonationViewModel(
    private val authRepository: AuthRepository = ServiceLocator.authRepository,
    private val donationRepository: DonationRepository = ServiceLocator.donationRepository,
    private val villageRepository: VillageRepository = ServiceLocator.villageRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(DonationUiState(isLoading = true))
    val uiState: StateFlow<DonationUiState> = _uiState.asStateFlow()

    init {
        loadData()
    }

    private fun loadData() {
        val currentUserId = authRepository.currentUserId.orEmpty()

        viewModelScope.launch {
            villageRepository.getVillageFlow().collect { village ->
                _uiState.value = _uiState.value.copy(village = village)
            }
        }

        viewModelScope.launch {
            villageRepository.getPaymentAccountsFlow().collect { accounts ->
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    paymentAccounts = accounts
                )
            }
        }

        viewModelScope.launch {
            donationRepository.getDonationsFlow(limit = 500).collect { donations ->
                _uiState.value = _uiState.value.copy(donations = donations)
            }
        }

        if (currentUserId.isNotBlank()) {
            viewModelScope.launch {
                authRepository.getUserProfileFlow(currentUserId).collect { profile ->
                    _uiState.value = _uiState.value.copy(userProfile = profile)
                }
            }

            viewModelScope.launch {
                donationRepository.getUserDonationsFlow(currentUserId).collect { myDonations ->
                    _uiState.value = _uiState.value.copy(userDonations = myDonations)
                }
            }
        }
    }

    fun submitDonation(
        amountText: String,
        paymentMethod: String,
        receivedAccountId: String,
        receivedAccountLabel: String,
        senderNumber: String,
        transactionId: String = "",
        notes: String = "",
        donorNameOverride: String? = null
    ) {
        val amount = amountText.toDoubleOrNull() ?: 0.0
        if (amount <= 0) {
            _uiState.value = _uiState.value.copy(errorMessage = "সঠিক অনুদানের পরিমাণ লিখুন")
            return
        }

        if (senderNumber.isBlank()) {
            _uiState.value = _uiState.value.copy(errorMessage = "প্রেরকের ফোন নম্বর প্রদান করুন")
            return
        }

        val currentUserId = authRepository.currentUserId.orEmpty()
        val profile = _uiState.value.userProfile
        val resolvedDonorName = donorNameOverride?.trim()?.ifBlank { null }
            ?: profile?.name?.trim()?.ifBlank { null }
            ?: authRepository.currentUser?.displayName?.trim()?.ifBlank { null }
            ?: "গ্রামবাসী"

        val donation = Donation(
            donorName = resolvedDonorName,
            amount = amount,
            paymentMethod = paymentMethod,
            receivedAccountId = receivedAccountId,
            receivedAccountLabel = receivedAccountLabel,
            transactionId = transactionId.trim(),
            senderNumber = senderNumber.trim(),
            userId = currentUserId,
            notes = notes.trim(),
            status = "Pending"
        )

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isSubmitting = true, errorMessage = null)
            val result = donationRepository.submitDonation(donation)

            result.fold(
                onSuccess = {
                    _uiState.value = _uiState.value.copy(
                        isSubmitting = false,
                        submissionSuccess = true,
                        errorMessage = null
                    )
                },
                onFailure = { error ->
                    _uiState.value = _uiState.value.copy(
                        isSubmitting = false,
                        errorMessage = error.localizedMessage ?: "অনুদান তথ্য জমা দেওয়া সম্ভব হয়নি"
                    )
                }
            )
        }
    }

    fun resetSubmissionState() {
        _uiState.value = _uiState.value.copy(submissionSuccess = false, errorMessage = null)
    }
}
