package expo.modules.alarm

class AlarmScheduleRecord {
  var id: String? = null
  var hour: Int = -1
  var minute: Int = -1
  var title: String? = null
  var weekdays: List<Int>? = null
  var timestamp: Double? = null
  var showUi: Boolean = false
  var soundUri: String? = null
  var ios: IosAlarmOptionsRecord? = null
  var android: AndroidAlarmOptionsRecord? = null

  companion object {
    fun fromMap(values: Map<String, Any?>): AlarmScheduleRecord = AlarmScheduleRecord().apply {
      id = AlarmSchedulerArguments.string(values, "id")
      hour = AlarmSchedulerArguments.int(values, "hour") ?: -1
      minute = AlarmSchedulerArguments.int(values, "minute") ?: -1
      title = AlarmSchedulerArguments.string(values, "title")
      weekdays = AlarmSchedulerArguments.intList(values, "weekdays")
      timestamp = AlarmSchedulerArguments.double(values, "timestamp")
      showUi = AlarmSchedulerArguments.boolean(values, "showUi") ?: false
      soundUri = AlarmSchedulerArguments.string(values, "soundUri")
      ios = AlarmSchedulerArguments.objectValue(values, "ios")?.let(IosAlarmOptionsRecord::fromMap)
      android = AlarmSchedulerArguments.objectValue(values, "android")?.let(AndroidAlarmOptionsRecord::fromMap)
    }
  }
}

class IosAlarmOptionsRecord {
  var metadata: Map<String, Any>? = null
  var alertTitle: String? = null
  var alertActionMode: String? = null
  var stopButtonTitle: String? = null
  var secondaryButtonTitle: String? = null
  var countdownTitle: String? = null
  var stopIntentBehavior: String? = null
  var secondaryButtonBehavior: String? = null
  var soundUri: String? = null
  var soundName: String? = null
  var silent: Boolean? = null

  companion object {
    fun fromMap(values: Map<String, Any?>): IosAlarmOptionsRecord = IosAlarmOptionsRecord().apply {
      metadata = AlarmSchedulerArguments.objectValue(values, "metadata")
      alertTitle = AlarmSchedulerArguments.string(values, "alertTitle")
      alertActionMode = AlarmSchedulerArguments.string(values, "alertActionMode")
      stopButtonTitle = AlarmSchedulerArguments.string(values, "stopButtonTitle")
      secondaryButtonTitle = AlarmSchedulerArguments.string(values, "secondaryButtonTitle")
      countdownTitle = AlarmSchedulerArguments.string(values, "countdownTitle")
      stopIntentBehavior = AlarmSchedulerArguments.string(values, "stopIntentBehavior")
      secondaryButtonBehavior = AlarmSchedulerArguments.string(values, "secondaryButtonBehavior")
      soundUri = AlarmSchedulerArguments.string(values, "soundUri")
      soundName = AlarmSchedulerArguments.string(values, "soundName")
      silent = AlarmSchedulerArguments.boolean(values, "silent")
    }
  }
}

class AndroidAlarmOptionsRecord {
  var metadata: Map<String, Any>? = null
  var alertTitle: String? = null
  var alertBody: String? = null
  var alertActionMode: String? = null
  var stopButtonTitle: String? = null
  var secondaryButtonTitle: String? = null
  var stopIntentBehavior: String? = null
  var secondaryButtonBehavior: String? = null
  var soundName: String? = null
  var soundUri: String? = null
  var silent: Boolean? = null
  var vibrate: Boolean? = null
  var enforceVolume: Boolean? = null
  var restoreVolume: Boolean? = null
  var volume: Double? = null
  var fullScreen: Boolean? = null
  var fullScreenTarget: String? = null
  var launchUri: String? = null
  var maxRingDurationSeconds: Double? = null
  var backupDelaySeconds: Double? = null

  companion object {
    fun fromMap(values: Map<String, Any?>): AndroidAlarmOptionsRecord = AndroidAlarmOptionsRecord().apply {
      metadata = AlarmSchedulerArguments.objectValue(values, "metadata")
      alertTitle = AlarmSchedulerArguments.string(values, "alertTitle")
      alertBody = AlarmSchedulerArguments.string(values, "alertBody")
      alertActionMode = AlarmSchedulerArguments.string(values, "alertActionMode")
      stopButtonTitle = AlarmSchedulerArguments.string(values, "stopButtonTitle")
      secondaryButtonTitle = AlarmSchedulerArguments.string(values, "secondaryButtonTitle")
      stopIntentBehavior = AlarmSchedulerArguments.string(values, "stopIntentBehavior")
      secondaryButtonBehavior = AlarmSchedulerArguments.string(values, "secondaryButtonBehavior")
      soundName = AlarmSchedulerArguments.string(values, "soundName")
      soundUri = AlarmSchedulerArguments.string(values, "soundUri")
      silent = AlarmSchedulerArguments.boolean(values, "silent")
      vibrate = AlarmSchedulerArguments.boolean(values, "vibrate")
      enforceVolume = AlarmSchedulerArguments.boolean(values, "enforceVolume")
      restoreVolume = AlarmSchedulerArguments.boolean(values, "restoreVolume")
      volume = AlarmSchedulerArguments.double(values, "volume")
      fullScreen = AlarmSchedulerArguments.boolean(values, "fullScreen")
      fullScreenTarget = AlarmSchedulerArguments.string(values, "fullScreenTarget")
      launchUri = AlarmSchedulerArguments.string(values, "launchUri")
      maxRingDurationSeconds = AlarmSchedulerArguments.double(values, "maxRingDurationSeconds")
      backupDelaySeconds = AlarmSchedulerArguments.double(values, "backupDelaySeconds")
    }
  }
}

class AlarmOccurrenceNextRecord {
  var delaySeconds: Double = 0.0
  var relationship: String = ""
  var metadata: Map<String, Any>? = null

  companion object {
    fun fromMap(values: Map<String, Any?>): AlarmOccurrenceNextRecord = AlarmOccurrenceNextRecord().apply {
      delaySeconds = AlarmSchedulerArguments.double(values, "delaySeconds") ?: 0.0
      relationship = AlarmSchedulerArguments.string(values, "relationship") ?: ""
      metadata = AlarmSchedulerArguments.objectValue(values, "metadata")
    }
  }
}

class AlarmOccurrenceResolutionRecord {
  var outcome: String = ""
  var next: AlarmOccurrenceNextRecord? = null
  var idempotencyKey: String? = null

  companion object {
    fun fromMap(values: Map<String, Any?>): AlarmOccurrenceResolutionRecord = AlarmOccurrenceResolutionRecord().apply {
      outcome = AlarmSchedulerArguments.string(values, "outcome") ?: ""
      next = AlarmSchedulerArguments.objectValue(values, "next")?.let(AlarmOccurrenceNextRecord::fromMap)
      idempotencyKey = AlarmSchedulerArguments.string(values, "idempotencyKey")
    }
  }
}

