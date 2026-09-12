package app.village.alislah.feature.notifications

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
import androidx.compose.material.icons.filled.ArrowForward
import androidx.compose.material.icons.filled.ArrowUpward
import androidx.compose.material.icons.filled.Campaign
import androidx.compose.material.icons.filled.Construction
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.People
import androidx.compose.material.icons.filled.VolunteerActivism
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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import app.village.alislah.components.EmptyState
import app.village.alislah.components.AlIslahCard
import app.village.alislah.components.AlIslahTopBar
import app.village.alislah.core.Formatters
import app.village.alislah.model.AppNotification
import app.village.alislah.theme.AlIslahError
import app.village.alislah.theme.AlIslahPrimary
import app.village.alislah.theme.AlIslahTheme

import app.village.alislah.nav.Destinations

@Composable
fun NotificationScreen(
    onBackClick: () -> Unit,
    onNavigateToRoute: ((String) -> Unit)? = null,
    viewModel: NotificationViewModel = viewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
    ) {
        AlIslahTopBar(
            title = "বিজ্ঞপ্তি ও নোটিফিকেশন",
            showBackButton = true,
            onBackClick = onBackClick
        )

        if (uiState.notifications.isEmpty()) {
            EmptyState(
                title = "কোনো নতুন বিজ্ঞপ্তি নেই",
                description = "নতুন কোনো ঘোষণা বা আপডেট এলে এখানে দেখতে পাবেন।"
            )
        } else {
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(start = 20.dp, end = 20.dp, top = 12.dp, bottom = 90.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                items(uiState.notifications) { notification ->
                    val targetRoute = Destinations.resolveNotificationRoute(
                        type = notification.type,
                        targetId = notification.targetId,
                        customRoute = notification.route,
                        title = notification.title,
                        body = notification.body
                    )
                    NotificationCard(
                        notification = notification,
                        hasActionPage = targetRoute != null && targetRoute != Destinations.NOTIFICATIONS,
                        onClick = {
                            viewModel.markAsRead(notification.id)
                            if (targetRoute != null && targetRoute != Destinations.NOTIFICATIONS) {
                                onNavigateToRoute?.invoke(targetRoute)
                            }
                        }
                    )
                }
            }
        }
    }
}

@Composable
private fun NotificationCard(
    notification: AppNotification,
    hasActionPage: Boolean,
    onClick: () -> Unit
) {
    val text = "${notification.title} ${notification.body} ${notification.type}".lowercase()
    val (icon, color, categoryLabel) = when {
        notification.type.equals("donation", ignoreCase = true) || text.contains("অনুদান") || text.contains("তহবিল") ->
            Triple(Icons.Default.VolunteerActivism, AlIslahPrimary, "অনুদান")
        notification.type.equals("expense", ignoreCase = true) || text.contains("ব্যয়") || text.contains("ব্যয়") || text.contains("খরচ") ->
            Triple(Icons.Default.ArrowUpward, Color(0xFFEF4444), "ব্যয় বিবরণী")
        notification.type.equals("problem", ignoreCase = true) || text.contains("সমস্যা") || text.contains("অভিযোগ") ->
            Triple(Icons.Default.Campaign, Color(0xFFF59E0B), "সমস্যা")
        notification.type.equals("project", ignoreCase = true) || text.contains("প্রকল্প") || text.contains("উন্নয়ন") || text.contains("উন্নয়ন") ->
            Triple(Icons.Default.Construction, Color(0xFF0EA5E9), "প্রকল্প")
        notification.type.equals("citizen", ignoreCase = true) || text.contains("নাগরিক") || text.contains("সদস্য") ->
            Triple(Icons.Default.People, Color(0xFF8B5CF6), "নাগরিক")
        else -> Triple(Icons.Default.Notifications, AlIslahPrimary, "সাধারণ ঘোষণা")
    }

    AlIslahCard(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.Top
        ) {
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .clip(RoundedCornerShape(14.dp))
                    .background(color.copy(alpha = 0.12f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = color,
                    modifier = Modifier.size(22.dp)
                )
            }

            Spacer(modifier = Modifier.width(14.dp))

            Column(modifier = Modifier.weight(1f)) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(6.dp))
                            .background(color.copy(alpha = 0.1f))
                            .padding(horizontal = 7.dp, vertical = 2.dp)
                    ) {
                        Text(
                            text = categoryLabel,
                            style = MaterialTheme.typography.labelSmall.copy(
                                fontWeight = FontWeight.Bold,
                                fontSize = 10.sp
                            ),
                            color = color
                        )
                    }

                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(
                            text = Formatters.formatRelativeTime(notification.createdAt),
                            style = MaterialTheme.typography.labelSmall,
                            color = AlIslahTheme.customColors.textTertiary
                        )
                        if (!notification.isRead) {
                            Spacer(modifier = Modifier.width(6.dp))
                            Box(
                                modifier = Modifier
                                    .size(8.dp)
                                    .clip(CircleShape)
                                    .background(AlIslahPrimary)
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(6.dp))

                Text(
                    text = notification.title,
                    style = MaterialTheme.typography.titleSmall.copy(
                        fontWeight = if (!notification.isRead) FontWeight.Bold else FontWeight.SemiBold
                    ),
                    color = AlIslahTheme.customColors.textPrimary
                )

                if (notification.body.isNotBlank()) {
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = notification.body,
                        style = MaterialTheme.typography.bodyMedium,
                        color = AlIslahTheme.customColors.textSecondary,
                        lineHeight = 20.sp
                    )
                }

                if (hasActionPage) {
                    Spacer(modifier = Modifier.height(8.dp))
                    Row(
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = "বিস্তারিত পেজে যান",
                            style = MaterialTheme.typography.labelSmall.copy(
                                fontWeight = FontWeight.SemiBold,
                                fontSize = 11.sp
                            ),
                            color = color
                        )
                        Spacer(modifier = Modifier.width(4.dp))
                        Icon(
                            imageVector = Icons.Default.ArrowForward,
                            contentDescription = null,
                            tint = color,
                            modifier = Modifier.size(12.dp)
                        )
                    }
                }
            }
        }
    }
}
