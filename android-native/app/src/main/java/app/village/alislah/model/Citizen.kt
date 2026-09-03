package app.village.alislah.model

import app.village.alislah.core.Parsing

data class Citizen(
    val id: String = "",
    val name: String = "",
    val phone: String = "",
    val email: String = "",
    val photoUrl: String = "",
    val profession: String = "",
    val village: String = "",
    val address: String = "",
    val nidNumber: String = "",
    val bloodGroup: String = "",
    val dateOfBirth: String = "",
    val isCitizen: Boolean = true,
    val blocked: Boolean = false
) {
    companion object {
        fun fromMap(id: String, map: Map<String, Any?>?): Citizen {
            return Citizen(
                id = id,
                name = Parsing.readString(map, "name", "Unnamed"),
                phone = Parsing.readString(map, "phone", ""),
                email = Parsing.readString(map, "email", ""),
                photoUrl = Parsing.readString(map, "photoUrl", ""),
                profession = Parsing.readString(map, "profession", "Villager"),
                village = Parsing.readString(map, "village", ""),
                address = Parsing.readString(map, "address", ""),
                nidNumber = Parsing.readString(map, "nidNumber", ""),
                bloodGroup = Parsing.readString(map, "bloodGroup", ""),
                dateOfBirth = Parsing.readString(map, "dateOfBirth", ""),
                isCitizen = Parsing.readBoolean(map, "isCitizen", true),
                blocked = Parsing.readBoolean(map, "blocked", false)
            )
        }
    }
}
