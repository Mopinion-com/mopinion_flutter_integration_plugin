import 'package:mopinion_flutter_integration_plugin/src/mopinion_form_state.dart';
import 'package:mopinion_flutter_integration_plugin/src/mopinion_platform.dart';

class MopinionFlutterIntegrationPlugin {
  static const _platform = MopinionPlatform();

  /// Initializes the SDK with [deploymentKey]. Optionally, you can enable logging.
  static Future<void> initSdk(String deploymentKey, {bool enableLogging = false}) =>
      _platform.initSdk(deploymentKey, enableLogging: enableLogging);

  /// Launches event with [eventName].
  static Future<void> event(String eventName) => _platform.event(eventName);

  /// Returns a stream of [MopinionFormState] events.
  static Stream<MopinionFormState> eventsData() => _platform.eventsData();

  /// Adds meta data to the form. This data will be sent with the form. Example:
  /// ```
  /// Map<String, String> map = {
  ///      "age": "29",
  ///      "name": "Manuel"
  ///    };
  /// await MopinionFlutterIntegrationPlugin.data(map);
  /// await MopinionFlutterIntegrationPlugin.event(yourEvent);
  /// ```
  static Future<void> data(Map<String, String> dataMap) =>
      _platform.data(dataMap);

  /// Removes meta data for [key].
  static Future<void> removeMetaData(String key) =>
      _platform.removeMetaData(key);

  /// Removes all meta data.
  static Future<void> removeAllMetaData() => _platform.removeAllMetaData();
}
