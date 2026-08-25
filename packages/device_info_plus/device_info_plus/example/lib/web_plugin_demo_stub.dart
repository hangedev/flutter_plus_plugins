// Non-web stub for the web-plugin demo.
//
// This file is the DEFAULT import target of the conditional import in
// `device_info_plus_demo.dart`. It compiles on every non-web platform
// (Android, iOS, macOS, Linux, Windows, Ohos) where `DeviceInfoPlusWebPlugin`,
// `Registrar`, and `package:web` are not available.
//
// IMPORTANT: keep the signature of [runWebPluginDemo] byte-identical to the one
// in `web_plugin_demo_web.dart` — divergence shows up as an analyzer error on
// only one platform and is easy to miss.

/// Runs the web-plugin demo.
///
/// Off the web platform this is a no-op that simply reports it was skipped.
Future<Map<String, dynamic>> runWebPluginDemo() async {
  return <String, dynamic>{
    'demo.web.plugin': 'skipped (web only)',
  };
}
