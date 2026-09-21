// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Non-web (io) side of the conditional import used by
/// `battery_demo_coverage.dart` to reference `BatteryPlusWebPlugin`.
///
/// `package:battery_plus/src/battery_plus_web.dart` transitively imports
/// `package:web`, which only compiles for browser targets — importing it
/// directly would break the Android/ohos/desktop builds of the example.
/// This stub exposes the same symbols so the demo file compiles everywhere;
/// on web builds the conditional import swaps in the real implementation.
library;

import 'dart:async';

import 'package:battery_plus/battery_plus.dart' show BatteryState;

/// Stand-in for `flutter_web_plugins.Registrar` on non-web builds.
class Registrar {}

/// Stand-in for the web plugin on non-web builds.
///
/// Mirrors the graceful-degradation behavior of the real implementation
/// when the browser Battery Status API is unavailable.
class BatteryPlusWebPlugin {
  /// Constructs a stub instance (no-op on non-web builds).
  BatteryPlusWebPlugin();

  /// No-op registration on non-web builds.
  static void registerWith(Registrar registrar) {}

  /// Always reports an empty battery on non-web builds.
  Future<int> get batteryLevel async => 0;

  /// Always reports an unknown state on non-web builds.
  Future<BatteryState> get batteryState async => BatteryState.unknown;

  /// Emits nothing on non-web builds.
  Stream<BatteryState> get onBatteryStateChanged => const Stream.empty();
}
