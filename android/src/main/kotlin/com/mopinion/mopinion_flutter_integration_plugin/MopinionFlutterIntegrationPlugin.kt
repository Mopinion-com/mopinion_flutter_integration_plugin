package com.mopinion.mopinion_flutter_integration_plugin


import android.app.Activity
import android.os.Build.VERSION
import android.util.Log
import com.mopinion.mopinion_android_sdk.ui.mopinion.Mopinion
import com.mopinion.mopinion_android_sdk.ui.states.FormState
import com.mopinion.mopinion_flutter_integration_plugin.MopinionFlutterBridgeConstants.CHANNEL
import com.mopinion.mopinion_flutter_integration_plugin.MopinionFlutterBridgeConstants.DEPLOYMENT_KEY
import com.mopinion.mopinion_flutter_integration_plugin.MopinionFlutterBridgeConstants.EVENT_CHANNEL_NAME
import com.mopinion.mopinion_flutter_integration_plugin.MopinionFlutterBridgeConstants.FIRST_ARGUMENT
import com.mopinion.mopinion_flutter_integration_plugin.MopinionFlutterBridgeConstants.KEY
import com.mopinion.mopinion_flutter_integration_plugin.MopinionFlutterBridgeConstants.LOG
import com.mopinion.mopinion_flutter_integration_plugin.MopinionFlutterBridgeConstants.VALUE
import com.mopinion.mopinion_flutter_integration_plugin.MopinionFlutterBridgeConstants.VERSION
import io.flutter.embedding.android.FlutterFragmentActivity
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
class MopinionFlutterIntegrationPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, EventChannel.StreamHandler  {

  private lateinit var channel: MethodChannel
  private lateinit var registry: TextureRegistry
  private lateinit var activity: Activity
  private lateinit var mopinion: Mopinion
  private lateinit var eventChannel: EventChannel

  private var eventSink: EventChannel.EventSink? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL)
    channel.setMethodCallHandler(this)
    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, EVENT_CHANNEL_NAME)
    eventChannel.setStreamHandler(this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    registry = binding.textureRegistry

    channel.setMethodCallHandler(null)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when(MopinionActions.map[call.method]) {
      MopinionActions.InitialiseSDK -> {
        val deploymentKey = call.argument(DEPLOYMENT_KEY) as String? ?: return
        val version = call.argument(VERSION) as String? ?: return
        val isLogActive = call.argument(LOG) as Boolean? ?: return
        Mopinion.initialiseFromFlutter(
          application = activity.application,
          deploymentKey = deploymentKey,
          pluginVersion = version,
          log = isLogActive
        )
      }
      MopinionActions.TriggerEvent -> {
        val eventName = call.argument(FIRST_ARGUMENT) as String? ?: return
        mopinion = Mopinion(activity as FlutterFragmentActivity, activity as FlutterFragmentActivity)
        mopinion.event(eventName) { formState ->
          if (formState is FormState.Loading) {
            if (formState.isLoading) {
              Log.d("FlutterFragmentActivity", "Loading")
              eventSink?.success("Loading")
            } else {
              Log.d("FlutterFragmentActivity", "NotLoading")
              eventSink?.success("NotLoading")
            }
          } else {
            Log.d("FlutterFragmentActivity", formState::class.java.simpleName)
            eventSink?.success(formState::class.java.simpleName)
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
        if (::mopinion.isInitialized) {
          mopinion.removeData()
        }
      }
      MopinionActions.RemoveMetaData -> {
        if (::mopinion.isInitialized) {
          val key = call.argument(KEY) as String? ?: return
          mopinion.removeData(key)
        }
      }
      null -> {}
    }
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {

  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {

  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
      eventSink = events
  }

  override fun onCancel(arguments: Any?) {
      eventSink = null
  }
}
