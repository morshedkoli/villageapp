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
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AccountBalance
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Construction
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import app.village.alislah.components.EmptyState
import app.village.alislah.components.AlIslahCard
import app.village.alislah.components.AlIslahTopBar
import app.village.alislah.components.ProgressRing
import app.village.alislah.components.StatusChip
import app.village.alislah.components.TimelineItem
import app.village.alislah.core.Formatters
import app.village.alislah.theme.CardShape
import app.village.alislah.theme.AlIslahPrimary
import app.village.alislah.theme.AlIslahTheme
import coil.compose.AsyncImage

@Composable
fun ProjectDetailsScreen(
    projectId: String,
    onBackClick: () -> Unit,
    viewModel: ProjectsViewModel = viewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val project = uiState.projects.find { it.id == projectId }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .statusBarsPadding()
    ) {
        AlIslahTopBar(
            title = "প্রকল্পের বিস্তারিত",
            showBackButton = true,
            onBackClick = onBackClick
        )

        if (project == null) {
            EmptyState(
                title = "প্রকল্পটি পাওয়া যায়নি",
                description = "প্রকল্পের তথ্য লোড করা সম্ভব হয়নি।"
            )
        } else {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
                    .padding(20.dp)
            ) {
                // Photo Gallery Carousel (if any)
                if (project.photos.isNotEmpty()) {
                    LazyRow(
                        horizontalArrangement = Arrangement.spacedBy(10.dp),
                        contentPadding = PaddingValues(bottom = 6.dp)
                    ) {
                        items(project.photos) { photoUrl ->
                            AsyncImage(
                                model = photoUrl,
                                contentDescription = project.title,
                                modifier = Modifier
                                    .width(280.dp)
                                    .height(180.dp)
                                    .clip(CardShape),
                                contentScale = ContentScale.Crop
                            )
                        }
                    }
                    Spacer(modifier = Modifier.height(16.dp))
                }

                // Header Card with Title & Progress Ring
                AlIslahCard(modifier = Modifier.fillMaxWidth()) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column(modifier = Modifier.weight(1f)) {
                            StatusChip(status = project.status)
                            Spacer(modifier = Modifier.height(8.dp))
                            Text(
                                text = project.title,
                                style = MaterialTheme.typography.titleLarge.copy(
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 19.sp
                                ),
                                color = AlIslahTheme.customColors.textPrimary
                            )
                        }
                        Spacer(modifier = Modifier.width(12.dp))
                        ProgressRing(
                            progress = project.progressPercentage / 100f,
                            size = 72.dp,
                            strokeWidth = 7.dp
                        )
                    }
                }

                Spacer(modifier = Modifier.height(14.dp))

                // Budget & Funding Summary Cards
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    AlIslahCard(modifier = Modifier.weight(1f)) {
                        Column {
                            Text(
                                text = "প্রাক্কলিত বাজেট",
                                style = MaterialTheme.typography.labelSmall,
                                color = AlIslahTheme.customColors.textTertiary
                            )
                            Spacer(modifier = Modifier.height(4.dp))
                            Text(
                                text = Formatters.formatBDT(project.estimatedCost),
                                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                                color = AlIslahTheme.customColors.textPrimary
                            )
                        }
                    }

                    AlIslahCard(modifier = Modifier.weight(1f)) {
                        Column {
                            Text(
                                text = "বরাদ্দকৃত তহবিল",
                                style = MaterialTheme.typography.labelSmall,
                                color = AlIslahTheme.customColors.textTertiary
                            )
                            Spacer(modifier = Modifier.height(4.dp))
                            Text(
                                text = Formatters.formatBDT(project.allocatedFunds),
                                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                                color = AlIslahPrimary
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(14.dp))

                // Description Box
                AlIslahCard(modifier = Modifier.fillMaxWidth()) {
                    Column {
                        Text(
                            text = "প্রকল্পের বিবরণ ও উদ্দেশ্য",
                            style = MaterialTheme.typography.titleSmall.copy(fontWeight = FontWeight.Bold),
                            color = AlIslahTheme.customColors.textPrimary
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = project.description,
                            style = MaterialTheme.typography.bodyLarge,
                            color = AlIslahTheme.customColors.textSecondary,
                            lineHeight = 22.sp
                        )
                    }
                }

                // Project Milestone Updates Timeline (if any)
                if (project.updates.isNotEmpty()) {
                    Spacer(modifier = Modifier.height(20.dp))
                    Text(
                        text = "কাজের অগ্রগতি ও আপডেটসমূহ",
                        style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                        color = AlIslahTheme.customColors.textPrimary
                    )
                    Spacer(modifier = Modifier.height(12.dp))

                    AlIslahCard(modifier = Modifier.fillMaxWidth()) {
                        Column {
                            project.updates.forEachIndexed { index, update ->
                                TimelineItem(
                                    title = "আপডেট #${index + 1}",
                                    date = "",
                                    description = update,
                                    isLast = index == project.updates.size - 1
                                )
                            }
                        }
                    }
                }

                // Spending Report Items (if any)
                if (project.spendingReport.isNotEmpty()) {
                    Spacer(modifier = Modifier.height(20.dp))
                    Text(
                        text = "ব্যয় ও খরচের হিসাব",
                        style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                        color = AlIslahTheme.customColors.textPrimary
                    )
                    Spacer(modifier = Modifier.height(12.dp))

                    AlIslahCard(modifier = Modifier.fillMaxWidth()) {
                        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                            project.spendingReport.forEach { item ->
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.Check,
                                        contentDescription = null,
                                        tint = AlIslahPrimary,
                                        modifier = Modifier.size(16.dp)
                                    )
                                    Spacer(modifier = Modifier.width(8.dp))
                                    Text(
                                        text = item,
                                        style = MaterialTheme.typography.bodyMedium,
                                        color = AlIslahTheme.customColors.textPrimary
                                    )
                                }
                            }
                        }
                    }
                }

                Spacer(modifier = Modifier.height(24.dp))
            }
        }
    }
}
