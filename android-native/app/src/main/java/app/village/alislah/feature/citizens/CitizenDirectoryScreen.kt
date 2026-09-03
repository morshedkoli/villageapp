package app.village.alislah.feature.citizens

import android.content.Intent
import android.net.Uri
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
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Call
import androidx.compose.material.icons.filled.Message
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
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
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import app.village.alislah.components.EmptyState
import app.village.alislah.components.AlIslahCard
import app.village.alislah.components.AlIslahTextField
import app.village.alislah.components.AlIslahTopBar
import app.village.alislah.model.Citizen
import app.village.alislah.theme.AlIslahError
import app.village.alislah.theme.AlIslahPrimary
import app.village.alislah.theme.AlIslahTheme
import coil.compose.AsyncImage

@Composable
fun CitizenDirectoryScreen(
    onNavigateToCitizenProfile: (String) -> Unit,
    viewModel: CitizenViewModel = viewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val context = LocalContext.current

    var searchQuery by remember { mutableStateOf("") }
    var selectedBloodGroup by remember { mutableStateOf("All") }

    val filteredCitizens = uiState.citizens.filter { citizen ->
        val matchesSearch = citizen.name.contains(searchQuery, ignoreCase = true) ||
                citizen.profession.contains(searchQuery, ignoreCase = true) ||
                citizen.phone.contains(searchQuery, ignoreCase = true) ||
                citizen.village.contains(searchQuery, ignoreCase = true)

        val matchesBloodGroup = if (selectedBloodGroup == "All") true
        else citizen.bloodGroup.equals(selectedBloodGroup, ignoreCase = true)

        matchesSearch && matchesBloodGroup
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .statusBarsPadding()
    ) {
        AlIslahTopBar(
            title = "গ্রামবাসী নাগরিক তালিকা",
            subtitle = "মোট নিবন্ধিত: ${uiState.citizens.size} জন"
        )

        // Search and Blood Group Filters
        Column(modifier = Modifier.padding(horizontal = 20.dp, vertical = 6.dp)) {
            AlIslahTextField(
                value = searchQuery,
                onValueChange = { searchQuery = it },
                modifier = Modifier.fillMaxWidth(),
                placeholder = "নাম, পেশা বা মোবাইল নম্বর দিয়ে খুঁজুন...",
                leadingIcon = {
                    Icon(
                        imageVector = Icons.Default.Search,
                        contentDescription = null,
                        tint = AlIslahTheme.customColors.textSecondary
                    )
                }
            )

            Spacer(modifier = Modifier.height(10.dp))

            // Blood Group Filter Chips
            LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                val bloodGroups = listOf("All", "A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-")
                items(bloodGroups) { bg ->
                    val isSelected = selectedBloodGroup == bg
                    val label = if (bg == "All") "সকল রক্তগ্রুপ" else bg
                    FilterChip(
                        selected = isSelected,
                        onClick = { selectedBloodGroup = bg },
                        label = { Text(text = label) },
                        colors = FilterChipDefaults.filterChipColors(
                            selectedContainerColor = AlIslahPrimary.copy(alpha = 0.15f),
                            selectedLabelColor = AlIslahPrimary
                        )
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(6.dp))

        if (filteredCitizens.isEmpty()) {
            EmptyState(
                title = "কোনো নাগরিক পাওয়া যায়নি",
                description = "আপনার অনুসন্ধান বা ফিল্টারের সাথে মিল রয়েছে এমন কোনো গ্রামবাসী পাওয়া যায়নি।"
            )
        } else {
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(start = 20.dp, end = 20.dp, top = 6.dp, bottom = 90.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                items(filteredCitizens) { citizen ->
                    CitizenCard(
                        citizen = citizen,
                        onClick = { onNavigateToCitizenProfile(citizen.id) },
                        onCall = {
                            if (citizen.phone.isNotBlank()) {
                                val intent = Intent(Intent.ACTION_DIAL, Uri.parse("tel:${citizen.phone}"))
                                context.startActivity(intent)
                            }
                        },
                        onSms = {
                            if (citizen.phone.isNotBlank()) {
                                val intent = Intent(Intent.ACTION_VIEW, Uri.parse("sms:${citizen.phone}"))
                                context.startActivity(intent)
                            }
                        }
                    )
                }
            }
        }
    }
}

@Composable
private fun CitizenCard(
    citizen: Citizen,
    onClick: () -> Unit,
    onCall: () -> Unit,
    onSms: () -> Unit
) {
    AlIslahCard(
        modifier = Modifier.fillMaxWidth(),
        onClick = onClick
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Avatar
            if (citizen.photoUrl.isNotBlank()) {
                AsyncImage(
                    model = citizen.photoUrl,
                    contentDescription = citizen.name,
                    modifier = Modifier
                        .size(52.dp)
                        .clip(CircleShape),
                    contentScale = ContentScale.Crop
                )
            } else {
                Box(
                    modifier = Modifier
                        .size(52.dp)
                        .clip(CircleShape)
                        .background(AlIslahPrimary.copy(alpha = 0.12f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Person,
                        contentDescription = null,
                        tint = AlIslahPrimary,
                        modifier = Modifier.size(28.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.width(14.dp))

            // Citizen Info
            Column(modifier = Modifier.weight(1f)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = citizen.name,
                        style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                        color = AlIslahTheme.customColors.textPrimary,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    if (citizen.bloodGroup.isNotBlank()) {
                        Spacer(modifier = Modifier.width(6.dp))
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(6.dp))
                                .background(AlIslahError.copy(alpha = 0.12f))
                                .padding(horizontal = 6.dp, vertical = 2.dp)
                        ) {
                            Text(
                                text = citizen.bloodGroup,
                                style = MaterialTheme.typography.labelSmall.copy(
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 10.sp
                                ),
                                color = AlIslahError
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(2.dp))

                Text(
                    text = if (citizen.profession.isNotBlank()) citizen.profession else "গ্রামবাসী",
                    style = MaterialTheme.typography.bodySmall,
                    color = AlIslahTheme.customColors.textSecondary
                )

                if (citizen.village.isNotBlank()) {
                    Text(
                        text = "গ্রাম: ${citizen.village}",
                        style = MaterialTheme.typography.labelSmall,
                        color = AlIslahTheme.customColors.textTertiary
                    )
                }
            }

            // Quick Call & SMS action buttons
            if (citizen.phone.isNotBlank()) {
                Row {
                    IconButton(
                        onClick = onCall,
                        modifier = Modifier.size(36.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Call,
                            contentDescription = "Call",
                            tint = AlIslahPrimary,
                            modifier = Modifier.size(20.dp)
                        )
                    }
                    IconButton(
                        onClick = onSms,
                        modifier = Modifier.size(36.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Message,
                            contentDescription = "SMS",
                            tint = Color(0xFF0EA5E9),
                            modifier = Modifier.size(20.dp)
                        )
                    }
                }
            }
        }
    }
}
