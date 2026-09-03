package app.village.alislah.feature.onboarding

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Campaign
import androidx.compose.material.icons.filled.NaturePeople
import androidx.compose.material.icons.filled.VolunteerActivism
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import app.village.alislah.components.ButtonVariant
import app.village.alislah.components.AlIslahButton
import app.village.alislah.theme.AlIslahPrimary
import app.village.alislah.theme.AlIslahTheme
import app.village.alislah.theme.PrimaryGradient

data class OnboardingPage(
    val title: String,
    val description: String,
    val icon: ImageVector
)

@Composable
fun OnboardingScreen(
    onFinish: () -> Unit
) {
    val pages = remember {
        listOf(
            OnboardingPage(
                title = "ডিজিটাল গ্রাম ব্যবস্থাপনা",
                description = "গ্রামের প্রতিটি উন্নয়ন কাজ ও তহবিলের হিসাব এখন সবার হাতের মুঠোয় স্বচ্ছ ও উন্মুক্ত।",
                icon = Icons.Default.NaturePeople
            ),
            OnboardingPage(
                title = "সরাসরি অনুদান ও হিসাব",
                description = "বিকাশ, নগদ বা ব্যাংকের মাধ্যমে সরাসরি গ্রামের ফান্ডে অনুদান দিন ও প্রতিটি ব্যয়ের হিসাব দেখুন।",
                icon = Icons.Default.VolunteerActivism
            ),
            OnboardingPage(
                title = "সমস্যা জানান ও অগ্রগতি দেখুন",
                description = "রাস্তাঘাট, কালভার্ট বা যেকোনো সমস্যা ছবিসহ জানান এবং সমাধান প্রক্রিয়ার লাইভ ট্র্যাকিং করুন।",
                icon = Icons.Default.Campaign
            )
        )
    }

    var currentPage by remember { mutableIntStateOf(0) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .statusBarsPadding()
            .navigationBarsPadding()
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Skip Button
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.End
        ) {
            if (currentPage < pages.size - 1) {
                TextButton(onClick = onFinish) {
                    Text(
                        text = "এড়িয়ে যান",
                        style = MaterialTheme.typography.labelLarge,
                        color = AlIslahTheme.customColors.textSecondary
                    )
                }
            } else {
                Spacer(modifier = Modifier.height(48.dp))
            }
        }

        Spacer(modifier = Modifier.weight(1f))

        // Animated Page Content
        AnimatedContent(
            targetState = currentPage,
            transitionSpec = {
                fadeIn(animationSpec = tween(400)) togetherWith fadeOut(animationSpec = tween(400))
            },
            label = "onboardingSlide"
        ) { pageIndex ->
            val page = pages[pageIndex]
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.fillMaxWidth()
            ) {
                Box(
                    modifier = Modifier
                        .size(130.dp)
                        .clip(CircleShape)
                        .background(PrimaryGradient),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = page.icon,
                        contentDescription = null,
                        tint = Color.White,
                        modifier = Modifier.size(68.dp)
                    )
                }

                Spacer(modifier = Modifier.height(36.dp))

                Text(
                    text = page.title,
                    style = MaterialTheme.typography.headlineMedium.copy(
                        fontWeight = FontWeight.Bold,
                        fontSize = 22.sp
                    ),
                    color = AlIslahTheme.customColors.textPrimary,
                    textAlign = TextAlign.Center
                )

                Spacer(modifier = Modifier.height(12.dp))

                Text(
                    text = page.description,
                    style = MaterialTheme.typography.bodyLarge,
                    color = AlIslahTheme.customColors.textSecondary,
                    textAlign = TextAlign.Center,
                    lineHeight = 22.sp
                )
            }
        }

        Spacer(modifier = Modifier.weight(1f))

        // Indicator Dots
        Row(
            horizontalArrangement = Arrangement.Center,
            verticalAlignment = Alignment.CenterVertically
        ) {
            pages.indices.forEach { index ->
                val isSelected = index == currentPage
                Box(
                    modifier = Modifier
                        .padding(horizontal = 4.dp)
                        .height(8.dp)
                        .width(if (isSelected) 24.dp else 8.dp)
                        .clip(RoundedCornerShape(4.dp))
                        .background(
                            if (isSelected) AlIslahPrimary
                            else AlIslahTheme.customColors.cardBorder
                        )
                )
            }
        }

        Spacer(modifier = Modifier.height(32.dp))

        // Navigation Action Button
        AlIslahButton(
            text = if (currentPage == pages.size - 1) "শুরু করুন" else "পরবর্তী",
            onClick = {
                if (currentPage < pages.size - 1) {
                    currentPage++
                } else {
                    onFinish()
                }
            },
            modifier = Modifier.fillMaxWidth(),
            variant = ButtonVariant.PRIMARY
        )
    }
}
