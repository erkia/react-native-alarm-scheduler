package expo.modules.alarm

import com.facebook.react.BaseReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.model.ReactModuleInfo
import com.facebook.react.module.model.ReactModuleInfoProvider

class AlarmSchedulerPackage : BaseReactPackage() {
  override fun getModule(name: String, reactContext: ReactApplicationContext): NativeModule? =
    if (name == "AlarmScheduler") AlarmSchedulerModule(reactContext) else null

  override fun getReactModuleInfoProvider() = ReactModuleInfoProvider {
    mapOf("AlarmScheduler" to ReactModuleInfo(
      "AlarmScheduler", AlarmSchedulerModule::class.java.name,
      false, false, false, true
    ))
  }
}
