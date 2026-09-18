package expo.modules.alarm

import org.junit.Assert.*
import org.junit.Test

class AlarmSchedulerArgumentsTest {
  @Test fun preservesDefaultsAndExplicitFalseOrZero() {
    val empty = AlarmScheduleRecord.fromMap(emptyMap())
    assertEquals(-1, empty.hour)
    assertFalse(empty.showUi)
    assertNull(empty.ios)
    val input = AlarmScheduleRecord.fromMap(mapOf(
      "hour" to 7.0, "minute" to 0.0, "weekdays" to listOf(1.0, 5.0),
      "soundUri" to "content://audio/123",
      "ios" to mapOf("silent" to false, "metadata" to mapOf("count" to 0.0, "enabled" to false)),
      "android" to mapOf("volume" to 0.0, "vibrate" to false)
    ))
    assertEquals(7, input.hour)
    assertEquals(listOf(1, 5), input.weekdays)
    assertEquals("content://audio/123", input.soundUri)
    assertEquals(false, input.ios?.silent)
    assertEquals(false, input.ios?.metadata?.get("enabled"))
    assertEquals(0.0, input.android?.volume)
    assertEquals(false, input.android?.vibrate)
  }

  @Test fun decodesResolutionAndTreatsNullAsAbsent() {
    val resolution = AlarmOccurrenceResolutionRecord.fromMap(mapOf(
      "outcome" to "deferred", "idempotencyKey" to null,
      "next" to mapOf("delaySeconds" to 15.0, "relationship" to "deferred")
    ))
    assertEquals("deferred", resolution.outcome)
    assertEquals(15.0, resolution.next?.delaySeconds)
    assertNull(resolution.idempotencyKey)
  }

  @Test fun rejectsInvalidInputBeforeScheduling() {
    for (input in listOf(
      mapOf("hour" to 1.5), mapOf("hour" to "7"), mapOf("timestamp" to Double.NaN),
      mapOf("showUi" to 1.0), mapOf("weekdays" to listOf(1.0, null)),
      mapOf("ios" to "invalid"), mapOf("android" to mapOf("silent" to "false"))
    )) {
      try {
        AlarmScheduleRecord.fromMap(input)
        fail("Expected rejection for $input")
      } catch (_: IllegalArgumentException) { }
    }
  }
}
