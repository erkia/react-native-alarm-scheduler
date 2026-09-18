import type { TurboModule, CodegenTypes } from 'react-native';
import { TurboModuleRegistry } from 'react-native';
import type { UnsafeObject } from 'react-native/Libraries/Types/CodegenTypes';

// Public input/result types are defined in AlarmScheduler.types.ts. Opaque maps here
// accommodate platform-specific options and arbitrary metadata keys across Codegen versions.
export type AlarmEvent = { name: string; payload: UnsafeObject };

export interface Spec extends TurboModule {
  getPermissionsAsync(): Promise<UnsafeObject>;
  requestPermissionsAsync(): Promise<UnsafeObject>;
  openAlarmSettingsAsync(): Promise<boolean>;
  openFullScreenIntentSettingsAsync(): Promise<boolean>;
  scheduleAlarmAsync(alarm: UnsafeObject): Promise<UnsafeObject>;
  cancelAlarmAsync(id: string): Promise<boolean>;
  getScheduledAlarmsAsync(): Promise<Array<UnsafeObject>>;
  getCurrentAlarmContextAsync(): Promise<UnsafeObject | null>;
  getPendingAlarmActionsAsync(): Promise<Array<UnsafeObject>>;
  clearPendingAlarmActionsAsync(ids: Array<string> | null): Promise<void>;
  getPendingNativeAlarmHandoffAsync(): Promise<UnsafeObject | null>;
  clearPendingNativeAlarmHandoffAsync(): Promise<void>;
  completeNativeAlarmAsync(alarmId: string): Promise<void>;
  resolveAlarmOccurrenceAsync(occurrenceId: string, resolution: UnsafeObject): Promise<UnsafeObject>;
  getAlarmOccurrencesAsync(alarmId: string | null): Promise<Array<UnsafeObject>>;
  cancelAlarmOccurrenceAsync(occurrenceId: string): Promise<boolean>;
  scheduleNativeAlarmBackupAsync(alarmId: string, delaySeconds: number | null): Promise<UnsafeObject>;
  cancelNativeAlarmBackupAsync(alarmId: string): Promise<boolean>;
  clearBypassAsync(alarmId: string): Promise<void>;
  resetNativeAlarmCompletionAsync(alarmId: string): Promise<void>;
  getNativeAlarmDebugStateAsync(alarmId: string): Promise<UnsafeObject>;
  setSystemAlarmAsync(alarm: UnsafeObject): Promise<boolean>;
  openSystemAlarmAppAsync(): Promise<boolean>;
  setObserving(event: string, observing: boolean): void;
  readonly onAlarmEvent: CodegenTypes.EventEmitter<AlarmEvent>;
}

export default TurboModuleRegistry.getEnforcing<Spec>("AlarmScheduler");
