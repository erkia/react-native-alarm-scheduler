import XCTest
@testable import AlarmScheduler

final class AlarmSchedulerArgumentsTests: XCTestCase {
  func testDefaultsAndExplicitFalseSurviveConversion() throws {
    let empty = try AlarmScheduleRecord([:])
    XCTAssertEqual(empty.hour, -1)
    XCTAssertFalse(empty.showUi)
    XCTAssertNil(empty.ios)
    let record = try AlarmScheduleRecord([
      "hour": 7.0, "minute": 0, "weekdays": [1, 5],
      "soundUri": "file:///song.wav",
      "ios": ["silent": false, "metadata": ["count": 0, "enabled": false]]
    ])
    XCTAssertEqual(record.hour, 7)
    XCTAssertEqual(record.weekdays, [1, 5])
    XCTAssertEqual(record.soundUri, "file:///song.wav")
    XCTAssertEqual(record.ios?.silent, false)
    XCTAssertEqual(record.ios?.metadata?["enabled"] as? Bool, false)
  }

  func testResolutionAndNullOptionals() throws {
    let record = try AlarmOccurrenceResolutionRecord([
      "outcome": "deferred", "idempotencyKey": NSNull(),
      "next": ["delaySeconds": 15.0, "relationship": "deferred"]
    ])
    XCTAssertEqual(record.next?.delaySeconds, 15)
    XCTAssertNil(record.idempotencyKey)
    XCTAssertNil(try AlarmSchedulerArguments.stringList(["ids": NSNull()], "ids"))
    XCTAssertEqual(try AlarmSchedulerArguments.stringList(["ids": []], "ids"), [])
  }

  func testInvalidFieldsAreRejectedBeforeScheduling() {
    let invalidInputs: [[String: Any]] = [
      ["hour": 1.5], ["hour": "7"], ["timestamp": Double.nan],
      ["showUi": 1], ["hour": true], ["weekdays": [1, NSNull()]],
      ["ios": "invalid"], ["ios": ["silent": "false"]]
    ]
    for input in invalidInputs {
      XCTAssertThrowsError(try AlarmScheduleRecord(input))
    }
  }
}
