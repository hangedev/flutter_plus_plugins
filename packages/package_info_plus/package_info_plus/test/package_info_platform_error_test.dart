// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Error-path scenarios for PackageInfo.fromPlatform. Runs in its own
// isolate so the static cache starts empty and every test observes the
// channel failure first-hand.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('dev.fluttercommunity.plus/package_info');

  tearDown(() {
    // Remove any handler installed by a test so the next one starts from
    // a clean channel state.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('PackageInfo.fromPlatform error scenarios', () {
    test(
        'should throw MissingPluginException when no native '
        'implementation answers', () async {
      // No mock handler installed: simulates a platform without a
      // package_info implementation.
      await expectLater(
        PackageInfo.fromPlatform(),
        throwsA(isA<MissingPluginException>()),
      );
    }, onPlatform: {
      'linux':
          const Skip('PackageInfoPlus on Linux does not use platform channels'),
    });

    test('should propagate a PlatformException raised by the native side',
        () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async => throw PlatformException(
            code: 'unavailable', message: 'bundle info missing'),
      );

      await expectLater(
        PackageInfo.fromPlatform(),
        throwsA(
          isA<PlatformException>().having(
            (e) => e.code,
            'code',
            'unavailable',
          ),
        ),
      );
    }, onPlatform: {
      'linux':
          const Skip('PackageInfoPlus on Linux does not use platform channels'),
    });
  });
}
