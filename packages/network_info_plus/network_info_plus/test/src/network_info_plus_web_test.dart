// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Web is the only platform where `flutter_web_plugins` (and thus `dart:ui_web`)
// is available, so the Web plugin source can only be compiled for the browser.
@TestOn('browser')
library network_info_plus_web_test;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:mockito/mockito.dart';
import 'package:network_info_plus/src/network_info_plus_web.dart';
import 'package:network_info_plus_platform_interface/network_info_plus_platform_interface.dart';

void main() {
  group('NetworkInfoPlusWebPlugin', () {
    test('should install the Web implementation as the platform instance',
        () {
      final previous = NetworkInfoPlatform.instance;
      NetworkInfoPlusWebPlugin.registerWith(_MockRegistrar());
      try {
        expect(
          NetworkInfoPlatform.instance,
          isA<NetworkInfoPlusWebPlugin>(),
        );
      } finally {
        // Restore the previous instance so other tests are unaffected.
        NetworkInfoPlatform.instance = previous;
      }
    });

    group('unsupported getters throw UnsupportedError - ', () {
      late NetworkInfoPlusWebPlugin plugin;
      setUp(() {
        plugin = NetworkInfoPlusWebPlugin();
      });

      test('should throw UnsupportedError for getWifiName', () {
        expect(plugin.getWifiName(), throwsUnsupportedError);
      });

      test('should throw UnsupportedError for getWifiBSSID', () {
        expect(plugin.getWifiBSSID(), throwsUnsupportedError);
      });

      test('should throw UnsupportedError for getWifiIP', () {
        expect(plugin.getWifiIP(), throwsUnsupportedError);
      });
    });

    group('error messages name the unsupported method - ', () {
      late NetworkInfoPlusWebPlugin plugin;
      setUp(() {
        plugin = NetworkInfoPlusWebPlugin();
      });

      test('should name getWifiName in the UnsupportedError message', () async {
        Object? caught;
        try {
          await plugin.getWifiName();
        } catch (e) {
          caught = e;
        }
        expect(caught, isUnsupportedError);
        expect(caught.toString(), contains('getWifiName'));
      });

      test('should name getWifiBSSID in the UnsupportedError message', () async {
        Object? caught;
        try {
          await plugin.getWifiBSSID();
        } catch (e) {
          caught = e;
        }
        expect(caught, isUnsupportedError);
        expect(caught.toString(), contains('getWifiBSSID'));
      });

      test('should name getWifiIP in the UnsupportedError message', () async {
        Object? caught;
        try {
          await plugin.getWifiIP();
        } catch (e) {
          caught = e;
        }
        expect(caught, isUnsupportedError);
        expect(caught.toString(), contains('getWifiIP'));
      });
    });
  });
}

/// A Mockito mock of the web [Registrar]. `registerWith` only uses the argument
/// to set the singleton; it never calls through the messenger, so an empty mock
/// is sufficient to exercise the registration path.
class _MockRegistrar extends Mock implements Registrar {}
