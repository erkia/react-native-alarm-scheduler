#import <Foundation/Foundation.h>

// Swift imports this pod's umbrella header; Codegen declarations require Objective-C++.
#ifdef __cplusplus
#import <AlarmSchedulerSpec/AlarmSchedulerSpec.h>
#import <React/RCTInvalidating.h>

@interface RCTAlarmScheduler : NativeAlarmSchedulerSpecBase <NativeAlarmSchedulerSpec, RCTInvalidating>
@end
#endif
