
import 'package:flutter/services.dart';

class MopinionFlutterIntegrationPlugin {
  static const platform = MethodChannel("MopinionFlutterBridge/native");
  static const events = EventChannel("MopinionFlutterBridge/native/events");

  static const eventAction = "trigger_event";
  static const initSdkAction = "init_sdk";
  static const addMetaDataAction = "add_meta_data";
  static const removeMetaDataAction = "remove_meta_data";
  static const removeAllMetaDataAction = "remove_all_meta_data";

  static Future<void> initSdk(String deploymentKey, bool log) async {
    await platform.invokeMethod(initSdkAction, <String, dynamic> {
      "deployment_key": deploymentKey,
      "log": log
    });
  }

  static Future<String> event(String eventName) async {
    return await platform.invokeMethod(eventAction, <String, dynamic> {
        "argument1": eventName
    });
  }

  static Future<Stream> eventsData() async {
    Stream stream;
    stream = events.receiveBroadcastStream();
    return stream;
  }

  static Future<void> data(Map<String, String> map) async {
    map.forEach((key, value) {
      platform.invokeMethod(addMetaDataAction, {
        "key": key,
        "value": value
      });
    });
  }

  static Future<void> removeMetaData(String key) async {
    platform.invokeMethod(removeMetaDataAction, {
      "key": key
    });
  }

  static Future<void> removeAllMetaData() async {
    platform.invokeMethod(removeAllMetaDataAction);
  }
}
