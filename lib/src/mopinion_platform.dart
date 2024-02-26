import 'package:flutter/services.dart';
import 'package:mopinion_flutter_integration_plugin/src/mopinion_form_state.dart';
import 'package:mopinion_flutter_integration_plugin/mopinion_flutter_integration_plugin.dart';

class MopinionPlatform {
  const MopinionPlatform();

  static const _platform = MethodChannel("MopinionFlutterBridge/native");
  static const _events = EventChannel("MopinionFlutterBridge/native/events");

  static const _eventAction = "trigger_event";
  static const _initSdkAction = "init_sdk";
  static const _addMetaDataAction = "add_meta_data";
  static const _removeMetaDataAction = "remove_meta_data";
  static const _removeAllMetaDataAction = "remove_all_meta_data";

  final version = "2.0.0";

  Future<void> initSdk(
    String deploymentKey, {
    bool enableLogging = false,
  }) {
    try {
      return _platform.invokeMethod(_initSdkAction, <String, dynamic>{
        "deployment_key": deploymentKey,
        "version": version,
        "log": enableLogging
      });
    } on PlatformException catch (error, stackTrace) {
      throw Exception(
          'Initializing SDK failed: ${error.message}, stackTrace: $stackTrace');
    }
  }

  Future<void> event(String eventName) {
    try {
      return _platform.invokeMethod(
          _eventAction, <String, dynamic>{"argument1": eventName});
    } on PlatformException catch (error, stackTrace) {
      throw Exception(
          'Launching event $eventName failed: ${error.message}, stackTrace: $stackTrace');
    }
  }

  Stream<MopinionFormState> eventsData() => _events
      .receiveBroadcastStream()
      .map((event) => (event as String).toMopinionFormState());

  Future<void> data(Map<String, String> map) async {
    for (final entry in map.entries) {
      try {
        await _platform.invokeMethod(_addMetaDataAction,
            <String, dynamic>{"key": entry.key, "value": entry.value});
      } on PlatformException catch (error, stackTrace) {
        throw Exception(
            'Adding meta data for key ${entry.key} failed: ${error.message}, stackTrace: $stackTrace');
      }
    }
  }

  Future<void> removeMetaData(String key) {
    try {
      return _platform.invokeMethod(_removeMetaDataAction, {"key": key});
    } on PlatformException catch (error, stackTrace) {
      throw Exception(
          'Removing meta data for key $key failed: ${error.message}, stackTrace: $stackTrace');
    }
  }

  Future<void> removeAllMetaData() {
    try {
      return _platform.invokeMethod(_removeAllMetaDataAction);
    } on PlatformException catch (error, stackTrace) {
      throw Exception(
          'Removing all meta data failed: ${error.message}, stackTrace: $stackTrace');
    }
  }
}
