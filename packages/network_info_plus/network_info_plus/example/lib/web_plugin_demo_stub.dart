// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

/// No-op stand-in for the web-plugin demo on non-browser platforms.
///
/// `NetworkInfoPlusWebPlugin` lives in `src/network_info_plus_web.dart`, which
/// imports `flutter_web_plugins` (and transitively `dart:ui_web`) and can
/// therefore only be compiled for the browser. `network_info_demo.dart`
/// conditionally imports this stub everywhere else, keeping the demo
/// compilable on iOS/Android/OHOS/desktop while the browser build gets the
/// real implementation in `web_plugin_demo_web.dart`.
Future<void> runWebPluginDemo(StringBuffer log) async {
  log.writeln('--- NetworkInfoPlusWebPlugin ---');
  log.writeln('skipped: web implementation only compiles for the browser');
}
