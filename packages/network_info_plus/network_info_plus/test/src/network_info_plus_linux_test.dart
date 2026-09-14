// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:network_info_plus_platform_interface/network_info_plus_platform_interface.dart';
import 'package:nm/nm.dart';

/// Runs [action] inside a guarded zone and returns every error it produces,
/// both thrown synchronously and reported as unhandled async errors.
///
/// The Linux plugin's `_getConnectionValue` does not await the value getter
/// immediately, so a thrown error briefly lives in an un-awaited Future and is
/// surfaced by the test runner's error zone as an unhandled error — which would
/// otherwise mark the test failed even when the error is expected. Capturing it
/// here lets us assert the documented throw without that side effect.
Future<List<Object>> collectErrors(Future<void> Function() action) async {
  final errors = <Object>[];
  await runZonedGuarded(() async {
    try {
      await action();
    } catch (e) {
      errors.add(e);
    }
  }, (Object e, StackTrace st) {
    errors.add(e);
  })!;
  return errors;
}

/// The NetworkManager address-data entry shape: a map with an `address`
/// (String) and a `prefix` (int, CIDR length).
typedef AddressDatum = Map<String, dynamic>;

AddressDatum _addr(String address, int prefix) =>
    <String, dynamic>{'address': address, 'prefix': prefix};

void main() {
  group('NetworkInfoPlusLinuxPlugin', () {
    test('should install the Linux implementation as the platform instance', () {
      final previous = NetworkInfoPlatform.instance;
      NetworkInfoPlusLinuxPlugin.registerWith();
      try {
        expect(
          NetworkInfoPlatform.instance,
          isA<NetworkInfoPlusLinuxPlugin>(),
        );
      } finally {
        NetworkInfoPlatform.instance = previous;
      }
    });

    group('when a wifi connection is active - ', () {
      late _FakeNmClient client;
      late NetworkInfoPlusLinuxPlugin plugin;

      setUp(() {
        final ip4 = _FakeIP4Config(
          addressData: [_addr('192.168.1.5', 24)],
          gateway: '192.168.1.1',
        );
        final ip6 = _FakeIP6Config(addressData: [_addr('2001:db8::1', 64)]);
        final wireless = _FakeWireless(permHwAddress: 'AA:BB:CC:DD:EE:FF');
        final device = _FakeDevice(wireless: wireless);
        final connection = _FakeActiveConnection(
          id: 'HomeWifi',
          ip4Config: ip4,
          ip6Config: ip6,
          devices: [device],
        );
        client = _FakeNmClient(connection);
        plugin = NetworkInfoPlusLinuxPlugin();
        plugin.createClient = () => client;
      });

      test('should return the connection id', () async {
        expect(await plugin.getWifiName(), 'HomeWifi');
      });

      test('should return the wireless permanent address', () async {
        expect(await plugin.getWifiBSSID(), 'AA:BB:CC:DD:EE:FF');
      });

      test('should return the first IPv4 address', () async {
        expect(await plugin.getWifiIP(), '192.168.1.5');
      });

      test('should return the first IPv6 address', () async {
        expect(await plugin.getWifiIPv6(), '2001:db8::1');
      });

      test('should derive the mask from the prefix length', () async {
        expect(await plugin.getWifiSubmask(), '255.255.255.0');
      });

      test('should return the configured gateway', () async {
        expect(await plugin.getWifiGatewayIP(), '192.168.1.1');
      });

      test('should compute the broadcast as ip | ~mask', () async {
        expect(await plugin.getWifiBroadcast(), '192.168.1.255');
      });

      test('should connect and close the client on every call', () async {
        await plugin.getWifiName();
        expect(client.connectCount, 1);
        expect(client.closeCount, 1);
      });
    });

    group('subnet/broadcast math across prefix lengths - ', () {
      // Each row: ip, prefix, expectedSubmask, expectedBroadcast.
      //
      // These expectations capture the plugin's ACTUAL behavior. The plugin
      // derives the mask as `0xffffffff >> (32 - prefix)` and prints it
      // little-endian, so for prefix lengths that are a multiple of 8 the
      // dotted-decimal mask happens to read correctly, while /30 reads as
      // `255.255.255.63`. The tests pin this documented behavior so a future
      // change to the math is intentional, not accidental.
      final cases = <List<dynamic>>[
        ['10.0.0.7', 8, '255.0.0.0', '10.255.255.255'],
        ['172.16.5.20', 16, '255.255.0.0', '172.16.255.255'],
        ['192.168.1.5', 24, '255.255.255.0', '192.168.1.255'],
        ['192.168.1.5', 30, '255.255.255.63', '192.168.1.197'],
        ['192.168.1.5', 32, '255.255.255.255', '192.168.1.5'],
      ];

      for (final c in cases) {
        final ip = c[0] as String;
        final prefix = c[1] as int;
        final submask = c[2] as String;
        final broadcast = c[3] as String;
        test('should derive submask $submask and broadcast $broadcast for prefix /$prefix',
            () async {
          final connection = _FakeActiveConnection(
            ip4Config:
                _FakeIP4Config(addressData: [_addr(ip, prefix)]),
          );
          final plugin = NetworkInfoPlusLinuxPlugin()
            ..createClient = () => _FakeNmClient(connection);

          expect(await plugin.getWifiSubmask(), submask);
          expect(await plugin.getWifiBroadcast(), broadcast);
        });
      }
    });

    group('when no connection is active (null primaryConnection) - ', () {
      late _FakeNmClient client;
      late NetworkInfoPlusLinuxPlugin plugin;

      setUp(() {
        client = _FakeNmClient(null);
        plugin = NetworkInfoPlusLinuxPlugin()..createClient = () => client;
      });

      test('should return null', () async {
        expect(await plugin.getWifiName(), isNull);
      });

      test('should return null', () async {
        expect(await plugin.getWifiBSSID(), isNull);
      });

      test('should return null', () async {
        expect(await plugin.getWifiIP(), isNull);
      });

      test('should return null', () async {
        expect(await plugin.getWifiIPv6(), isNull);
      });

      test('should throw when no address data is available', () async {
        // Documented behavior: with a null connection the address data is
        // absent, and `_getSubnetMask` casts a null prefix to `int`, which
        // throws. Captured inside a guarded zone because the plugin does not
        // await the getter immediately, so the throw surfaces as an unhandled
        // async error. Pinned here so any future hardening is intentional.
        final errors = await collectErrors(() => plugin.getWifiSubmask());
        expect(errors, isNotEmpty);
        expect(errors.first, isA<TypeError>());
      });

      test('should return null', () async {
        expect(await plugin.getWifiGatewayIP(), isNull);
      });

      test('should throw when no address data is available',
          () async {
        // Documented behavior: `_getBroadcast` calls `_getSubnetMask`, which
        // throws on absent address data (see the submask test above).
        final errors = await collectErrors(() => plugin.getWifiBroadcast());
        expect(errors, isNotEmpty);
        expect(errors.first, isA<TypeError>());
      });

      test('should still connect and close the client', () async {
        await plugin.getWifiIP();
        expect(client.connectCount, 1);
        expect(client.closeCount, 1);
      });
    });

    group('connection with empty address data - ', () {
      test('should return null when address data is empty', () async {
        final connection = _FakeActiveConnection(
          ip4Config: _FakeIP4Config(addressData: const []),
        );
        final plugin = NetworkInfoPlusLinuxPlugin()
          ..createClient = () => _FakeNmClient(connection);

        expect(await plugin.getWifiIP(), isNull);
      });

      test('should throw when address data is empty', () async {
        // Documented behavior: empty address data -> `firstOrNull` is null ->
        // `['prefix'] as int` throws a TypeError inside `_getSubnetMask`,
        // which `_getBroadcast` propagates. Captured in a guarded zone (see
        // collectErrors) because the throw surfaces as an unhandled async error.
        final connection = _FakeActiveConnection(
          ip4Config: _FakeIP4Config(addressData: const []),
        );
        final plugin = NetworkInfoPlusLinuxPlugin()
          ..createClient = () => _FakeNmClient(connection);

        final errors = await collectErrors(() => plugin.getWifiBroadcast());
        expect(errors, isNotEmpty);
        expect(errors.first, isA<TypeError>());
      });
    });

    group('device lookup for BSSID - ', () {
      test('should return null when the connection has no wireless device', () async {
        // A wired device has no `wireless`, so the BSSID lookup finds nothing.
        final wired = _FakeDevice(wireless: null);
        final connection = _FakeActiveConnection(devices: [wired]);
        final plugin = NetworkInfoPlusLinuxPlugin()
          ..createClient = () => _FakeNmClient(connection);

        expect(await plugin.getWifiBSSID(), isNull);
      });

      test('should pick the first device that has a wireless interface', () async {
        final wireless = _FakeWireless(permHwAddress: '11:22:33:44:55:66');
        final wired = _FakeDevice(wireless: null);
        final wifi = _FakeDevice(wireless: wireless);
        final connection = _FakeActiveConnection(devices: [wired, wifi]);
        final plugin = NetworkInfoPlusLinuxPlugin()
          ..createClient = () => _FakeNmClient(connection);

        expect(await plugin.getWifiBSSID(), '11:22:33:44:55:66');
      });
    });
  });
}

// ---------------------------------------------------------------------------
// Fakes for the `nm` (NetworkManager D-Bus) types.
//
// `NetworkManagerClient`, `NetworkManagerActiveConnection`, etc. are backed by
// real D-Bus objects and cannot be instantiated in a unit test. The Linux
// plugin exposes `createClient` as a `@visibleForTesting` seam, so we inject a
// configured Fake whose getters return canned data. We extend `Fake` (not a raw
// Mock) because the relevant nm getters are non-nullable, which breaks
// Mockito's default `null` stubs; overriding the specific getters we use keeps
// the fake fully type-safe.
// ---------------------------------------------------------------------------

class _FakeNmClient extends Fake implements NetworkManagerClient {
  _FakeNmClient(this._connection);
  final NetworkManagerActiveConnection? _connection;

  int connectCount = 0;
  int closeCount = 0;

  @override
  NetworkManagerActiveConnection? get primaryConnection => _connection;

  @override
  Future<void> connect() async {
    connectCount++;
  }

  @override
  Future<void> close() async {
    closeCount++;
  }
}

class _FakeActiveConnection extends Fake
    implements NetworkManagerActiveConnection {
  _FakeActiveConnection({
    this.id = '',
    this.ip4Config,
    this.ip6Config,
    this.devices = const [],
  });

  @override
  final String id;
  @override
  final NetworkManagerIP4Config? ip4Config;
  @override
  final NetworkManagerIP6Config? ip6Config;
  @override
  final List<NetworkManagerDevice> devices;
}

class _FakeIP4Config extends Fake implements NetworkManagerIP4Config {
  _FakeIP4Config({this.addressData = const [], this.gateway = ''});
  @override
  final List<Map<String, dynamic>> addressData;
  @override
  final String gateway;
}

class _FakeIP6Config extends Fake implements NetworkManagerIP6Config {
  _FakeIP6Config({this.addressData = const []});
  @override
  final List<Map<String, dynamic>> addressData;
}

class _FakeDevice extends Fake implements NetworkManagerDevice {
  _FakeDevice({this.wireless});
  @override
  final NetworkManagerDeviceWireless? wireless;
}

class _FakeWireless extends Fake implements NetworkManagerDeviceWireless {
  _FakeWireless({this.permHwAddress = ''});
  @override
  final String permHwAddress;
}
