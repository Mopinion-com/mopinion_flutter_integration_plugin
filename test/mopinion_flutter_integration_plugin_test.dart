import 'package:flutter_test/flutter_test.dart';
import 'package:mopinion_flutter_integration_plugin/mopinion_flutter_integration_plugin.dart';
import 'package:mopinion_flutter_integration_plugin/mopinion_flutter_integration_plugin_platform_interface.dart';
import 'package:mopinion_flutter_integration_plugin/mopinion_flutter_integration_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMopinionFlutterIntegrationPluginPlatform
    with MockPlatformInterfaceMixin
    implements MopinionFlutterIntegrationPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final MopinionFlutterIntegrationPluginPlatform initialPlatform = MopinionFlutterIntegrationPluginPlatform.instance;

  test('$MethodChannelMopinionFlutterIntegrationPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMopinionFlutterIntegrationPlugin>());
  });

  test('getPlatformVersion', () async {
    MopinionFlutterIntegrationPlugin mopinionFlutterIntegrationPlugin = MopinionFlutterIntegrationPlugin();
    MockMopinionFlutterIntegrationPluginPlatform fakePlatform = MockMopinionFlutterIntegrationPluginPlatform();
    MopinionFlutterIntegrationPluginPlatform.instance = fakePlatform;

    expect(await mopinionFlutterIntegrationPlugin.getPlatformVersion(), '42');
  });
}
