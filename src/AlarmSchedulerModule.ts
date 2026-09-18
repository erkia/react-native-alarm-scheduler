import NativeAlarmScheduler from './specs/NativeAlarmScheduler';
import { AlarmSchedulerEventEmitter } from './AlarmSchedulerEventEmitter';

import type {
  AlarmPermissionResponse,
  AlarmAction,
  AlarmContext,
  AlarmOccurrence,
  AlarmOccurrenceResolution,
  AlarmOccurrenceResolutionResult,
  AlarmScheduleInput,
  NativeAlarmBackupResult,
  NativeAlarmDebugState,
  ScheduledAlarm,
} from "./AlarmScheduler.types";

class AlarmSchedulerModule extends AlarmSchedulerEventEmitter {
  constructor() {
    super(NativeAlarmScheduler);
  }

  getPermissionsAsync(): Promise<AlarmPermissionResponse> {
    return NativeAlarmScheduler.getPermissionsAsync() as Promise<AlarmPermissionResponse>;
  }

  requestPermissionsAsync(): Promise<AlarmPermissionResponse> {
    return NativeAlarmScheduler.requestPermissionsAsync() as Promise<AlarmPermissionResponse>;
  }

  openAlarmSettingsAsync(): Promise<boolean> {
    return NativeAlarmScheduler.openAlarmSettingsAsync() as Promise<boolean>;
  }

  openFullScreenIntentSettingsAsync(): Promise<boolean> {
    return NativeAlarmScheduler.openFullScreenIntentSettingsAsync() as Promise<boolean>;
  }

  scheduleAlarmAsync(alarm: AlarmScheduleInput): Promise<ScheduledAlarm> {
    return NativeAlarmScheduler.scheduleAlarmAsync(alarm) as Promise<ScheduledAlarm>;
  }

  cancelAlarmAsync(id: string): Promise<boolean> {
    return NativeAlarmScheduler.cancelAlarmAsync(id) as Promise<boolean>;
  }

  getScheduledAlarmsAsync(): Promise<ScheduledAlarm[]> {
    return NativeAlarmScheduler.getScheduledAlarmsAsync() as Promise<ScheduledAlarm[]>;
  }

  getCurrentAlarmContextAsync(): Promise<AlarmContext | null> {
    return NativeAlarmScheduler.getCurrentAlarmContextAsync() as Promise<AlarmContext | null>;
  }

  getPendingAlarmActionsAsync(): Promise<AlarmAction[]> {
    return NativeAlarmScheduler.getPendingAlarmActionsAsync() as Promise<AlarmAction[]>;
  }

  clearPendingAlarmActionsAsync(ids?: string[]): Promise<void> {
    return NativeAlarmScheduler.clearPendingAlarmActionsAsync(ids ?? null) as Promise<void>;
  }

  getPendingNativeAlarmHandoffAsync(): Promise<AlarmAction | null> {
    return NativeAlarmScheduler.getPendingNativeAlarmHandoffAsync() as Promise<AlarmAction | null>;
  }

  clearPendingNativeAlarmHandoffAsync(): Promise<void> {
    return NativeAlarmScheduler.clearPendingNativeAlarmHandoffAsync() as Promise<void>;
  }

  completeNativeAlarmAsync(alarmId: string): Promise<void> {
    return NativeAlarmScheduler.completeNativeAlarmAsync(alarmId) as Promise<void>;
  }

  resolveAlarmOccurrenceAsync(occurrenceId: string, resolution: AlarmOccurrenceResolution): Promise<AlarmOccurrenceResolutionResult> {
    return NativeAlarmScheduler.resolveAlarmOccurrenceAsync(occurrenceId, resolution) as Promise<AlarmOccurrenceResolutionResult>;
  }

  getAlarmOccurrencesAsync(alarmId?: string): Promise<AlarmOccurrence[]> {
    return NativeAlarmScheduler.getAlarmOccurrencesAsync(alarmId ?? null) as Promise<AlarmOccurrence[]>;
  }

  cancelAlarmOccurrenceAsync(occurrenceId: string): Promise<boolean> {
    return NativeAlarmScheduler.cancelAlarmOccurrenceAsync(occurrenceId) as Promise<boolean>;
  }

  scheduleNativeAlarmBackupAsync(alarmId: string, delaySeconds?: number): Promise<NativeAlarmBackupResult> {
    return NativeAlarmScheduler.scheduleNativeAlarmBackupAsync(alarmId, delaySeconds ?? null) as Promise<NativeAlarmBackupResult>;
  }

  cancelNativeAlarmBackupAsync(alarmId: string): Promise<boolean> {
    return NativeAlarmScheduler.cancelNativeAlarmBackupAsync(alarmId) as Promise<boolean>;
  }

  clearBypassAsync(alarmId: string): Promise<void> {
    return NativeAlarmScheduler.clearBypassAsync(alarmId) as Promise<void>;
  }

  resetNativeAlarmCompletionAsync(alarmId: string): Promise<void> {
    return NativeAlarmScheduler.resetNativeAlarmCompletionAsync(alarmId) as Promise<void>;
  }

  getNativeAlarmDebugStateAsync(alarmId: string): Promise<NativeAlarmDebugState> {
    return NativeAlarmScheduler.getNativeAlarmDebugStateAsync(alarmId) as Promise<NativeAlarmDebugState>;
  }

  setSystemAlarmAsync(alarm: AlarmScheduleInput): Promise<boolean> {
    return NativeAlarmScheduler.setSystemAlarmAsync(alarm) as Promise<boolean>;
  }

  openSystemAlarmAppAsync(): Promise<boolean> {
    return NativeAlarmScheduler.openSystemAlarmAppAsync() as Promise<boolean>;
  }

}

export const AlarmScheduler = new AlarmSchedulerModule();
export default AlarmScheduler;
