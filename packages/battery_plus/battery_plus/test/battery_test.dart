// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:async/async.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:battery_plus_platform_interface/battery_plus_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// A configurable, in-process [BatteryPlatform] used to drive the [Battery]
/// facade without crossing any real platform channels.
///
/// Every result can be tuned per test, and any getter can be made to fail by
/// assigning an error, which lets both success and failure paths be exercised.
class FakeBatteryPlatform
    with MockPlatformInterfaceMixin
    implements BatteryPlatform {
  FakeBatteryPlatform({
    this.batteryLevelResult = 42,
    this.batteryStateResult = BatteryState.charging,
    this.isInBatterySaveModeResult = true,
    Stream<BatteryState>? batteryStateStream,
  }) : onBatteryStateChangedStream = batteryStateStream;

  int batteryLevelResult;
  BatteryState batteryStateResult;
  bool isInBatterySaveModeResult;

  /// When set, the matching getter completes with this error instead of a value.
  Object? batteryLevelError;
  Object? batteryStateError;
  Object? isInBatterySaveModeError;

  /// The stream surfaced through [onBatteryStateChanged].
  Stream<BatteryState>? onBatteryStateChangedStream;

  @override
  Future<int> get batteryLevel => batteryLevelError != null
      ? Future<int>.error(batteryLevelError!)
      : Future<int>.value(batteryLevelResult);

  @override
  Future<BatteryState> get batteryState => batteryStateError != null
      ? Future<BatteryState>.error(batteryStateError!)
      : Future<BatteryState>.value(batteryStateResult);

  @override
  Future<bool> get isInBatterySaveMode => isInBatterySaveModeError != null
      ? Future<bool>.error(isInBatterySaveModeError!)
      : Future<bool>.value(isInBatterySaveModeResult);

  @override
  Stream<BatteryState> get onBatteryStateChanged =>
      onBatteryStateChangedStream ?? const Stream<BatteryState>.empty();
}

void main() {
  // Captured before any test swaps it, so the real platform can be restored
  // and the [Battery] singleton never leaks a fake into another test file.
  final BatteryPlatform defaultPlatform = BatteryPlatform.instance;

  group('Battery', () {
    late FakeBatteryPlatform platform;

    setUp(() {
      platform = FakeBatteryPlatform();
      BatteryPlatform.instance = platform;
    });

    tearDown(() {
      BatteryPlatform.instance = defaultPlatform;
    });

    group('batteryLevel', () {
      test('forwards the value reported by the platform', () async {
        platform.batteryLevelResult = 87;
        expect(await Battery().batteryLevel, 87);
      });

      test('supports the empty battery boundary (0%)', () async {
        platform.batteryLevelResult = 0;
        expect(await Battery().batteryLevel, 0);
      });

      test('supports the fully charged boundary (100%)', () async {
        platform.batteryLevelResult = 100;
        expect(await Battery().batteryLevel, 100);
      });

      test('surfaces a PlatformException as a rejected future', () {
        platform.batteryLevelError = PlatformException(
          code: 'UNAVAILABLE',
          message: 'Battery level is not available on this device.',
        );
        expect(Battery().batteryLevel, throwsA(isA<PlatformException>()));
      });
    });

    group('isInBatterySaveMode', () {
      test('forwards true when the platform reports power-save mode', () async {
        platform.isInBatterySaveModeResult = true;
        expect(await Battery().isInBatterySaveMode, isTrue);
      });

      test('forwards false when the platform reports normal mode', () async {
        platform.isInBatterySaveModeResult = false;
        expect(await Battery().isInBatterySaveMode, isFalse);
      });

      test('surfaces a PlatformException as a rejected future', () {
        platform.isInBatterySaveModeError = PlatformException(
          code: 'UNAVAILABLE',
          message: 'Battery save mode is not available on this device.',
        );
        expect(
          Battery().isInBatterySaveMode,
          throwsA(isA<PlatformException>()),
        );
      });
    });

    group('batteryState', () {
      // Exhaustively assert that every BatteryState value (including the
      // platform-specific `connectedNotCharging`) flows through the facade
      // untouched.
      for (final state in BatteryState.values) {
        test('forwards $state from the platform', () async {
          platform.batteryStateResult = state;
          expect(await Battery().batteryState, state);
        });
      }

      test('surfaces a PlatformException as a rejected future', () {
        platform.batteryStateError = PlatformException(
          code: 'UNAVAILABLE',
          message: 'Battery state is not available on this device.',
        );
        expect(Battery().batteryState, throwsA(isA<PlatformException>()));
      });
    });

    group('onBatteryStateChanged', () {
      test('emits every BatteryState value in order', () async {
        platform.onBatteryStateChangedStream = Stream.fromIterable([
          BatteryState.unknown,
          BatteryState.charging,
          BatteryState.connectedNotCharging,
          BatteryState.discharging,
          BatteryState.full,
        ]);

        final queue = StreamQueue<BatteryState>(Battery().onBatteryStateChanged);

        expect(await queue.next, BatteryState.unknown);
        expect(await queue.next, BatteryState.charging);
        expect(await queue.next, BatteryState.connectedNotCharging);
        expect(await queue.next, BatteryState.discharging);
        expect(await queue.next, BatteryState.full);

        expect(await queue.hasNext, isFalse);
      });

      test('delivers every event to multiple concurrent listeners', () async {
        final controller = StreamController<BatteryState>.broadcast();
        platform.onBatteryStateChangedStream = controller.stream;

        final receivedByFirst = <BatteryState>[];
        final receivedBySecond = <BatteryState>[];
        Battery().onBatteryStateChanged.listen(receivedByFirst.add);
        Battery().onBatteryStateChanged.listen(receivedBySecond.add);

        controller
          ..add(BatteryState.charging)
          ..add(BatteryState.connectedNotCharging);

        // Drain pending microtasks so both listeners have processed the events.
        await Future<void>.delayed(Duration.zero);

        expect(
          receivedByFirst,
          [BatteryState.charging, BatteryState.connectedNotCharging],
        );
        expect(
          receivedBySecond,
          [BatteryState.charging, BatteryState.connectedNotCharging],
        );

        await controller.close();
      });
    });

    group('singleton', () {
      test('always returns the same instance', () {
        expect(identical(Battery(), Battery()), isTrue);
      });
    });

    // Drives the four public properties through an explicitly typed
    // instance variable (instead of the `Battery().x` chained form) so the
    // full API surface is referenced once in a single place.
    group('API surface via typed instance', () {
      late FakeBatteryPlatform platform;

      setUp(() {
        platform = FakeBatteryPlatform();
        BatteryPlatform.instance = platform;
      });

      tearDown(() {
        BatteryPlatform.instance = defaultPlatform;
      });

      test('batteryLevel forwards the platform value', () async {
        platform.batteryLevelResult = 64;
        final Battery battery = Battery();
        expect(await battery.batteryLevel, 64);
      });

      test('isInBatterySaveMode forwards the platform value', () async {
        platform.isInBatterySaveModeResult = false;
        final Battery battery = Battery();
        expect(await battery.isInBatterySaveMode, isFalse);
      });

      test('batteryState forwards the platform value', () async {
        platform.batteryStateResult = BatteryState.connectedNotCharging;
        final Battery battery = Battery();
        expect(await battery.batteryState, BatteryState.connectedNotCharging);
      });

      test('onBatteryStateChanged forwards the platform stream', () async {
        platform.onBatteryStateChangedStream = Stream.fromIterable([
          BatteryState.charging,
          BatteryState.full,
        ]);
        final Battery battery = Battery();
        expect(
          await battery.onBatteryStateChanged.toList(),
          [BatteryState.charging, BatteryState.full],
        );
      });
    });
  });
}
