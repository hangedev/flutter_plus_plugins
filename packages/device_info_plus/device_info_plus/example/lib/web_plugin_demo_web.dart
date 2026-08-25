// Web implementation of the web-plugin demo.
//
// This file is imported ONLY on the web platform (via the `dart.library.js_interop`
// conditional import in `device_info_plus_demo.dart`). It references
// `DeviceInfoPlusWebPlugin`, `Registrar`, and `package:web`, none of which
// resolve off the web platform.
//
// IMPORTANT: keep the signature of [runWebPluginDemo] byte-identical to the one
// in `web_plugin_demo_stub.dart` — divergence shows up as an analyzer error on
// only one platform and is easy to miss.

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'package:device_info_plus/device_info_plus.dart';
// DeviceInfoPlusWebPlugin is only conditionally exported on web; import the
// source directly here (this file is itself web-only).
// ignore: implementation_imports
import 'package:device_info_plus/src/device_info_plus_web.dart';

/// Runs the web-plugin demo, exercising:
/// - [DeviceInfoPlusWebPlugin.registerWith] (web registration),
/// - the [DeviceInfoPlusWebPlugin] constructor,
/// - [DeviceInfoPlusWebPlugin.deviceInfo] (returns a [WebBrowserInfo]).
Future<Map<String, dynamic>> runWebPluginDemo() async {
  final results = <String, dynamic>{};
  try {
    // 1) registerWith(Registrar) — wires the plugin into the web platform.
    DeviceInfoPlusWebPlugin.registerWith(Registrar());
    results['demo.web.registerWith'] = 'ok';

    // 2) Constructor — accepts a navigator.
    final plugin = DeviceInfoPlusWebPlugin(web.window.navigator);
    results['demo.web.constructor'] = 'ok';

    // 3) deviceInfo() — returns a Future<BaseDeviceInfo> (WebBrowserInfo on web).
    final info = await plugin.deviceInfo();
    results['demo.web.deviceInfo.runtimeType'] = info.runtimeType.toString();
    final browserInfo = info as WebBrowserInfo;
    results['demo.web.deviceInfo.browserName'] = browserInfo.browserName.name;
    results['demo.web.deviceInfo.userAgent'] = browserInfo.userAgent ?? '';
  } catch (e) {
    results['demo.web.error'] = e.toString();
  }
  return results;
}
