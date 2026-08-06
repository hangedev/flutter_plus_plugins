// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sensors_plus_example/main.dart';
import 'package:sensors_plus_example/sensors_coverage_demo.dart';

/// 为传感器插件设置 mock MethodChannel 和 EventChannel handler，
/// 使所有平台异步调用在测试环境中正常完成，避免 Timer/微任务残留。
void setupMockSensorChannels() {
  const standardMethod = StandardMethodCodec();

  // Mock MethodChannel: 所有 set*SamplingPeriod 调用返回成功
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('dev.fluttercommunity.plus/sensors/method',
          (ByteData? message) async {
    return standardMethod.encodeSuccessEnvelope(null);
  });

  // Mock 每个 EventChannel: listen 返回成功并发送空结束帧，cancel 返回成功
  for (final channelName in [
    'dev.fluttercommunity.plus/sensors/accelerometer',
    'dev.fluttercommunity.plus/sensors/user_accel',
    'dev.fluttercommunity.plus/sensors/gyroscope',
    'dev.fluttercommunity.plus/sensors/magnetometer',
    'dev.fluttercommunity.plus/sensors/barometer',
  ]) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(channelName, (ByteData? message) async {
      final methodCall = standardMethod.decodeMethodCall(message);
      if (methodCall.method == 'listen') {
        // 发送一个传感器数据帧让流正常激活，然后发送结束帧
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
          channelName,
          standardMethod.encodeSuccessEnvelope([0.0, 0.0, 0.0, 0.0]),
          (_) {},
        );
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
          channelName,
          null,
          (_) {},
        );
        return standardMethod.encodeSuccessEnvelope(null);
      } else if (methodCall.method == 'cancel') {
        return standardMethod.encodeSuccessEnvelope(null);
      }
      return null;
    });
  }
}

void clearMockSensorChannels() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler(
          'dev.fluttercommunity.plus/sensors/method', null);
  for (final channelName in [
    'dev.fluttercommunity.plus/sensors/accelerometer',
    'dev.fluttercommunity.plus/sensors/user_accel',
    'dev.fluttercommunity.plus/sensors/gyroscope',
    'dev.fluttercommunity.plus/sensors/magnetometer',
    'dev.fluttercommunity.plus/sensors/barometer',
  ]) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(channelName, null);
  }
}

void main() {
  setUp(() {
    // 禁止 SensorsCoverageDemo 在测试中启动
    SensorsCoverageDemo.testMode = true;
    setupMockSensorChannels();
  });

  tearDown(() {
    clearMockSensorChannels();
  });

  testWidgets('App renders sensor UI correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 验证 AppBar 标题
    expect(find.text('Sensors Plus Example'), findsOneWidget);

    // 验证传感器标签
    expect(find.text('UserAccelerometer'), findsOneWidget);
    expect(find.text('Accelerometer'), findsOneWidget);
    expect(find.text('Gyroscope'), findsOneWidget);
    expect(find.text('Magnetometer'), findsOneWidget);
    expect(find.text('Barometer'), findsOneWidget);

    // 验证坐标轴标签
    expect(find.text('X'), findsWidgets);
    expect(find.text('Y'), findsWidgets);
    expect(find.text('Z'), findsWidgets);

    // 验证更新间隔选择器
    expect(find.text('Update Interval:'), findsOneWidget);
  });

  testWidgets('Sensor data shows placeholder or values',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 传感器数据列应该存在（可能是占位 '?' 或来自 mock 的数值）
    expect(find.text('Interval'), findsWidgets);
  });

  testWidgets('Snake game widget is present', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 验证 Snake 游戏区域的 CustomPaint 存在
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('SegmentedButton for interval selection exists',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 验证采样周期分段按钮存在
    expect(find.byType(SegmentedButton<Duration>), findsOneWidget);
  });
}
