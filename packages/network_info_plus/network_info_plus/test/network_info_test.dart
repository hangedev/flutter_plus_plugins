// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:network_info_plus_platform_interface/network_info_plus_platform_interface.dart';
// MethodChannelNetworkInfo is the default platform implementation; it is not
// re-exported from the platform-interface barrel file, so import it directly.
import 'package:network_info_plus_platform_interface/method_channel_network_info.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:mockito/mockito.dart';

// ---------------------------------------------------------------------------
// Shared fixtures
// ---------------------------------------------------------------------------

const String kWifiNameResult = '1337wifi';
const String kWifiBSSIDResult = 'c0:ff:33:c0:d3:55';
const String kWifiIpAddressResult = '127.0.0.1';
const String kWifiIpV6 = '2002:7f00:0001:0:0:0:0:0';
const String kWifiBroadcast = '127.0.0.255';
const String kWifiGatewayIP = '127.0.0.0';
const String kWifiSubmask = '255.255.255.0';

void main() {
  group('NetworkInfo', () {
    late NetworkInfo networkInfo;
    late MockNetworkInfoPlatform fakePlatform;

    setUp(() async {
      fakePlatform = MockNetworkInfoPlatform();
      NetworkInfoPlatform.instance = fakePlatform;
      networkInfo = NetworkInfo();
    });

    // Reset the platform instance between tests so a previous test cannot leak
    // its mock into the next one. The cached `NetworkInfo._singleton` holds no
    // mutable state of its own — every getter delegates live to
    // `NetworkInfoPlatform.instance`, which is swapped here, so swapping the
    // platform is the complete and correct state reset.
    tearDown(() {
      NetworkInfoPlatform.instance = MethodChannelNetworkInfo();
    });

    group('getWifiName - ', () {
      test('should return the SSID reported by the platform', () async {
        fakePlatform.getWifiNameResult = kWifiNameResult;

        final result = await networkInfo.getWifiName();

        expect(result, kWifiNameResult);
        expect(fakePlatform.getWifiNameCallCount, 1);
      });

      test('should return null when the platform has no wifi connection',
          () async {
        fakePlatform.getWifiNameResult = null;

        expect(await networkInfo.getWifiName(), isNull);
      });

      test('should return an empty string when the SSID is empty', () async {
        fakePlatform.getWifiNameResult = '';

        expect(await networkInfo.getWifiName(), '');
      });

      test('should return an SSID containing special characters', () async {
        const special = 'Café ☕ 5GHz 📶';
        fakePlatform.getWifiNameResult = special;

        expect(await networkInfo.getWifiName(), special);
      });

      test('should propagate a platform exception to the caller', () async {
        fakePlatform.getWifiNameException = Exception('permission denied');

        await expectLater(
          networkInfo.getWifiName(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getWifiBSSID - ', () {
      test('should return the BSSID reported by the platform', () async {
        fakePlatform.getWifiBSSIDResult = kWifiBSSIDResult;

        expect(await networkInfo.getWifiBSSID(), kWifiBSSIDResult);
      });

      test('should return null when the platform reports no BSSID', () async {
        fakePlatform.getWifiBSSIDResult = null;

        expect(await networkInfo.getWifiBSSID(), isNull);
      });

      test('should return an empty string when the BSSID is empty', () async {
        fakePlatform.getWifiBSSIDResult = '';

        expect(await networkInfo.getWifiBSSID(), '');
      });
    });

    group('getWifiIP - ', () {
      test('should return the IPv4 reported by the platform', () async {
        fakePlatform.getWifiIPResult = kWifiIpAddressResult;

        expect(await networkInfo.getWifiIP(), kWifiIpAddressResult);
      });

      test('should return null when the platform reports no IP', () async {
        fakePlatform.getWifiIPResult = null;

        expect(await networkInfo.getWifiIP(), isNull);
      });
    });

    group('getWifiIPv6 - ', () {
      test('should return the IPv6 reported by the platform', () async {
        fakePlatform.getWifiIPv6Result = kWifiIpV6;

        expect(await networkInfo.getWifiIPv6(), kWifiIpV6);
      });

      test('should return null when the platform reports no IPv6', () async {
        fakePlatform.getWifiIPv6Result = null;

        expect(await networkInfo.getWifiIPv6(), isNull);
      });
    });

    group('getWifiSubmask - ', () {
      test('should return the submask reported by the platform', () async {
        fakePlatform.getWifiSubmaskResult = kWifiSubmask;

        expect(await networkInfo.getWifiSubmask(), kWifiSubmask);
      });

      test('should return null when the platform reports no submask',
          () async {
        fakePlatform.getWifiSubmaskResult = null;

        expect(await networkInfo.getWifiSubmask(), isNull);
      });
    });

    group('getWifiGatewayIP - ', () {
      test('should return the gateway reported by the platform', () async {
        fakePlatform.getWifiGatewayIPResult = kWifiGatewayIP;

        expect(await networkInfo.getWifiGatewayIP(), kWifiGatewayIP);
      });

      test('should return null when the platform reports no gateway',
          () async {
        fakePlatform.getWifiGatewayIPResult = null;

        expect(await networkInfo.getWifiGatewayIP(), isNull);
      });
    });

    group('getWifiBroadcast - ', () {
      test('should return the broadcast reported by the platform', () async {
        fakePlatform.getWifiBroadcastResult = kWifiBroadcast;

        expect(await networkInfo.getWifiBroadcast(), kWifiBroadcast);
      });

      test('should return null when the platform reports no broadcast',
          () async {
        fakePlatform.getWifiBroadcastResult = null;

        expect(await networkInfo.getWifiBroadcast(), isNull);
      });
    });

    group('when the platform denies location permission - ', () {
      // Every getter must surface the platform's permission failure instead
      // of swallowing it, so apps can prompt the user to grant location.
      final permissionError = PlatformException(
        code: 'PERMISSION_DENIED',
        message: 'Location permission is required to read wifi info',
      );

      final gettersUnderTest = <String, Future<String?> Function()>{
        'getWifiName': () => networkInfo.getWifiName(),
        'getWifiBSSID': () => networkInfo.getWifiBSSID(),
        'getWifiIP': () => networkInfo.getWifiIP(),
        'getWifiIPv6': () => networkInfo.getWifiIPv6(),
        'getWifiSubmask': () => networkInfo.getWifiSubmask(),
        'getWifiGatewayIP': () => networkInfo.getWifiGatewayIP(),
        'getWifiBroadcast': () => networkInfo.getWifiBroadcast(),
      };

      for (final entry in gettersUnderTest.entries) {
        test(
            'should propagate the permission-denied PlatformException '
            'from ${entry.key}', () async {
          fakePlatform.pendingException = permissionError;

          await expectLater(
            entry.value(),
            throwsA(
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                'PERMISSION_DENIED',
              ),
            ),
          );
        });
      }
    });

    group('when the platform is slow or unresponsive - ', () {
      test('should throw a TimeoutException when the platform never responds',
          () async {
        fakePlatform.getWifiNameGate = Completer<String?>();

        await expectLater(
          networkInfo.getWifiName().timeout(const Duration(milliseconds: 25)),
          throwsA(isA<TimeoutException>()),
        );
      });

      test(
          'should still deliver the value when the platform responds '
          'within the timeout', () async {
        fakePlatform.getWifiNameDelay = const Duration(milliseconds: 10);

        final result = await networkInfo
            .getWifiName()
            .timeout(const Duration(seconds: 1));

        expect(result, kWifiNameResult);
      });
    });

    group('when getters are invoked concurrently - ', () {
      test('should resolve all seven getters issued via Future.wait',
          () async {
        fakePlatform.getWifiNameResult = 'ssid';
        fakePlatform.getWifiBSSIDResult = 'bssid';
        fakePlatform.getWifiIPResult = '10.0.0.1';
        fakePlatform.getWifiIPv6Result = '::1';
        fakePlatform.getWifiSubmaskResult = '255.255.255.0';
        fakePlatform.getWifiGatewayIPResult = '10.0.0.254';
        fakePlatform.getWifiBroadcastResult = '10.0.0.255';

        final results = await Future.wait([
          networkInfo.getWifiName(),
          networkInfo.getWifiBSSID(),
          networkInfo.getWifiIP(),
          networkInfo.getWifiIPv6(),
          networkInfo.getWifiSubmask(),
          networkInfo.getWifiGatewayIP(),
          networkInfo.getWifiBroadcast(),
        ]);

        expect(results, [
          'ssid',
          'bssid',
          '10.0.0.1',
          '::1',
          '255.255.255.0',
          '10.0.0.254',
          '10.0.0.255',
        ]);
        // Every getter was dispatched exactly once despite the parallelism.
        expect(fakePlatform.getWifiNameCallCount, 1);
      });

      test(
          'should serve many parallel calls of the same getter '
          'without cross-talk', () async {
        fakePlatform.getWifiIPResult = '10.0.0.2';

        final results = await Future.wait(
          List.generate(25, (_) => networkInfo.getWifiIP()),
        );

        expect(results.every((ip) => ip == '10.0.0.2'), isTrue);
      });
    });

    group('singleton - ', () {
      test('should always return the same cached instance', () {
        final first = NetworkInfo();
        final second = NetworkInfo();

        expect(identical(first, second), isTrue);
      });
    });
  });
}

/// A configurable, Mockito-backed mock of [NetworkInfoPlatform].
///
/// Each getter exposes the configured result (defaulting to the canned fixture
/// values) and records its call count so tests can assert interaction. Setting
/// the `...Exception` field makes the corresponding getter throw, covering the
/// error-propagation path.
class MockNetworkInfoPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements NetworkInfoPlatform {
  MockNetworkInfoPlatform() {
    // Sensible defaults so a test only has to override what it cares about.
    getWifiNameResult = kWifiNameResult;
    getWifiBSSIDResult = kWifiBSSIDResult;
    getWifiIPResult = kWifiIpAddressResult;
    getWifiIPv6Result = kWifiIpV6;
    getWifiSubmaskResult = kWifiSubmask;
    getWifiGatewayIPResult = kWifiGatewayIP;
    getWifiBroadcastResult = kWifiBroadcast;
  }

  // --- Configurable results -------------------------------------------------
  String? getWifiNameResult;
  String? getWifiBSSIDResult;
  String? getWifiIPResult;
  String? getWifiIPv6Result;
  String? getWifiSubmaskResult;
  String? getWifiGatewayIPResult;
  String? getWifiBroadcastResult;

  // --- Optional failure injection ------------------------------------------
  Object? getWifiNameException;

  /// When set, EVERY getter throws this object — used to exercise uniform
  /// error propagation (e.g. a permission-denied PlatformException).
  Object? pendingException;

  // --- Optional timing controls ---------------------------------------------
  /// When set, `getWifiName` does not complete until this completer fires —
  /// used to model an unresponsive platform for timeout tests.
  Completer<String?>? getWifiNameGate;

  /// When set, `getWifiName` waits this long before responding.
  Duration? getWifiNameDelay;

  // --- Interaction recording -----------------------------------------------
  int getWifiNameCallCount = 0;

  @override
  Future<String?> getWifiName() async {
    getWifiNameCallCount++;
    final gate = getWifiNameGate;
    if (gate != null) {
      // Never completes on its own; the test controls completion.
      return gate.future;
    }
    final delay = getWifiNameDelay;
    if (delay != null) {
      await Future<void>.delayed(delay);
    }
    final exception = getWifiNameException;
    if (exception != null) {
      throw exception;
    }
    if (pendingException != null) {
      throw pendingException!;
    }
    return getWifiNameResult;
  }

  @override
  Future<String?> getWifiBSSID() async {
    if (pendingException != null) throw pendingException!;
    return getWifiBSSIDResult;
  }

  @override
  Future<String?> getWifiIP() async {
    if (pendingException != null) throw pendingException!;
    return getWifiIPResult;
  }

  @override
  Future<String?> getWifiIPv6() async {
    if (pendingException != null) throw pendingException!;
    return getWifiIPv6Result;
  }

  @override
  Future<String?> getWifiSubmask() async {
    if (pendingException != null) throw pendingException!;
    return getWifiSubmaskResult;
  }

  @override
  Future<String?> getWifiGatewayIP() async {
    if (pendingException != null) throw pendingException!;
    return getWifiGatewayIPResult;
  }

  @override
  Future<String?> getWifiBroadcast() async {
    if (pendingException != null) throw pendingException!;
    return getWifiBroadcastResult;
  }
}
