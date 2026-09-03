package app.village.alislah.model

import app.village.alislah.core.Parsing
import java.util.Date

data class AppNotification(
    val id: String = "",
    val title: String = "",
    val body: String = "",
    val type: String = "general", // "donation", "problem", "project", "citizen", "general"
    val source: String = "admin",
    val createdAt: Date = Date(),
    val isRead: Boolean = false
) {
    companion object {
        fun fromMap(id: String, map: Map<String, Any?>?, isRead: Boolean = false): AppNotification {
            return AppNotification(
                id = id,
                title = Parsing.readString(map, "title", "Notification"),
                body = Parsing.readString(map, "body", ""),
                type = Parsing.readString(map, "type", "general"),
                source = Parsing.readString(map, "source", "admin"),
                createdAt = Parsing.readDate(map, "createdAt"),
                isRead = isRead
            )
        }
    }
}
