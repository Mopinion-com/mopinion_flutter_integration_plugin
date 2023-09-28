import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mopinion_flutter_integration_plugin/mopinion_flutter_integration_plugin_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelMopinionFlutterIntegrationPlugin platform = MethodChannelMopinionFlutterIntegrationPlugin();
  const MethodChannel channel = MethodChannel('mopinion_flutter_integration_plugin');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
