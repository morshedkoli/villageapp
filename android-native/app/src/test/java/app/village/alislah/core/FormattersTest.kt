package app.village.alislah.core

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import java.util.Date

class FormattersTest {

    @Test
    fun testFormatBDT() {
        val formatted = Formatters.formatBDT(25000.0)
        assertTrue(formatted.startsWith("৳"))
        assertTrue(formatted.contains("25,000"))
    }

    @Test
    fun testFormatBDTZero() {
        val formatted = Formatters.formatBDT(0.0)
        assertTrue(formatted.startsWith("৳"))
        assertTrue(formatted.contains("0"))
    }

    @Test
    fun testFormatRelativeTimeJustNow() {
        val now = Date()
        val relative = Formatters.formatRelativeTime(now)
        assertEquals("এইমাত্র", relative)
    }

    @Test
    fun testToBanglaDigits() {
        val bangla = Formatters.toBanglaDigits("1234567890")
        assertEquals("১২৩৪৫৬৭৮৯০", bangla)
    }
}
