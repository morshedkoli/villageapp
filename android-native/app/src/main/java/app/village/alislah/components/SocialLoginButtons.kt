package app.village.alislah.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Fill
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import app.village.alislah.theme.ButtonShape
import app.village.alislah.theme.AlIslahTheme

@Composable
fun GoogleSignInButton(
    text: String = "Google দিয়ে চালিয়ে যান",
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    isLoading: Boolean = false
) {
    OutlinedButton(
        onClick = onClick,
        modifier = modifier
            .fillMaxWidth()
            .height(52.dp),
        shape = ButtonShape,
        border = BorderStroke(1.dp, AlIslahTheme.customColors.cardBorder),
        enabled = !isLoading
    ) {
        if (isLoading) {
            CircularProgressIndicator(
                modifier = Modifier.size(22.dp),
                strokeWidth = 2.dp,
                color = AlIslahTheme.customColors.textPrimary
            )
        } else {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.Center
            ) {
                GoogleLogoIcon(modifier = Modifier.size(20.dp))
                Spacer(modifier = Modifier.width(12.dp))
                Text(
                    text = text,
                    style = MaterialTheme.typography.titleMedium.copy(
                        fontWeight = FontWeight.SemiBold,
                        fontSize = 15.sp
                    ),
                    color = AlIslahTheme.customColors.textPrimary
                )
            }
        }
    }
}

@Composable
fun GoogleLogoIcon(modifier: Modifier = Modifier) {
    Canvas(modifier = modifier) {
        val w = size.width
        val h = size.height

        // Colors
        val red = Color(0xFFEA4335)
        val blue = Color(0xFF4285F4)
        val green = Color(0xFF34A853)
        val yellow = Color(0xFFFBBC05)

        // Draw Google G geometry
        // Blue Bar & sector
        val bluePath = Path().apply {
            moveTo(w * 0.95f, h * 0.5f)
            lineTo(w * 0.5f, h * 0.5f)
            lineTo(w * 0.5f, h * 0.35f)
            lineTo(w * 0.95f, h * 0.35f)
            close()
        }
        drawPath(bluePath, blue, style = Fill)

        // Blue outer arc right
        drawArc(
            color = blue,
            startAngle = -45f,
            sweepAngle = 90f,
            useCenter = true,
            size = size
        )

        // Green arc bottom
        drawArc(
            color = green,
            startAngle = 45f,
            sweepAngle = 90f,
            useCenter = true,
            size = size
        )

        // Yellow arc left
        drawArc(
            color = yellow,
            startAngle = 135f,
            sweepAngle = 90f,
            useCenter = true,
            size = size
        )

        // Red arc top
        drawArc(
            color = red,
            startAngle = 225f,
            sweepAngle = 90f,
            useCenter = true,
            size = size
        )

        // Center cutout
        drawCircle(
            color = Color.White,
            radius = w * 0.30f,
            center = Offset(w * 0.5f, h * 0.5f)
        )

        // Blue middle horizontal bar
        val barPath = Path().apply {
            moveTo(w * 0.45f, h * 0.38f)
            lineTo(w * 0.92f, h * 0.38f)
            lineTo(w * 0.92f, h * 0.62f)
            lineTo(w * 0.45f, h * 0.62f)
            close()
        }
        drawPath(barPath, blue, style = Fill)
    }
}

@Composable
fun OrDivider(
    text: String = "অথবা",
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        HorizontalDivider(
            modifier = Modifier.weight(1f),
            color = AlIslahTheme.customColors.cardBorder
        )
        Text(
            text = "  $text  ",
            style = MaterialTheme.typography.bodySmall,
            color = AlIslahTheme.customColors.textTertiary
        )
        HorizontalDivider(
            modifier = Modifier.weight(1f),
            color = AlIslahTheme.customColors.cardBorder
        )
    }
}
