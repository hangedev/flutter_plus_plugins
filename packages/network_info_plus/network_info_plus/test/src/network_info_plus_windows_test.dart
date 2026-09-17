// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('windows')
library network_info_plus_windows_test;

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:network_info_plus/src/windows_structs.dart';
import 'package:network_info_plus_platform_interface/network_info_plus_platform_interface.dart';
import 'package:win32/win32.dart';

/// A regex that matches a dotted-quad IPv4 address with each octet 0–255.
final RegExp _ipv4RegExp = RegExp(
  r'^(?:(?:25[0-5]|2[0-4][9]|1[0-9]{2}|[1-9][0-9]|[0-9])\.){3}'
  r'(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])$',
);

/// A regex that matches a MAC/BSSID formatted as six colon-separated hex pairs.
final RegExp _bssidRegExp =
    RegExp(r'^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$');

/// A GUID used by the adapter-lookup fixtures. `ConvertInterfaceGuidToLuid`
/// only accepts GUIDs that encode a real interface LUID, so a fixed literal
/// (which does not) is used to exercise the rejection path; the matching
/// paths use a live adapter discovered from the host instead.
const String _kTestInterfaceGuid = '{B7698F8B-AD5B-4C31-95C2-D2AEED9F3B9C}';

void main() {
  group('NetworkInfoPlusWindowsPlugin - registration', () {
    test('should install the Windows implementation as the platform instance',
        () {
      final previous = NetworkInfoPlatform.instance;
      NetworkInfoPlusWindowsPlugin.registerWith();
      try {
        expect(
          NetworkInfoPlatform.instance,
          isA<NetworkInfoPlusWindowsPlugin>(),
        );
      } finally {
        NetworkInfoPlatform.instance = previous;
      }
    });
  });

  group('formatBssid - ', () {
    late NetworkInfoPlusWindowsPlugin plugin;
    setUp(() {
      plugin = NetworkInfoPlusWindowsPlugin();
    });

    test('should format six bytes as lowercase colon-separated hex pairs', () {
      expect(
        plugin.formatBssid([0xAB, 0xCD, 0xEF, 0x01, 0x23, 0x45]),
        'ab:cd:ef:01:23:45',
      );
    });

    test('should zero-pad each byte to two hex digits', () {
      expect(
        plugin.formatBssid([0x00, 0x05, 0x0A, 0x0F, 0x10, 0xFF]),
        '00:05:0a:0f:10:ff',
      );
    });

    test('should lowercase uppercase hex digits', () {
      expect(
        plugin.formatBssid([0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54]),
        'fe:dc:ba:98:76:54',
      );
    });

    test('should match the standard BSSID shape', () {
      final formatted =
          plugin.formatBssid([0xC0, 0xFF, 0x33, 0xC0, 0xD3, 0x55]);
      expect(formatted, matches(_bssidRegExp));
    });

    test('should return an empty string for an empty byte list', () {
      // Parameter-anomaly case: fewer than six bytes still renders, just
      // with fewer groups — pinned so any future validation is intentional.
      expect(plugin.formatBssid([]), '');
    });
  });

  group('clientHandle lifecycle - ', () {
    late NetworkInfoPlusWindowsPlugin plugin;
    setUp(() {
      plugin = NetworkInfoPlusWindowsPlugin();
    });

    test('should start closed (NULL) on a fresh plugin instance', () {
      // win32 6.x: HANDLE is a Pointer-backed extension type, not an int, so
      // assert closed-ness via isValid instead of comparing against NULL (0).
      expect(plugin.clientHandle.isValid, isFalse);
    });

    test('should return to NULL after an openHandle/closeHandle round-trip',
        () {
      // On a host without the WLAN service `openHandle` is a documented no-op
      // (clientHandle stays NULL); on a WLAN-capable host it opens a real
      // handle. Either way `closeHandle` must leave the handle closed.
      plugin.openHandle();
      plugin.closeHandle();
      // win32 6.x: HANDLE is a Pointer-backed extension type, not an int, so
      // assert closed-ness via isValid instead of comparing against NULL (0).
      expect(plugin.clientHandle.isValid, isFalse);
    });

    test('should remain NULL when closeHandle is called repeatedly', () {
      plugin.closeHandle();
      plugin.closeHandle();
      // win32 6.x: HANDLE is a Pointer-backed extension type, not an int, so
      // assert closed-ness via isValid instead of comparing against NULL (0).
      expect(plugin.clientHandle.isValid, isFalse);
    });
  });

  group('query - ', () {
    late NetworkInfoPlusWindowsPlugin plugin;
    setUp(() {
      plugin = NetworkInfoPlusWindowsPlugin();
    });

    test('should return the callback result when connected, or null when not',
        () {
      // The callback only runs when a connected WLAN interface exists. On an
      // adapter-less host the query reports null; with a live connection the
      // callback's marker value must flow through unchanged.
      const marker = 'query-callback-marker';
      final result = plugin.query((pGuid, pAttributes) => marker);
      expect(result == null || result == marker, isTrue);
    });

    test('should close the client handle when the query finishes', () {
      plugin.query((pGuid, pAttributes) => null);
      // `query` always closes the handle it opened, even on failure paths.
      // win32 6.x: HANDLE is a Pointer-backed extension type, not an int, so
      // assert closed-ness via isValid instead of comparing against NULL (0).
      expect(plugin.clientHandle.isValid, isFalse);
    });
  });

  group('formatIPAddress - ', () {
    late NetworkInfoPlusWindowsPlugin plugin;
    setUp(() {
      plugin = NetworkInfoPlusWindowsPlugin();
    });

    test('should format an AF_INET sockaddr as a dotted-quad address', () {
      // 0x0100007F little-endian in memory is 7F 00 00 01 → 127.0.0.1.
      final addr = calloc<SOCKADDR_IN>()
        ..ref.sin_family = AF_INET
        ..ref.sin_addr = 0x0100007F;
      try {
        expect(plugin.formatIPAddress(addr.cast<SOCKADDR>()), '127.0.0.1');
      } finally {
        free(addr);
      }
    });

    test('should format an AF_INET6 sockaddr with compressed zeros', () {
      final addr = calloc<SOCKADDR_IN6>()..ref.sin6_family = AF_INET6;
      addr.ref.sin6_addr[15] = 1; // ::1
      try {
        expect(plugin.formatIPAddress(addr.cast<SOCKADDR>()), '::1');
      } finally {
        free(addr);
      }
    });

    test('should return an empty string for an unsupported address family',
        () {
      // Parameter-anomaly case: AF_UNSPEC (0) matches neither branch, so the
      // (zero-initialized) buffer is returned as an empty string.
      final addr = calloc<SOCKADDR_IN>()..ref.sin_family = 0;
      try {
        expect(plugin.formatIPAddress(addr.cast<SOCKADDR>()), '');
      } finally {
        free(addr);
      }
    });
  });

  group('getAdapterAddress - ', () {
    late NetworkInfoPlusWindowsPlugin plugin;
    setUp(() {
      plugin = NetworkInfoPlusWindowsPlugin();
    });

    test('should return null when the GUID is not a valid interface GUID', () {
      // Parameter-anomaly case: `ConvertInterfaceGuidToLuid` rejects a GUID
      // that does not encode an interface LUID, and the plugin surfaces that
      // as null instead of throwing.
      final guid = calloc<GUID>()..ref.setGUID(_kTestInterfaceGuid);
      final adapter = calloc<IP_ADAPTER_ADDRESSES_LH>();
      try {
        expect(plugin.getAdapterAddress(guid, adapter), isNull);
      } finally {
        free(guid);
        free(adapter);
      }
    });

    test('should return null for an empty adapter list', () {
      // Boundary case: a null list head terminates the walk immediately.
      final guid = calloc<GUID>()..ref.setGUID(_kTestInterfaceGuid);
      try {
        expect(
          plugin.getAdapterAddress(
            guid,
            nullptr.cast<IP_ADAPTER_ADDRESSES_LH>(),
          ),
          isNull,
        );
      } finally {
        free(guid);
      }
    });

    group('when a live adapter is present - ', () {
      // Matching tests bind a real host adapter: `GetAdaptersAddresses`
      // reports each adapter's GUID as its name, which is exactly what the
      // plugin converts back to a LUID. Hosts without any convertible adapter
      // simply skip these tests.
      test('should find the live adapter the GUID resolves to', () {
        final fixture = _LiveAdapterFixture.discover();
        if (fixture == null) {
          return;
        }
        try {
          final result =
              plugin.getAdapterAddress(fixture.guid, fixture.adapters);

          expect(result, isNotNull);
          expect(result!.ref.Luid.Value, fixture.luidValue);
        } finally {
          fixture.dispose();
        }
      });

      test('should walk the linked list past non-matching adapters', () {
        final fixture = _LiveAdapterFixture.discover();
        if (fixture == null) {
          return;
        }
        try {
          final head = calloc<IP_ADAPTER_ADDRESSES_LH>();
          final tail = calloc<IP_ADAPTER_ADDRESSES_LH>();
          try {
            // Guarantee the head differs from the target LUID.
            head.ref.Luid.Value = fixture.luidValue ^ 0x1;
            tail.ref.Luid.Value = fixture.luidValue;
            head.ref.Next = tail;

            final result = plugin.getAdapterAddress(fixture.guid, head);

            expect(result, isNotNull);
            expect(result!.address, tail.address);
          } finally {
            free(head);
            free(tail);
          }
        } finally {
          fixture.dispose();
        }
      });

      test('should return null when no adapter matches the GUID', () {
        final fixture = _LiveAdapterFixture.discover();
        if (fixture == null) {
          return;
        }
        try {
          final lone = calloc<IP_ADAPTER_ADDRESSES_LH>();
          try {
            lone.ref.Luid.Value = fixture.luidValue ^ 0x2;

            expect(plugin.getAdapterAddress(fixture.guid, lone), isNull);
          } finally {
            free(lone);
          }
        } finally {
          fixture.dispose();
        }
      });
    });
  });

  group('getIPAddr - ', () {
    late NetworkInfoPlusWindowsPlugin plugin;
    setUp(() {
      plugin = NetworkInfoPlusWindowsPlugin();
    });

    test('should return a valid IPv4 address or null for AF_INET', () async {
      final ip = await plugin.getIPAddr(AF_INET);
      // Null simply means "no connected WLAN interface on this host".
      if (ip != null) {
        expect(ip, matches(_ipv4RegExp));
      }
    });

    test('should return an IPv6 address or null for AF_INET6', () async {
      final ip = await plugin.getIPAddr(AF_INET6);
      if (ip != null) {
        expect(ip, isNotEmpty);
        expect(ip, contains(':'));
      }
    });
  });

  group('extractSubnet - ', () {
    late NetworkInfoPlusWindowsPlugin plugin;
    setUp(() {
      plugin = NetworkInfoPlusWindowsPlugin();
    });

    test('should render prefix /24 as 255.255.255.0', () {
      final adapter = _adapterWithPrefixes([24]);
      try {
        expect(plugin.extractSubnet(adapter), '255.255.255.0');
      } finally {
        _freeAdapter(adapter);
      }
    });

    test('should render prefix /0 as 0.0.0.0', () {
      final adapter = _adapterWithPrefixes([0]);
      try {
        expect(plugin.extractSubnet(adapter), '0.0.0.0');
      } finally {
        _freeAdapter(adapter);
      }
    });

    test('should render prefix /32 as 255.255.255.255', () {
      final adapter = _adapterWithPrefixes([32]);
      try {
        expect(plugin.extractSubnet(adapter), '255.255.255.255');
      } finally {
        _freeAdapter(adapter);
      }
    });

    test('should render prefix /20 as 255.255.240.0', () {
      final adapter = _adapterWithPrefixes([20]);
      try {
        expect(plugin.extractSubnet(adapter), '255.255.240.0');
      } finally {
        _freeAdapter(adapter);
      }
    });

    test('should derive the mask from the LAST unicast address in the chain',
        () {
      // The walk skips every node until Next is null, so the trailing /20
      // wins over the leading /24.
      final adapter = _adapterWithPrefixes([24, 20]);
      try {
        expect(plugin.extractSubnet(adapter), '255.255.240.0');
      } finally {
        _freeAdapter(adapter);
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Live WLAN tests
  //
  // These exercise the real Windows WLAN/FFI code path. They require a Wi-Fi
  // adapter and an active connection, which a CI/host machine often lacks.
  // When the OS reports no connection the getters return `null`, so we skip
  // rather than fail — keeping the suite green on adapter-less hosts while
  // still asserting correctness where a value is available.
  // ---------------------------------------------------------------------------

  group('when querying a live WLAN adapter (skipped when none) - ', () {
    late NetworkInfoPlusWindowsPlugin plugin;
    setUp(() {
      plugin = NetworkInfoPlusWindowsPlugin();
    });

    test('should return a well-formed BSSID or null', () async {
      final bssid = await plugin.getWifiBSSID();
      if (bssid == null) {
        // No active Wi-Fi connection on this host — nothing to assert.
        return;
      }
      expect(bssid, matches(_bssidRegExp));
    });

    test('should return a non-empty SSID or null', () async {
      final name = await plugin.getWifiName();
      if (name == null) {
        return;
      }
      expect(name, isNotEmpty);
    });

    test('should return a valid IPv4 or null', () async {
      final ip = await plugin.getWifiIP();
      if (ip == null) {
        return;
      }
      expect(ip, matches(_ipv4RegExp));
    });

    test('should return a non-empty IPv6 or null', () async {
      final ipv6 = await plugin.getWifiIPv6();
      if (ipv6 == null) {
        return;
      }
      expect(ipv6, isNotEmpty);
    });

    test('should return a valid IPv4 mask or null', () async {
      final mask = await plugin.getWifiSubmask();
      if (mask == null) {
        return;
      }
      expect(mask, matches(_ipv4RegExp));
    });

    test('should return a valid IPv4 gateway or null', () async {
      final gateway = await plugin.getWifiGatewayIP();
      if (gateway == null) {
        return;
      }
      expect(gateway, matches(_ipv4RegExp));
    });

    test('should return a valid IPv4 broadcast or null', () async {
      final broadcast = await plugin.getWifiBroadcast();
      if (broadcast == null) {
        return;
      }
      expect(broadcast, matches(_ipv4RegExp));
    });

    test('should let every getter complete without throwing on a quiet adapter',
        () async {
      // Even with no connection, none of the getters should throw.
      await plugin.getWifiName();
      await plugin.getWifiBSSID();
      await plugin.getWifiIP();
      await plugin.getWifiIPv6();
      await plugin.getWifiSubmask();
      await plugin.getWifiGatewayIP();
      await plugin.getWifiBroadcast();
    });
  });
}

/// Allocates an adapter whose unicast-address chain carries [prefixes] — one
/// [IP_ADAPTER_UNICAST_ADDRESS_LH] node per entry, linked in order.
///
/// The returned adapter (and every chain node) is `calloc` memory; release it
/// with [_freeAdapter].
Pointer<IP_ADAPTER_ADDRESSES_LH> _adapterWithPrefixes(List<int> prefixes) {
  final adapter = calloc<IP_ADAPTER_ADDRESSES_LH>();
  var current = calloc<IP_ADAPTER_UNICAST_ADDRESS_LH>()
    ..ref.OnLinkPrefixLength = prefixes.first;
  adapter.ref.FirstUnicastAddress = current;
  for (final prefix in prefixes.skip(1)) {
    final next = calloc<IP_ADAPTER_UNICAST_ADDRESS_LH>()
      ..ref.OnLinkPrefixLength = prefix;
    current.ref.Next = next;
    current = next;
  }
  return adapter;
}

/// Releases an adapter allocated by [_adapterWithPrefixes], walking and
/// freeing every unicast-address node in the chain.
void _freeAdapter(Pointer<IP_ADAPTER_ADDRESSES_LH> adapter) {
  var node = adapter.ref.FirstUnicastAddress;
  while (node != nullptr) {
    final next = node.ref.Next;
    free(node);
    node = next;
  }
  free(adapter);
}

/// Binds a real network adapter from this host for `getAdapterAddress`
/// matching tests: [guid] is the adapter's interface GUID (its `AdapterName`),
/// [luidValue] the LUID `ConvertInterfaceGuidToLuid` derives from it, and
/// [adapters] the full live adapter list the node was found in.
///
/// Call [dispose] to release all native memory. [discover] returns null when
/// the host reports no adapter with a convertible GUID, so tests can skip.
class _LiveAdapterFixture {
  _LiveAdapterFixture._(
    this.guid,
    this.luidValue,
    this.adapters,
    this._size,
  );

  final Pointer<GUID> guid;
  final int luidValue;
  final Pointer<IP_ADAPTER_ADDRESSES_LH> adapters;
  final Pointer<ULONG> _size;

  static _LiveAdapterFixture? discover() {
    const maxAttempts = 3;
    var attempts = 0;

    final size = calloc<ULONG>()..value = 8192;
    var adapters = calloc<IP_ADAPTER_ADDRESSES_LH>(
      1 + size.value ~/ sizeOf<IP_ADAPTER_ADDRESSES_LH>(),
    );

    // Grow the buffer until GetAdaptersAddresses fits the adapter list.
    while (true) {
      final hr = GetAdaptersAddresses(
        AF_UNSPEC,
        GET_ADAPTERS_ADDRESSES_FLAGS(0),
        adapters,
        size,
      );
      if (hr == NO_ERROR) {
        break;
      }
      free(adapters);
      if (hr != 111 /* ERROR_BUFFER_OVERFLOW */ || ++attempts > maxAttempts) {
        free(size);
        return null;
      }
      adapters = calloc<IP_ADAPTER_ADDRESSES_LH>(
        1 + size.value ~/ sizeOf<IP_ADAPTER_ADDRESSES_LH>(),
      );
    }

    // Walk the list; the first adapter whose name is a GUID convertible to an
    // interface LUID becomes the fixture.
    var node = adapters;
    while (node != nullptr) {
      Pointer<GUID>? guid;
      final luid = calloc<NET_LUID_LH>();
      try {
        final name = node.ref.AdapterName.toDartString();
        guid = calloc<GUID>()..ref.setGUID(name);
        if (ConvertInterfaceGuidToLuid(guid, luid) == NO_ERROR) {
          final luidValue = luid.ref.Value;
          free(luid);
          return _LiveAdapterFixture._(guid, luidValue, adapters, size);
        }
      } catch (_) {
        // Adapter name was not a parseable GUID — try the next adapter.
      }
      free(luid);
      if (guid != null) {
        free(guid);
      }
      node = node.ref.Next;
    }

    free(adapters);
    free(size);
    return null;
  }

  void dispose() {
    free(guid);
    free(adapters);
    free(_size);
  }
}
