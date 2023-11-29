import 'package:flutter/services.dart';

class MopinionFlutterIntegrationPlugin {
  static const platform = MethodChannel("MopinionFlutterBridge/native");
  static const events = EventChannel("MopinionFlutterBridge/native/events");

  static const eventAction = "trigger_event";
  static const initSdkAction = "init_sdk";
  static const addMetaDataAction = "add_meta_data";
  static const removeMetaDataAction = "remove_meta_data";
  static const removeAllMetaDataAction = "remove_all_meta_data";

  static Future<void> initSdk(String deploymentKey, bool log) =>
      platform.invokeMethod(initSdkAction,
          <String, dynamic>{"deployment_key": deploymentKey, "log": log});

  static Future<String?> event(String eventName) =>
      platform.invokeMethod<String>(
          eventAction, <String, dynamic>{"argument1": eventName});

  static Stream eventsData() => events.receiveBroadcastStream();

  static Future<void> data(Map<String, String> map) async {
    for (final entry in map.entries) {
      await platform.invokeMethod(addMetaDataAction,
          <String, dynamic>{"key": entry.key, "value": entry.value});
    }
  }

  static Future<void> removeMetaData(String key) =>
      platform.invokeMethod(removeMetaDataAction, {"key": key});

  static Future<void> removeAllMetaData() =>
      platform.invokeMethod(removeAllMetaDataAction);
}
