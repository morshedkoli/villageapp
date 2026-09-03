package app.village.alislah.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import app.village.alislah.theme.CardShape
import app.village.alislah.theme.AlIslahTheme

@Composable
fun AlIslahCard(
    modifier: Modifier = Modifier,
    shape: Shape = CardShape,
    backgroundColor: Color = AlIslahTheme.customColors.cardBackground,
    borderColor: Color = AlIslahTheme.customColors.cardBorder,
    borderWidth: Dp = 1.dp,
    elevation: Dp = 0.dp,
    onClick: (() -> Unit)? = null,
    content: @Composable BoxScope.() -> Unit
) {
    Card(
        modifier = modifier
            .then(
                if (onClick != null) Modifier.clickable { onClick() } else Modifier
            ),
        shape = shape,
        colors = CardDefaults.cardColors(containerColor = backgroundColor),
        border = BorderStroke(borderWidth, borderColor),
        elevation = CardDefaults.cardElevation(defaultElevation = elevation)
    ) {
        Box(modifier = Modifier.padding(16.dp)) {
            content()
        }
    }
}
