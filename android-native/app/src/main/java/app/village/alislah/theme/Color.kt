package app.village.alislah.theme

import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color

// Brand Core Colors
val AlIslahPrimary = Color(0xFF22C55E)
val AlIslahPrimaryDark = Color(0xFF16A34A)
val AlIslahPrimaryLight = Color(0xFF4ADE80)
val AlIslahPrimaryContainer = Color(0xFFDCFCE7)
val AlIslahOnPrimaryContainer = Color(0xFF14532D)

val AlIslahSecondary = Color(0xFF0EA5E9)
val AlIslahSecondaryContainer = Color(0xFFE0F2FE)
val AlIslahOnSecondaryContainer = Color(0xFF0369A1)

val AlIslahTertiary = Color(0xFF8B5CF6)
val AlIslahTertiaryContainer = Color(0xFFF3E8FF)
val AlIslahOnTertiaryContainer = Color(0xFF581C87)

// Status & Semantic Colors
val AlIslahSuccess = Color(0xFF22C55E)
val AlIslahSuccessContainer = Color(0xFFDCFCE7)
val AlIslahSuccessContent = Color(0xFF15803D)

val AlIslahWarning = Color(0xFFF59E0B)
val AlIslahWarningContainer = Color(0xFFFEF3C7)
val AlIslahWarningContent = Color(0xFFB45309)

val AlIslahError = Color(0xFFEF4444)
val AlIslahErrorContainer = Color(0xFFFEE2E2)
val AlIslahErrorContent = Color(0xFFB91C1C)

val AlIslahInfo = Color(0xFF3B82F6)
val AlIslahInfoContainer = Color(0xFFDBEAFE)
val AlIslahInfoContent = Color(0xFF1D4ED8)

// Neutral Colors - Light Mode
val LightBackground = Color(0xFFF8FAFC)
val LightSurface = Color(0xFFFFFFFF)
val LightSurfaceVariant = Color(0xFFF1F5F9)
val LightSurfaceBorder = Color(0xFFE2E8F0)
val LightTextPrimary = Color(0xFF0F172A)
val LightTextSecondary = Color(0xFF64748B)
val LightTextTertiary = Color(0xFF94A3B8)

// Neutral Colors - Dark Mode
val DarkBackground = Color(0xFF090D16)
val DarkSurface = Color(0xFF131B2E)
val DarkSurfaceVariant = Color(0xFF1E293B)
val DarkSurfaceBorder = Color(0xFF334155)
val DarkTextPrimary = Color(0xFFF8FAFC)
val DarkTextSecondary = Color(0xFF94A3B8)
val DarkTextTertiary = Color(0xFF64748B)

// Gradients
val PrimaryGradient = Brush.linearGradient(
    colors = listOf(Color(0xFF22C55E), Color(0xFF16A34A))
)

val HeroCardGradientLight = Brush.verticalGradient(
    colors = listOf(Color(0xFF16A34A), Color(0xFF15803D))
)

val HeroCardGradientDark = Brush.verticalGradient(
    colors = listOf(Color(0xFF14532D), Color(0xFF052E16))
)

val GlassGradientLight = Brush.linearGradient(
    colors = listOf(
        Color(0xFFFFFFFF).copy(alpha = 0.9f),
        Color(0xFFF8FAFC).copy(alpha = 0.7f)
    )
)

val GlassGradientDark = Brush.linearGradient(
    colors = listOf(
        Color(0xFF1E293B).copy(alpha = 0.9f),
        Color(0xFF0F172A).copy(alpha = 0.7f)
    )
)
