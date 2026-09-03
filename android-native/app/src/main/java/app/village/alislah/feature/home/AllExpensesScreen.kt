package app.village.alislah.feature.home

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowUpward
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import app.village.alislah.components.EmptyState
import app.village.alislah.components.AlIslahCard
import app.village.alislah.components.AlIslahTextField
import app.village.alislah.components.AlIslahTopBar
import app.village.alislah.core.Formatters
import app.village.alislah.model.FundTransaction
import app.village.alislah.theme.AlIslahTheme

@Composable
fun AllExpensesScreen(
    onBackClick: () -> Unit,
    viewModel: HomeViewModel = viewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    var searchQuery by remember { mutableStateOf("") }
    var selectedCategory by remember { mutableStateOf("All") }

    val filteredExpenses = uiState.allExpenses.filter { expense ->
        val matchesSearch = expense.project.contains(searchQuery, ignoreCase = true) ||
                expense.category.contains(searchQuery, ignoreCase = true) ||
                expense.notes.contains(searchQuery, ignoreCase = true)

        val matchesCategory = if (selectedCategory == "All") true else expense.category.equals(selectedCategory, ignoreCase = true)

        matchesSearch && matchesCategory
    }

    val totalSpent = filteredExpenses.sumOf { it.amount }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .statusBarsPadding()
    ) {
        AlIslahTopBar(
            title = "গ্রামের ব্যয় ও খরচের খতিয়ান",
            subtitle = "মোট ব্যয়: ${Formatters.formatBDT(totalSpent)}",
            showBackButton = true,
            onBackClick = onBackClick
        )

        Column(modifier = Modifier.padding(horizontal = 20.dp, vertical = 8.dp)) {
            AlIslahTextField(
                value = searchQuery,
                onValueChange = { searchQuery = it },
                modifier = Modifier.fillMaxWidth(),
                placeholder = "প্রকল্পের নাম, খাত দিয়ে খুঁজুন...",
                leadingIcon = {
                    Icon(
                        imageVector = Icons.Default.Search,
                        contentDescription = null,
                        tint = AlIslahTheme.customColors.textSecondary
                    )
                }
            )

            Spacer(modifier = Modifier.height(10.dp))

            LazyRow(
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                val categories = listOf("All", "রাস্তাঘাট", "কালভার্ট", "মসজিদ/মাদ্রাসা", "ত্রাণ ও সাহায্য", "চিকিৎসা", "অন্যান্য")
                items(categories) { cat ->
                    val isSelected = selectedCategory == cat
                    val label = if (cat == "All") "সকল খাত" else cat
                    FilterChip(
                        selected = isSelected,
                        onClick = { selectedCategory = cat },
                        label = { Text(text = label) },
                        colors = FilterChipDefaults.filterChipColors(
                            selectedContainerColor = Color(0xFFEF4444).copy(alpha = 0.15f),
                            selectedLabelColor = Color(0xFFEF4444)
                        )
                    )
                }
            }
        }

        if (filteredExpenses.isEmpty()) {
            EmptyState(
                title = "কোনো ব্যয়ের হিসাব পাওয়া যায়নি",
                description = "আপনার অনুসন্ধান বা নির্বাচিত খাতের জন্য কোনো ব্যয়ের রেকর্ড নেই।"
            )
        } else {
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(horizontal = 20.dp, vertical = 8.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                items(filteredExpenses) { expense ->
                    ExpenseDetailCard(expense = expense)
                }
            }
        }
    }
}

@Composable
private fun ExpenseDetailCard(expense: FundTransaction) {
    AlIslahCard(modifier = Modifier.fillMaxWidth()) {
        Column(modifier = Modifier.fillMaxWidth()) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        modifier = Modifier
                            .size(40.dp)
                            .clip(RoundedCornerShape(10.dp))
                            .background(Color(0xFFEF4444).copy(alpha = 0.12f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.ArrowUpward,
                            contentDescription = null,
                            tint = Color(0xFFEF4444),
                            modifier = Modifier.size(20.dp)
                        )
                    }
                    Spacer(modifier = Modifier.width(12.dp))
                    Column {
                        Text(
                            text = expense.project,
                            style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                            color = AlIslahTheme.customColors.textPrimary
                        )
                        Text(
                            text = "${expense.category} • ${Formatters.formatDateTime(expense.createdAt)}",
                            style = MaterialTheme.typography.bodySmall,
                            color = AlIslahTheme.customColors.textTertiary
                        )
                    }
                }

                Text(
                    text = "- ${Formatters.formatBDT(expense.amount)}",
                    style = MaterialTheme.typography.titleLarge.copy(
                        fontWeight = FontWeight.Bold,
                        color = Color(0xFFEF4444)
                    )
                )
            }

            if (expense.notes.isNotBlank()) {
                Spacer(modifier = Modifier.height(10.dp))
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(8.dp))
                        .background(AlIslahTheme.customColors.cardBorder.copy(alpha = 0.3f))
                        .padding(8.dp)
                ) {
                    Text(
                        text = "বিবরণ: ${expense.notes}",
                        style = MaterialTheme.typography.bodySmall,
                        color = AlIslahTheme.customColors.textSecondary
                    )
                }
            }
        }
    }
}
