package app.village.alislah.model

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class ModelParsingTest {

    @Test
    fun testVillageDefensiveParsingWithNullMap() {
        val village = Village.fromMap("main_village", null)
        assertEquals("main_village", village.id)
        assertEquals("গ্রামবাসী", village.name)
        assertEquals(0, village.totalCitizens)
        assertEquals(0.0, village.totalFundCollected, 0.001)
        assertEquals(0.0, village.availableBalance, 0.001)
    }

    @Test
    fun testDonationDefensiveParsing() {
        val map = mapOf(
            "donorName" to "Md Rahim",
            "amount" to 1500,
            "paymentMethod" to "bKash",
            "status" to "Approved",
            "transactionId" to "TRX9988"
        )
        val donation = Donation.fromMap("d1", map)
        assertEquals("d1", donation.id)
        assertEquals("Md Rahim", donation.donorName)
        assertEquals(1500.0, donation.amount, 0.001)
        assertEquals("bKash", donation.paymentMethod)
        assertTrue(donation.isApproved)
        assertFalse(donation.isPending)
    }

    @Test
    fun testProblemDefensiveParsing() {
        val map = mapOf(
            "title" to "Road Damaged",
            "description" to "Potholes near school",
            "status" to "Pending",
            "upvotesCount" to 12
        )
        val problem = Problem.fromMap("p1", map)
        assertEquals("Road Damaged", problem.title)
        assertEquals(12, problem.upvotesCount)
        assertTrue(problem.isPending)
        assertFalse(problem.isApproved)
    }

    @Test
    fun testProjectProgressCalculation() {
        val map = mapOf(
            "title" to "Bridge Construction",
            "estimatedCost" to 100000.0,
            "allocatedFunds" to 50000.0,
            "status" to "In Progress"
        )
        val project = Project.fromMap("proj1", map)
        assertEquals(50.0f, project.progressPercentage, 0.001f)
        assertTrue(project.isInProgress)
        assertFalse(project.isCompleted)
    }

    @Test
    fun testCitizenDefensiveParsing() {
        val map = mapOf(
            "name" to "Karim Ahmed",
            "profession" to "Doctor",
            "bloodGroup" to "O+",
            "isCitizen" to true,
            "blocked" to false
        )
        val citizen = Citizen.fromMap("c1", map)
        assertEquals("Karim Ahmed", citizen.name)
        assertEquals("Doctor", citizen.profession)
        assertEquals("O+", citizen.bloodGroup)
        assertTrue(citizen.isCitizen)
        assertFalse(citizen.blocked)
    }
}
