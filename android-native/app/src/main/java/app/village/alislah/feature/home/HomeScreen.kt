package app.village.alislah.feature.home

import androidx.compose.foundation.background
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
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AccountBalance
import androidx.compose.material.icons.filled.ArrowDownward
import androidx.compose.material.icons.filled.ArrowForward
import androidx.compose.material.icons.filled.ArrowOutward
import androidx.compose.material.icons.filled.ArrowUpward
import androidx.compose.material.icons.filled.Assessment
import androidx.compose.material.icons.filled.Campaign
import androidx.compose.material.icons.filled.Construction
import androidx.compose.material.icons.filled.Diversity3
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.People
import androidx.compose.material.icons.filled.VolunteerActivism
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import app.village.alislah.components.AlIslahCard
import app.village.alislah.components.KpiCard
import app.village.alislah.components.ShimmerCard
import app.village.alislah.components.StatusChip
import app.village.alislah.core.Formatters
import app.village.alislah.model.Donation
import app.village.alislah.model.FundTransaction
import app.village.alislah.model.Project
import app.village.alislah.theme.CardShape
import app.village.alislah.theme.AlIslahError
import app.village.alislah.theme.AlIslahPrimary
import app.village.alislah.theme.AlIslahPrimaryLight
import app.village.alislah.theme.AlIslahTheme

@Composable
fun HomeScreen(
    onNavigateToDonationCheckout: () -> Unit,
    onNavigateToAllDonations: () -> Unit,
    onNavigateToAllExpenses: () -> Unit,
    onNavigateToProblems: () -> Unit,
    onNavigateToReportProblem: () -> Unit,
    onNavigateToProjects: () -> Unit,
    onNavigateToProjectDetails: (String) -> Unit,
    onNavigateToCitizens: () -> Unit,
    onNavigateToLeaders: () -> Unit,
    onNavigateToReports: () -> Unit,
    onNavigateToNotifications: () -> Unit,
    viewModel: HomeViewModel = viewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background),
        contentPadding = PaddingValues(bottom = 90.dp)
    ) {
        // Top Header / Greeting Bar
        item {
            HeaderSection(
                userName = uiState.userProfile?.name ?: "সম্মানিত গ্রামবাসী",
                villageName = uiState.village.name,
                unreadCount = uiState.unreadNotificationsCount,
                onNotificationClick = onNavigateToNotifications
            )
        }

        // Hero Fund Balance Card
        item {
            HeroFundCard(
                availableBalance = uiState.village.availableBalance,
                totalCollected = uiState.village.totalFundCollected,
                totalSpent = uiState.village.totalSpent,
                onDonateClick = onNavigateToDonationCheckout,
                onViewExpensesClick = onNavigateToAllExpenses
            )
        }

        // Quick Action Grid Shortcuts
        item {
            QuickActionsSection(
                onDonate = onNavigateToDonationCheckout,
                onReportProblem = onNavigateToReportProblem,
                onProjects = onNavigateToProjects,
                onCitizens = onNavigateToCitizens,
                onLeaders = onNavigateToLeaders,
                onReports = onNavigateToReports
            )
        }

        // 4 KPI Summary Cards
        item {
            KpiMetricsGrid(
                totalCitizens = uiState.village.totalCitizens,
                activeProjects = uiState.activeProjects.size,
                pendingProblems = uiState.pendingProblems.size,
                emergencyFund = uiState.village.emergencyFund,
                onCitizensClick = onNavigateToCitizens,
                onProjectsClick = onNavigateToProjects,
                onProblemsClick = onNavigateToProblems,
                onEmergencyClick = onNavigateToReports
            )
        }

        // Active Development Projects Carousel
        if (uiState.activeProjects.isNotEmpty()) {
            item {
                SectionHeader(
                    title = "চলমান উন্নয়ন প্রকল্প",
                    actionTitle = "সকল প্রকল্প",
                    onActionClick = onNavigateToProjects
                )
            }
            item {
                ActiveProjectsCarousel(
                    projects = uiState.activeProjects,
                    onProjectClick = onNavigateToProjectDetails
                )
            }
        }

        // Recent Donations Feed
        item {
            SectionHeader(
                title = "সাম্প্রতিক অনুদান",
                actionTitle = "সকল অনুদান",
                onActionClick = onNavigateToAllDonations
            )
        }
        if (uiState.recentDonations.isEmpty()) {
            item {
                EmptyInlineState(message = "এখনও কোনো সাম্প্রতিক অনুদান নেই")
            }
        } else {
            items(uiState.recentDonations) { donation ->
                DonationListItem(donation = donation)
            }
        }

        // Recent Expenses / Fund Transparency
        item {
            Spacer(modifier = Modifier.height(12.dp))
            SectionHeader(
                title = "সাম্প্রতিক ব্যয় ও উন্নয়ন খরচ",
                actionTitle = "সকল ব্যয় বিবরণ",
                onActionClick = onNavigateToAllExpenses
            )
        }
        if (uiState.recentExpenses.isEmpty()) {
            item {
                EmptyInlineState(message = "কোনো ব্যয়ের রেকর্ড নেই")
            }
        } else {
            items(uiState.recentExpenses) { expense ->
                ExpenseListItem(expense = expense)
            }
        }
    }
}

@Composable
private fun HeaderSection(
    userName: String,
    villageName: String,
    unreadCount: Int,
    onNotificationClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .statusBarsPadding()
            .padding(horizontal = 20.dp, vertical = 16.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column {
            Text(
                text = "আসসালামু আলাইকুম 👋",
                style = MaterialTheme.typography.bodyMedium,
                color = AlIslahTheme.customColors.textSecondary
            )
            Text(
                text = userName,
                style = MaterialTheme.typography.headlineSmall.copy(
                    fontWeight = FontWeight.Bold,
                    fontSize = 20.sp
                ),
                color = AlIslahTheme.customColors.textPrimary,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }

        IconButton(onClick = onNotificationClick) {
            Box(contentAlignment = Alignment.TopEnd) {
                Box(
                    modifier = Modifier
                        .size(42.dp)
                        .clip(CircleShape)
                        .background(AlIslahTheme.customColors.cardBackground),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Notifications,
                        contentDescription = "Notifications",
                        tint = AlIslahTheme.customColors.textPrimary,
                        modifier = Modifier.size(22.dp)
                    )
                }
                if (unreadCount > 0) {
                    Box(
                        modifier = Modifier
                            .offset(x = 2.dp, y = (-2).dp)
                            .size(16.dp)
                            .clip(CircleShape)
                            .background(AlIslahError),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = if (unreadCount > 9) "9+" else unreadCount.toString(),
                            style = MaterialTheme.typography.labelSmall.copy(
                                fontSize = 9.sp,
                                fontWeight = FontWeight.Bold
                            ),
                            color = Color.White
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun HeroFundCard(
    availableBalance: Double,
    totalCollected: Double,
    totalSpent: Double,
    onDonateClick: () -> Unit,
    onViewExpensesClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp, vertical = 8.dp),
        shape = CardShape,
        colors = CardDefaults.cardColors(containerColor = Color.Transparent)
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(AlIslahTheme.customColors.heroGradient)
                .padding(22.dp)
        ) {
            Column(modifier = Modifier.fillMaxWidth()) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "গ্রাম উন্নয়ন তহবিল (অবশিষ্ট স্থিতি)",
                        style = MaterialTheme.typography.titleSmall,
                        color = Color.White.copy(alpha = 0.85f)
                    )
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(8.dp))
                            .background(Color.White.copy(alpha = 0.2f))
                            .clickable { onViewExpensesClick() }
                            .padding(horizontal = 8.dp, vertical = 4.dp)
                    ) {
                        Text(
                            text = "হিসাব বিবরণী",
                            style = MaterialTheme.typography.labelSmall,
                            color = Color.White
                        )
                    }
                }

                Spacer(modifier = Modifier.height(10.dp))

                Text(
                    text = Formatters.formatBDT(availableBalance),
                    style = MaterialTheme.typography.displayMedium.copy(
                        fontWeight = FontWeight.ExtraBold,
                        fontSize = 32.sp
                    ),
                    color = Color.White
                )

                Spacer(modifier = Modifier.height(20.dp))

                // Inflow and Outflow Sub-cards
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .clip(RoundedCornerShape(14.dp))
                            .background(Color.White.copy(alpha = 0.15f))
                            .padding(12.dp)
                    ) {
                        Column {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(
                                    imageVector = Icons.Default.ArrowDownward,
                                    contentDescription = null,
                                    tint = AlIslahPrimaryLight,
                                    modifier = Modifier.size(16.dp)
                                )
                                Spacer(modifier = Modifier.width(4.dp))
                                Text(
                                    text = "মোট অনুদান",
                                    style = MaterialTheme.typography.labelSmall,
                                    color = Color.White.copy(alpha = 0.85f)
                                )
                            }
                            Spacer(modifier = Modifier.height(4.dp))
                            Text(
                                text = Formatters.formatBDT(totalCollected),
                                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                                color = Color.White,
                                maxLines = 1
                            )
                        }
                    }

                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .clip(RoundedCornerShape(14.dp))
                            .background(Color.White.copy(alpha = 0.15f))
                            .padding(12.dp)
                    ) {
                        Column {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(
                                    imageVector = Icons.Default.ArrowUpward,
                                    contentDescription = null,
                                    tint = Color(0xFFFCA5A5),
                                    modifier = Modifier.size(16.dp)
                                )
                                Spacer(modifier = Modifier.width(4.dp))
                                Text(
                                    text = "মোট ব্যয়",
                                    style = MaterialTheme.typography.labelSmall,
                                    color = Color.White.copy(alpha = 0.85f)
                                )
                            }
                            Spacer(modifier = Modifier.height(4.dp))
                            Text(
                                text = Formatters.formatBDT(totalSpent),
                                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                                color = Color.White,
                                maxLines = 1
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(18.dp))

                // Donate Action Button
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(12.dp))
                        .background(Color.White)
                        .clickable { onDonateClick() }
                        .padding(vertical = 12.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = Icons.Default.VolunteerActivism,
                            contentDescription = null,
                            tint = Color(0xFF16A34A),
                            modifier = Modifier.size(20.dp)
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            text = "তহবিলে অনুদান দিন",
                            style = MaterialTheme.typography.labelLarge.copy(
                                fontWeight = FontWeight.Bold,
                                color = Color(0xFF16A34A)
                            )
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun QuickActionsSection(
    onDonate: () -> Unit,
    onReportProblem: () -> Unit,
    onProjects: () -> Unit,
    onCitizens: () -> Unit,
    onLeaders: () -> Unit,
    onReports: () -> Unit
) {
    val actions = listOf(
        QuickActionItem("অনুদান দিন", Icons.Default.Favorite, AlIslahPrimary, onDonate),
        QuickActionItem("সমস্যা জানান", Icons.Default.Campaign, Color(0xFFF59E0B), onReportProblem),
        QuickActionItem("উন্নয়ন প্রকল্প", Icons.Default.Construction, Color(0xFF0EA5E9), onProjects),
        QuickActionItem("নাগরিক তালিকা", Icons.Default.People, Color(0xFF8B5CF6), onCitizens),
        QuickActionItem("গ্রাম কমিটি", Icons.Default.Diversity3, Color(0xFFEC4899), onLeaders),
        QuickActionItem("অডিট ও রিপোর্ট", Icons.Default.Assessment, Color(0xFF14B8A6), onReports)
    )

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp, vertical = 12.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            actions.take(3).forEach { item ->
                QuickActionButton(item = item, modifier = Modifier.weight(1f))
            }
        }

        Spacer(modifier = Modifier.height(10.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            actions.drop(3).forEach { item ->
                QuickActionButton(item = item, modifier = Modifier.weight(1f))
            }
        }
    }
}

private data class QuickActionItem(
    val title: String,
    val icon: ImageVector,
    val color: Color,
    val onClick: () -> Unit
)

@Composable
private fun QuickActionButton(item: QuickActionItem, modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .clickable { item.onClick() }
            .padding(vertical = 6.dp, horizontal = 4.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Box(
            modifier = Modifier
                .size(52.dp)
                .clip(RoundedCornerShape(16.dp))
                .background(item.color.copy(alpha = 0.12f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = item.icon,
                contentDescription = item.title,
                tint = item.color,
                modifier = Modifier.size(26.dp)
            )
        }
        Spacer(modifier = Modifier.height(6.dp))
        Text(
            text = item.title,
            style = MaterialTheme.typography.labelSmall.copy(fontWeight = FontWeight.Medium),
            color = AlIslahTheme.customColors.textPrimary,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )
    }
}

@Composable
private fun KpiMetricsGrid(
    totalCitizens: Int,
    activeProjects: Int,
    pendingProblems: Int,
    emergencyFund: Double,
    onCitizensClick: () -> Unit,
    onProjectsClick: () -> Unit,
    onProblemsClick: () -> Unit,
    onEmergencyClick: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp, vertical = 8.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            KpiCard(
                title = "মোট নাগরিক",
                value = "$totalCitizens জন",
                icon = Icons.Default.People,
                iconColor = Color(0xFF0EA5E9),
                iconBgColor = Color(0xFFE0F2FE),
                modifier = Modifier.weight(1f),
                subtitle = "নিবন্ধিত গ্রামবাসী",
                onClick = onCitizensClick
            )
            KpiCard(
                title = "চলমান প্রকল্প",
                value = "$activeProjects টি",
                icon = Icons.Default.Construction,
                iconColor = AlIslahPrimary,
                iconBgColor = AlIslahPrimary.copy(alpha = 0.12f),
                modifier = Modifier.weight(1f),
                subtitle = "উন্নয়নমূলক কাজ",
                onClick = onProjectsClick
            )
        }

        Spacer(modifier = Modifier.height(12.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            KpiCard(
                title = "নতুন সমস্যা",
                value = "$pendingProblems টি",
                icon = Icons.Default.Campaign,
                iconColor = Color(0xFFF59E0B),
                iconBgColor = Color(0xFFFEF3C7),
                modifier = Modifier.weight(1f),
                subtitle = "অপেক্ষমাণ রিপোর্ট",
                onClick = onProblemsClick
            )
            KpiCard(
                title = "জরুরি তহবিল",
                value = Formatters.formatBDT(emergencyFund),
                icon = Icons.Default.AccountBalance,
                iconColor = Color(0xFF8B5CF6),
                iconBgColor = Color(0xFFF3E8FF),
                modifier = Modifier.weight(1f),
                subtitle = "দুর্যোগ ফান্ড",
                onClick = onEmergencyClick
            )
        }
    }
}

@Composable
private fun ActiveProjectsCarousel(
    projects: List<Project>,
    onProjectClick: (String) -> Unit
) {
    LazyRow(
        modifier = Modifier.fillMaxWidth(),
        contentPadding = PaddingValues(horizontal = 20.dp),
        horizontalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        items(projects) { project ->
            AlIslahCard(
                modifier = Modifier.width(280.dp),
                onClick = { onProjectClick(project.id) }
            ) {
                Column(modifier = Modifier.fillMaxWidth()) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        StatusChip(status = project.status)
                        Text(
                            text = "${project.progressPercentage.toInt()}% সম্পন্ন",
                            style = MaterialTheme.typography.labelSmall.copy(fontWeight = FontWeight.Bold),
                            color = AlIslahPrimary
                        )
                    }

                    Spacer(modifier = Modifier.height(10.dp))

                    Text(
                        text = project.title,
                        style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                        color = AlIslahTheme.customColors.textPrimary,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )

                    Spacer(modifier = Modifier.height(4.dp))

                    Text(
                        text = project.description,
                        style = MaterialTheme.typography.bodySmall,
                        color = AlIslahTheme.customColors.textSecondary,
                        maxLines = 2,
                        overflow = TextOverflow.Ellipsis
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    LinearProgressIndicator(
                        progress = { project.progressPercentage / 100f },
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(6.dp)
                            .clip(RoundedCornerShape(3.dp)),
                        color = AlIslahPrimary,
                        trackColor = AlIslahTheme.customColors.cardBorder,
                        strokeCap = StrokeCap.Round
                    )

                    Spacer(modifier = Modifier.height(10.dp))

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text(
                            text = "বাজেট: ${Formatters.formatBDT(project.estimatedCost)}",
                            style = MaterialTheme.typography.labelSmall,
                            color = AlIslahTheme.customColors.textTertiary
                        )
                        Icon(
                            imageVector = Icons.Default.ArrowOutward,
                            contentDescription = null,
                            tint = AlIslahPrimary,
                            modifier = Modifier.size(16.dp)
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun DonationListItem(donation: Donation) {
    AlIslahCard(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp, vertical = 4.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(44.dp)
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

            Spacer(modifier = Modifier.width(14.dp))

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = donation.donorName,
                    style = MaterialTheme.typography.titleSmall.copy(fontWeight = FontWeight.SemiBold),
                    color = AlIslahTheme.customColors.textPrimary,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Text(
                    text = "${donation.paymentMethod} • ${Formatters.formatRelativeTime(donation.createdAt)}",
                    style = MaterialTheme.typography.bodySmall,
                    color = AlIslahTheme.customColors.textTertiary
                )
            }

            Column(horizontalAlignment = Alignment.End) {
                Text(
                    text = "+ ${Formatters.formatBDT(donation.amount)}",
                    style = MaterialTheme.typography.titleMedium.copy(
                        fontWeight = FontWeight.Bold,
                        color = AlIslahPrimary
                    )
                )
                StatusChip(status = donation.status)
            }
        }
    }
}

@Composable
private fun ExpenseListItem(expense: FundTransaction) {
    AlIslahCard(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp, vertical = 4.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .clip(RoundedCornerShape(12.dp))
                    .background(Color(0xFFEF4444).copy(alpha = 0.12f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.ArrowUpward,
                    contentDescription = null,
                    tint = Color(0xFFEF4444),
                    modifier = Modifier.size(22.dp)
                )
            }

            Spacer(modifier = Modifier.width(14.dp))

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = expense.project,
                    style = MaterialTheme.typography.titleSmall.copy(fontWeight = FontWeight.SemiBold),
                    color = AlIslahTheme.customColors.textPrimary,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Text(
                    text = "${expense.category} • ${Formatters.formatRelativeTime(expense.createdAt)}",
                    style = MaterialTheme.typography.bodySmall,
                    color = AlIslahTheme.customColors.textTertiary
                )
            }

            Text(
                text = "- ${Formatters.formatBDT(expense.amount)}",
                style = MaterialTheme.typography.titleMedium.copy(
                    fontWeight = FontWeight.Bold,
                    color = Color(0xFFEF4444)
                )
            )
        }
    }
}

@Composable
private fun SectionHeader(
    title: String,
    actionTitle: String? = null,
    onActionClick: (() -> Unit)? = null
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp, vertical = 12.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = title,
            style = MaterialTheme.typography.titleLarge.copy(
                fontWeight = FontWeight.Bold,
                fontSize = 17.sp
            ),
            color = AlIslahTheme.customColors.textPrimary
        )

        if (actionTitle != null && onActionClick != null) {
            Row(
                modifier = Modifier.clickable { onActionClick() },
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = actionTitle,
                    style = MaterialTheme.typography.labelSmall.copy(
                        fontWeight = FontWeight.SemiBold,
                        color = AlIslahPrimary
                    )
                )
                Icon(
                    imageVector = Icons.Default.ArrowForward,
                    contentDescription = null,
                    tint = AlIslahPrimary,
                    modifier = Modifier.size(14.dp)
                )
            }
        }
    }
}

@Composable
private fun EmptyInlineState(message: String) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp, vertical = 12.dp)
            .clip(CardShape)
            .background(AlIslahTheme.customColors.cardBackground)
            .padding(16.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = message,
            style = MaterialTheme.typography.bodyMedium,
            color = AlIslahTheme.customColors.textTertiary
        )
    }
}
