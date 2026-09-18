import Foundation

struct AlarmScheduleRecord {
  var id: String?
  var hour: Int = -1
  var minute: Int = -1
  var title: String?
  var weekdays: [Int]?
  var timestamp: Double?
  var showUi: Bool = false
  var soundUri: String?
  var ios: IosAlarmOptionsRecord?

  init() {}

  init(_ values: [String: Any]) throws {
    id = try AlarmSchedulerArguments.string(values, "id")
    hour = try AlarmSchedulerArguments.int(values, "hour") ?? -1
    minute = try AlarmSchedulerArguments.int(values, "minute") ?? -1
    title = try AlarmSchedulerArguments.string(values, "title")
    weekdays = try AlarmSchedulerArguments.intList(values, "weekdays")
    timestamp = try AlarmSchedulerArguments.double(values, "timestamp")
    showUi = try AlarmSchedulerArguments.boolean(values, "showUi") ?? false
    soundUri = try AlarmSchedulerArguments.string(values, "soundUri")
    ios = try AlarmSchedulerArguments.object(values, "ios").map { try IosAlarmOptionsRecord($0) }
  }
}

struct IosAlarmOptionsRecord {
  var metadata: [String: Any]?
  var alertTitle: String?
  var alertActionMode: String?
  var stopButtonTitle: String?
  var secondaryButtonTitle: String?
  var countdownTitle: String?
  var stopIntentBehavior: String?
  var secondaryButtonBehavior: String?
  var soundUri: String?
  var soundName: String?
  var silent: Bool = false

  init() {}

  init(_ values: [String: Any]) throws {
    metadata = try AlarmSchedulerArguments.object(values, "metadata")
    alertTitle = try AlarmSchedulerArguments.string(values, "alertTitle")
    alertActionMode = try AlarmSchedulerArguments.string(values, "alertActionMode")
    stopButtonTitle = try AlarmSchedulerArguments.string(values, "stopButtonTitle")
    secondaryButtonTitle = try AlarmSchedulerArguments.string(values, "secondaryButtonTitle")
    countdownTitle = try AlarmSchedulerArguments.string(values, "countdownTitle")
    stopIntentBehavior = try AlarmSchedulerArguments.string(values, "stopIntentBehavior")
    secondaryButtonBehavior = try AlarmSchedulerArguments.string(values, "secondaryButtonBehavior")
    soundUri = try AlarmSchedulerArguments.string(values, "soundUri")
    soundName = try AlarmSchedulerArguments.string(values, "soundName")
    silent = try AlarmSchedulerArguments.boolean(values, "silent") ?? false
  }
}

final class InvalidAlarmException: LocalizedError {
  private let message: String

  var reason: String {
    message
  }

  var errorDescription: String? { message }

  init(_ reason: String) {
    self.message = reason
  }
}

final class UnsupportedAlarmException: LocalizedError {
  private let message: String

  var reason: String {
    message
  }

  var errorDescription: String? { message }

  init(_ reason: String) {
    self.message = reason
  }
}
