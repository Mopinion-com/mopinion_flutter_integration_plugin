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

  static Stream<MopinionFormState> eventsData() => events
      .receiveBroadcastStream()
      .map((event) => (event as String).toMopinionFormState());

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

extension on String {
  MopinionFormState toMopinionFormState() {
    switch (this) {
      case "Loading":
        return MopinionFormState.loading;
      case "NotLoading":
        return MopinionFormState.notLoading;
      case "FormOpened":
        return MopinionFormState.formOpened;
      case "FormSent":
        return MopinionFormState.formSent;
      case "FormCanceled":
        return MopinionFormState.formCanceled;
      case "FormClosed":
        return MopinionFormState.formClosed;
      case "Error":
        return MopinionFormState.error;
      case "HasNotBeenShown":
        return MopinionFormState.hasNotBeenShown;
      default:
        return MopinionFormState.unknown;
    }
  }
}

enum MopinionFormState {
  loading,
  notLoading,
  formOpened,
  formSent,
  formCanceled,
  formClosed,
  error,
  hasNotBeenShown,
  unknown,
}
