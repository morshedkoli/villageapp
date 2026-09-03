package app.village.alislah.feature.problems

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.ThumbUp
import androidx.compose.material.icons.outlined.ThumbUp
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
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
import app.village.alislah.theme.CardShape
import app.village.alislah.theme.AlIslahPrimary
import app.village.alislah.theme.AlIslahTheme
import coil.compose.AsyncImage

@Composable
fun ProblemDetailsScreen(
    problemId: String,
    onBackClick: () -> Unit,
    viewModel: ProblemsViewModel = viewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val problem = uiState.problems.find { it.id == problemId }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .statusBarsPadding()
    ) {
        AlIslahTopBar(
            title = "সমস্যার বিস্তারিত বিবরণ",
            showBackButton = true,
            onBackClick = onBackClick
        )

        if (problem == null) {
            EmptyState(
                title = "সমস্যাটি পাওয়া যায়নি",
                description = "হয়তো এটি মুছে ফেলা হয়েছে বা নেটওয়ার্ক সংযোগ সমস্যা।"
            )
        } else {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
                    .padding(20.dp)
            ) {
                // Header Status & Date
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    StatusChip(status = problem.status)
                    Text(
                        text = Formatters.formatDateTime(problem.createdAt),
                        style = MaterialTheme.typography.bodySmall,
                        color = AlIslahTheme.customColors.textTertiary
                    )
                }

                Spacer(modifier = Modifier.height(14.dp))

                Text(
                    text = problem.title,
                    style = MaterialTheme.typography.headlineSmall.copy(
                        fontWeight = FontWeight.Bold,
                        fontSize = 22.sp
                    ),
                    color = AlIslahTheme.customColors.textPrimary
                )

                Spacer(modifier = Modifier.height(14.dp))

                // Optional Photo
                if (problem.photoUrl.isNotBlank()) {
                    AsyncImage(
                        model = problem.photoUrl,
                        contentDescription = problem.title,
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(220.dp)
                            .clip(CardShape),
                        contentScale = ContentScale.Crop
                    )
                    Spacer(modifier = Modifier.height(16.dp))
                }

                // Description Box
                AlIslahCard(modifier = Modifier.fillMaxWidth()) {
                    Column {
                        Text(
                            text = "সমস্যার বিবরণ",
                            style = MaterialTheme.typography.titleSmall.copy(fontWeight = FontWeight.Bold),
                            color = AlIslahTheme.customColors.textPrimary
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = problem.description,
                            style = MaterialTheme.typography.bodyLarge,
                            color = AlIslahTheme.customColors.textSecondary,
                            lineHeight = 22.sp
                        )
                    }
                }

                Spacer(modifier = Modifier.height(14.dp))

                // Location & Reporter Details
                AlIslahCard(modifier = Modifier.fillMaxWidth()) {
                    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                        if (problem.location.isNotBlank()) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(
                                    imageVector = Icons.Default.LocationOn,
                                    contentDescription = null,
                                    tint = AlIslahPrimary,
                                    modifier = Modifier.size(20.dp)
                                )
                                Spacer(modifier = Modifier.width(10.dp))
                                Column {
                                    Text(
                                        text = "স্থান / এলাকা",
                                        style = MaterialTheme.typography.labelSmall,
                                        color = AlIslahTheme.customColors.textTertiary
                                    )
                                    Text(
                                        text = problem.location,
                                        style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Medium),
                                        color = AlIslahTheme.customColors.textPrimary
                                    )
                                }
                            }
                        }

                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(
                                imageVector = Icons.Default.Person,
                                contentDescription = null,
                                tint = AlIslahPrimary,
                                modifier = Modifier.size(20.dp)
                            )
                            Spacer(modifier = Modifier.width(10.dp))
                            Column {
                                Text(
                                    text = "রিপোর্ট করেছেন",
                                    style = MaterialTheme.typography.labelSmall,
                                    color = AlIslahTheme.customColors.textTertiary
                                )
                                Text(
                                    text = problem.reportedByName,
                                    style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Medium),
                                    color = AlIslahTheme.customColors.textPrimary
                                )
                            }
                        }
                    }
                }

                Spacer(modifier = Modifier.height(24.dp))

                // Upvote Action Button
                AlIslahButton(
                    text = if (problem.hasVoted) "ভোট দেওয়া হয়েছে (${problem.upvotesCount})" else "সমস্যাটির সমর্থনে ভোট দিন (${problem.upvotesCount})",
                    onClick = { viewModel.toggleUpvote(problem.id) },
                    modifier = Modifier.fillMaxWidth(),
                    icon = if (problem.hasVoted) Icons.Filled.ThumbUp else Icons.Outlined.ThumbUp,
                    variant = if (problem.hasVoted) ButtonVariant.TONAL else ButtonVariant.PRIMARY
                )

                Spacer(modifier = Modifier.height(20.dp))
            }
        }
    }
}
