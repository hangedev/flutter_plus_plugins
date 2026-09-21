// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('browser')
library;

import 'package:battery_plus/src/battery_plus_web.dart';
import 'package:battery_plus_platform_interface/battery_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// Tests for the web implementation of [BatteryPlatform].
///
/// On the Dart VM there is no Battery Status API, so every JS interop call
/// inside [BatteryPlusWebPlugin._getBatteryManager] throws and is swallowed
/// by its catch-all handler (`null` is returned). The plugin is expected to
/// degrade gracefully and deterministically: level `0`, state `unknown`.
/// These tests pin down exactly that contract.
void main() {
  group('BatteryPlusWebPlugin', () {
    test('registerWith installs the web implementation as platform instance',
        () {
      final BatteryPlatform previousPlatform = BatteryPlatform.instance;
      addTearDown(() {
        BatteryPlatform.instance = previousPlatform;
      });

      BatteryPlusWebPlugin.registerWith(Registrar());

      expect(BatteryPlatform.instance, isA<BatteryPlusWebPlugin>());
    });

    test('batteryLevel degrades to 0 without the Battery Status API',
        () async {
      final BatteryPlusWebPlugin plugin = BatteryPlusWebPlugin();

      expect(await plugin.batteryLevel, 0);
    });

    test('batteryState degrades to unknown without the Battery Status API',
        () async {
      final BatteryPlusWebPlugin plugin = BatteryPlusWebPlugin();

      expect(await plugin.batteryState, BatteryState.unknown);
    });

    test('onBatteryStateChanged emits unknown without the Battery Status API',
        () async {
      final BatteryPlusWebPlugin plugin = BatteryPlusWebPlugin();

      expect(
        await plugin.onBatteryStateChanged.first,
        BatteryState.unknown,
      );
    });
  });
}
