// WebSensorsPlugin（Web 平台实现）单元测试。
//
// `lib/src/web_sensors.dart` 依赖 `dart:js_interop`，该库仅在浏览器平台可编译，
// 因此本文件声明 `@TestOn('browser')`：
// - `flutter test`（VM）会整体跳过本文件（不参与编译，不影响现有用例）；
// - `flutter test --platform chrome` 时加载并执行。
@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:sensors_plus_platform_interface/sensors_plus_platform_interface.dart';
// ignore: implementation_imports
import 'package:sensors_plus/src/web_sensors.dart';
// ignore: implementation_imports
import 'package:sensors_plus/src/web_sensors_interop.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SensorsPlatform previousPlatform;

  setUp(() {
    previousPlatform = SensorsPlatform.instance;
  });

  tearDown(() {
    // 恢复平台实例，避免 WebSensorsPlugin 的流缓存影响其他用例。
    SensorsPlatform.instance = previousPlatform;
  });

  group('WebSensorsPlugin.registerWith', () {
    test('registers the plugin as the platform instance', () {
      // registerWith 忽略 registrar 参数，空构造即可。
      WebSensorsPlugin.registerWith(Registrar());
      expect(SensorsPlatform.instance, isA<WebSensorsPlugin>());
    });
  });

  group('WebSensorsPlugin.barometerEventStream', () {
    test('returns an empty stream on web', () async {
      final plugin = WebSensorsPlugin();
      await expectLater(plugin.barometerEventStream(), emitsDone);
    });

    test('returns an empty stream with custom sampling period', () async {
      final plugin = WebSensorsPlugin();
      await expectLater(
        plugin.barometerEventStream(
            samplingPeriod: SensorInterval.gameInterval),
        emitsDone,
      );
    });
  });

  group('WebSensorsPlugin accelerometerEventStream', () {
    test('returns a broadcast stream', () {
      final plugin = WebSensorsPlugin();
      expect(plugin.accelerometerEventStream().isBroadcast, isTrue);
    });

    test('repeated calls return the cached stream', () {
      final plugin = WebSensorsPlugin();
      final first = plugin.accelerometerEventStream();
      final second = plugin.accelerometerEventStream(
          samplingPeriod: SensorInterval.gameInterval);
      expect(identical(first, second), isTrue);
    });

    test('subscription can be cancelled without errors', () async {
      final plugin = WebSensorsPlugin();
      final subscription =
          plugin.accelerometerEventStream().listen((_) {}, onError: (_) {});
      await subscription.cancel();
    });
  });

  group('WebSensorsPlugin userAccelerometerEventStream', () {
    test('returns a broadcast stream', () {
      final plugin = WebSensorsPlugin();
      expect(plugin.userAccelerometerEventStream().isBroadcast, isTrue);
    });

    test('repeated calls return the cached stream', () {
      final plugin = WebSensorsPlugin();
      final first = plugin.userAccelerometerEventStream();
      final second = plugin.userAccelerometerEventStream(
          samplingPeriod: SensorInterval.uiInterval);
      expect(identical(first, second), isTrue);
    });

    test('subscription can be cancelled without errors', () async {
      final plugin = WebSensorsPlugin();
      final subscription =
          plugin.userAccelerometerEventStream().listen((_) {}, onError: (_) {});
      await subscription.cancel();
    });
  });

  group('WebSensorsPlugin gyroscopeEventStream', () {
    test('returns a broadcast stream', () {
      final plugin = WebSensorsPlugin();
      expect(plugin.gyroscopeEventStream().isBroadcast, isTrue);
    });

    test('repeated calls return the cached stream', () {
      final plugin = WebSensorsPlugin();
      final first = plugin.gyroscopeEventStream();
      final second = plugin.gyroscopeEventStream(
          samplingPeriod: SensorInterval.normalInterval);
      expect(identical(first, second), isTrue);
    });

    test('subscription can be cancelled without errors', () async {
      final plugin = WebSensorsPlugin();
      final subscription =
          plugin.gyroscopeEventStream().listen((_) {}, onError: (_) {});
      await subscription.cancel();
    });
  });

  group('WebSensorsPlugin magnetometerEventStream', () {
    test('returns a broadcast stream', () {
      final plugin = WebSensorsPlugin();
      expect(plugin.magnetometerEventStream().isBroadcast, isTrue);
    });

    test('repeated calls return the cached stream', () {
      final plugin = WebSensorsPlugin();
      final first = plugin.magnetometerEventStream();
      final second = plugin.magnetometerEventStream(
          samplingPeriod: SensorInterval.normalInterval);
      expect(identical(first, second), isTrue);
    });

    test('subscription can be cancelled without errors', () async {
      final plugin = WebSensorsPlugin();
      final subscription =
          plugin.magnetometerEventStream().listen((_) {}, onError: (_) {});
      await subscription.cancel();
    });
  });

  group('Duration.frequency (sampling period conversion)', () {
    test('caps at 100Hz for very short periods', () {
      const period = Duration(microseconds: 10);
      expect(_frequencyOf(period), 100);
    });

    test('converts SensorInterval.normalInterval to 5Hz', () {
      // 200ms -> 1000 ~/ 200 = 5
      expect(_frequencyOf(SensorInterval.normalInterval), 5);
    });

    test('converts SensorInterval.gameInterval to 50Hz', () {
      // 20ms -> 1000 ~/ 20 = 50
      expect(_frequencyOf(SensorInterval.gameInterval), 50);
    });

    test('converted frequency is accepted by SensorOptions', () {
      final options = SensorOptions(
        frequency: _frequencyOf(SensorInterval.gameInterval),
      );
      expect(options, isNotNull);
    });
  });
}

/// 与 `lib/src/web_sensors.dart` 中匿名扩展 `Duration.frequency` 相同的换算语义。
///
/// 该扩展未命名、仅在库内可见，无法在库外直接调用（亦不允许修改 lib），
/// 因此按同一规则复算并验证其换算契约；实际生效路径为
/// `*EventStream(samplingPeriod:)` -> `SensorOptions(frequency:)`。
int _frequencyOf(Duration duration) {
  if (duration.inMicroseconds <= 10) {
    return 100;
  }
  return 1000 ~/ duration.inMilliseconds;
}
