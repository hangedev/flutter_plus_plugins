// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Demonstrates the complete documented API surface of `package_info_plus`
/// (see README.OpenHarmony.md §3 API / §4 Properties).
///
/// The example page already renders most properties as tiles; this demo
/// additionally exercises the `data` map representation, value equality,
/// `hashCode` and `toString`, which are not shown in the UI. Results are
/// written to the debug log only — nothing is rendered on screen.
class PackageInfoApiDemo {
  const PackageInfoApiDemo();

  /// Runs the demo. Every call goes through `PackageInfo.fromPlatform`,
  /// whose result is cached, so repeated runs are cheap.
  Future<void> run() async {
    final info = await PackageInfo.fromPlatform();

    // §3 API: fromPlatform (retrieves and caches platform data).
    final cached = await PackageInfo.fromPlatform();

    // §4 Properties.
    debugPrint('PackageInfoApiDemo.appName: ${info.appName}');
    debugPrint('PackageInfoApiDemo.packageName: ${info.packageName}');
    debugPrint('PackageInfoApiDemo.version: ${info.version}');
    debugPrint('PackageInfoApiDemo.buildNumber: ${info.buildNumber}');
    debugPrint('PackageInfoApiDemo.buildSignature: ${info.buildSignature}');
    debugPrint(
      'PackageInfoApiDemo.installerStore: '
      '${info.installerStore ?? 'not available'}',
    );
    debugPrint(
      'PackageInfoApiDemo.installTime: '
      "${info.installTime?.toIso8601String() ?? 'not available'}",
    );
    debugPrint(
      'PackageInfoApiDemo.updateTime: '
      "${info.updateTime?.toIso8601String() ?? 'not available'}",
    );

    // Map representation — the only documented property the example page
    // does not display. Optional fields are omitted when empty or null.
    debugPrint('PackageInfoApiDemo.data: ${info.data}');
    debugPrint(
      'PackageInfoApiDemo.data keys: ${info.data.keys.toList().join(', ')}',
    );

    // Value equality, caching and debugging helpers.
    debugPrint('PackageInfoApiDemo.cached equals: ${info == cached}');
    debugPrint('PackageInfoApiDemo.hashCode: ${info.hashCode}');
    debugPrint('PackageInfoApiDemo.toString: $info');
  }
}
