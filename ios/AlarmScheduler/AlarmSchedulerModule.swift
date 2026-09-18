import React
import Foundation
import UIKit

#if canImport(AlarmKit)
import AlarmKit
#endif

@objc(AlarmSchedulerImplementation)
public class AlarmSchedulerModule: NSObject {
  @objc public var eventHandler: ((String, [String: Any]) -> Void)?
  private var alarmActionObserver: NSObjectProtocol?
  private var alarmUpdatesTask: Task<Void, Never>?

  deinit {
    if let alarmActionObserver {
      NotificationCenter.default.removeObserver(alarmActionObserver)
    }
    alarmUpdatesTask?.cancel()
  }

  // React Native calls through the Objective-C++ TurboModule adapter. Keep the
  // scheduling engine in Swift, including its async tasks and main-thread UI work.
  @objc public func invoke(_ method: String, arguments: [String: Any],
                           resolve: @escaping RCTPromiseResolveBlock,
                           reject: @escaping RCTPromiseRejectBlock) {
    Task {
      do {
        let result = try await invoke(method, arguments: arguments)
        resolve(result)
      } catch {
        let code = error is UnsupportedAlarmException ? "ERR_UNSUPPORTED_ALARM" :
          (error is InvalidAlarmException ? "ERR_INVALID_ALARM" : "ERR_ALARM_SCHEDULER")
        reject(code, error.localizedDescription, error)
      }
    }
  }

  private func invoke(_ method: String, arguments: [String: Any]) async throws -> Any? {
    func string(_ key: String) throws -> String {
      try AlarmSchedulerArguments.required(AlarmSchedulerArguments.string(arguments, key), key)
    }
    func object(_ key: String) throws -> [String: Any] {
      try AlarmSchedulerArguments.required(AlarmSchedulerArguments.object(arguments, key), key)
    }
    switch method {
    case "getPermissionsAsync":
      return await permissions()
    case "requestPermissionsAsync":
      #if canImport(AlarmKit)
      if #available(iOS 26.0, *) {
        _ = try? await AlarmManager.shared.requestAuthorization()
      }
      #endif
      return await permissions()
    case "openAlarmSettingsAsync":
      return await MainActor.run {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return false }
        UIApplication.shared.open(url)
        return true
      }
    case "openFullScreenIntentSettingsAsync":
      return false
    case "scheduleAlarmAsync":
      return try await schedule(AlarmScheduleRecord(object("alarm")))
    case "cancelAlarmAsync":
      return await cancel(id: try string("id"))
    case "getScheduledAlarmsAsync":
      return visibleScheduledAlarms()
    case "getCurrentAlarmContextAsync":
      return currentAlarmContext()
    case "getPendingAlarmActionsAsync":
      return AlarmSchedulerNativeAlarmStore.all()
    case "clearPendingAlarmActionsAsync":
      AlarmSchedulerNativeAlarmStore.clear(ids: try AlarmSchedulerArguments.stringList(arguments, "ids"))
    case "getPendingNativeAlarmHandoffAsync":
      return AlarmSchedulerNativeAlarmStore.pendingHandoff()
    case "clearPendingNativeAlarmHandoffAsync":
      AlarmSchedulerNativeAlarmStore.clearPendingHandoff()
    case "completeNativeAlarmAsync":
      let alarmId = try string("alarmId")
      AlarmSchedulerNativeAlarmStore.complete(alarmId: alarmId)
      await cancelNativeAndRetryAlarms(originalAlarmId: alarmId)
      AlarmSchedulerNativeAlarmStore.clearActions(alarmId: alarmId)
      finishOccurrenceRecords(alarmId: alarmId)
    case "resolveAlarmOccurrenceAsync":
      return try await resolveAlarmOccurrence(
        occurrenceId: string("occurrenceId"),
        resolution: AlarmOccurrenceResolutionRecord(object("resolution"))
      )
    case "getAlarmOccurrencesAsync":
      return AlarmSchedulerOccurrenceStore.all(alarmId: try AlarmSchedulerArguments.string(arguments, "alarmId"))
    case "cancelAlarmOccurrenceAsync":
      return await cancelAlarmOccurrence(occurrenceId: try string("occurrenceId"))
    case "scheduleNativeAlarmBackupAsync":
      return await scheduleNativeAlarmBackup(
        alarmId: try string("alarmId"),
        delaySeconds: try AlarmSchedulerArguments.double(arguments, "delaySeconds")
      )
    case "cancelNativeAlarmBackupAsync":
      return await cancelNativeAlarmBackup(alarmId: try string("alarmId"))
    case "clearBypassAsync", "resetNativeAlarmCompletionAsync":
      AlarmSchedulerNativeAlarmStore.resetCompletion(alarmId: try string("alarmId"))
    case "getNativeAlarmDebugStateAsync":
      let alarmId = try string("alarmId")
      var state: [String: Any] = [
        "alarmId": alarmId,
        "isComplete": AlarmSchedulerNativeAlarmStore.isComplete(alarmId: alarmId),
        "activeRetryAlarmIds": AlarmSchedulerNativeAlarmStore.retryAlarmIds(for: alarmId),
        "pendingActions": AlarmSchedulerNativeAlarmStore.all().filter { ($0["alarmId"] as? String) == alarmId },
        "pendingHandoff": AlarmSchedulerNativeAlarmStore.pendingHandoff() as Any,
        "intentDebugCounts": AlarmSchedulerNativeAlarmStore.intentDebugCounts(alarmId: alarmId),
        "currentContext": currentAlarmContext() as Any
      ]
      if let storedAlarm = storedAlarms().first(where: { ($0["id"] as? String) == alarmId }),
        let alarmKitDebugState = storedAlarm["alarmKitDebugState"] as? [String: Any] {
        alarmKitDebugState.forEach { key, value in state[key] = value }
      }
      return state
    case "setSystemAlarmAsync":
      throw UnsupportedAlarmException("iOS does not expose the Clock app alarm list through a public API. Use scheduleAlarmAsync on iOS 26+.")
    case "openSystemAlarmAppAsync":
      return await MainActor.run {
        guard let url = URL(string: "clock-alarm:") else { return false }
        UIApplication.shared.open(url)
        return true
      }
    default:
      throw InvalidAlarmException("Unknown alarm method: \(method)")
    }
    return nil
  }

  @objc public func setObserving(_ event: String, observing: Bool) {
    // Serialize observer changes with invalidation, which also runs on the main queue.
    DispatchQueue.main.async {
      switch event {
      case "onAlarmAction":
        if observing { self.startAlarmActionObserving() } else { self.stopAlarmActionObserving() }
      case "onAlarmStateChange":
        if observing { self.startAlarmUpdatesObserving() } else { self.stopAlarmUpdatesObserving() }
      default: break
      }
    }
  }

  @objc public func invalidate() {
    DispatchQueue.main.async {
      self.stopAlarmActionObserving()
      self.stopAlarmUpdatesObserving()
      self.eventHandler = nil
    }
  }

  private func sendEvent(_ name: String, _ payload: [String: Any]) {
    eventHandler?(name, payload)
  }

  private func startAlarmActionObserving() {
    guard alarmActionObserver == nil else {
      return
    }
    alarmActionObserver = NotificationCenter.default.addObserver(
      forName: AlarmSchedulerNativeAlarmStore.actionRecordedNotification,
      object: nil,
      queue: .main
    ) { [weak self] notification in
      guard let action = notification.userInfo as? [String: Any] else {
        return
      }
      self?.sendEvent("onAlarmAction", action)
    }
  }

  private func stopAlarmActionObserving() {
    if let alarmActionObserver {
      NotificationCenter.default.removeObserver(alarmActionObserver)
      self.alarmActionObserver = nil
    }
  }

  private func startAlarmUpdatesObserving() {
    guard alarmUpdatesTask == nil else {
      return
    }
    #if canImport(AlarmKit)
    if #available(iOS 26.0, *) {
      alarmUpdatesTask = Task { [weak self] in
        for await alarms in AlarmManager.shared.alarmUpdates {
          guard !Task.isCancelled else {
            return
          }
          for alarm in alarms {
            await self?.sendAlarmStateChange(alarm)
          }
        }
      }
    }
    #endif
  }

  private func stopAlarmUpdatesObserving() {
    alarmUpdatesTask?.cancel()
    alarmUpdatesTask = nil
  }

  #if canImport(AlarmKit)
  @available(iOS 26.0, *)
  @MainActor
  private func sendAlarmStateChange(_ alarm: Alarm) {
    let nativeAlarmId = alarm.id.uuidString
    var occurrence = AlarmSchedulerOccurrenceStore.occurrence(id: nativeAlarmId)
    let alarmId = occurrence?["alarmId"] as? String ?? nativeAlarmId
    let state = mapAlarmState(alarm.state)
    if state == "alerting",
      occurrence?["relationship"] as? String == "primary",
      occurrence?["occurrenceId"] as? String == alarmId {
      AlarmSchedulerOccurrenceStore.updatePhase(occurrenceId: alarmId, phase: "cancelled")
      occurrence = nil
    }
    if occurrence == nil,
      let storedAlarm = storedAlarms().first(where: { ($0["id"] as? String) == alarmId }) {
      if state == "alerting" {
        occurrence = activePrimaryOccurrence(
          alarmId: alarmId,
          metadata: storedAlarm["metadata"] as? [String: Any] ?? [:]
        )
      } else {
        occurrence = AlarmSchedulerOccurrenceStore.all(alarmId: alarmId).first(where: {
          ($0["relationship"] as? String) == "primary" &&
            (($0["phase"] as? String) == "scheduled" || ($0["phase"] as? String) == "ringing")
        })
      }
    } else if state == "alerting", let occurrenceId = occurrence?["occurrenceId"] as? String {
      AlarmSchedulerOccurrenceStore.updatePhase(occurrenceId: occurrenceId, phase: "ringing")
    }
    let occurrenceId = occurrence?["occurrenceId"] as? String ?? nativeAlarmId
    var event: [String: Any] = [
      "id": alarmId,
      "occurrenceId": occurrenceId,
      "state": state,
      "timestamp": Int64(Date().timeIntervalSince1970 * 1000)
    ]
    if let relationship = occurrence?["relationship"] {
      event["relationship"] = relationship
    }
    if let metadata = occurrence?["metadata"] {
      event["metadata"] = metadata
    } else if let storedAlarm = storedAlarms().first(where: { ($0["id"] as? String) == alarmId }) {
      event["metadata"] = storedAlarm["metadata"]
    }
    sendEvent("onAlarmStateChange", event)
  }
  #endif

  private func permissions() async -> [String: Any] {
    #if canImport(AlarmKit)
    if #available(iOS 26.0, *) {
      let status = AlarmManager.shared.authorizationState
      return [
        "platform": "ios",
        "status": mapAuthorizationStatus(status),
        "canScheduleExactAlarms": status == .authorized,
        "canOpenSettings": true
      ]
    }
    #endif

    return [
      "platform": "ios",
      "status": "unavailable",
      "canScheduleExactAlarms": false,
      "canOpenSettings": true
    ]
  }
}
