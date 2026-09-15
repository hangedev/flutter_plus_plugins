// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:battery_plus/src/battery_plus_linux.dart';
import 'package:battery_plus_platform_interface/battery_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:upower/upower.dart';

import 'battery_plus_linux_test.mocks.dart';

@GenerateMocks([UPowerClient, UPowerDevice])
void main() {
  group('BatteryPlusLinuxPlugin', () {
    test('registers itself as the active platform implementation', () {
      BatteryPlusLinuxPlugin.registerWith();
      expect(BatteryPlatform.instance, isA<BatteryPlusLinuxPlugin>());
    });

    group('batteryLevel', () {
      test('rounds the reported percentage to the nearest integer', () async {
        final battery = BatteryPlusLinuxPlugin()
          ..createClient = () => createMockClient(percentage: 56.78);
        expect(battery.batteryLevel, completion(equals(57)));
      });

      test('reports 0% when the device is empty (lower boundary)', () async {
        final battery = BatteryPlusLinuxPlugin()
          ..createClient = () => createMockClient(percentage: 0.0);
        expect(battery.batteryLevel, completion(equals(0)));
      });

      test('reports 100% when the device is full (upper boundary)', () async {
        final battery = BatteryPlusLinuxPlugin()
          ..createClient = () => createMockClient(percentage: 100.0);
        expect(battery.batteryLevel, completion(equals(100)));
      });

      test('propagates the failure when the client cannot connect', () async {
        final battery = BatteryPlusLinuxPlugin()
          ..createClient = () => createMockClient(
                percentage: 50,
                connectError: Exception('DBus connection refused'),
              );
        expect(battery.batteryLevel, throwsA(isA<Exception>()));
      });
    });

    group('batteryState', () {
      // Exhaustively verify the UPowerDeviceState -> BatteryState mapping so
      // that every enum value (including the platform-specific
      // `connectedNotCharging`) is covered by a dedicated assertion.
      for (final mapping in <(UPowerDeviceState, BatteryState)>[
        (UPowerDeviceState.charging, BatteryState.charging),
        (UPowerDeviceState.discharging, BatteryState.discharging),
        (UPowerDeviceState.pendingDischarge, BatteryState.discharging),
        (UPowerDeviceState.fullyCharged, BatteryState.full),
        (UPowerDeviceState.pendingCharge, BatteryState.connectedNotCharging),
        (UPowerDeviceState.unknown, BatteryState.unknown),
        (UPowerDeviceState.empty, BatteryState.unknown),
      ]) {
        final upowerState = mapping.$1;
        final expectedBatteryState = mapping.$2;

        test('maps $upowerState to $expectedBatteryState', () async {
          final battery = BatteryPlusLinuxPlugin()
            ..createClient = () => createMockClient(state: upowerState);
          expect(battery.batteryState, completion(expectedBatteryState));
        });
      }

      test('propagates the failure when the client cannot connect', () async {
        final battery = BatteryPlusLinuxPlugin()
          ..createClient = () => createMockClient(
                state: UPowerDeviceState.charging,
                connectError: Exception('DBus connection refused'),
              );
        expect(battery.batteryState, throwsA(isA<Exception>()));
      });
    });

    group('onBatteryStateChanged', () {
      test('emits the converted state whenever the device reports a change',
          () {
        final battery = BatteryPlusLinuxPlugin()
          ..createClient = () {
            final client = createMockClient(state: UPowerDeviceState.charging);
            final device = client.displayDevice;
            when(device.propertiesChanged).thenAnswer((_) {
              when(device.state).thenReturn(UPowerDeviceState.fullyCharged);
              return Stream.value(['State']);
            });
            return client;
          };

        expect(battery.onBatteryStateChanged.isBroadcast, isTrue);
        expect(
          battery.onBatteryStateChanged,
          emitsInOrder([BatteryState.charging, BatteryState.full]),
        );
      });

      test(
          'emits connectedNotCharging when charging stops at the charge limit',
          () {
        final battery = BatteryPlusLinuxPlugin()
          ..createClient = () {
            final client = createMockClient(state: UPowerDeviceState.charging);
            final device = client.displayDevice;
            when(device.propertiesChanged).thenAnswer((_) {
              when(device.state).thenReturn(UPowerDeviceState.pendingCharge);
              return Stream.value(['State']);
            });
            return client;
          };

        expect(
          battery.onBatteryStateChanged,
          emitsInOrder([
            BatteryState.charging,
            BatteryState.connectedNotCharging,
          ]),
        );
      });

      test(
          'delivers the initial state to every concurrent listener on the stream',
          () async {
        final battery = BatteryPlusLinuxPlugin()
          ..createClient = () {
            final client = createMockClient(state: UPowerDeviceState.pendingCharge);
            final device = client.displayDevice;
            when(device.propertiesChanged)
                .thenAnswer((_) => const Stream<List<String>>.empty());
            return client;
          };

        final receivedByFirst = <BatteryState>[];
        final receivedBySecond = <BatteryState>[];
        // A single broadcast stream must fan out to several listeners.
        final stream = battery.onBatteryStateChanged;
        stream.listen(receivedByFirst.add);
        stream.listen(receivedBySecond.add);

        // Let the async `_startListenState` run and emit the initial state.
        await Future<void>.delayed(Duration.zero);

        expect(receivedByFirst, [BatteryState.connectedNotCharging]);
        expect(receivedBySecond, [BatteryState.connectedNotCharging]);
      });
    });
  });
}

/// Builds a fully stubbed [MockUPowerClient] for a single battery read.
///
/// [percentage] and [state] configure the reported display device values, while
/// [connectError] (when provided) makes the mocked `connect()` future complete
/// with an error so failure paths can be exercised.
MockUPowerClient createMockClient({
  double? percentage,
  UPowerDeviceState? state,
  Object? connectError,
}) {
  final device = MockUPowerDevice();
  if (percentage != null) {
    when(device.percentage).thenReturn(percentage);
  }
  if (state != null) {
    when(device.state).thenReturn(state);
  }

  final client = MockUPowerClient();
  when(client.displayDevice).thenReturn(device);
  if (connectError != null) {
    when(client.connect())
        .thenAnswer((_) => Future<void>.error(connectError));
  }
  return client;
}
