// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sensors_plus_platform_interface/sensors_plus_platform_interface.dart';
// ignore_for_file: implementation_imports
import 'package:sensors_plus_platform_interface/src/method_channel_sensors.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // MethodChannelSensors 缓存了广播流实例，需在每个测试前重置平台实例，
  // 否则后续测试复用同一广播流，平台侧 listen 不再触发、无事件返回。
  setUp(() {
    SensorsPlatform.instance = MethodChannelSensors();
  });

  tearDown(() {
    _clearMockHandlers();
  });

  group('SensorInterval constants', () {
    test('normalInterval should be 200ms', () {
      expect(SensorInterval.normalInterval, const Duration(milliseconds: 200));
    });

    test('uiInterval should be ~66ms', () {
      expect(SensorInterval.uiInterval,
          const Duration(milliseconds: 66, microseconds: 667));
    });

    test('gameInterval should be 20ms', () {
      expect(SensorInterval.gameInterval, const Duration(milliseconds: 20));
    });

    test('fastestInterval should be Duration.zero', () {
      expect(SensorInterval.fastestInterval, Duration.zero);
    });
  });

  group('Sensors singleton', () {
    test('Sensors() returns singleton instance', () {
      final a = Sensors();
      final b = Sensors();
      expect(identical(a, b), isTrue);
    });
  });

  group('AccelerometerEvent', () {
    test('stores values correctly', () {
      final now = DateTime.now();
      final event = AccelerometerEvent(1.0, 2.0, 3.0, now);
      expect(event.x, 1.0);
      expect(event.y, 2.0);
      expect(event.z, 3.0);
      expect(event.timestamp, now);
    });

    test('toString contains all values', () {
      final now = DateTime.now();
      final event = AccelerometerEvent(1.0, 2.0, 3.0, now);
      expect(event.toString(), contains('1.0'));
      expect(event.toString(), contains('2.0'));
      expect(event.toString(), contains('3.0'));
    });

    test('handles negative values', () {
      final now = DateTime.now();
      final event = AccelerometerEvent(-9.8, -0.5, -1.2, now);
      expect(event.x, -9.8);
      expect(event.y, -0.5);
      expect(event.z, -1.2);
    });

    test('handles zero values', () {
      final now = DateTime.now();
      final event = AccelerometerEvent(0.0, 0.0, 0.0, now);
      expect(event.x, 0.0);
      expect(event.y, 0.0);
      expect(event.z, 0.0);
    });

    test('handles extreme values', () {
      final now = DateTime.now();
      final event = AccelerometerEvent(
          double.maxFinite, -double.maxFinite, double.minPositive, now);
      expect(event.x, double.maxFinite);
      expect(event.y, -double.maxFinite);
      expect(event.z, double.minPositive);
    });
  });

  group('UserAccelerometerEvent', () {
    test('stores values correctly', () {
      final now = DateTime.now();
      final event = UserAccelerometerEvent(1.0, 2.0, 3.0, now);
      expect(event.x, 1.0);
      expect(event.y, 2.0);
      expect(event.z, 3.0);
      expect(event.timestamp, now);
    });

    test('toString contains all values', () {
      final now = DateTime.now();
      final event = UserAccelerometerEvent(1.0, 2.0, 3.0, now);
      expect(event.toString(), contains('1.0'));
      expect(event.toString(), contains('2.0'));
      expect(event.toString(), contains('3.0'));
    });

    test('handles negative values', () {
      final now = DateTime.now();
      final event = UserAccelerometerEvent(-5.0, -6.0, -7.0, now);
      expect(event.x, -5.0);
      expect(event.y, -6.0);
      expect(event.z, -7.0);
    });
  });

  group('GyroscopeEvent', () {
    test('stores values correctly', () {
      final now = DateTime.now();
      final event = GyroscopeEvent(0.1, 0.2, 0.3, now);
      expect(event.x, 0.1);
      expect(event.y, 0.2);
      expect(event.z, 0.3);
      expect(event.timestamp, now);
    });

    test('toString contains all values', () {
      final now = DateTime.now();
      final event = GyroscopeEvent(0.1, 0.2, 0.3, now);
      expect(event.toString(), contains('0.1'));
      expect(event.toString(), contains('0.2'));
      expect(event.toString(), contains('0.3'));
    });
  });

  group('MagnetometerEvent', () {
    test('stores values correctly', () {
      final now = DateTime.now();
      final event = MagnetometerEvent(10.0, 20.0, 30.0, now);
      expect(event.x, 10.0);
      expect(event.y, 20.0);
      expect(event.z, 30.0);
      expect(event.timestamp, now);
    });

    test('toString contains all values', () {
      final now = DateTime.now();
      final event = MagnetometerEvent(10.0, 20.0, 30.0, now);
      expect(event.toString(), contains('10.0'));
      expect(event.toString(), contains('20.0'));
      expect(event.toString(), contains('30.0'));
    });
  });

  group('BarometerEvent', () {
    test('stores values correctly', () {
      final now = DateTime.now();
      final event = BarometerEvent(1013.25, now);
      expect(event.pressure, 1013.25);
      expect(event.timestamp, now);
    });

    test('toString contains pressure', () {
      final now = DateTime.now();
      final event = BarometerEvent(1013.25, now);
      expect(event.toString(), contains('1013.25'));
      expect(event.toString(), contains('hPa'));
    });

    test('handles extreme pressure values', () {
      final now = DateTime.now();
      final low = BarometerEvent(870.0, now); // very low pressure (hurricane)
      final high = BarometerEvent(1084.0, now); // very high pressure
      expect(low.pressure, 870.0);
      expect(high.pressure, 1084.0);
    });
  });

  group('accelerometerEventStream', () {
    late List<MethodCall> methodCalls;

    setUp(() {
      methodCalls = [];
      _initializeFakeMethodChannel('setAccelerationSamplingPeriod', methodCalls);
    });

    tearDown(() {
      _clearMockHandlers();
    });

    test('streams accelerometer events with timestamp', () async {
      const channelName = 'dev.fluttercommunity.plus/sensors/accelerometer';
      final date = DateTime.now();
      final sensorData = <double>[
        1.0,
        2.0,
        3.0,
        date.microsecondsSinceEpoch.toDouble(),
      ];
      _initializeFakeSensorChannel(channelName, sensorData);

      final event = await accelerometerEventStream().first;

      expect(event.x, sensorData[0]);
      expect(event.y, sensorData[1]);
      expect(event.z, sensorData[2]);
      expect(event.timestamp, date);
    });

    test('sends sampling period via method channel', () async {
      const channelName = 'dev.fluttercommunity.plus/sensors/accelerometer';
      final date = DateTime.now();
      final sensorData = <double>[
        1.0,
        2.0,
        3.0,
        date.microsecondsSinceEpoch.toDouble(),
      ];
      _initializeFakeSensorChannel(channelName, sensorData);

      await accelerometerEventStream(
              samplingPeriod: SensorInterval.gameInterval)
          .first;

      expect(methodCalls, isNotEmpty);
      expect(methodCalls.first.method, 'setAccelerationSamplingPeriod');
      expect(methodCalls.first.arguments,
          SensorInterval.gameInterval.inMicroseconds);
    });

    // ignore: deprecated_member_use
    test('deprecated accelerometerEvents getter works', () async {
      const channelName = 'dev.fluttercommunity.plus/sensors/accelerometer';
      final date = DateTime.now();
      final sensorData = <double>[
        1.0,
        2.0,
        3.0,
        date.microsecondsSinceEpoch.toDouble(),
      ];
      _initializeFakeSensorChannel(channelName, sensorData);

      // ignore: deprecated_member_use
      final event = await accelerometerEvents.first;

      expect(event.x, sensorData[0]);
      expect(event.y, sensorData[1]);
      expect(event.z, sensorData[2]);
    });
  });

  group('userAccelerometerEventStream', () {
    late List<MethodCall> methodCalls;

    setUp(() {
      methodCalls = [];
      _initializeFakeMethodChannel(
          'setUserAccelerometerSamplingPeriod', methodCalls);
    });

    tearDown(() {
      _clearMockHandlers();
    });

    test('streams user accelerometer events with timestamp', () async {
      const channelName = 'dev.fluttercommunity.plus/sensors/user_accel';
      final date = DateTime.now();
      final sensorData = <double>[
        6.0,
        7.0,
        8.0,
        date.microsecondsSinceEpoch.toDouble(),
      ];
      _initializeFakeSensorChannel(channelName, sensorData);

      final event = await userAccelerometerEventStream().first;

      expect(event.x, sensorData[0]);
      expect(event.y, sensorData[1]);
      expect(event.z, sensorData[2]);
      expect(event.timestamp, date);
    });

    test('sends sampling period via method channel', () async {
      const channelName = 'dev.fluttercommunity.plus/sensors/user_accel';
      final date = DateTime.now();
      final sensorData = <double>[
        6.0,
        7.0,
        8.0,
        date.microsecondsSinceEpoch.toDouble(),
      ];
      _initializeFakeSensorChannel(channelName, sensorData);

      await userAccelerometerEventStream(
              samplingPeriod: SensorInterval.uiInterval)
          .first;

      expect(methodCalls, isNotEmpty);
      expect(methodCalls.first.method, 'setUserAccelerometerSamplingPeriod');
      expect(
          methodCalls.first.arguments, SensorInterval.uiInterval.inMicroseconds);
    });

    // ignore: deprecated_member_use
    test('deprecated userAccelerometerEvents getter works', () async {
      const channelName = 'dev.fluttercommunity.plus/sensors/user_accel';
      final date = DateTime.now();
      final sensorData = <double>[
        6.0,
        7.0,
        8.0,
        date.microsecondsSinceEpoch.toDouble(),
      ];
      _initializeFakeSensorChannel(channelName, sensorData);

      // ignore: deprecated_member_use
      final event = await userAccelerometerEvents.first;

      expect(event.x, sensorData[0]);
      expect(event.y, sensorData[1]);
      expect(event.z, sensorData[2]);
    });
  });

  group('gyroscopeEventStream', () {
    late List<MethodCall> methodCalls;

    setUp(() {
      methodCalls = [];
      _initializeFakeMethodChannel('setGyroscopeSamplingPeriod', methodCalls);
    });

    tearDown(() {
      _clearMockHandlers();
    });

    test('streams gyroscope events with timestamp', () async {
      const channelName = 'dev.fluttercommunity.plus/sensors/gyroscope';
      final date = DateTime.now();
      final sensorData = <double>[
        3.0,
        4.0,
        5.0,
        date.microsecondsSinceEpoch.toDouble(),
      ];
      _initializeFakeSensorChannel(channelName, sensorData);

      final event = await gyroscopeEventStream().first;

      expect(event.x, sensorData[0]);
      expect(event.y, sensorData[1]);
      expect(event.z, sensorData[2]);
      expect(event.timestamp, date);
    });

    test('sends sampling period via method channel', () async {
      const channelName = 'dev.fluttercommunity.plus/sensors/gyroscope';
      final date = DateTime.now();
      final sensorData = <double>[
        3.0,
        4.0,
        5.0,
        date.microsecondsSinceEpoch.toDouble(),
      ];
      _initializeFakeSensorChannel(channelName, sensorData);

      await gyroscopeEventStream(
              samplingPeriod: SensorInterval.normalInterval)
          .first;

      expect(methodCalls, isNotEmpty);
      expect(methodCalls.first.method, 'setGyroscopeSamplingPeriod');
      expect(methodCalls.first.arguments,
          SensorInterval.normalInterval.inMicroseconds);
    });

    // ignore: deprecated_member_use
    test('deprecated gyroscopeEvents getter works', () async {
      const channelName = 'dev.fluttercommunity.plus/sensors/gyroscope';
      final date = DateTime.now();
      final sensorData = <double>[
        3.0,
        4.0,
        5.0,
        date.microsecondsSinceEpoch.toDouble(),
      ];
      _initializeFakeSensorChannel(channelName, sensorData);

      // ignore: deprecated_member_use
      final event = await gyroscopeEvents.first;

      expect(event.x, sensorData[0]);
      expect(event.y, sensorData[1]);
      expect(event.z, sensorData[2]);
    });
  });

  group('magnetometerEventStream', () {
    late List<MethodCall> methodCalls;

    setUp(() {
      methodCalls = [];
      _initializeFakeMethodChannel('setMagnetometerSamplingPeriod', methodCalls);
    });

    tearDown(() {
      _clearMockHandlers();
    });

    test('streams magnetometer events with timestamp', () async {
      const channelName = 'dev.fluttercommunity.plus/sensors/magnetometer';
      final date = DateTime.now();
      final sensorData = <double>[
        8.0,
        9.0,
        10.0,
        date.microsecondsSinceEpoch.toDouble(),
      ];
      _initializeFakeSensorChannel(channelName, sensorData);

      final event = await magnetometerEventStream().first;

      expect(event.x, sensorData[0]);
      expect(event.y, sensorData[1]);
      expect(event.z, sensorData[2]);
      expect(event.timestamp, date);
    });

    test('sends sampling period via method channel', () async {
      const channelName = 'dev.fluttercommunity.plus/sensors/magnetometer';
      final date = DateTime.now();
      final sensorData = <double>[
        8.0,
        9.0,
        10.0,
        date.microsecondsSinceEpoch.toDouble(),
      ];
      _initializeFakeSensorChannel(channelName, sensorData);

      await magnetometerEventStream(
              samplingPeriod: SensorInterval.fastestInterval)
          .first;

      expect(methodCalls, isNotEmpty);
      expect(methodCalls.first.method, 'setMagnetometerSamplingPeriod');
      expect(methodCalls.first.arguments,
          SensorInterval.fastestInterval.inMicroseconds);
    });

    // ignore: deprecated_member_use
    test('deprecated magnetometerEvents getter works', () async {
      const channelName = 'dev.fluttercommunity.plus/sensors/magnetometer';
      final date = DateTime.now();
      final sensorData = <double>[
        8.0,
        9.0,
        10.0,
        date.microsecondsSinceEpoch.toDouble(),
      ];
      _initializeFakeSensorChannel(channelName, sensorData);

      // ignore: deprecated_member_use
      final event = await magnetometerEvents.first;

      expect(event.x, sensorData[0]);
      expect(event.y, sensorData[1]);
      expect(event.z, sensorData[2]);
    });
  });

  group('barometerEventStream', () {
    late List<MethodCall> methodCalls;

    setUp(() {
      methodCalls = [];
      _initializeFakeMethodChannel('setBarometerSamplingPeriod', methodCalls);
    });

    tearDown(() {
      _clearMockHandlers();
    });

    test('streams barometer events with timestamp', () async {
      const channelName = 'dev.fluttercommunity.plus/sensors/barometer';
      final date = DateTime.now();
      final sensorData = <double>[
        1000.0,
        date.microsecondsSinceEpoch.toDouble(),
      ];
      _initializeFakeSensorChannel(channelName, sensorData);

      final event = await barometerEventStream().first;

      expect(event.pressure, sensorData[0]);
      expect(event.timestamp, date);
    });

    test('sends sampling period via method channel', () async {
      const channelName = 'dev.fluttercommunity.plus/sensors/barometer';
      final date = DateTime.now();
      final sensorData = <double>[
        1000.0,
        date.microsecondsSinceEpoch.toDouble(),
      ];
      _initializeFakeSensorChannel(channelName, sensorData);

      await barometerEventStream(
              samplingPeriod: SensorInterval.normalInterval)
          .first;

      expect(methodCalls, isNotEmpty);
      expect(methodCalls.first.method, 'setBarometerSamplingPeriod');
      expect(methodCalls.first.arguments,
          SensorInterval.normalInterval.inMicroseconds);
    });
  });

  group('Error handling', () {
    setUp(() {
      // 传感器流内部会调用 MethodChannel，必须提供 mock 以避免
      // MissingPluginException 在测试完成后异步抛出。
      _initializeFakeMethodChannel('setAccelerationSamplingPeriod', []);
      _initializeFakeMethodChannel('setGyroscopeSamplingPeriod', []);
    });

    test('sensor error event is propagated to stream', () async {
      const channelName = 'dev.fluttercommunity.plus/sensors/accelerometer';
      _initializeFakeSensorChannelWithError(
          channelName, 'SENSOR_ERROR', 'Sensor not available');

      final stream = accelerometerEventStream();
      expect(
        stream,
        emitsError(isA<PlatformException>()),
      );
    });

    test('sensor not found error is propagated', () async {
      const channelName = 'dev.fluttercommunity.plus/sensors/gyroscope';
      _initializeFakeSensorChannelWithError(
          channelName, 'NO_SENSOR', 'Sensor not found');

      final stream = gyroscopeEventStream();
      expect(
        stream,
        emitsError(isA<PlatformException>()),
      );
    });

    test('error event carries the platform error code', () async {
      const channelName = 'dev.fluttercommunity.plus/sensors/accelerometer';
      _initializeFakeSensorChannelWithError(
          channelName, 'SENSOR_ERROR', 'Sensor not available');

      final completer = Completer<PlatformException>();
      accelerometerEventStream().listen(
        (_) => fail('Expected an error, not data'),
        onError: (Object error) => completer.complete(error as PlatformException),
      );
      final error = await completer.future;
      expect(error.code, 'SENSOR_ERROR');
      expect(error.message, 'Sensor not available');
    });
  });

  group('Concurrent subscriptions', () {
    tearDown(() {
      _clearMockHandlers();
    });

    test('multiple calls return the same cached broadcast stream', () async {
      const channelName = 'dev.fluttercommunity.plus/sensors/accelerometer';
      final date = DateTime.now();
      final sensorData = <double>[
        1.0,
        2.0,
        3.0,
        date.microsecondsSinceEpoch.toDouble(),
      ];
      _initializeFakeMethodChannel('setAccelerationSamplingPeriod', []);
      _initializeFakeSensorChannel(channelName, sensorData);

      // 平台接口文档化的行为：同一传感器多次调用返回同一个缓存的广播流。
      final stream1 = accelerometerEventStream();
      final stream2 = accelerometerEventStream();

      expect(identical(stream1, stream2), isTrue);
    });

    test('repeated subscribe and cancel does not throw', () async {
      const channelName = 'dev.fluttercommunity.plus/sensors/accelerometer';
      final date = DateTime.now();
      final sensorData = <double>[
        1.0,
        2.0,
        3.0,
        date.microsecondsSinceEpoch.toDouble(),
      ];
      _initializeFakeMethodChannel('setAccelerationSamplingPeriod', []);
      _initializeFakeSensorChannel(channelName, sensorData);

      for (var i = 0; i < 3; i++) {
        final sub = accelerometerEventStream().listen((_) {});
        await sub.cancel();
      }
      // 多次订阅/取消不应抛出异常
    });

    test('different sensor streams work concurrently', () async {
      final date = DateTime.now();

      _initializeFakeMethodChannel('setAccelerationSamplingPeriod', []);
      _initializeFakeMethodChannel('setGyroscopeSamplingPeriod', []);

      _initializeFakeSensorChannel(
          'dev.fluttercommunity.plus/sensors/accelerometer',
          [1.0, 2.0, 3.0, date.microsecondsSinceEpoch.toDouble()]);
      _initializeFakeSensorChannel(
          'dev.fluttercommunity.plus/sensors/gyroscope',
          [4.0, 5.0, 6.0, date.microsecondsSinceEpoch.toDouble()]);

      final accelEvent = await accelerometerEventStream().first;
      final gyroEvent = await gyroscopeEventStream().first;

      expect(accelEvent.x, 1.0);
      expect(gyroEvent.x, 4.0);
    });

    test('subscribe and unsubscribe does not crash', () async {
      const channelName = 'dev.fluttercommunity.plus/sensors/accelerometer';
      final date = DateTime.now();
      final sensorData = <double>[
        1.0,
        2.0,
        3.0,
        date.microsecondsSinceEpoch.toDouble(),
      ];
      _initializeFakeMethodChannel('setAccelerationSamplingPeriod', []);
      _initializeFakeSensorChannel(channelName, sensorData);

      final sub = accelerometerEventStream().listen((_) {});
      await sub.cancel();
      // Should not throw
    });
  });

  group('Sampling period boundaries', () {
    tearDown(() {
      _clearMockHandlers();
    });

    test('fastestInterval (Duration.zero) is handled', () async {
      const channelName = 'dev.fluttercommunity.plus/sensors/accelerometer';
      final date = DateTime.now();
      final sensorData = <double>[
        1.0,
        2.0,
        3.0,
        date.microsecondsSinceEpoch.toDouble(),
      ];
      final methodCalls = <MethodCall>[];
      _initializeFakeMethodChannel('setAccelerationSamplingPeriod', methodCalls);
      _initializeFakeSensorChannel(channelName, sensorData);

      await accelerometerEventStream(
              samplingPeriod: SensorInterval.fastestInterval)
          .first;

      expect(methodCalls, isNotEmpty);
      expect(methodCalls.first.arguments, 0);
    });

    test('custom sampling period is passed correctly', () async {
      const channelName = 'dev.fluttercommunity.plus/sensors/accelerometer';
      final date = DateTime.now();
      final sensorData = <double>[
        1.0,
        2.0,
        3.0,
        date.microsecondsSinceEpoch.toDouble(),
      ];
      final methodCalls = <MethodCall>[];
      _initializeFakeMethodChannel('setAccelerationSamplingPeriod', methodCalls);
      _initializeFakeSensorChannel(channelName, sensorData);

      const customPeriod = Duration(milliseconds: 500);
      await accelerometerEventStream(samplingPeriod: customPeriod).first;

      expect(methodCalls, isNotEmpty);
      expect(methodCalls.first.arguments, customPeriod.inMicroseconds);
    });
  });
}

void _initializeFakeMethodChannel(
    String methodName, List<MethodCall> methodCalls) {
  const standardMethod = StandardMethodCodec();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('dev.fluttercommunity.plus/sensors/method',
          (ByteData? message) async {
    final methodCall = standardMethod.decodeMethodCall(message);
    if (methodCall.method == methodName) {
      methodCalls.add(methodCall);
      return standardMethod.encodeSuccessEnvelope(null);
    } else if (methodCalls.isEmpty) {
      // Allow other method calls when not tracking
      return standardMethod.encodeSuccessEnvelope(null);
    }
    return standardMethod.encodeSuccessEnvelope(null);
  });
}

void _initializeFakeSensorChannel(
    String channelName, List<double> sensorData) {
  const standardMethod = StandardMethodCodec();

  void emitEvent(ByteData? event) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
      channelName,
      event,
      (ByteData? reply) {},
    );
  }

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler(channelName, (ByteData? message) async {
    final methodCall = standardMethod.decodeMethodCall(message);
    if (methodCall.method == 'listen') {
      emitEvent(standardMethod.encodeSuccessEnvelope(sensorData));
      emitEvent(null);
      return standardMethod.encodeSuccessEnvelope(null);
    } else if (methodCall.method == 'cancel') {
      return standardMethod.encodeSuccessEnvelope(null);
    } else {
      fail('Expected listen or cancel');
    }
  });
}

void _initializeFakeSensorChannelWithError(
    String channelName, String errorCode, String errorMessage) {
  const standardMethod = StandardMethodCodec();

  void emitError() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
      channelName,
      standardMethod.encodeErrorEnvelope(
          code: errorCode, message: errorMessage),
      (ByteData? reply) {},
    );
  }

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler(channelName, (ByteData? message) async {
    final methodCall = standardMethod.decodeMethodCall(message);
    if (methodCall.method == 'listen') {
      emitError();
      return standardMethod.encodeSuccessEnvelope(null);
    } else if (methodCall.method == 'cancel') {
      return standardMethod.encodeSuccessEnvelope(null);
    } else {
      fail('Expected listen or cancel');
    }
  });
}

void _clearMockHandlers() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler(
          'dev.fluttercommunity.plus/sensors/method', null);
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler(
          'dev.fluttercommunity.plus/sensors/accelerometer', null);
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler(
          'dev.fluttercommunity.plus/sensors/user_accel', null);
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler(
          'dev.fluttercommunity.plus/sensors/gyroscope', null);
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler(
          'dev.fluttercommunity.plus/sensors/magnetometer', null);
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler(
          'dev.fluttercommunity.plus/sensors/barometer', null);
}
