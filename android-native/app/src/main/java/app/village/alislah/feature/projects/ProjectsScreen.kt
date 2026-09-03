package app.village.alislah.feature.projects

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
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowForward
import androidx.compose.material.icons.filled.Construction
import androidx.compose.material3.Icon
import androidx.compose.material3.LinearProgressIndicator
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
import androidx.compose.ui.graphics.StrokeCap
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
import app.village.alislah.model.Project
import app.village.alislah.theme.CardShape
import app.village.alislah.theme.AlIslahPrimary
import app.village.alislah.theme.AlIslahTheme
import coil.compose.AsyncImage

@Composable
fun ProjectsScreen(
    onNavigateToProjectDetails: (String) -> Unit,
    onBackClick: (() -> Unit)? = null,
    viewModel: ProjectsViewModel = viewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    var selectedTabIndex by remember { mutableIntStateOf(0) }
    val tabTitles = listOf("সকল", "চলমান", "পরিকল্পনা", "সম্পন্ন")

    val filteredProjects = when (selectedTabIndex) {
        1 -> uiState.projects.filter { it.isInProgress }
        2 -> uiState.projects.filter { it.status.equals("Planning", ignoreCase = true) }
        3 -> uiState.projects.filter { it.isCompleted }
        else -> uiState.projects
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .statusBarsPadding()
    ) {
        AlIslahTopBar(
            title = "উন্নয়ন প্রকল্পসমূহ",
            showBackButton = onBackClick != null,
            onBackClick = onBackClick ?: {}
        )

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

        if (filteredProjects.isEmpty()) {
            EmptyState(
                title = "কোনো উন্নয়ন প্রকল্প নেই",
                description = "বর্তমানে এই বিভাগে কোনো উন্নয়ন প্রকল্প তালিকাভুক্ত নেই।"
            )
        } else {
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(start = 20.dp, end = 20.dp, top = 6.dp, bottom = 90.dp),
                verticalArrangement = Arrangement.spacedBy(14.dp)
            ) {
                items(filteredProjects) { project ->
                    ProjectCard(
                        project = project,
                        onClick = { onNavigateToProjectDetails(project.id) }
                    )
                }
            }
        }
    }
}

@Composable
private fun ProjectCard(
    project: Project,
    onClick: () -> Unit
) {
    AlIslahCard(
        modifier = Modifier.fillMaxWidth(),
        onClick = onClick
    ) {
        Column(modifier = Modifier.fillMaxWidth()) {
            // Optional photo thumbnail
            if (project.photos.isNotEmpty()) {
                AsyncImage(
                    model = project.photos.first(),
                    contentDescription = project.title,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(140.dp)
                        .clip(CardShape),
                    contentScale = ContentScale.Crop
                )
                Spacer(modifier = Modifier.height(12.dp))
            }

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                StatusChip(status = project.status)
                Text(
                    text = "${project.progressPercentage.toInt()}% সম্পন্ন",
                    style = MaterialTheme.typography.labelMedium.copy(fontWeight = FontWeight.Bold),
                    color = AlIslahPrimary
                )
            }

            Spacer(modifier = Modifier.height(10.dp))

            Text(
                text = project.title,
                style = MaterialTheme.typography.titleLarge.copy(
                    fontWeight = FontWeight.Bold,
                    fontSize = 18.sp
                ),
                color = AlIslahTheme.customColors.textPrimary,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis
            )

            Spacer(modifier = Modifier.height(6.dp))

            Text(
                text = project.description,
                style = MaterialTheme.typography.bodyMedium,
                color = AlIslahTheme.customColors.textSecondary,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis
            )

            Spacer(modifier = Modifier.height(14.dp))

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

            Spacer(modifier = Modifier.height(12.dp))

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(8.dp))
                    .background(AlIslahTheme.customColors.cardBorder.copy(alpha = 0.3f))
                    .padding(8.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = "বরাদ্দকৃত তহবিল",
                        style = MaterialTheme.typography.labelSmall,
                        color = AlIslahTheme.customColors.textTertiary
                    )
                    Text(
                        text = Formatters.formatBDT(project.allocatedFunds),
                        style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold),
                        color = AlIslahPrimary
                    )
                }

                Column(horizontalAlignment = Alignment.End) {
                    Text(
                        text = "মোট প্রাক্কলিত বাজেট",
                        style = MaterialTheme.typography.labelSmall,
                        color = AlIslahTheme.customColors.textTertiary
                    )
                    Text(
                        text = Formatters.formatBDT(project.estimatedCost),
                        style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold),
                        color = AlIslahTheme.customColors.textPrimary
                    )
                }
            }
        }
    }
}
