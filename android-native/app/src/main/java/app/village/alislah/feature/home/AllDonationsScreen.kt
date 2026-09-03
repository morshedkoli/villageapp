package app.village.alislah.feature.home

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.VolunteerActivism
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import app.village.alislah.components.EmptyState
import app.village.alislah.components.AlIslahCard
import app.village.alislah.components.AlIslahTextField
import app.village.alislah.components.AlIslahTopBar
import app.village.alislah.components.StatusChip
import app.village.alislah.core.Formatters
import app.village.alislah.model.Donation
import app.village.alislah.theme.AlIslahPrimary
import app.village.alislah.theme.AlIslahTheme

@Composable
fun AllDonationsScreen(
    onBackClick: () -> Unit,
    viewModel: HomeViewModel = viewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    var searchQuery by remember { mutableStateOf("") }
    var selectedFilter by remember { mutableStateOf("All") }

    val filteredDonations = uiState.allDonations.filter { donation ->
        val matchesSearch = donation.donorName.contains(searchQuery, ignoreCase = true) ||
                donation.transactionId.contains(searchQuery, ignoreCase = true) ||
                donation.senderNumber.contains(searchQuery, ignoreCase = true)

        val matchesFilter = when (selectedFilter) {
            "Approved" -> donation.isApproved
            "Pending" -> donation.isPending
            else -> true
        }

        matchesSearch && matchesFilter
    }

    val totalSum = filteredDonations.filter { it.isApproved }.sumOf { it.amount }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .statusBarsPadding()
    ) {
        AlIslahTopBar(
            title = "সকল অনুদানের তালিকা",
            subtitle = "মোট সংগৃহীত: ${Formatters.formatBDT(totalSum)}",
            showBackButton = true,
            onBackClick = onBackClick
        )

        // Search and Filter Bar
        Column(modifier = Modifier.padding(horizontal = 20.dp, vertical = 8.dp)) {
            AlIslahTextField(
                value = searchQuery,
                onValueChange = { searchQuery = it },
                modifier = Modifier.fillMaxWidth(),
                placeholder = "দাতার নাম, ট্রানজেকশন আইডি দিয়ে খুঁজুন...",
                leadingIcon = {
                    Icon(
                        imageVector = Icons.Default.Search,
                        contentDescription = null,
                        tint = AlIslahTheme.customColors.textSecondary
                    )
                }
            )

            Spacer(modifier = Modifier.height(10.dp))

            LazyRow(
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                val filters = listOf("All" to "সকল অনুদান", "Approved" to "অনুমোদিত", "Pending" to "অপেক্ষমাণ")
                items(filters) { (key, label) ->
                    val isSelected = selectedFilter == key
                    FilterChip(
                        selected = isSelected,
                        onClick = { selectedFilter = key },
                        label = { Text(text = label) },
                        colors = FilterChipDefaults.filterChipColors(
                            selectedContainerColor = AlIslahPrimary.copy(alpha = 0.15f),
                            selectedLabelColor = AlIslahPrimary
                        )
                    )
                }
            }
        }

        if (filteredDonations.isEmpty()) {
            EmptyState(
                title = "কোনো অনুদান পাওয়া যায়নি",
                description = "আপনার অনুসন্ধান বা ফিল্টারের সাথে মিল রয়েছে এমন কোনো অনুদান পাওয়া যায়নি।"
            )
        } else {
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(horizontal = 20.dp, vertical = 8.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                items(filteredDonations) { donation ->
                    DonationDetailCard(donation = donation)
                }
            }
        }
    }
}

@Composable
private fun DonationDetailCard(donation: Donation) {
    AlIslahCard(modifier = Modifier.fillMaxWidth()) {
        Column(modifier = Modifier.fillMaxWidth()) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        modifier = Modifier
                            .size(40.dp)
                            .clip(RoundedCornerShape(10.dp))
                            .background(AlIslahPrimary.copy(alpha = 0.12f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.VolunteerActivism,
                            contentDescription = null,
                            tint = AlIslahPrimary,
                            modifier = Modifier.size(20.dp)
                        )
                    }
                    Spacer(modifier = Modifier.width(12.dp))
                    Column {
                        Text(
                            text = donation.donorName,
                            style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                            color = AlIslahTheme.customColors.textPrimary
                        )
                        Text(
                            text = Formatters.formatDateTime(donation.createdAt),
                            style = MaterialTheme.typography.bodySmall,
                            color = AlIslahTheme.customColors.textTertiary
                        )
                    }
                }

                StatusChip(status = donation.status)
            }

            Spacer(modifier = Modifier.height(14.dp))

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(10.dp))
                    .background(AlIslahTheme.customColors.cardBorder.copy(alpha = 0.3f))
                    .padding(10.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = "পেমেন্ট মেথড",
                        style = MaterialTheme.typography.labelSmall,
                        color = AlIslahTheme.customColors.textTertiary
                    )
                    Text(
                        text = "${donation.paymentMethod} (${donation.senderNumber})",
                        style = MaterialTheme.typography.bodySmall.copy(fontWeight = FontWeight.Medium),
                        color = AlIslahTheme.customColors.textPrimary
                    )
                }

                Column(horizontalAlignment = Alignment.End) {
                    Text(
                        text = "পরিমাণ",
                        style = MaterialTheme.typography.labelSmall,
                        color = AlIslahTheme.customColors.textTertiary
                    )
                    Text(
                        text = Formatters.formatBDT(donation.amount),
                        style = MaterialTheme.typography.titleMedium.copy(
                            fontWeight = FontWeight.Bold,
                            color = AlIslahPrimary
                        )
                    )
                }
            }

            if (donation.transactionId.isNotBlank()) {
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "TxID: ${donation.transactionId}",
                    style = MaterialTheme.typography.labelSmall,
                    color = AlIslahTheme.customColors.textSecondary
                )
            }
        }
    }
}
