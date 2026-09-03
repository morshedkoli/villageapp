package app.village.alislah.core

import com.google.firebase.Timestamp
import java.util.Date

object Parsing {
    fun readString(map: Map<String, Any?>?, key: String, default: String = ""): String {
        if (map == null) return default
        val value = map[key] ?: return default
        return value.toString()
    }

    fun readDouble(map: Map<String, Any?>?, key: String, default: Double = 0.0): Double {
        if (map == null) return default
        val value = map[key] ?: return default
        return when (value) {
            is Number -> value.toDouble()
            is String -> value.toDoubleOrNull() ?: default
            else -> default
        }
    }

    fun readInt(map: Map<String, Any?>?, key: String, default: Int = 0): Int {
        if (map == null) return default
        val value = map[key] ?: return default
        return when (value) {
            is Number -> value.toInt()
            is String -> value.toIntOrNull() ?: default
            else -> default
        }
    }

    fun readBoolean(map: Map<String, Any?>?, key: String, default: Boolean = false): Boolean {
        if (map == null) return default
        val value = map[key] ?: return default
        return when (value) {
            is Boolean -> value
            is String -> value.equals("true", ignoreCase = true)
            is Number -> value.toInt() != 0
            else -> default
        }
    }

    fun readDate(map: Map<String, Any?>?, key: String, default: Date = Date()): Date {
        if (map == null) return default
        val value = map[key] ?: return default
        return when (value) {
            is Timestamp -> value.toDate()
            is Date -> value
            is Number -> Date(value.toLong())
            is String -> {
                // Try parsing standard ISO or timestamp string if any
                try {
                    Date(value.toLong())
                } catch (e: Exception) {
                    default
                }
            }
            else -> default
        }
    }

    @Suppress("UNCHECKED_CAST")
    fun readStringList(map: Map<String, Any?>?, key: String): List<String> {
        if (map == null) return emptyList()
        val value = map[key] ?: return emptyList()
        return when (value) {
            is List<*> -> value.mapNotNull { it?.toString() }
            else -> emptyList()
        }
    }
}
