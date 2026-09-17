// 浏览器平台实现：驱动 WebSensorsPlugin 的全部公开接口。
//
// 本文件仅在 `dart.library.js_interop` 条件命中的 Web 平台参与编译，
// 与 sensors_coverage_demo.dart 中的条件导入配套；
// Android/OHOS 等平台编译时被 web_sensors_demo_stub.dart 替换。

// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:sensors_plus/sensors_plus.dart';
// ignore: implementation_imports
import 'package:sensors_plus/src/web_sensors.dart';
// ignore: implementation_imports
import 'package:sensors_plus/src/web_sensors_interop.dart';

/// 覆盖 [WebSensorsPlugin] 的 6 个公开方法与 Duration.frequency 频率换算。
Future<void> runWebSensorsDemo() async {
  print('[WebSensorsDemo] === WebSensorsPlugin.registerWith ===');
  // Web 平台的插件注册入口，将平台实例注册为 WebSensorsPlugin。
  WebSensorsPlugin.registerWith(Registrar());

  final plugin = WebSensorsPlugin();

  // 4 个传感器事件流方法；不支持对应传感器的浏览器会回退为零值事件。
  await _subscribeOnce(
    'WebSensorsPlugin.accelerometerEventStream',
    plugin.accelerometerEventStream(
        samplingPeriod: SensorInterval.gameInterval),
  );
  await _subscribeOnce(
    'WebSensorsPlugin.userAccelerometerEventStream',
    plugin.userAccelerometerEventStream(
        samplingPeriod: SensorInterval.uiInterval),
  );
  await _subscribeOnce(
    'WebSensorsPlugin.gyroscopeEventStream',
    plugin.gyroscopeEventStream(
        samplingPeriod: SensorInterval.normalInterval),
  );
  await _subscribeOnce(
    'WebSensorsPlugin.magnetometerEventStream',
    plugin.magnetometerEventStream(
        samplingPeriod: SensorInterval.normalInterval),
  );

  // 浏览器没有气压计 API，barometerEventStream 返回空流。
  await _subscribeOnce(
    'WebSensorsPlugin.barometerEventStream',
    plugin.barometerEventStream(),
  );

  // Duration.frequency（lib 内匿名扩展，库外不可直接调用）是采样周期到
  // 频率(Hz)的换算出口，经 SensorOptions(frequency:) 传给 Web Sensor API；
  // 此处按同一语义复算：20ms -> 50Hz。
  const period = SensorInterval.gameInterval;
  final frequency =
      period.inMicroseconds <= 10 ? 100 : 1000 ~/ period.inMilliseconds;
  final options = SensorOptions(frequency: frequency);
  print('[WebSensorsDemo] Duration.frequency 换算: '
      '${period.inMilliseconds}ms -> ${frequency}Hz（$options）');
}

/// 订阅流，收到首个事件或异常后取消；2 秒无事件则超时结束。
Future<void> _subscribeOnce(String name, Stream<dynamic> stream) async {
  final completer = Completer<void>();
  final sub = stream.listen(
    (event) {
      print('  $name: 收到事件');
      if (!completer.isCompleted) {
        completer.complete();
      }
    },
    onError: (Object error) {
      print('  $name: onError（浏览器可能不支持该传感器）: $error');
      if (!completer.isCompleted) {
        completer.complete();
      }
    },
    cancelOnError: true,
  );
  await completer.future
      .timeout(const Duration(seconds: 2), onTimeout: () {
    print('  $name: 超时（未收到事件或异常）');
  }).catchError((_) {});
  await sub.cancel();
}
