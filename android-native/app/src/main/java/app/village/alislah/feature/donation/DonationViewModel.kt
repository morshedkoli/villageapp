package app.village.alislah.feature.donation

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.village.alislah.data.AuthRepository
import app.village.alislah.data.DonationRepository
import app.village.alislah.data.VillageRepository
import app.village.alislah.di.ServiceLocator
import app.village.alislah.model.Donation
import app.village.alislah.model.PaymentAccount
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

data class DonationUiState(
    val isLoading: Boolean = false,
    val isSubmitting: Boolean = false,
    val paymentAccounts: List<PaymentAccount> = emptyList(),
    val donations: List<Donation> = emptyList(),
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
        viewModelScope.launch {
            villageRepository.getPaymentAccountsFlow().collect { accounts ->
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    paymentAccounts = accounts
                )
            }
        }

        viewModelScope.launch {
            donationRepository.getDonationsFlow(limit = 100).collect { donations ->
                _uiState.value = _uiState.value.copy(donations = donations)
            }
        }
    }

    fun submitDonation(
        donorName: String,
        amountText: String,
        paymentMethod: String,
        receivedAccountId: String,
        receivedAccountLabel: String,
        transactionId: String,
        senderNumber: String,
        notes: String
    ) {
        val amount = amountText.toDoubleOrNull() ?: 0.0
        if (amount <= 0) {
            _uiState.value = _uiState.value.copy(errorMessage = "সঠিক অনুদানের পরিমাণ লিখুন")
            return
        }

        if (donorName.isBlank() || senderNumber.isBlank() || transactionId.isBlank()) {
            _uiState.value = _uiState.value.copy(errorMessage = "সকল প্রয়োজনীয় তথ্য সঠিকভাবে পূরণ করুন")
            return
        }

        val currentUserId = authRepository.currentUserId ?: ""

        val donation = Donation(
            donorName = donorName.trim(),
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
