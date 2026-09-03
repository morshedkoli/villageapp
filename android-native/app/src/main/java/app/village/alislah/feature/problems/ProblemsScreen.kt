package app.village.alislah.feature.problems

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
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material.icons.filled.ThumbUp
import androidx.compose.material.icons.outlined.ThumbUp
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
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import app.village.alislah.components.EmptyState
import app.village.alislah.components.AlIslahCard
import app.village.alislah.components.AlIslahTopBar
import app.village.alislah.components.StatusChip
import app.village.alislah.core.Formatters
import app.village.alislah.model.Problem
import app.village.alislah.theme.AlIslahPrimary
import app.village.alislah.theme.AlIslahTheme
import coil.compose.AsyncImage

@Composable
fun ProblemsScreen(
    onNavigateToReportProblem: () -> Unit,
    onNavigateToProblemDetails: (String) -> Unit,
    viewModel: ProblemsViewModel = viewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    var selectedTabIndex by remember { mutableIntStateOf(0) }
    val tabTitles = listOf("সকল", "অপেক্ষমাণ", "গৃহীত", "সমাধান")

    val filteredProblems = when (selectedTabIndex) {
        1 -> uiState.problems.filter { it.isPending }
        2 -> uiState.problems.filter { it.isApproved }
        3 -> uiState.problems.filter { it.isCompleted }
        else -> uiState.problems
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .statusBarsPadding()
    ) {
        Column(modifier = Modifier.fillMaxSize()) {
            AlIslahTopBar(title = "গ্রামের সমস্যা ও অভিযোগ")

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

            Spacer(modifier = Modifier.height(10.dp))

            if (filteredProblems.isEmpty()) {
                EmptyState(
                    title = "কোনো সমস্যা বা অভিযোগ নেই",
                    description = "আপনার এলাকায় কোনো সমস্যা থাকলে ছবি ও বিস্তারিত বিবরণসহ রিপোর্ট করুন।",
                    actionButtonText = "সমস্যা জানান",
                    onActionClick = onNavigateToReportProblem
                )
            } else {
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(start = 20.dp, end = 20.dp, top = 6.dp, bottom = 90.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    items(filteredProblems) { problem ->
                        ProblemCard(
                            problem = problem,
                            onClick = { onNavigateToProblemDetails(problem.id) },
                            onUpvote = { viewModel.toggleUpvote(problem.id) }
                        )
                    }
                }
            }
        }

        // Floating Action Button
        FloatingActionButton(
            onClick = onNavigateToReportProblem,
            modifier = Modifier
                .align(Alignment.BottomEnd)
                .padding(end = 20.dp, bottom = 80.dp),
            containerColor = AlIslahPrimary,
            contentColor = Color.White,
            shape = CircleShape
        ) {
            Icon(imageVector = Icons.Default.Add, contentDescription = "Report Problem")
        }
    }
}

@Composable
private fun ProblemCard(
    problem: Problem,
    onClick: () -> Unit,
    onUpvote: () -> Unit
) {
    AlIslahCard(
        modifier = Modifier.fillMaxWidth(),
        onClick = onClick
    ) {
        Column(modifier = Modifier.fillMaxWidth()) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                StatusChip(status = problem.status)
                Text(
                    text = Formatters.formatRelativeTime(problem.createdAt),
                    style = MaterialTheme.typography.labelSmall,
                    color = AlIslahTheme.customColors.textTertiary
                )
            }

            Spacer(modifier = Modifier.height(10.dp))

            Text(
                text = problem.title,
                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                color = AlIslahTheme.customColors.textPrimary,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis
            )

            Spacer(modifier = Modifier.height(6.dp))

            Text(
                text = problem.description,
                style = MaterialTheme.typography.bodyMedium,
                color = AlIslahTheme.customColors.textSecondary,
                maxLines = 3,
                overflow = TextOverflow.Ellipsis
            )

            // Optional Image Preview
            if (problem.photoUrl.isNotBlank()) {
                Spacer(modifier = Modifier.height(12.dp))
                AsyncImage(
                    model = problem.photoUrl,
                    contentDescription = problem.title,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(160.dp)
                        .clip(RoundedCornerShape(12.dp)),
                    contentScale = ContentScale.Crop
                )
            }

            Spacer(modifier = Modifier.height(14.dp))

            // Footer with Location and Upvote button
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                if (problem.location.isNotBlank()) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        modifier = Modifier.weight(1f, fill = false)
                    ) {
                        Icon(
                            imageVector = Icons.Default.LocationOn,
                            contentDescription = null,
                            tint = AlIslahTheme.customColors.textTertiary,
                            modifier = Modifier.size(16.dp)
                        )
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(
                            text = problem.location,
                            style = MaterialTheme.typography.labelSmall,
                            color = AlIslahTheme.customColors.textSecondary,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    }
                } else {
                    Text(
                        text = "রিপোর্টার: ${problem.reportedByName}",
                        style = MaterialTheme.typography.labelSmall,
                        color = AlIslahTheme.customColors.textTertiary
                    )
                }

                // Upvote Button
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(20.dp))
                        .background(
                            if (problem.hasVoted) AlIslahPrimary.copy(alpha = 0.15f)
                            else AlIslahTheme.customColors.cardBorder.copy(alpha = 0.5f)
                        )
                        .clickable { onUpvote() }
                        .padding(horizontal = 12.dp, vertical = 6.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = if (problem.hasVoted) Icons.Filled.ThumbUp else Icons.Outlined.ThumbUp,
                            contentDescription = "Upvote",
                            tint = if (problem.hasVoted) AlIslahPrimary else AlIslahTheme.customColors.textSecondary,
                            modifier = Modifier.size(16.dp)
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                        Text(
                            text = "${problem.upvotesCount}",
                            style = MaterialTheme.typography.labelSmall.copy(fontWeight = FontWeight.Bold),
                            color = if (problem.hasVoted) AlIslahPrimary else AlIslahTheme.customColors.textSecondary
                        )
                    }
                }
            }
        }
    }
}
