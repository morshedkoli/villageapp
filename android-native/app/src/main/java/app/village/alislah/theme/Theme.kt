package app.village.alislah.theme

import android.app.Activity
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.SideEffect
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

@Immutable
data class AlIslahCustomColors(
    val heroGradient: Brush,
    val cardBackground: Color,
    val cardBorder: Color,
    val textPrimary: Color,
    val textSecondary: Color,
    val textTertiary: Color,
    val statusPendingBg: Color,
    val statusPendingFg: Color,
    val statusApprovedBg: Color,
    val statusApprovedFg: Color,
    val statusRejectedBg: Color,
    val statusRejectedFg: Color,
    val statusCompletedBg: Color,
    val statusCompletedFg: Color,
    val statusInProgressBg: Color,
    val statusInProgressFg: Color,
    val dividerColor: Color
)

val LocalAlIslahCustomColors = staticCompositionLocalOf {
    AlIslahCustomColors(
        heroGradient = HeroCardGradientLight,
        cardBackground = LightSurface,
        cardBorder = LightSurfaceBorder,
        textPrimary = LightTextPrimary,
        textSecondary = LightTextSecondary,
        textTertiary = LightTextTertiary,
        statusPendingBg = AlIslahWarningContainer,
        statusPendingFg = AlIslahWarningContent,
        statusApprovedBg = AlIslahSuccessContainer,
        statusApprovedFg = AlIslahSuccessContent,
        statusRejectedBg = AlIslahErrorContainer,
        statusRejectedFg = AlIslahErrorContent,
        statusCompletedBg = AlIslahInfoContainer,
        statusCompletedFg = AlIslahInfoContent,
        statusInProgressBg = AlIslahSecondaryContainer,
        statusInProgressFg = AlIslahOnSecondaryContainer,
        dividerColor = LightSurfaceBorder
    )
}

private val LightColorScheme = lightColorScheme(
    primary = AlIslahPrimary,
    onPrimary = Color.White,
    primaryContainer = AlIslahPrimaryContainer,
    onPrimaryContainer = AlIslahOnPrimaryContainer,
    secondary = AlIslahSecondary,
    onSecondary = Color.White,
    secondaryContainer = AlIslahSecondaryContainer,
    onSecondaryContainer = AlIslahOnSecondaryContainer,
    tertiary = AlIslahTertiary,
    onTertiary = Color.White,
    tertiaryContainer = AlIslahTertiaryContainer,
    onTertiaryContainer = AlIslahOnTertiaryContainer,
    background = LightBackground,
    onBackground = LightTextPrimary,
    surface = LightSurface,
    onSurface = LightTextPrimary,
    surfaceVariant = LightSurfaceVariant,
    onSurfaceVariant = LightTextSecondary,
    outline = LightSurfaceBorder,
    error = AlIslahError,
    onError = Color.White,
    errorContainer = AlIslahErrorContainer,
    onErrorContainer = AlIslahErrorContent
)

private val DarkColorScheme = darkColorScheme(
    primary = AlIslahPrimary,
    onPrimary = Color.Black,
    primaryContainer = Color(0xFF14532D),
    onPrimaryContainer = Color(0xFFDCFCE7),
    secondary = AlIslahSecondary,
    onSecondary = Color.Black,
    secondaryContainer = Color(0xFF0369A1),
    onSecondaryContainer = Color(0xFFE0F2FE),
    tertiary = AlIslahTertiary,
    onTertiary = Color.White,
    tertiaryContainer = Color(0xFF581C87),
    onTertiaryContainer = Color(0xFFF3E8FF),
    background = DarkBackground,
    onBackground = DarkTextPrimary,
    surface = DarkSurface,
    onSurface = DarkTextPrimary,
    surfaceVariant = DarkSurfaceVariant,
    onSurfaceVariant = DarkTextSecondary,
    outline = DarkSurfaceBorder,
    error = AlIslahError,
    onError = Color.Black,
    errorContainer = Color(0xFF7F1D1D),
    onErrorContainer = Color(0xFFFEE2E2)
)

@Composable
fun AlIslahTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme

    val customColors = if (darkTheme) {
        AlIslahCustomColors(
            heroGradient = HeroCardGradientDark,
            cardBackground = DarkSurface,
            cardBorder = DarkSurfaceBorder,
            textPrimary = DarkTextPrimary,
            textSecondary = DarkTextSecondary,
            textTertiary = DarkTextTertiary,
            statusPendingBg = Color(0xFF451A03),
            statusPendingFg = Color(0xFFFDE68A),
            statusApprovedBg = Color(0xFF052E16),
            statusApprovedFg = Color(0xFFBBF7D0),
            statusRejectedBg = Color(0xFF450A0A),
            statusRejectedFg = Color(0xFFFECACA),
            statusCompletedBg = Color(0xFF172554),
            statusCompletedFg = Color(0xFFBFDBFE),
            statusInProgressBg = Color(0xFF082F49),
            statusInProgressFg = Color(0xFFBAE6FD),
            dividerColor = DarkSurfaceBorder
        )
    } else {
        AlIslahCustomColors(
            heroGradient = HeroCardGradientLight,
            cardBackground = LightSurface,
            cardBorder = LightSurfaceBorder,
            textPrimary = LightTextPrimary,
            textSecondary = LightTextSecondary,
            textTertiary = LightTextTertiary,
            statusPendingBg = AlIslahWarningContainer,
            statusPendingFg = AlIslahWarningContent,
            statusApprovedBg = AlIslahSuccessContainer,
            statusApprovedFg = AlIslahSuccessContent,
            statusRejectedBg = AlIslahErrorContainer,
            statusRejectedFg = AlIslahErrorContent,
            statusCompletedBg = AlIslahInfoContainer,
            statusCompletedFg = AlIslahInfoContent,
            statusInProgressBg = AlIslahSecondaryContainer,
            statusInProgressFg = AlIslahOnSecondaryContainer,
            dividerColor = LightSurfaceBorder
        )
    }

    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = colorScheme.background.toArgb()
            window.navigationBarColor = colorScheme.background.toArgb()
            WindowCompat.getInsetsController(window, view).apply {
                isAppearanceLightStatusBars = !darkTheme
                isAppearanceLightNavigationBars = !darkTheme
            }
        }
    }

    CompositionLocalProvider(
        LocalAlIslahSpacing provides AlIslahSpacing(),
        LocalAlIslahCustomColors provides customColors
    ) {
        MaterialTheme(
            colorScheme = colorScheme,
            typography = AlIslahTypography,
            shapes = AlIslahShapes,
            content = content
        )
    }
}

object AlIslahTheme {
    val spacing: AlIslahSpacing
        @Composable
        get() = LocalAlIslahSpacing.current

    val customColors: AlIslahCustomColors
        @Composable
        get() = LocalAlIslahCustomColors.current
}
