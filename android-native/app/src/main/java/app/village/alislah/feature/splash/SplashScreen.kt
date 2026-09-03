package app.village.alislah.feature.splash

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.draw.scale
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import app.village.alislah.R
import app.village.alislah.theme.AlIslahPrimary
import app.village.alislah.theme.AlIslahTheme
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@Composable
fun SplashScreen(
    onNavigateToHome: () -> Unit,
    onNavigateToOnboarding: () -> Unit,
    isUserLoggedIn: Boolean
) {
    val logoScale = remember { Animatable(0.2f) }
    val logoAlpha = remember { Animatable(0f) }
    val textAlpha = remember { Animatable(0f) }
    val textSlide = remember { Animatable(30f) }
    val footerAlpha = remember { Animatable(0f) }

    // Infinite ambient animations
    val infiniteTransition = rememberInfiniteTransition(label = "ambient")
    val pulseScale by infiniteTransition.animateFloat(
        initialValue = 1f,
        targetValue = 1.12f,
        animationSpec = infiniteRepeatable(
            animation = tween(2200, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "pulse"
    )
    val glowRotation by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(
            animation = tween(12000, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "rotation"
    )

    LaunchedEffect(key1 = true) {
        // Step 1: Animate logo with spring physics
        launch {
            logoAlpha.animateTo(1f, tween(600))
        }
        launch {
            logoScale.animateTo(
                targetValue = 1f,
                animationSpec = spring(
                    dampingRatio = Spring.DampingRatioMediumBouncy,
                    stiffness = Spring.StiffnessLow
                )
            )
        }

        delay(450)

        // Step 2: Animate brand text slide & fade
        launch {
            textAlpha.animateTo(1f, tween(700, easing = FastOutSlowInEasing))
        }
        launch {
            textSlide.animateTo(0f, spring(dampingRatio = Spring.DampingRatioLowBouncy))
        }

        delay(300)

        // Step 3: Animate footer loader
        launch {
            footerAlpha.animateTo(1f, tween(500))
        }

        delay(1800)

        // Navigate
        if (isUserLoggedIn) {
            onNavigateToHome()
        } else {
            onNavigateToOnboarding()
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    colors = listOf(
                        Color(0xFF0F172A),
                        Color(0xFF052E16),
                        Color(0xFF064E3B)
                    )
                )
            )
            .statusBarsPadding()
            .navigationBarsPadding(),
        contentAlignment = Alignment.Center
    ) {
        // Ambient background glow rings
        Box(
            modifier = Modifier
                .size(280.dp)
                .scale(pulseScale)
                .rotate(glowRotation)
                .blur(60.dp)
                .background(
                    Brush.sweepGradient(
                        colors = listOf(
                            Color(0xFF22C55E).copy(alpha = 0.35f),
                            Color(0xFFEAB308).copy(alpha = 0.25f),
                            Color(0xFF0EA5E9).copy(alpha = 0.20f),
                            Color(0xFF22C55E).copy(alpha = 0.35f)
                        )
                    ),
                    shape = CircleShape
                )
        )

        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
            modifier = Modifier.padding(24.dp)
        ) {
            // Main App Logo Container
            Box(
                modifier = Modifier
                    .scale(logoScale.value)
                    .alpha(logoAlpha.value)
                    .size(120.dp)
                    .shadow(
                        elevation = 24.dp,
                        shape = RoundedCornerShape(32.dp),
                        spotColor = Color(0xFF22C55E).copy(alpha = 0.6f)
                    )
                    .clip(RoundedCornerShape(32.dp))
                    .background(Color.White),
                contentAlignment = Alignment.Center
            ) {
                Image(
                    painter = painterResource(id = R.drawable.app_logo),
                    contentDescription = "Al Islah Logo",
                    modifier = Modifier.fillMaxSize()
                )
            }

            Spacer(modifier = Modifier.height(28.dp))

            // App Title & Tagline with slide animation
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier
                    .alpha(textAlpha.value)
                    .padding(top = textSlide.value.dp)
            ) {
                Text(
                    text = "Al Islah",
                    style = MaterialTheme.typography.displayMedium.copy(
                        fontWeight = FontWeight.Black,
                        fontSize = 36.sp,
                        letterSpacing = 1.2.sp
                    ),
                    color = Color.White
                )

                Spacer(modifier = Modifier.height(8.dp))

                Text(
                    text = "গ্রামের ঐক্য, স্বচ্ছতা ও টেকসই উন্নয়ন",
                    style = MaterialTheme.typography.bodyLarge.copy(
                        fontWeight = FontWeight.Medium,
                        fontSize = 15.sp,
                        letterSpacing = 0.3.sp
                    ),
                    color = Color(0xFF86EFAC)
                )
            }
        }

        // Bottom Animated Dots
        Box(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .padding(bottom = 48.dp)
                .alpha(footerAlpha.value)
        ) {
            AnimatedLoadingDots()
        }
    }
}

@Composable
private fun AnimatedLoadingDots() {
    val infiniteTransition = rememberInfiniteTransition(label = "dots")
    val dot1 by infiniteTransition.animateFloat(
        initialValue = 0.3f, targetValue = 1f,
        animationSpec = infiniteRepeatable(tween(700, 0), RepeatMode.Reverse), label = "d1"
    )
    val dot2 by infiniteTransition.animateFloat(
        initialValue = 0.3f, targetValue = 1f,
        animationSpec = infiniteRepeatable(tween(700, 200), RepeatMode.Reverse), label = "d2"
    )
    val dot3 by infiniteTransition.animateFloat(
        initialValue = 0.3f, targetValue = 1f,
        animationSpec = infiniteRepeatable(tween(700, 400), RepeatMode.Reverse), label = "d3"
    )

    Row(
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(modifier = Modifier.size(8.dp).alpha(dot1).clip(CircleShape).background(Color(0xFF22C55E)))
        Box(modifier = Modifier.size(8.dp).alpha(dot2).clip(CircleShape).background(Color(0xFF86EFAC)))
        Box(modifier = Modifier.size(8.dp).alpha(dot3).clip(CircleShape).background(Color(0xFFEAB308)))
    }
}
