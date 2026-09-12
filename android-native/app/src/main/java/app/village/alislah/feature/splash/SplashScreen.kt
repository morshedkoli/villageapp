package app.village.alislah.feature.splash

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.LinearOutSlowInEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.VolunteerActivism
import androidx.compose.material3.Icon
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
import androidx.compose.ui.text.PlatformTextStyle
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import app.village.alislah.R
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@Composable
fun SplashScreen(
    onNavigateToHome: () -> Unit,
    onNavigateToOnboarding: () -> Unit,
    isUserLoggedIn: Boolean
) {
    // 1. Stage 1: Charity Receptacle (Caring Hands)
    val receptacleScale = remember { Animatable(0.75f) }
    val receptacleAlpha = remember { Animatable(0f) }
    val handsAlpha = remember { Animatable(1f) }

    // 2. Stage 2: Golden Taka Coin
    val coinY = remember { Animatable(-120f) }
    val coinScale = remember { Animatable(0.5f) }
    val coinAlpha = remember { Animatable(0f) }
    val coinRotation = remember { Animatable(-25f) }

    // 3. Stage 3: Impact Ripples & Sparks
    val rippleScale = remember { Animatable(0.6f) }
    val rippleAlpha = remember { Animatable(0f) }
    val sparksY = remember { Animatable(0f) }
    val sparksAlpha = remember { Animatable(0f) }

    // 4. Stage 4: App Logo Blossom
    val logoScale = remember { Animatable(0.85f) }
    val logoAlpha = remember { Animatable(0f) }

    // 5. Stage 5: Typography & Progress
    val textAlpha = remember { Animatable(0f) }
    val textSlide = remember { Animatable(25f) }
    val badgeAlpha = remember { Animatable(0f) }
    val progress = remember { Animatable(0f) }

    // Continuous ambient glow
    val infiniteTransition = rememberInfiniteTransition(label = "ambient")
    val ambientScale by infiniteTransition.animateFloat(
        initialValue = 1f,
        targetValue = 1.15f,
        animationSpec = infiniteRepeatable(
            animation = tween(2200, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "ambient_pulse"
    )
    val coinShimmer by infiniteTransition.animateFloat(
        initialValue = -10f,
        targetValue = 10f,
        animationSpec = infiniteRepeatable(
            animation = tween(1500, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "coin_shimmer"
    )

    LaunchedEffect(Unit) {
        // Step 1: Open charity hands appear in center
        launch {
            receptacleAlpha.animateTo(1f, tween(400, easing = LinearOutSlowInEasing))
        }
        launch {
            receptacleScale.animateTo(1f, spring(dampingRatio = Spring.DampingRatioMediumBouncy))
        }

        delay(250)

        // Step 2: Golden Taka Coin appears above and glides into the caring hands
        launch {
            coinAlpha.animateTo(1f, tween(250))
        }
        launch {
            coinScale.animateTo(1f, tween(400, easing = LinearOutSlowInEasing))
        }
        launch {
            coinRotation.animateTo(0f, tween(700, easing = FastOutSlowInEasing))
        }
        coinY.animateTo(0f, tween(750, easing = FastOutSlowInEasing))

        // Step 3: Coin lands in hands!
        // Hands compress slightly then spring back upon receiving the donation
        launch {
            receptacleScale.animateTo(0.93f, tween(90))
            receptacleScale.animateTo(1f, spring(dampingRatio = Spring.DampingRatioMediumBouncy))
        }
        // Coin absorbs smoothly into the heart of the hands
        launch {
            delay(100)
            coinAlpha.animateTo(0f, tween(250))
            coinScale.animateTo(0.3f, tween(250))
        }
        // Impact ripples burst outward (Golden & Emerald)
        launch {
            rippleAlpha.snapTo(0.95f)
            rippleScale.snapTo(0.5f)
            launch { rippleScale.animateTo(2.6f, tween(900, easing = LinearOutSlowInEasing)) }
            launch { rippleAlpha.animateTo(0f, tween(900, easing = LinearOutSlowInEasing)) }
        }
        // Sparks/Blessings float upwards
        launch {
            sparksAlpha.snapTo(1f)
            sparksY.snapTo(0f)
            launch { sparksY.animateTo(-85f, tween(1000, easing = LinearOutSlowInEasing)) }
            launch {
                delay(350)
                sparksAlpha.animateTo(0f, tween(650))
            }
        }

        delay(550)

        // Step 4: Hands morph seamlessly into flourishing Al Islah Logo
        launch {
            handsAlpha.animateTo(0f, tween(300))
            logoAlpha.animateTo(1f, tween(350))
            logoScale.animateTo(1.08f, spring(dampingRatio = Spring.DampingRatioLowBouncy, stiffness = Spring.StiffnessMedium))
            logoScale.animateTo(1f, spring(dampingRatio = Spring.DampingRatioMediumBouncy))
        }

        delay(400)

        // Step 5: Brand Text & Tagline Slide In
        launch {
            textAlpha.animateTo(1f, tween(600, easing = FastOutSlowInEasing))
        }
        launch {
            textSlide.animateTo(0f, spring(dampingRatio = Spring.DampingRatioMediumBouncy))
        }

        delay(250)

        // Step 6: Trust Badge & Progress Bar
        launch {
            badgeAlpha.animateTo(1f, tween(450))
        }
        launch {
            progress.animateTo(1f, tween(1100, easing = FastOutSlowInEasing))
        }

        delay(1200)

        // Step 7: Smoothly Navigate
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
                        Color(0xFF021008), // Deep obsidian green
                        Color(0xFF062A17), // Rich village emerald
                        Color(0xFF03140C)  // Midnight forest
                    )
                )
            )
            .statusBarsPadding()
            .navigationBarsPadding(),
        contentAlignment = Alignment.Center
    ) {
        // Ambient background glowing aura
        Box(
            modifier = Modifier
                .size(300.dp)
                .scale(ambientScale)
                .blur(75.dp)
                .background(
                    Brush.radialGradient(
                        colors = listOf(
                            Color(0xFF10B981).copy(alpha = 0.38f),
                            Color(0xFFF59E0B).copy(alpha = 0.22f),
                            Color.Transparent
                        )
                    ),
                    shape = CircleShape
                )
        )

        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp)
        ) {
            // Center Animated Donation Stage
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier.size(200.dp)
            ) {
                // Expanding Impact Ripple Wave 1 (Gold)
                if (rippleAlpha.value > 0.01f) {
                    Box(
                        modifier = Modifier
                            .size(110.dp)
                            .scale(rippleScale.value)
                            .alpha(rippleAlpha.value)
                            .border(
                                width = 3.dp,
                                brush = Brush.sweepGradient(
                                    listOf(Color(0xFFFBBF24), Color(0xFF10B981), Color(0xFFFBBF24))
                                ),
                                shape = CircleShape
                            )
                    )
                    // Ripple Wave 2 (Emerald)
                    Box(
                        modifier = Modifier
                            .size(90.dp)
                            .scale(rippleScale.value * 1.25f)
                            .alpha(rippleAlpha.value * 0.7f)
                            .border(
                                width = 2.dp,
                                color = Color(0xFF34D399),
                                shape = CircleShape
                            )
                    )
                }

                // Floating Hearts / Blessings floating up upon donation absorption
                if (sparksAlpha.value > 0.01f) {
                    Box(
                        modifier = Modifier
                            .offset(y = sparksY.value.dp)
                            .alpha(sparksAlpha.value)
                    ) {
                        Row(
                            horizontalArrangement = Arrangement.spacedBy(38.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(
                                imageVector = Icons.Default.Favorite,
                                contentDescription = null,
                                tint = Color(0xFFF59E0B),
                                modifier = Modifier.size(18.dp)
                            )
                            Icon(
                                imageVector = Icons.Default.VolunteerActivism,
                                contentDescription = null,
                                tint = Color(0xFF34D399),
                                modifier = Modifier.size(24.dp)
                            )
                            Icon(
                                imageVector = Icons.Default.Favorite,
                                contentDescription = null,
                                tint = Color(0xFFF59E0B),
                                modifier = Modifier.size(18.dp)
                            )
                        }
                    }
                }

                // Stage Receptacle: Open Charity Hands (Pre-impact)
                if (handsAlpha.value > 0.01f) {
                    Box(
                        modifier = Modifier
                            .scale(receptacleScale.value)
                            .alpha(receptacleAlpha.value * handsAlpha.value)
                            .size(136.dp)
                            .shadow(
                                elevation = 24.dp,
                                shape = RoundedCornerShape(36.dp),
                                spotColor = Color(0xFF10B981).copy(alpha = 0.5f)
                            )
                            .clip(RoundedCornerShape(36.dp))
                            .background(
                                Brush.linearGradient(
                                    colors = listOf(
                                        Color(0xFF0F3D24),
                                        Color(0xFF062314)
                                    )
                                )
                            )
                            .border(1.5.dp, Color(0xFF34D399).copy(alpha = 0.5f), RoundedCornerShape(36.dp)),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.VolunteerActivism,
                            contentDescription = null,
                            tint = Color(0xFF6EE7B7),
                            modifier = Modifier.size(62.dp)
                        )
                    }
                }

                // Stage Blossom: Al Islah Flourished Brand Logo (Post-impact)
                if (logoAlpha.value > 0.01f) {
                    Box(
                        modifier = Modifier
                            .scale(logoScale.value)
                            .alpha(logoAlpha.value)
                            .size(136.dp)
                            .shadow(
                                elevation = 30.dp,
                                shape = RoundedCornerShape(36.dp),
                                spotColor = Color(0xFFF59E0B).copy(alpha = 0.5f)
                            )
                            .clip(RoundedCornerShape(36.dp))
                            .background(Color.White),
                        contentAlignment = Alignment.Center
                    ) {
                        Image(
                            painter = painterResource(id = R.drawable.app_logo),
                            contentDescription = "Al Islah Logo",
                            modifier = Modifier.fillMaxSize()
                        )
                    }
                }

                // Falling Golden Taka Donation Coin (In foreground, always visible while gliding down)
                if (coinAlpha.value > 0.01f) {
                    Box(
                        modifier = Modifier
                            .offset(y = coinY.value.dp)
                            .rotate(coinRotation.value + coinShimmer)
                            .scale(coinScale.value)
                            .alpha(coinAlpha.value)
                            .size(56.dp)
                            .shadow(
                                elevation = 20.dp,
                                shape = CircleShape,
                                spotColor = Color(0xFFF59E0B)
                            )
                            .clip(CircleShape)
                            .background(
                                Brush.radialGradient(
                                    colors = listOf(
                                        Color(0xFFFFFBEB), // Bright gold shine center
                                        Color(0xFFFDE047), // Gold core
                                        Color(0xFFD97706)  // Rich amber gold rim
                                    )
                                )
                            )
                            .border(2.5.dp, Color(0xFFFEF3C7), CircleShape),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = "৳",
                            style = TextStyle(
                                fontSize = 30.sp,
                                fontWeight = FontWeight.Black,
                                color = Color(0xFF78350F),
                                platformStyle = PlatformTextStyle(includeFontPadding = false)
                            ),
                            textAlign = TextAlign.Center
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(28.dp))

            // Brand Title & Animated Tagline
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier
                    .alpha(textAlpha.value)
                    .offset(y = textSlide.value.dp)
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

                Spacer(modifier = Modifier.height(6.dp))

                Text(
                    text = "আল ইসলাহ • মানবকল্যাণ ও উন্নয়ন",
                    style = MaterialTheme.typography.titleSmall.copy(
                        fontWeight = FontWeight.SemiBold,
                        fontSize = 15.sp,
                        letterSpacing = 0.4.sp
                    ),
                    color = Color(0xFFFBBF24) // Warm gold
                )

                Spacer(modifier = Modifier.height(8.dp))

                Text(
                    text = "আপনার অনুদানে গড়ে উঠুক আমাদের স্বপ্নের গ্রাম",
                    style = MaterialTheme.typography.bodyMedium.copy(
                        fontWeight = FontWeight.Medium,
                        fontSize = 14.sp
                    ),
                    color = Color(0xFFD1FAE5),
                    textAlign = TextAlign.Center
                )
            }

            Spacer(modifier = Modifier.height(22.dp))

            // Donation Security & Trust Badge
            Box(
                modifier = Modifier
                    .alpha(badgeAlpha.value)
                    .clip(RoundedCornerShape(20.dp))
                    .background(Color(0xFF10B981).copy(alpha = 0.12f))
                    .border(1.dp, Color(0xFF10B981).copy(alpha = 0.3f), RoundedCornerShape(20.dp))
                    .padding(horizontal = 14.dp, vertical = 6.dp)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.VolunteerActivism,
                        contentDescription = null,
                        tint = Color(0xFF34D399),
                        modifier = Modifier.size(15.dp)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Text(
                        text = "স্বচ্ছ ও নিরাপদ জনকল্যাণ তহবিল",
                        style = MaterialTheme.typography.labelSmall.copy(
                            fontWeight = FontWeight.SemiBold,
                            fontSize = 11.sp
                        ),
                        color = Color(0xFF6EE7B7)
                    )
                }
            }
        }

        // Bottom Progress Loading Line
        Column(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .padding(bottom = 36.dp)
                .alpha(badgeAlpha.value),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Elegant micro progress bar
            Box(
                modifier = Modifier
                    .width(140.dp)
                    .height(3.5.dp)
                    .clip(RoundedCornerShape(2.dp))
                    .background(Color.White.copy(alpha = 0.12f))
            ) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth(progress.value)
                        .height(3.5.dp)
                        .clip(RoundedCornerShape(2.dp))
                        .background(
                            Brush.horizontalGradient(
                                listOf(Color(0xFF10B981), Color(0xFFFBBF24))
                            )
                        )
                )
            }

            Spacer(modifier = Modifier.height(10.dp))

            Text(
                text = "গ্রামের সেবায় আমরা সদা সচেষ্ট...",
                style = MaterialTheme.typography.labelSmall.copy(
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Normal
                ),
                color = Color(0xFF6EE7B7).copy(alpha = 0.7f)
            )
        }
    }
}
