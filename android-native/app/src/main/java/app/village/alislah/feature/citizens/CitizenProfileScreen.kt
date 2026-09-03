package app.village.alislah.feature.citizens

import android.content.Intent
import android.net.Uri
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
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Badge
import androidx.compose.material.icons.filled.Call
import androidx.compose.material.icons.filled.Email
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.InvertColors
import androidx.compose.material.icons.filled.Message
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Phone
import androidx.compose.material.icons.filled.Work
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
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import app.village.alislah.components.ButtonVariant
import app.village.alislah.components.EmptyState
import app.village.alislah.components.AlIslahButton
import app.village.alislah.components.AlIslahCard
import app.village.alislah.components.AlIslahTopBar
import app.village.alislah.theme.CardShape
import app.village.alislah.theme.AlIslahError
import app.village.alislah.theme.AlIslahPrimary
import app.village.alislah.theme.AlIslahTheme
import coil.compose.AsyncImage

@Composable
fun CitizenProfileScreen(
    citizenId: String,
    onBackClick: () -> Unit,
    viewModel: CitizenViewModel = viewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val citizen = uiState.citizens.find { it.id == citizenId }
    val context = LocalContext.current

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .statusBarsPadding()
    ) {
        AlIslahTopBar(
            title = "নাগরিক প্রোফাইল",
            showBackButton = true,
            onBackClick = onBackClick
        )

        if (citizen == null) {
            EmptyState(
                title = "নাগরিকের তথ্য পাওয়া যায়নি",
                description = "প্রোফাইল লোড করা সম্ভব হয়নি।"
            )
        } else {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
                    .padding(20.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // Large Avatar
                if (citizen.photoUrl.isNotBlank()) {
                    AsyncImage(
                        model = citizen.photoUrl,
                        contentDescription = citizen.name,
                        modifier = Modifier
                            .size(100.dp)
                            .clip(CircleShape),
                        contentScale = ContentScale.Crop
                    )
                } else {
                    Box(
                        modifier = Modifier
                            .size(100.dp)
                            .clip(CircleShape)
                            .background(AlIslahPrimary.copy(alpha = 0.12f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.Person,
                            contentDescription = null,
                            tint = AlIslahPrimary,
                            modifier = Modifier.size(54.dp)
                        )
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                Text(
                    text = citizen.name,
                    style = MaterialTheme.typography.headlineSmall.copy(
                        fontWeight = FontWeight.Bold,
                        fontSize = 22.sp
                    ),
                    color = AlIslahTheme.customColors.textPrimary
                )

                Spacer(modifier = Modifier.height(4.dp))

                Text(
                    text = if (citizen.profession.isNotBlank()) citizen.profession else "গ্রামবাসী",
                    style = MaterialTheme.typography.bodyLarge,
                    color = AlIslahTheme.customColors.textSecondary
                )

                if (citizen.bloodGroup.isNotBlank()) {
                    Spacer(modifier = Modifier.height(8.dp))
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(8.dp))
                            .background(AlIslahError.copy(alpha = 0.12f))
                            .padding(horizontal = 10.dp, vertical = 4.dp)
                    ) {
                        Text(
                            text = "রক্তের গ্রুপ: ${citizen.bloodGroup}",
                            style = MaterialTheme.typography.labelSmall.copy(
                                fontWeight = FontWeight.Bold,
                                color = AlIslahError
                            )
                        )
                    }
                }

                Spacer(modifier = Modifier.height(20.dp))

                // Call & Message Action Buttons
                if (citizen.phone.isNotBlank()) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        AlIslahButton(
                            text = "কল করুন",
                            onClick = {
                                val intent = Intent(Intent.ACTION_DIAL, Uri.parse("tel:${citizen.phone}"))
                                context.startActivity(intent)
                            },
                            modifier = Modifier.weight(1f),
                            icon = Icons.Default.Call,
                            variant = ButtonVariant.PRIMARY
                        )

                        AlIslahButton(
                            text = "এসএমএস",
                            onClick = {
                                val intent = Intent(Intent.ACTION_VIEW, Uri.parse("sms:${citizen.phone}"))
                                context.startActivity(intent)
                            },
                            modifier = Modifier.weight(1f),
                            icon = Icons.Default.Message,
                            variant = ButtonVariant.OUTLINE
                        )
                    }
                }

                Spacer(modifier = Modifier.height(24.dp))

                // Information Card
                AlIslahCard(modifier = Modifier.fillMaxWidth()) {
                    Column(verticalArrangement = Arrangement.spacedBy(14.dp)) {
                        Text(
                            text = "ব্যক্তিগত তথ্য",
                            style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                            color = AlIslahTheme.customColors.textPrimary
                        )

                        ProfileInfoRow(
                            icon = Icons.Default.Phone,
                            label = "মোবাইল নম্বর",
                            value = if (citizen.phone.isNotBlank()) citizen.phone else "দেওয়া হয়নি"
                        )

                        ProfileInfoRow(
                            icon = Icons.Default.Home,
                            label = "গ্রাম / এলাকা",
                            value = if (citizen.village.isNotBlank()) citizen.village else "গ্রামবাসী"
                        )

                        if (citizen.email.isNotBlank()) {
                            ProfileInfoRow(
                                icon = Icons.Default.Email,
                                label = "ইমেইল",
                                value = citizen.email
                            )
                        }

                        if (citizen.profession.isNotBlank()) {
                            ProfileInfoRow(
                                icon = Icons.Default.Work,
                                label = "পেশা",
                                value = citizen.profession
                            )
                        }

                        if (citizen.bloodGroup.isNotBlank()) {
                            ProfileInfoRow(
                                icon = Icons.Default.InvertColors,
                                label = "রক্তের গ্রুপ",
                                value = citizen.bloodGroup
                            )
                        }

                        if (citizen.address.isNotBlank()) {
                            ProfileInfoRow(
                                icon = Icons.Default.Home,
                                label = "ঠিকানা",
                                value = citizen.address
                            )
                        }

                        if (citizen.nidNumber.isNotBlank()) {
                            ProfileInfoRow(
                                icon = Icons.Default.Badge,
                                label = "জাতীয় পরিচয়পত্র (NID)",
                                value = citizen.nidNumber
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(24.dp))
            }
        }
    }
}

@Composable
private fun ProfileInfoRow(
    icon: ImageVector,
    label: String,
    value: String
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(36.dp)
                .clip(RoundedCornerShape(8.dp))
                .background(AlIslahTheme.customColors.cardBorder.copy(alpha = 0.5f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = AlIslahTheme.customColors.textSecondary,
                modifier = Modifier.size(18.dp)
            )
        }

        Spacer(modifier = Modifier.width(12.dp))

        Column {
            Text(
                text = label,
                style = MaterialTheme.typography.labelSmall,
                color = AlIslahTheme.customColors.textTertiary
            )
            Text(
                text = value,
                style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Medium),
                color = AlIslahTheme.customColors.textPrimary
            )
        }
    }
}
