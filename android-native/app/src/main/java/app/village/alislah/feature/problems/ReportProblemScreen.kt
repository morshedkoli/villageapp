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
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Campaign
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Image
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material.icons.filled.Person
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Icon
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import app.village.alislah.components.ButtonVariant
import app.village.alislah.components.AlIslahButton
import app.village.alislah.components.AlIslahCard
import app.village.alislah.components.AlIslahTextField
import app.village.alislah.components.AlIslahTopBar
import app.village.alislah.theme.AlIslahPrimary
import app.village.alislah.theme.AlIslahTheme

@Composable
fun ReportProblemScreen(
    onBackClick: () -> Unit,
    viewModel: ProblemsViewModel = viewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    var title by remember { mutableStateOf("") }
    var description by remember { mutableStateOf("") }
    var location by remember { mutableStateOf("") }
    var photoUrl by remember { mutableStateOf("") }
    var reporterName by remember { mutableStateOf("") }

    if (uiState.reportSuccess) {
        AlertDialog(
            onDismissRequest = {
                viewModel.resetReportState()
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
                    text = "সমস্যা রিপোর্ট গৃহীত হয়েছে!",
                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold)
                )
            },
            text = {
                Text(
                    text = "আপনার অভিযোগটি গ্রাম উন্নয়ন কমিটির নিকট পাঠানো হয়েছে। দ্রুত পর্যালোচনা করে প্রয়োজনীয় ব্যবস্থা নেওয়া হবে। ধন্যবাদ!",
                    style = MaterialTheme.typography.bodyMedium,
                    color = AlIslahTheme.customColors.textSecondary
                )
            },
            confirmButton = {
                TextButton(
                    onClick = {
                        viewModel.resetReportState()
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
            title = "নতুন সমস্যা জানান",
            showBackButton = true,
            onBackClick = onBackClick
        )

        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(20.dp)
        ) {
            Text(
                text = "গ্রামের সমস্যা তুলে ধরুন",
                style = MaterialTheme.typography.headlineSmall.copy(fontWeight = FontWeight.Bold),
                color = AlIslahTheme.customColors.textPrimary
            )

            Spacer(modifier = Modifier.height(4.dp))

            Text(
                text = "রাস্তাঘাট, কালভার্ট, পানি নিষ্কাশন বা যেকোনো জনকল্যাণমূলক সমস্যা রিপোর্ট করুন",
                style = MaterialTheme.typography.bodyMedium,
                color = AlIslahTheme.customColors.textSecondary
            )

            Spacer(modifier = Modifier.height(20.dp))

            AlIslahTextField(
                value = title,
                onValueChange = { title = it },
                modifier = Modifier.fillMaxWidth(),
                label = "সমস্যার শিরোনাম *",
                placeholder = "যেমন: দক্ষিণ পাড়া ব্রিজের রেলিং ভাঙা",
                leadingIcon = {
                    Icon(
                        imageVector = Icons.Default.Campaign,
                        contentDescription = null,
                        tint = AlIslahTheme.customColors.textSecondary
                    )
                }
            )

            Spacer(modifier = Modifier.height(14.dp))

            AlIslahTextField(
                value = description,
                onValueChange = { description = it },
                modifier = Modifier.fillMaxWidth(),
                label = "বিস্তারিত বিবরণ *",
                placeholder = "সমস্যাটির বিস্তারিত বিবরণ লিখুন...",
                singleLine = false,
                maxLines = 4,
                minLines = 3
            )

            Spacer(modifier = Modifier.height(14.dp))

            AlIslahTextField(
                value = location,
                onValueChange = { location = it },
                modifier = Modifier.fillMaxWidth(),
                label = "স্থান / এলাকা *",
                placeholder = "যেমন: পূর্ব পাড়া জামে মসজিদের সামনে",
                leadingIcon = {
                    Icon(
                        imageVector = Icons.Default.LocationOn,
                        contentDescription = null,
                        tint = AlIslahTheme.customColors.textSecondary
                    )
                }
            )

            Spacer(modifier = Modifier.height(14.dp))

            AlIslahTextField(
                value = photoUrl,
                onValueChange = { photoUrl = it },
                modifier = Modifier.fillMaxWidth(),
                label = "ছবির লিংক (ঐচ্ছিক)",
                placeholder = "https://example.com/photo.jpg",
                leadingIcon = {
                    Icon(
                        imageVector = Icons.Default.Image,
                        contentDescription = null,
                        tint = AlIslahTheme.customColors.textSecondary
                    )
                }
            )

            Spacer(modifier = Modifier.height(14.dp))

            AlIslahTextField(
                value = reporterName,
                onValueChange = { reporterName = it },
                modifier = Modifier.fillMaxWidth(),
                label = "আপনার নাম (ঐচ্ছিক)",
                placeholder = "আপনার নাম",
                leadingIcon = {
                    Icon(
                        imageVector = Icons.Default.Person,
                        contentDescription = null,
                        tint = AlIslahTheme.customColors.textSecondary
                    )
                }
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

            AlIslahButton(
                text = "রিপোর্ট জমা দিন",
                onClick = {
                    viewModel.reportProblem(
                        title = title,
                        description = description,
                        photoUrl = photoUrl,
                        location = location,
                        reportedByName = reporterName
                    )
                },
                modifier = Modifier.fillMaxWidth(),
                isLoading = uiState.isSubmitting,
                variant = ButtonVariant.PRIMARY
            )

            Spacer(modifier = Modifier.height(20.dp))
        }
    }
}
