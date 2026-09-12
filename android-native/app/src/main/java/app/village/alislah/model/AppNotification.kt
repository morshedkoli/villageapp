package app.village.alislah.model

import app.village.alislah.core.Parsing
import java.util.Date

data class AppNotification(
    val id: String = "",
    val title: String = "",
    val body: String = "",
    val type: String = "general", // "donation", "problem", "project", "citizen", "expense", "general"
    val targetId: String = "",
    val route: String = "",
    val source: String = "admin",
    val createdAt: Date = Date(),
    val isRead: Boolean = false,
    val data: Map<String, Any?> = emptyMap()
) {
    companion object {
        fun fromMap(id: String, map: Map<String, Any?>?, isRead: Boolean = false): AppNotification {
            val dataMap = (map?.get("data") as? Map<*, *>)?.mapNotNull { (k, v) ->
                if (k is String) k to v else null
            }?.toMap() ?: emptyMap()

            val targetId = Parsing.readString(map, "targetId",
                Parsing.readString(map, "problemId",
                    Parsing.readString(map, "projectId",
                        Parsing.readString(map, "donationId",
                            Parsing.readString(map, "citizenId",
                                (dataMap["targetId"] ?: dataMap["problemId"] ?: dataMap["projectId"] ?: dataMap["donationId"] ?: dataMap["id"])?.toString() ?: ""
                            )
                        )
                    )
                )
            )

            val route = Parsing.readString(map, "route",
                Parsing.readString(map, "link",
                    (dataMap["route"] ?: dataMap["link"])?.toString() ?: ""
                )
            )

            return AppNotification(
                id = id,
                title = Parsing.readString(map, "title", "Notification"),
                body = Parsing.readString(map, "body", ""),
                type = Parsing.readString(map, "type", (dataMap["type"]?.toString()) ?: "general"),
                targetId = targetId,
                route = route,
                source = Parsing.readString(map, "source", "admin"),
                createdAt = Parsing.readDate(map, "createdAt"),
                isRead = isRead,
                data = dataMap
            )
        }
    }
}
