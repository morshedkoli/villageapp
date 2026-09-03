package app.village.alislah.core

import java.text.DecimalFormat
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

object Formatters {
    private val bdtFormat = DecimalFormat("#,##,##0")
    private val standardDateFormat = SimpleDateFormat("dd MMM yyyy", Locale.getDefault())
    private val standardDateTimeFormat = SimpleDateFormat("dd MMM yyyy, hh:mm a", Locale.getDefault())
    private val timeOnlyFormat = SimpleDateFormat("hh:mm a", Locale.getDefault())

    fun formatBDT(amount: Double): String {
        return "৳ " + bdtFormat.format(amount)
    }

    fun formatBDT(amount: Long): String {
        return "৳ " + bdtFormat.format(amount)
    }

    fun formatDate(date: Date): String {
        return standardDateFormat.format(date)
    }

    fun formatDateTime(date: Date): String {
        return standardDateTimeFormat.format(date)
    }

    fun formatRelativeTime(date: Date): String {
        val now = System.currentTimeMillis()
        val diff = now - date.time

        val seconds = diff / 1000
        val minutes = seconds / 60
        val hours = minutes / 60
        val days = hours / 24

        return when {
            seconds < 60 -> "এইমাত্র"
            minutes < 60 -> "$minutes মিনিট আগে"
            hours < 24 -> "$hours ঘণ্টা আগে"
            days == 1L -> "গতকাল"
            days < 7 -> "$days দিন আগে"
            else -> formatDate(date)
        }
    }

    fun toBanglaDigits(input: String): String {
        val banglaDigits = charArrayOf('০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯')
        val builder = StringBuilder()
        for (ch in input) {
            if (ch in '0'..'9') {
                builder.append(banglaDigits[ch - '0'])
            } else {
                builder.append(ch)
            }
        }
        return builder.toString()
    }
}
