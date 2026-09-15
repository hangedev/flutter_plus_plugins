// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

// The package barrel cannot be imported on web (it unconditionally exports
// the Linux/D-Bus implementation, which needs dart:io), so the web plugin is
// imported directly from src.
// ignore: implementation_imports
import 'package:network_info_plus/src/network_info_plus_web.dart';

/// Demonstrates every public member of `NetworkInfoPlusWebPlugin`.
///
/// All three getters throw [UnsupportedError] by design — the web platform
/// cannot read wifi details — so the demo surfaces those errors as logged
/// values. This documents the expected behavior for web builds of the
/// example and exercises the error path of each getter.
Future<void> runWebPluginDemo(StringBuffer log) async {
  log.writeln('--- NetworkInfoPlusWebPlugin ---');
  final webPlugin = NetworkInfoPlusWebPlugin();

  log.writeln('getWifiName: ${await _read(webPlugin.getWifiName)}');
  log.writeln('getWifiBSSID: ${await _read(webPlugin.getWifiBSSID)}');
  log.writeln('getWifiIP: ${await _read(webPlugin.getWifiIP)}');
}

/// Invokes [getter], returning its value or a readable rendering of the
/// thrown error (the expected outcome for the web getters).
Future<String> _read(Future<String?> Function() getter) async {
  try {
    return await getter() ?? '<null>';
  } catch (e) {
    return e.toString();
  }
}
