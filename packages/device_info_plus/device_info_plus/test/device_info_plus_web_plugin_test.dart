@TestOn('browser')
library device_info_plus_web_plugin_test;

import 'dart:html' as html;

import 'package:device_info_plus/src/device_info_plus_web.dart';
import 'package:device_info_plus/src/model/web_browser_info.dart';
import 'package:device_info_plus_platform_interface/device_info_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:mockito/mockito.dart';

/// Mockito mock of [Registrar]. `registerWith` ignores its argument (it reads
/// `html.window.navigator` directly), so a mock is sufficient and avoids
/// constructing a real [Registrar].
class _MockRegistrar extends Mock implements Registrar {}

void main() {
  group('DeviceInfoPlusWebPlugin', () {
    test('constructs with a navigator', () {
      final plugin = DeviceInfoPlusWebPlugin(html.window.navigator);
      expect(plugin, isA<DeviceInfoPlatform>());
    });

    test('deviceInfo() returns a WebBrowserInfo populated from the navigator',
        () async {
      final plugin = DeviceInfoPlusWebPlugin(html.window.navigator);
      final info = await plugin.deviceInfo();
      expect(info, isA<WebBrowserInfo>());
      expect(info, isA<BaseDeviceInfo>());
      // browserName derives from the real navigator.userAgent.
      expect((info as WebBrowserInfo).browserName, isNotNull);
    });

    test('registerWith installs the plugin as the platform instance', () {
      DeviceInfoPlusWebPlugin.registerWith(_MockRegistrar());
      expect(DeviceInfoPlatform.instance, isA<DeviceInfoPlusWebPlugin>());
    });
  });
}
