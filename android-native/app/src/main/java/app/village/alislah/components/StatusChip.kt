package app.village.alislah.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import app.village.alislah.theme.AlIslahTheme
import app.village.alislah.theme.PillShape

@Composable
fun StatusChip(
    status: String,
    modifier: Modifier = Modifier,
    customLabel: String? = null
) {
    val (bgColor, fgColor, defaultLabel) = when (status.lowercase()) {
        "approved", "verified" -> Triple(
            AlIslahTheme.customColors.statusApprovedBg,
            AlIslahTheme.customColors.statusApprovedFg,
            "অনুমোদিত"
        )
        "pending" -> Triple(
            AlIslahTheme.customColors.statusPendingBg,
            AlIslahTheme.customColors.statusPendingFg,
            "অপেক্ষমাণ"
        )
        "rejected" -> Triple(
            AlIslahTheme.customColors.statusRejectedBg,
            AlIslahTheme.customColors.statusRejectedFg,
            "বাতিল"
        )
        "in progress", "ongoing" -> Triple(
            AlIslahTheme.customColors.statusInProgressBg,
            AlIslahTheme.customColors.statusInProgressFg,
            "চলমান"
        )
        "completed" -> Triple(
            AlIslahTheme.customColors.statusCompletedBg,
            AlIslahTheme.customColors.statusCompletedFg,
            "সম্পন্ন"
        )
        "planning" -> Triple(
            AlIslahTheme.customColors.statusPendingBg,
            AlIslahTheme.customColors.statusPendingFg,
            "পরিকল্পনা"
        )
        else -> Triple(
            AlIslahTheme.customColors.cardBorder,
            AlIslahTheme.customColors.textSecondary,
            status
        )
    }

    val displayLabel = customLabel ?: defaultLabel

    Box(
        modifier = modifier
            .clip(PillShape)
            .background(bgColor)
            .padding(horizontal = 10.dp, vertical = 4.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = displayLabel,
            style = MaterialTheme.typography.labelSmall.copy(
                fontWeight = FontWeight.SemiBold,
                fontSize = 11.sp
            ),
            color = fgColor
        )
    }
}
