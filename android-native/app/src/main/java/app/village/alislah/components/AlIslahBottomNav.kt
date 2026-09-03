package app.village.alislah.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Campaign
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.People
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.outlined.Campaign
import androidx.compose.material.icons.outlined.FavoriteBorder
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.PeopleOutline
import androidx.compose.material.icons.outlined.PersonOutline
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import app.village.alislah.theme.AlIslahPrimary
import app.village.alislah.theme.AlIslahTheme

enum class BottomNavTab(
    val title: String,
    val selectedIcon: ImageVector,
    val unselectedIcon: ImageVector,
    val route: String
) {
    HOME("হোম", Icons.Filled.Home, Icons.Outlined.Home, "home"),
    DONATIONS("দান", Icons.Filled.Favorite, Icons.Outlined.FavoriteBorder, "donations"),
    PROBLEMS("সমস্যা", Icons.Filled.Campaign, Icons.Outlined.Campaign, "problems"),
    CITIZENS("নাগরিক", Icons.Filled.People, Icons.Outlined.PeopleOutline, "citizens"),
    PROFILE("প্রোফাইল", Icons.Filled.Person, Icons.Outlined.PersonOutline, "profile")
}

@Composable
fun AlIslahBottomNav(
    currentRoute: String,
    onTabSelected: (BottomNavTab) -> Unit,
    modifier: Modifier = Modifier
) {
    Surface(
        modifier = modifier.fillMaxWidth(),
        color = AlIslahTheme.customColors.cardBackground,
        shadowElevation = 8.dp
    ) {
        Column {
            HorizontalDivider(
                thickness = 1.dp,
                color = AlIslahTheme.customColors.dividerColor
            )
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .navigationBarsPadding()
                    .padding(vertical = 8.dp, horizontal = 6.dp),
                horizontalArrangement = Arrangement.SpaceAround,
                verticalAlignment = Alignment.CenterVertically
            ) {
                BottomNavTab.values().forEach { tab ->
                    val isSelected = currentRoute == tab.route

                    val iconTint by animateColorAsState(
                        targetValue = if (isSelected) AlIslahPrimary else AlIslahTheme.customColors.textTertiary,
                        label = "iconTint"
                    )

                    val textColor by animateColorAsState(
                        targetValue = if (isSelected) AlIslahPrimary else AlIslahTheme.customColors.textSecondary,
                        label = "textColor"
                    )

                    val interactionSource = remember { MutableInteractionSource() }

                    Column(
                        modifier = Modifier
                            .clip(RoundedCornerShape(12.dp))
                            .clickable(
                                interactionSource = interactionSource,
                                indication = null
                            ) { onTabSelected(tab) }
                            .padding(horizontal = 10.dp, vertical = 4.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(12.dp))
                                .background(
                                    if (isSelected) AlIslahPrimary.copy(alpha = 0.12f)
                                    else Color.Transparent
                                )
                                .padding(horizontal = 14.dp, vertical = 4.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = if (isSelected) tab.selectedIcon else tab.unselectedIcon,
                                contentDescription = tab.title,
                                tint = iconTint,
                                modifier = Modifier.size(22.dp)
                            )
                        }

                        Spacer(modifier = Modifier.height(2.dp))

                        Text(
                            text = tab.title,
                            style = MaterialTheme.typography.labelSmall.copy(
                                fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
                                fontSize = 11.sp
                            ),
                            color = textColor
                        )
                    }
                }
            }
        }
    }
}
