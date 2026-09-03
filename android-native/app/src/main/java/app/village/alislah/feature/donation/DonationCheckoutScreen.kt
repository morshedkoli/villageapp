package app.village.alislah.feature.donation

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.ContentCopy
import androidx.compose.material.icons.filled.MonetizationOn
import androidx.compose.material.icons.filled.Payment
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Phone
import androidx.compose.material.icons.filled.Receipt
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import app.village.alislah.components.ButtonVariant
import app.village.alislah.components.AlIslahButton
import app.village.alislah.components.AlIslahCard
import app.village.alislah.components.AlIslahTextField
import app.village.alislah.components.AlIslahTopBar
import app.village.alislah.core.Formatters
import app.village.alislah.model.PaymentAccount
import app.village.alislah.theme.CardShape
import app.village.alislah.theme.AlIslahPrimary
import app.village.alislah.theme.AlIslahTheme

@Composable
fun DonationCheckoutScreen(
    onBackClick: () -> Unit,
    viewModel: DonationViewModel = viewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val context = LocalContext.current

    var selectedAccountIndex by remember { mutableStateOf(0) }
    var amount by remember { mutableStateOf("500") }
    var donorName by remember { mutableStateOf("") }
    var senderNumber by remember { mutableStateOf("") }
    var transactionId by remember { mutableStateOf("") }
    var notes by remember { mutableStateOf("") }

    val presetAmounts = listOf("100", "500", "1000", "2000", "5000", "10000")

    // Fallback accounts if not yet fetched from village document
    val displayAccounts = if (uiState.paymentAccounts.isNotEmpty()) {
        uiState.paymentAccounts
    } else {
        listOf(
            PaymentAccount(id = "bk1", type = "bkash", number = "01700000000", name = "গ্রাম উন্নয়ন ফান্ড"),
            PaymentAccount(id = "ng1", type = "nagad", number = "01800000000", name = "গ্রাম উন্নয়ন ফান্ড"),
            PaymentAccount(id = "rk1", type = "rocket", number = "01900000000", name = "গ্রাম উন্নয়ন ফান্ড")
        )
    }

    val selectedAccount = displayAccounts.getOrElse(selectedAccountIndex) { displayAccounts.first() }

    fun copyToClipboard(text: String) {
        val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = ClipData.newPlainText("Payment Number", text)
        clipboard.setPrimaryClip(clip)
        Toast.makeText(context, "নাম্বার কপি করা হয়েছে!", Toast.LENGTH_SHORT).show()
    }

    if (uiState.submissionSuccess) {
        AlertDialog(
            onDismissRequest = {
                viewModel.resetSubmissionState()
                onBackClick()
            },
            icon = {
                Icon(
                    imageVector = Icons.Default.CheckCircle,
                    contentDescription = null,
                    tint = AlIslahPrimary,
                    modifier = Modifier.size(54.dp)
                )
            },
            title = {
                Text(
                    text = "অনুদানের তথ্য সফলভাবে গৃহীত হয়েছে!",
                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold)
                )
            },
            text = {
                Text(
                    text = "আপনার অনুদানটি যাচাইয়ের জন্য জমা হয়েছে। অ্যাডমিন কর্তৃক যাচাই সম্পন্ন হওয়ার সাথে সাথে ফান্ডে যুক্ত হবে। জাযাকাল্লাহু খাইরান!",
                    style = MaterialTheme.typography.bodyMedium,
                    color = AlIslahTheme.customColors.textSecondary
                )
            },
            confirmButton = {
                TextButton(
                    onClick = {
                        viewModel.resetSubmissionState()
                        onBackClick()
                    }
                ) {
                    Text(text = "ঠিক আছে", color = AlIslahPrimary, fontWeight = FontWeight.Bold)
                }
            }
        )
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .statusBarsPadding()
            .navigationBarsPadding()
            .imePadding()
    ) {
        AlIslahTopBar(
            title = "অনুদান প্রদান করুন",
            showBackButton = true,
            onBackClick = onBackClick
        )

        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(20.dp)
        ) {
            // Step 1: Select Official Payment Account
            Text(
                text = "১. অফিসিয়াল পেমেন্ট নম্বর নির্বাচন করুন",
                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                color = AlIslahTheme.customColors.textPrimary
            )

            Spacer(modifier = Modifier.height(10.dp))

            LazyRow(
                horizontalArrangement = Arrangement.spacedBy(10.dp),
                contentPadding = PaddingValues(bottom = 6.dp)
            ) {
                items(displayAccounts.indices.toList()) { index ->
                    val acc = displayAccounts[index]
                    val isSelected = selectedAccountIndex == index

                    Box(
                        modifier = Modifier
                            .width(220.dp)
                            .clip(CardShape)
                            .background(
                                if (isSelected) AlIslahPrimary.copy(alpha = 0.1f)
                                else AlIslahTheme.customColors.cardBackground
                            )
                            .border(
                                width = if (isSelected) 2.dp else 1.dp,
                                color = if (isSelected) AlIslahPrimary else AlIslahTheme.customColors.cardBorder,
                                shape = CardShape
                            )
                            .clickable { selectedAccountIndex = index }
                            .padding(14.dp)
                    ) {
                        Column {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Text(
                                    text = acc.displayType,
                                    style = MaterialTheme.typography.titleSmall.copy(fontWeight = FontWeight.Bold),
                                    color = if (isSelected) AlIslahPrimary else AlIslahTheme.customColors.textPrimary
                                )
                                IconButton(
                                    onClick = { copyToClipboard(acc.number) },
                                    modifier = Modifier.size(24.dp)
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.ContentCopy,
                                        contentDescription = "Copy",
                                        tint = AlIslahPrimary,
                                        modifier = Modifier.size(16.dp)
                                    )
                                }
                            }
                            Spacer(modifier = Modifier.height(4.dp))
                            Text(
                                text = acc.number,
                                style = MaterialTheme.typography.bodyLarge.copy(fontWeight = FontWeight.Bold),
                                color = AlIslahTheme.customColors.textPrimary
                            )
                            if (acc.name.isNotBlank()) {
                                Text(
                                    text = acc.name,
                                    style = MaterialTheme.typography.labelSmall,
                                    color = AlIslahTheme.customColors.textTertiary
                                )
                            }
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(20.dp))

            // Step 2: Amount Input & Presets
            Text(
                text = "২. অনুদানের পরিমাণ (টাকা)",
                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                color = AlIslahTheme.customColors.textPrimary
            )

            Spacer(modifier = Modifier.height(10.dp))

            AlIslahTextField(
                value = amount,
                onValueChange = { amount = it },
                modifier = Modifier.fillMaxWidth(),
                placeholder = "পরিমাণ লিখুন (যেমন: ৫০০)",
                leadingIcon = {
                    Icon(
                        imageVector = Icons.Default.MonetizationOn,
                        contentDescription = null,
                        tint = AlIslahPrimary
                    )
                },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)
            )

            Spacer(modifier = Modifier.height(10.dp))

            // Quick Preset Amount Chips
            LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                items(presetAmounts) { preset ->
                    val isSelected = amount == preset
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(8.dp))
                            .background(
                                if (isSelected) AlIslahPrimary
                                else AlIslahTheme.customColors.cardBackground
                            )
                            .border(
                                1.dp,
                                if (isSelected) AlIslahPrimary else AlIslahTheme.customColors.cardBorder,
                                RoundedCornerShape(8.dp)
                            )
                            .clickable { amount = preset }
                            .padding(horizontal = 14.dp, vertical = 8.dp)
                    ) {
                        Text(
                            text = "৳ $preset",
                            style = MaterialTheme.typography.labelMedium.copy(fontWeight = FontWeight.Bold),
                            color = if (isSelected) Color.White else AlIslahTheme.customColors.textPrimary
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Step 3: Donor Details & TxID
            Text(
                text = "৩. আপনার তথ্য ও ট্রানজেকশন আইডি",
                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                color = AlIslahTheme.customColors.textPrimary
            )

            Spacer(modifier = Modifier.height(12.dp))

            AlIslahTextField(
                value = donorName,
                onValueChange = { donorName = it },
                modifier = Modifier.fillMaxWidth(),
                label = "দাতার নাম *",
                placeholder = "আপনার নাম (বা 'নাম প্রকাশে অনিচ্ছুক')",
                leadingIcon = {
                    Icon(
                        imageVector = Icons.Default.Person,
                        contentDescription = null,
                        tint = AlIslahTheme.customColors.textSecondary
                    )
                }
            )

            Spacer(modifier = Modifier.height(14.dp))

            AlIslahTextField(
                value = senderNumber,
                onValueChange = { senderNumber = it },
                modifier = Modifier.fillMaxWidth(),
                label = "প্রেরকের নম্বর (যে নম্বর থেকে পাঠিয়েছেন) *",
                placeholder = "017XXXXXXXX",
                leadingIcon = {
                    Icon(
                        imageVector = Icons.Default.Phone,
                        contentDescription = null,
                        tint = AlIslahTheme.customColors.textSecondary
                    )
                },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone)
            )

            Spacer(modifier = Modifier.height(14.dp))

            AlIslahTextField(
                value = transactionId,
                onValueChange = { transactionId = it },
                modifier = Modifier.fillMaxWidth(),
                label = "ট্রানজেকশন আইডি (TxID / TrxID) *",
                placeholder = "যেমন: 9J3K8L2M9P",
                leadingIcon = {
                    Icon(
                        imageVector = Icons.Default.Receipt,
                        contentDescription = null,
                        tint = AlIslahTheme.customColors.textSecondary
                    )
                }
            )

            Spacer(modifier = Modifier.height(14.dp))

            AlIslahTextField(
                value = notes,
                onValueChange = { notes = it },
                modifier = Modifier.fillMaxWidth(),
                label = "মন্তব্য / উৎসর্গ (ঐচ্ছিক)",
                placeholder = "যেমন: মসজিদের উন্নয়ন বাবদ",
                singleLine = false,
                maxLines = 3
            )

            if (uiState.errorMessage != null) {
                Spacer(modifier = Modifier.height(14.dp))
                AlIslahCard(
                    backgroundColor = AlIslahTheme.customColors.statusRejectedBg,
                    borderColor = Color.Transparent
                ) {
                    Text(
                        text = uiState.errorMessage ?: "",
                        style = MaterialTheme.typography.bodyMedium,
                        color = AlIslahTheme.customColors.statusRejectedFg
                    )
                }
            }

            Spacer(modifier = Modifier.height(28.dp))

            // Submit Button
            AlIslahButton(
                text = "অনুদান সম্পন্ন করুন (${Formatters.formatBDT(amount.toDoubleOrNull() ?: 0.0)})",
                onClick = {
                    viewModel.submitDonation(
                        donorName = donorName,
                        amountText = amount,
                        paymentMethod = selectedAccount.displayType,
                        receivedAccountId = selectedAccount.id,
                        receivedAccountLabel = "${selectedAccount.displayType} - ${selectedAccount.number}",
                        transactionId = transactionId,
                        senderNumber = senderNumber,
                        notes = notes
                    )
                },
                modifier = Modifier.fillMaxWidth(),
                isLoading = uiState.isSubmitting,
                variant = ButtonVariant.PRIMARY
            )

            Spacer(modifier = Modifier.height(24.dp))
        }
    }
}
