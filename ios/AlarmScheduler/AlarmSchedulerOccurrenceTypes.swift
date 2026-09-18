import Foundation

struct AlarmOccurrenceNextRecord {
  var delaySeconds: Double = 0
  var relationship: String = ""
  var metadata: [String: Any]?

  init() {}

  init(_ values: [String: Any]) throws {
    delaySeconds = try AlarmSchedulerArguments.double(values, "delaySeconds") ?? 0
    relationship = try AlarmSchedulerArguments.string(values, "relationship") ?? ""
    metadata = try AlarmSchedulerArguments.object(values, "metadata")
  }
}

struct AlarmOccurrenceResolutionRecord {
  var outcome: String = ""
  var next: AlarmOccurrenceNextRecord?
  var idempotencyKey: String?

  init() {}

  init(_ values: [String: Any]) throws {
    outcome = try AlarmSchedulerArguments.string(values, "outcome") ?? ""
    next = try AlarmSchedulerArguments.object(values, "next").map { try AlarmOccurrenceNextRecord($0) }
    idempotencyKey = try AlarmSchedulerArguments.string(values, "idempotencyKey")
  }
}
