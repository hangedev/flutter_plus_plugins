// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:async';

import 'package:sensors_plus/sensors_plus.dart';

/// 一个覆盖全部公开接口的演示集合，不在界面上展示任何内容，
/// 仅在后台驱动每个 API 以验证鸿蒙化实现的可用性。
///
/// 覆盖目标：
/// - [Sensors] 单例与 4 个 *EventStream() 方法
/// - 4 个废弃顶层属性（accelerometerEvents / gyroscopeEvents /
///   userAccelerometerEvents / magnetometerEvents）
/// - 4 个顶层 *EventStream() 函数
/// - [SensorInterval] 全部常量（normal/ui/game/fastest）
/// - 异常场景（onError）、并发订阅、重复订阅/取消、采样周期切换
class SensorsCoverageDemo {
  SensorsCoverageDemo();

  /// 在测试环境中设为 true，跳过传感器订阅以避免 Timer/Stream 残留。
  static bool testMode = false;

  final _subscriptions = <StreamSubscription<dynamic>>[];
  bool _running = false;

  /// 启动全部演示。每个传感器订阅一个事件后即取消，避免长时间占用。
  Future<void> run() async {
    if (_running) {
      return;
    }
    // 测试环境下跳过，避免 Timer/Stream 残留导致 widget 测试失败
    if (testMode) {
      return;
    }
    _running = true;

    print('[SensorsCoverageDemo] === SensorInterval 常量 ===');
    _demonstrateSensorIntervals();

    print('[SensorsCoverageDemo] === Sensors 单例 ===');
    _demonstrateSingleton();

    print('[SensorsCoverageDemo] === Sensors.*EventStream() 方法 ===');
    await _demonstrateSensorsClassStreams();

    print('[SensorsCoverageDemo] === 顶层 *EventStream() 函数 ===');
    await _demonstrateTopLevelStreams();

    print('[SensorsCoverageDemo] === 废弃顶层属性 ===');
    await _demonstrateDeprecatedGetters();

    print('[SensorsCoverageDemo] === 异常处理（onError） ===');
    await _demonstrateErrorHandling();

    print('[SensorsCoverageDemo] === 采样周期切换 ===');
    await _demonstrateSamplingPeriodSwitch();

    print('[SensorsCoverageDemo] === 并发订阅 / 重复订阅取消 ===');
    await _demonstrateConcurrentSubscriptions();

    print('[SensorsCoverageDemo] 全部演示完成');
    await dispose();
  }

  /// 覆盖 [SensorInterval] 的 4 个常量。
  void _demonstrateSensorIntervals() {
    print('  normalInterval  = ${SensorInterval.normalInterval.inMilliseconds}ms');
    print('  uiInterval      = ${SensorInterval.uiInterval.inMicroseconds}us');
    print('  gameInterval    = ${SensorInterval.gameInterval.inMilliseconds}ms');
    print('  fastestInterval = ${SensorInterval.fastestInterval.inMicroseconds}us');
  }

  /// 覆盖 [Sensors] 单例：多次构造返回同一实例。
  void _demonstrateSingleton() {
    final a = Sensors();
    final b = Sensors();
    print('  Sensors() 单例一致性: ${identical(a, b)}');
  }

  /// 覆盖 [Sensors] 类的 5 个 *EventStream() 方法。
  Future<void> _demonstrateSensorsClassStreams() async {
    final sensors = Sensors();
    await _subscribeOnce('Sensors.accelerometerEventStream',
        sensors.accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval));
    await _subscribeOnce('Sensors.userAccelerometerEventStream',
        sensors.userAccelerometerEventStream(samplingPeriod: SensorInterval.uiInterval));
    await _subscribeOnce('Sensors.gyroscopeEventStream',
        sensors.gyroscopeEventStream(samplingPeriod: SensorInterval.normalInterval));
    await _subscribeOnce('Sensors.magnetometerEventStream',
        sensors.magnetometerEventStream(samplingPeriod: SensorInterval.normalInterval));
  }

  /// 覆盖 4 个顶层 *EventStream() 函数。
  Future<void> _demonstrateTopLevelStreams() async {
    await _subscribeOnce('accelerometerEventStream',
        accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval));
    await _subscribeOnce('userAccelerometerEventStream',
        userAccelerometerEventStream(samplingPeriod: SensorInterval.uiInterval));
    await _subscribeOnce('gyroscopeEventStream',
        gyroscopeEventStream(samplingPeriod: SensorInterval.normalInterval));
    await _subscribeOnce('magnetometerEventStream',
        magnetometerEventStream(samplingPeriod: SensorInterval.normalInterval));
  }

  /// 覆盖 4 个废弃顶层属性。
  Future<void> _demonstrateDeprecatedGetters() async {
    await _subscribeOnce('accelerometerEvents (deprecated)', accelerometerEvents);
    await _subscribeOnce('userAccelerometerEvents (deprecated)', userAccelerometerEvents);
    await _subscribeOnce('gyroscopeEvents (deprecated)', gyroscopeEvents);
    await _subscribeOnce('magnetometerEvents (deprecated)', magnetometerEvents);
  }

  /// 覆盖异常场景：订阅流的 onError 回调。
  Future<void> _demonstrateErrorHandling() async {
    final completer = Completer<void>();
    late StreamSubscription<dynamic> sub;
    sub = accelerometerEventStream().listen(
      (event) {
        print('  收到事件: x=${event.x.toStringAsFixed(2)}');
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onError: (Object error) {
        print('  onError 触发: $error（设备可能不支持该传感器）');
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      cancelOnError: true,
    );
    _subscriptions.add(sub);
    // 等待首个事件或异常，最长 2 秒
    await completer.future.timeout(const Duration(seconds: 2), onTimeout: () {
      print('  onError 演示超时（未收到事件或异常）');
    }).catchError((_) {});
    await sub.cancel();
  }

  /// 覆盖采样周期切换：game -> ui -> normal。
  Future<void> _demonstrateSamplingPeriodSwitch() async {
    for (final period in [
      SensorInterval.gameInterval,
      SensorInterval.uiInterval,
      SensorInterval.normalInterval,
    ]) {
      final stream = accelerometerEventStream(samplingPeriod: period);
      final sub = stream.listen((event) {
        print('  period=${period.inMilliseconds}ms x=${event.x.toStringAsFixed(2)}');
      }, onError: (Object error) {
        print('  period=${period.inMilliseconds}ms onError: $error');
      });
      _subscriptions.add(sub);
      // 切换采样周期会触发平台侧 setUpdateInterval
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await sub.cancel();
    }
  }

  /// 覆盖并发订阅与重复订阅/取消。
  Future<void> _demonstrateConcurrentSubscriptions() async {
    // 同一传感器的缓存广播流
    final stream1 = accelerometerEventStream();
    final stream2 = accelerometerEventStream();
    print('  同一传感器多次调用返回同一广播流: ${identical(stream1, stream2)}');

    // 重复订阅再取消，不应抛出异常
    for (var i = 0; i < 3; i++) {
      final sub = accelerometerEventStream().listen((_) {});
      await sub.cancel();
    }
    print('  重复订阅/取消 3 次完成，无异常');

    // 不同传感器并发
    final subAccel = accelerometerEventStream().listen((event) {
      print('  并发[accel] x=${event.x.toStringAsFixed(2)}');
    }, onError: (_) {});
    final subGyro = gyroscopeEventStream().listen((event) {
      print('  并发[gyro] x=${event.x.toStringAsFixed(2)}');
    }, onError: (_) {});
    _subscriptions.add(subAccel);
    _subscriptions.add(subGyro);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    await subAccel.cancel();
    await subGyro.cancel();
  }

  /// 订阅流，收到首个事件或异常后取消。
  Future<void> _subscribeOnce(
      String name, Stream<dynamic> stream) async {
    final completer = Completer<void>();
    final sub = stream.listen(
      (event) {
        print('  $name: 收到事件');
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onError: (Object error) {
        print('  $name: onError（设备可能不支持）: $error');
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      cancelOnError: true,
    );
    _subscriptions.add(sub);
    await completer.future
        .timeout(const Duration(seconds: 2), onTimeout: () {
      print('  $name: 超时（未收到事件或异常）');
    }).catchError((_) {});
    await sub.cancel();
  }

  /// 释放全部订阅。
  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    _running = false;
  }
}
