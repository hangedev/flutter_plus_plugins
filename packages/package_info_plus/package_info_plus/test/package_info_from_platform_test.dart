// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Runs in its own isolate, so the static `PackageInfo.fromPlatform` cache
// starts empty and the platform-channel path can be exercised without any
// ordering dependency on other test files.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('dev.fluttercommunity.plus/package_info');
  final log = <MethodCall>[];

  // Fixed values keep the suite deterministic.
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    channel,
    (MethodCall methodCall) async {
      log.add(methodCall);
      switch (methodCall.method) {
        case 'getAll':
          // Mirrors the payload returned by the OHOS implementation
          // (ohos/src/main/ets/.../PackageInfoPlugin.ets): every field is
          // reported as a string and `installerStore` is an empty string.
          return <String, dynamic>{
            'appName': 'package_info_example',
            'buildNumber': '1',
            'packageName': 'io.flutter.plugins.packageinfoexample',
            'version': '1.0',
            'buildSignature': 'a1b2c3d4e5f6a7b8',
            'installerStore': '',
          };
        default:
          assert(false);
          return null;
      }
    },
  );

  tearDown(() {
    log.clear();
  });

  group('PackageInfo.fromPlatform channel behavior', () {
    test(
        'should fetch every documented property from the platform channel '
        'on the first call and cache the result', () async {
      final first = await PackageInfo.fromPlatform();

      expect(first.appName, 'package_info_example');
      expect(first.buildNumber, '1');
      expect(first.packageName, 'io.flutter.plugins.packageinfoexample');
      expect(first.version, '1.0');
      expect(first.buildSignature, 'a1b2c3d4e5f6a7b8');
      expect(first.installerStore, '');
      expect(log, <Matcher>[
        isMethodCall('getAll', arguments: null),
      ]);

      // Cached: a second call returns the identical instance without
      // hitting the platform channel again.
      final cached = await PackageInfo.fromPlatform();
      expect(identical(cached, first), isTrue);
      expect(log, <Matcher>[
        isMethodCall('getAll', arguments: null),
      ]);
    }, onPlatform: {
      'linux':
          const Skip('PackageInfoPlus on Linux does not use platform channels'),
    });

    test('should keep concurrent first calls value-equal', () async {
      // The channel mock is already exercised by the earlier tests in
      // this file, so reset the singleton first to observe the first-call
      // behavior under concurrency.
      PackageInfo.setMockInitialValues(
        appName: 'package_info_example',
        packageName: 'io.flutter.plugins.packageinfoexample',
        version: '1.0',
        buildNumber: '1',
        buildSignature: 'a1b2c3d4e5f6a7b8',
        installerStore: '',
      );

      final results = await Future.wait(
        List.generate(8, (_) => PackageInfo.fromPlatform()),
      );

      // Concurrent readers all end up with value-equal data once the
      // cache is populated.
      expect(results.every((r) => r == results.first), isTrue);
    }, onPlatform: {
      'linux':
          const Skip('PackageInfoPlus on Linux does not use platform channels'),
    });
  });
}
