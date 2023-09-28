package com.mopinion.mopinion_flutter_integration_plugin


import android.util.Log
import androidx.fragment.app.FragmentActivity
import com.mopinion.mopinion_android_sdk.ui.mopinion.Mopinion
import com.mopinion.mopinion_flutter_integration_plugin.MopinionFlutterBridgeConstants.DEPLOYMENT_KEY
import com.mopinion.mopinion_flutter_integration_plugin.MopinionFlutterBridgeConstants.FIRST_ARGUMENT
import com.mopinion.mopinion_flutter_integration_plugin.MopinionFlutterBridgeConstants.KEY
import com.mopinion.mopinion_flutter_integration_plugin.MopinionFlutterBridgeConstants.LOG
import com.mopinion.mopinion_flutter_integration_plugin.MopinionFlutterBridgeConstants.VALUE
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.view.TextureRegistry

/** MopinionFlutterIntegrationPlugin */
class MopinionFlutterIntegrationPlugin: FlutterPlugin, MethodCallHandler, ActivityAware  {

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel
  private lateinit var registry: TextureRegistry
  private lateinit var activity: FragmentActivity
  private lateinit var mopinion: Mopinion

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {

    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "mopinion_flutter_integration_plugin")
    channel.setMethodCallHandler(this)

  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    registry = binding.textureRegistry

    channel.setMethodCallHandler(null)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    var counter = 0
    when(MopinionActions.map[call.method]) {
      MopinionActions.InitialiseSDK -> {
        val deploymentKey = call.argument(DEPLOYMENT_KEY) as String? ?: return
        val isLogActive = call.argument(LOG) as Boolean? ?: return
        Mopinion.initialiseFromFlutter(
          application = activity.application,
          deploymentKey = deploymentKey,
          log = isLogActive
        )
      }
      MopinionActions.TriggerEvent -> {
        val eventName = call.argument(FIRST_ARGUMENT) as String? ?: return
        mopinion = Mopinion(activity, activity)
        mopinion.event(eventName) {
          if (counter == 0) {
            Log.d("FlutterFragmentActivity", it::class.java.simpleName)
            result.success(it::class.java.simpleName)
            counter ++
          }
        }
      }
      MopinionActions.AddMetaData -> {
        if (::mopinion.isInitialized) {
          val key = call.argument(KEY) as String? ?: return
          val value = call.argument(VALUE) as String? ?: return
          mopinion.data(key, value)
        }
      }
      MopinionActions.RemoveAllMetaData -> {
        mopinion.removeData()
      }
      MopinionActions.RemoveMetaData -> {
        val key = call.argument(KEY) as String? ?: return
        mopinion.removeData(key)
      }
      null -> {}
    }
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity as FragmentActivity
  }

  override fun onDetachedFromActivityForConfigChanges() {

  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity as FragmentActivity
  }

  override fun onDetachedFromActivity() {

  }
}
