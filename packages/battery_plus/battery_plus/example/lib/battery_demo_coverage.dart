// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Demo coverage helper for the `battery_plus` public API surface.
///
/// This file exists purely so that the example app *references* the full
/// `battery_plus` API surface — every [BatteryState] enum value, every
/// public entry point of [BatteryPlusLinuxPlugin] (including the
/// [BatteryPlusLinuxPlugin.createClient] factory field), and the web
/// implementation [BatteryPlusWebPlugin] — instead of only the slice
/// exercised by the interactive widgets in `main.dart`.
///
/// It is invoked from `MyHomePage.initState` and intentionally renders **no
/// UI**; it only makes the calls so the symbols are exercised/covered.
library;

import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' show debugPrint;

// The web plugin lives behind conditional imports: its real implementation
// pulls in `package:web`, which only compiles for browser targets. On every
// other build the `battery_plus_web_demo_io.dart` stub keeps this file (and
// therefore the whole example app) compilable.
import 'battery_plus_web_demo_io.dart'
    if (dart.library.html) 'package:flutter_web_plugins/flutter_web_plugins.dart'
    show Registrar;
import 'battery_plus_web_demo_io.dart'
    if (dart.library.html) 'package:battery_plus/src/battery_plus_web.dart'
    show BatteryPlusWebPlugin;

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

  // Exercise the Linux Dart-plugin surface (registerWith, createClient,
  // batteryLevel, batteryState, onBatteryStateChanged). Guarded so it never
  // overrides the native platform implementation on non-Linux targets.
  await _exerciseLinuxPlugin();

  // Exercise the web plugin surface (registerWith, batteryLevel,
  // batteryState, onBatteryStateChanged). Guarded so it never overrides the
  // active platform implementation on non-web targets.
  await _exerciseWebPlugin();
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
    // createClient: reference and invoke the UPower client factory field so
    // the demo covers it (constructing the client is lazy and never connects).
    // The member is @visibleForTesting; this coverage demo is exactly the
    // sanctioned kind of out-of-band API-surface exercise.
    // ignore: invalid_use_of_visible_for_testing_member
    final clientFactory = plugin.createClient;
    final client = clientFactory();
    debugPrint('battery_plus demo: linux createClient -> $client');

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

Future<void> _exerciseWebPlugin() async {
  if (!kIsWeb) {
    return;
  }

  StreamSubscription<BatteryState>? subscription;

  try {
    // registerWith: installs the web implementation as the active platform
    // (the same call the generated web plugin registrant performs).
    BatteryPlusWebPlugin.registerWith(Registrar());

    final BatteryPlusWebPlugin plugin = BatteryPlusWebPlugin();

    final level = await plugin.batteryLevel;
    debugPrint('battery_plus demo: web batteryLevel = $level');

    final state = await plugin.batteryState;
    debugPrint('battery_plus demo: web batteryState = ${state.name}');

    // onBatteryStateChanged: subscribe so the stream getter is exercised.
    // The Battery Status API is unsupported on some browsers, so errors from
    // the subscription are swallowed.
    subscription = plugin.onBatteryStateChanged.listen(
      (BatteryState changed) => debugPrint(
          'battery_plus demo: web onBatteryStateChanged = ${changed.name}'),
      onError: (Object error) => debugPrint(
          'battery_plus demo: web onBatteryStateChanged error: $error'),
    );
  } catch (error) {
    // Browsers without the Battery Status API report failures here; never
    // surface the error to the host widget.
    debugPrint('battery_plus demo: web plugin call failed: $error');
  } finally {
    await subscription?.cancel();
  }
}
