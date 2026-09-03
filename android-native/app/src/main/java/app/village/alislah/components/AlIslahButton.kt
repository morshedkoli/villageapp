package app.village.alislah.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import app.village.alislah.theme.ButtonShape
import app.village.alislah.theme.AlIslahPrimary
import app.village.alislah.theme.AlIslahTheme

enum class ButtonVariant {
    PRIMARY,
    SECONDARY,
    OUTLINE,
    TONAL
}

@Composable
fun AlIslahButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    variant: ButtonVariant = ButtonVariant.PRIMARY,
    enabled: Boolean = true,
    isLoading: Boolean = false,
    icon: ImageVector? = null,
    height: Dp = 50.dp
) {
    when (variant) {
        ButtonVariant.PRIMARY -> {
            Button(
                onClick = onClick,
                modifier = modifier.height(height),
                enabled = enabled && !isLoading,
                shape = ButtonShape,
                colors = ButtonDefaults.buttonColors(
                    containerColor = AlIslahPrimary,
                    contentColor = Color.White,
                    disabledContainerColor = AlIslahPrimary.copy(alpha = 0.5f),
                    disabledContentColor = Color.White.copy(alpha = 0.8f)
                ),
                contentPadding = PaddingValues(horizontal = 20.dp)
            ) {
                ButtonInnerContent(text = text, isLoading = isLoading, icon = icon, contentColor = Color.White)
            }
        }
        ButtonVariant.SECONDARY -> {
            Button(
                onClick = onClick,
                modifier = modifier.height(height),
                enabled = enabled && !isLoading,
                shape = ButtonShape,
                colors = ButtonDefaults.buttonColors(
                    containerColor = MaterialTheme.colorScheme.secondary,
                    contentColor = Color.White
                ),
                contentPadding = PaddingValues(horizontal = 20.dp)
            ) {
                ButtonInnerContent(text = text, isLoading = isLoading, icon = icon, contentColor = Color.White)
            }
        }
        ButtonVariant.TONAL -> {
            Button(
                onClick = onClick,
                modifier = modifier.height(height),
                enabled = enabled && !isLoading,
                shape = ButtonShape,
                colors = ButtonDefaults.buttonColors(
                    containerColor = MaterialTheme.colorScheme.primaryContainer,
                    contentColor = MaterialTheme.colorScheme.onPrimaryContainer
                ),
                contentPadding = PaddingValues(horizontal = 20.dp)
            ) {
                ButtonInnerContent(
                    text = text,
                    isLoading = isLoading,
                    icon = icon,
                    contentColor = MaterialTheme.colorScheme.onPrimaryContainer
                )
            }
        }
        ButtonVariant.OUTLINE -> {
            OutlinedButton(
                onClick = onClick,
                modifier = modifier.height(height),
                enabled = enabled && !isLoading,
                shape = ButtonShape,
                colors = ButtonDefaults.outlinedButtonColors(
                    contentColor = AlIslahPrimary
                ),
                border = BorderStroke(1.5.dp, AlIslahPrimary),
                contentPadding = PaddingValues(horizontal = 20.dp)
            ) {
                ButtonInnerContent(text = text, isLoading = isLoading, icon = icon, contentColor = AlIslahPrimary)
            }
        }
    }
}

@Composable
private fun ButtonInnerContent(
    text: String,
    isLoading: Boolean,
    icon: ImageVector?,
    contentColor: Color
) {
    if (isLoading) {
        CircularProgressIndicator(
            modifier = Modifier.size(20.dp),
            color = contentColor,
            strokeWidth = 2.5.dp
        )
    } else {
        Row(
            verticalAlignment = Alignment.CenterVertically
        ) {
            if (icon != null) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = contentColor,
                    modifier = Modifier.size(18.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
            }
            Text(
                text = text,
                style = MaterialTheme.typography.labelLarge.copy(
                    fontWeight = FontWeight.SemiBold,
                    fontSize = 15.sp
                ),
                color = contentColor
            )
        }
    }
}
