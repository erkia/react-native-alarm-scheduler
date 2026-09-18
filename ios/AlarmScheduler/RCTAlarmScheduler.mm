#import "RCTAlarmScheduler.h"
#import "AlarmScheduler-Swift.h"

@implementation RCTAlarmScheduler {
  AlarmSchedulerImplementation *_implementation;
}

+ (NSString *)moduleName { return @"AlarmScheduler"; }
+ (BOOL)requiresMainQueueSetup { return NO; }

- (instancetype)init {
  if ((self = [super init])) {
    _implementation = [AlarmSchedulerImplementation new];
    __weak RCTAlarmScheduler *weakSelf = self;
    _implementation.eventHandler = ^(NSString *name, NSDictionary *payload) {
      [weakSelf emitOnAlarmEvent:@{@"name": name, @"payload": payload}];
    };
  }
  return self;
}

- (void)getPermissionsAsync:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  [_implementation invoke:@"getPermissionsAsync" arguments:@{} resolve:resolve reject:reject];
}

- (void)requestPermissionsAsync:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  [_implementation invoke:@"requestPermissionsAsync" arguments:@{} resolve:resolve reject:reject];
}

- (void)openAlarmSettingsAsync:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  [_implementation invoke:@"openAlarmSettingsAsync" arguments:@{} resolve:resolve reject:reject];
}

- (void)openFullScreenIntentSettingsAsync:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  [_implementation invoke:@"openFullScreenIntentSettingsAsync" arguments:@{} resolve:resolve reject:reject];
}

- (void)scheduleAlarmAsync:(NSDictionary *)alarm resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  [_implementation invoke:@"scheduleAlarmAsync" arguments:@{@"alarm": alarm} resolve:resolve reject:reject];
}

- (void)cancelAlarmAsync:(NSString *)id resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  [_implementation invoke:@"cancelAlarmAsync" arguments:@{@"id": id} resolve:resolve reject:reject];
}

- (void)getScheduledAlarmsAsync:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  [_implementation invoke:@"getScheduledAlarmsAsync" arguments:@{} resolve:resolve reject:reject];
}

- (void)getCurrentAlarmContextAsync:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  [_implementation invoke:@"getCurrentAlarmContextAsync" arguments:@{} resolve:resolve reject:reject];
}

- (void)getPendingAlarmActionsAsync:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  [_implementation invoke:@"getPendingAlarmActionsAsync" arguments:@{} resolve:resolve reject:reject];
}

- (void)clearPendingAlarmActionsAsync:(NSArray *)ids resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  [_implementation invoke:@"clearPendingAlarmActionsAsync" arguments:@{@"ids": ids ?: [NSNull null]} resolve:resolve reject:reject];
}

- (void)getPendingNativeAlarmHandoffAsync:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  [_implementation invoke:@"getPendingNativeAlarmHandoffAsync" arguments:@{} resolve:resolve reject:reject];
}

- (void)clearPendingNativeAlarmHandoffAsync:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  [_implementation invoke:@"clearPendingNativeAlarmHandoffAsync" arguments:@{} resolve:resolve reject:reject];
}

- (void)completeNativeAlarmAsync:(NSString *)alarmId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  [_implementation invoke:@"completeNativeAlarmAsync" arguments:@{@"alarmId": alarmId} resolve:resolve reject:reject];
}

- (void)resolveAlarmOccurrenceAsync:(NSString *)occurrenceId resolution:(NSDictionary *)resolution resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  [_implementation invoke:@"resolveAlarmOccurrenceAsync" arguments:@{@"occurrenceId": occurrenceId, @"resolution": resolution} resolve:resolve reject:reject];
}

- (void)getAlarmOccurrencesAsync:(NSString *)alarmId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  [_implementation invoke:@"getAlarmOccurrencesAsync" arguments:@{@"alarmId": alarmId ?: [NSNull null]} resolve:resolve reject:reject];
}

- (void)cancelAlarmOccurrenceAsync:(NSString *)occurrenceId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  [_implementation invoke:@"cancelAlarmOccurrenceAsync" arguments:@{@"occurrenceId": occurrenceId} resolve:resolve reject:reject];
}

- (void)scheduleNativeAlarmBackupAsync:(NSString *)alarmId delaySeconds:(NSNumber *)delaySeconds resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  [_implementation invoke:@"scheduleNativeAlarmBackupAsync" arguments:@{@"alarmId": alarmId, @"delaySeconds": delaySeconds ?: [NSNull null]} resolve:resolve reject:reject];
}

- (void)cancelNativeAlarmBackupAsync:(NSString *)alarmId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  [_implementation invoke:@"cancelNativeAlarmBackupAsync" arguments:@{@"alarmId": alarmId} resolve:resolve reject:reject];
}

- (void)clearBypassAsync:(NSString *)alarmId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  [_implementation invoke:@"clearBypassAsync" arguments:@{@"alarmId": alarmId} resolve:resolve reject:reject];
}

- (void)resetNativeAlarmCompletionAsync:(NSString *)alarmId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  [_implementation invoke:@"resetNativeAlarmCompletionAsync" arguments:@{@"alarmId": alarmId} resolve:resolve reject:reject];
}

- (void)getNativeAlarmDebugStateAsync:(NSString *)alarmId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  [_implementation invoke:@"getNativeAlarmDebugStateAsync" arguments:@{@"alarmId": alarmId} resolve:resolve reject:reject];
}

- (void)setSystemAlarmAsync:(NSDictionary *)alarm resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  [_implementation invoke:@"setSystemAlarmAsync" arguments:@{@"alarm": alarm} resolve:resolve reject:reject];
}

- (void)openSystemAlarmAppAsync:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  [_implementation invoke:@"openSystemAlarmAppAsync" arguments:@{} resolve:resolve reject:reject];
}

- (void)setObserving:(NSString *)event observing:(BOOL)observing {
  [_implementation setObserving:event observing:observing];
}

- (void)invalidate {
  [_implementation invalidate];
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeAlarmSchedulerSpecJSI>(params);
}
@end
