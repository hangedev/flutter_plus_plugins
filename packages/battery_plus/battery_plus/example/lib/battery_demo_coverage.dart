// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Demo coverage helper for the `battery_plus` public API surface.
///
/// This file exists purely so that the example app *references* the full
/// `battery_plus` API surface — every [BatteryState] enum value and every
/// public entry point of [BatteryPlusLinuxPlugin] — instead of only the slice
/// exercised by the interactive widgets in `main.dart`.
///
/// It is invoked from `MyHomePage.initState` and intentionally renders **no
/// UI**; it only makes the calls so the symbols are exercised/covered.
library;

import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' show debugPrint;

/// Whether the Linux Dart plugin can be driven on the current platform.
///
/// `registerWith()` replaces the active platform implementation, so it must not
/// run on other platforms (e.g. the ohos native plugin) where it would disrupt
/// the real battery backend.
bool get _canRunLinuxPlugin =>
    !kIsWeb && bool.fromEnvironment('dart.platform.is_linux');

/// Every [BatteryState] value, referenced explicitly so the demo covers the
/// full enum surface (including the platform-specific
/// [BatteryState.connectedNotCharging]).
const List<BatteryState> demoBatteryStates = <BatteryState>[
  BatteryState.full,
  BatteryState.charging,
  BatteryState.connectedNotCharging,
  BatteryState.discharging,
  BatteryState.unknown,
];

/// Runs the demo coverage for the `battery_plus` API.
///
/// Calls are best-effort and never throw into the host widget: any failure is
/// swallowed and logged, so this can be safely invoked from `initState`
/// without affecting the running example app.
Future<void> runBatteryDemoCoverage() async {
  // Reference every BatteryState value explicitly.
  for (final state in demoBatteryStates) {
    debugPrint('battery_plus demo: enum ${state.name}');
  }

  // Exercise the Linux Dart-plugin surface (registerWith, batteryLevel,
  // batteryState, onBatteryStateChanged). Guarded so it never overrides the
  // native platform implementation on non-Linux targets.
  await _exerciseLinuxPlugin();
}

Future<void> _exerciseLinuxPlugin() async {
  if (!_canRunLinuxPlugin) {
    return;
  }

  // registerWith: installs the Linux implementation as the active platform.
  BatteryPlusLinuxPlugin.registerWith();

  final plugin = BatteryPlusLinuxPlugin();
  StreamSubscription<BatteryState>? subscription;

  try {
    final level = await plugin.batteryLevel;
    debugPrint('battery_plus demo: linux batteryLevel = $level');

    final state = await plugin.batteryState;
    debugPrint('battery_plus demo: linux batteryState = ${state.name}');

    // onBatteryStateChanged: subscribe so the stream getter is exercised.
    subscription = plugin.onBatteryStateChanged.listen(
      (BatteryState changed) =>
          debugPrint('battery_plus demo: linux onBatteryStateChanged = '
              '${changed.name}'),
    );
  } catch (error) {
    // Even on Linux the UPower daemon may be unavailable; never surface the
    // error to the host widget.
    debugPrint('battery_plus demo: linux plugin call failed: $error');
  } finally {
    await subscription?.cancel();
  }
}
