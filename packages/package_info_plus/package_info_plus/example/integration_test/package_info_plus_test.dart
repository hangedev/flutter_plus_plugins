// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:package_info_plus_example/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('fromPlatform', (WidgetTester tester) async {
    final info = await PackageInfo.fromPlatform();
    // These tests are based on the example app. The tests should be updated if any related info changes.
    if (kIsWeb) {
      expect(info.appName, 'package_info_plus_example');
      expect(info.buildNumber, '4');
      expect(info.buildSignature, isEmpty);
      expect(info.packageName, 'package_info_plus_example');
      expect(info.version, '1.2.3');
      expect(info.installerStore, null);
    } else {
      if (Platform.isAndroid) {
        expect(info.appName, 'package_info_example');
        expect(info.buildNumber, '4');
        expect(info.buildSignature, isNotEmpty);
        expect(info.packageName, 'io.flutter.plugins.packageinfoexample');
        expect(info.version, '1.2.3');
        // Since Android 14 (API 34) OS returns com.android.shell when app is
        // installed via package installer; older versions report null.
        expect(info.installerStore, anyOf(isNull, 'com.android.shell'));
      } else if (Platform.isIOS) {
        expect(info.appName, 'Package Info Plus Example');
        expect(info.buildNumber, '4');
        expect(info.buildSignature, isEmpty);
        expect(info.packageName, 'io.flutter.plugins.packageInfoExample');
        expect(info.version, '1.2.3');
        expect(info.installerStore, 'com.apple.simulator');
      } else if (Platform.isMacOS) {
        expect(info.appName, 'Package Info Plus Example');
        expect(info.buildNumber, '4');
        expect(info.buildSignature, isEmpty);
        expect(info.packageName, 'io.flutter.plugins.packageInfoExample');
        expect(info.version, '1.2.3');
        expect(info.installerStore, null);
      } else if (Platform.isLinux) {
        expect(info.appName, 'package_info_plus_example');
        expect(info.buildNumber, '4');
        expect(info.buildSignature, isEmpty);
        expect(info.packageName, 'package_info_plus_example');
        expect(info.version, '1.2.3');
      } else if (Platform.isWindows) {
        expect(info.appName, 'example');
        expect(info.buildNumber, '4');
        expect(info.buildSignature, isEmpty);
        expect(info.packageName, 'example');
        expect(info.version, '1.2.3');
        expect(info.installerStore, null);
      } else {
        // OpenHarmony: the OHOS runner reports none of the stock platform
        // flags above. Values come from the OHOS implementation, based on
        // example/ohos/AppScope/app.json5 (label "example", bundleName
        // "io.flutter.plugins.example", versionName "1.2.3", versionCode 4).
        expect(info.appName, 'example');
        expect(info.buildNumber, '4');
        expect(info.buildSignature, isNotEmpty); // signing certificate fingerprint
        expect(info.packageName, 'io.flutter.plugins.example');
        expect(info.version, '1.2.3');
        // The OHOS implementation reports no store information: the key
        // is either absent (null) or an empty string on the Dart side,
        // depending on the plugin har build.
        expect(info.installerStore, anyOf(isNull, ''));
      }
    }
  });

  testWidgets('example', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    if (kIsWeb) {
      expect(find.text('package_info_plus_example'), findsNWidgets(2));
      expect(find.text('1.2.3'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('Not set'), findsOneWidget);
      expect(find.text('not available'), findsOneWidget);
    } else {
      if (Platform.isAndroid) {
        expect(find.text('package_info_example'), findsOneWidget);
        expect(find.text('4'), findsOneWidget);
        expect(
          find.text('io.flutter.plugins.packageinfoexample'),
          findsOneWidget,
        );
        expect(find.text('1.2.3'), findsOneWidget);
        expect(find.text('Not set'), findsNothing);
        // Since Android 14 (API 34) OS returns com.android.shell when app is
        // installed via package installer; older versions report null, which
        // the tile renders as the fallback text.
        final storeTile = find.text('com.android.shell').evaluate().isNotEmpty
            ? find.text('com.android.shell')
            : find.text('not available');
        expect(storeTile, findsOneWidget);
      } else if (Platform.isIOS) {
        expect(find.text('Package Info Plus Example'), findsOneWidget);
        expect(find.text('4'), findsOneWidget);
        expect(
            find.text('io.flutter.plugins.packageInfoExample'), findsOneWidget);
        expect(find.text('1.2.3'), findsOneWidget);
        expect(find.text('Not set'), findsOneWidget);
        expect(find.text('com.apple.simulator'), findsOneWidget);
      } else if (Platform.isMacOS) {
        expect(find.text('Package Info Plus Example'), findsOneWidget);
        expect(find.text('4'), findsOneWidget);
        expect(
            find.text('io.flutter.plugins.packageInfoExample'), findsOneWidget);
        expect(find.text('1.2.3'), findsOneWidget);
        expect(find.text('Not set'), findsOneWidget);
        expect(find.text('not available'), findsOneWidget);
      } else if (Platform.isLinux) {
        expect(find.text('package_info_plus_example'), findsNWidgets(2));
        expect(find.text('1.2.3'), findsOneWidget);
        expect(find.text('4'), findsOneWidget);
        expect(find.text('Not set'), findsOneWidget);
      } else if (Platform.isWindows) {
        expect(find.text('example'), findsNWidgets(2));
        expect(find.text('1.2.3'), findsOneWidget);
        expect(find.text('4'), findsOneWidget);
        expect(find.text('Not set'), findsOneWidget);
        expect(find.text('not available'), findsOneWidget);
      } else {
        // OpenHarmony: mirrors the OHOS branch of the fromPlatform test
        // above (label "example", bundleName "io.flutter.plugins.example").
        expect(find.text('example'), findsOneWidget);
        expect(find.text('4'), findsOneWidget);
        expect(find.text('io.flutter.plugins.example'), findsOneWidget);
        expect(find.text('1.2.3'), findsOneWidget);
        // Every version field is populated on OHOS. Only the installer
        // store tile falls back: 'not available' when the key is absent
        // (null), 'Not set' for the empty-string store.
        final storeFallback = find.text('not available').evaluate().isNotEmpty
            ? find.text('not available')
            : find.text('Not set');
        expect(storeFallback, findsOneWidget);
      }
    }
  });
}
