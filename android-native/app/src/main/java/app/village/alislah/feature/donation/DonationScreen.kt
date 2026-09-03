package app.village.alislah.feature.donation

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
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.VolunteerActivism
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Tab
import androidx.compose.material3.TabRow
import androidx.compose.material3.TabRowDefaults
import androidx.compose.material3.TabRowDefaults.tabIndicatorOffset
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import app.village.alislah.components.ButtonVariant
import app.village.alislah.components.EmptyState
import app.village.alislah.components.AlIslahButton
import app.village.alislah.components.AlIslahCard
import app.village.alislah.components.AlIslahTopBar
import app.village.alislah.components.StatusChip
import app.village.alislah.core.Formatters
import app.village.alislah.model.Donation
import app.village.alislah.theme.CardShape
import app.village.alislah.theme.AlIslahPrimary
import app.village.alislah.theme.AlIslahTheme
import app.village.alislah.theme.PrimaryGradient

@Composable
fun DonationScreen(
    onNavigateToCheckout: () -> Unit,
    viewModel: DonationViewModel = viewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    var selectedTabIndex by remember { mutableIntStateOf(0) }
    val tabTitles = listOf("সকল অনুদান", "অনুমোদিত", "অপেক্ষমাণ")

    val filteredDonations = when (selectedTabIndex) {
        1 -> uiState.donations.filter { it.isApproved }
        2 -> uiState.donations.filter { it.isPending }
        else -> uiState.donations
    }

    val totalApprovedAmount = uiState.donations.filter { it.isApproved }.sumOf { it.amount }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .statusBarsPadding()
    ) {
        Column(modifier = Modifier.fillMaxSize()) {
            AlIslahTopBar(title = "গ্রাম অনুদান তহবিল")

            // Top CTA Card
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp, vertical = 8.dp)
                    .clip(CardShape)
                    .background(PrimaryGradient)
                    .padding(20.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "মোট সংগৃহীত অনুদান",
                            style = MaterialTheme.typography.titleSmall,
                            color = Color.White.copy(alpha = 0.85f)
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = Formatters.formatBDT(totalApprovedAmount),
                            style = MaterialTheme.typography.headlineMedium.copy(
                                fontWeight = FontWeight.ExtraBold,
                                fontSize = 24.sp
                            ),
                            color = Color.White
                        )
                    }

                    AlIslahButton(
                        text = "দান করুন",
                        onClick = onNavigateToCheckout,
                        variant = ButtonVariant.SECONDARY,
                        height = 42.dp,
                        icon = Icons.Default.Add
                    )
                }
            }

            // Tab Row
            TabRow(
                selectedTabIndex = selectedTabIndex,
                containerColor = MaterialTheme.colorScheme.background,
                contentColor = AlIslahPrimary,
                indicator = { tabPositions ->
                    TabRowDefaults.SecondaryIndicator(
                        Modifier.tabIndicatorOffset(tabPositions[selectedTabIndex]),
                        color = AlIslahPrimary
                    )
                },
                modifier = Modifier.padding(horizontal = 20.dp)
            ) {
                tabTitles.forEachIndexed { index, title ->
                    Tab(
                        selected = selectedTabIndex == index,
                        onClick = { selectedTabIndex = index },
                        text = {
                            Text(
                                text = title,
                                style = MaterialTheme.typography.labelLarge.copy(
                                    fontWeight = if (selectedTabIndex == index) FontWeight.Bold else FontWeight.Normal
                                )
                            )
                        }
                    )
                }
            }

            Spacer(modifier = Modifier.height(8.dp))

            if (filteredDonations.isEmpty()) {
                EmptyState(
                    title = "কোনো অনুদান পাওয়া যায়নি",
                    description = "এই ক্যাটাগরিতে বর্তমানে কোনো অনুদানের রেকর্ড নেই।",
                    actionButtonText = "প্রথম অনুদানটি দিন",
                    onActionClick = onNavigateToCheckout
                )
            } else {
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(start = 20.dp, end = 20.dp, top = 8.dp, bottom = 90.dp),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    items(filteredDonations) { donation ->
                        DonationFeedCard(donation = donation)
                    }
                }
            }
        }

        // Floating Action Button
        FloatingActionButton(
            onClick = onNavigateToCheckout,
            modifier = Modifier
                .align(Alignment.BottomEnd)
                .padding(end = 20.dp, bottom = 80.dp),
            containerColor = AlIslahPrimary,
            contentColor = Color.White,
            shape = CircleShape
        ) {
            Icon(imageVector = Icons.Default.Add, contentDescription = "Donate")
        }
    }
}

@Composable
private fun DonationFeedCard(donation: Donation) {
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
                            .size(42.dp)
                            .clip(RoundedCornerShape(12.dp))
                            .background(AlIslahPrimary.copy(alpha = 0.12f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.VolunteerActivism,
                            contentDescription = null,
                            tint = AlIslahPrimary,
                            modifier = Modifier.size(22.dp)
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

            Spacer(modifier = Modifier.height(12.dp))

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
                        text = "পেমেন্ট মাধ্যম",
                        style = MaterialTheme.typography.labelSmall,
                        color = AlIslahTheme.customColors.textTertiary
                    )
                    Text(
                        text = "${donation.paymentMethod} • ${donation.senderNumber}",
                        style = MaterialTheme.typography.bodySmall.copy(fontWeight = FontWeight.Medium),
                        color = AlIslahTheme.customColors.textPrimary
                    )
                }

                Text(
                    text = "+ ${Formatters.formatBDT(donation.amount)}",
                    style = MaterialTheme.typography.titleMedium.copy(
                        fontWeight = FontWeight.Bold,
                        color = AlIslahPrimary
                    )
                )
            }

            if (donation.transactionId.isNotBlank()) {
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                    text = "TxID: ${donation.transactionId}",
                    style = MaterialTheme.typography.labelSmall,
                    color = AlIslahTheme.customColors.textTertiary
                )
            }
        }
    }
}
