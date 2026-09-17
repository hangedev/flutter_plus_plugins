// 非浏览器平台的占位实现。
//
// `WebSensorsPlugin`（lib/src/web_sensors.dart）依赖 dart:js_interop，
// 仅在浏览器平台可编译。sensors_coverage_demo.dart 通过条件导入
// `import 'web_sensors_demo_stub.dart'
//     if (dart.library.js_interop) 'web_sensors_demo_web.dart';`
// 保证 Android/OHOS 等平台编译时只引入本文件，不触碰任何 Web 专用 API。

/// 驱动 WebSensorsPlugin 全部公开接口。
/// 浏览器平台的实际实现见 web_sensors_demo_web.dart。
Future<void> runWebSensorsDemo() async {}
