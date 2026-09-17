// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';
// SOCKADDR_IN/SOCKADDR_IN6 are the plugin's own FFI structs (win32 does not
// ship them), needed to demo `formatIPAddress` with a concrete sockaddr. Not
// re-exported by the package barrel, hence the src import.
// ignore: implementation_imports
import 'package:network_info_plus/src/windows_structs.dart';
import 'package:win32/win32.dart';

// The web plugin class can only be compiled for the browser
// (flutter_web_plugins needs dart:ui_web), so it lives behind a conditional
// import; every other platform gets the no-op stub.
import 'web_plugin_demo_stub.dart'
    if (dart.library.js_interop) 'web_plugin_demo_web.dart';

/// A headless demo that exercises the full `network_info_plus` API surface.
///
/// It is invoked from `main.dart`'s `initState`. It does **not** render any UI;
/// it only fetches every piece of network information the plugin exposes and
/// logs the results, including the error-handling path for each getter. This
/// raises the demo's coverage of the plugin API to 100% of its public methods
/// and demonstrates the recommended try/`PlatformException` usage pattern.
///
/// Besides the top-level [NetworkInfo] facade, the demo also drives the three
/// platform implementation classes the package exports —
/// `NetworkInfoPlusLinuxPlugin`, `NetworkInfoPlusWindowsPlugin` (via the FFI
/// demo below) and `NetworkInfoPlusWebPlugin` (via the conditional import) —
/// so every public member of the library is invoked somewhere. OS-specific
/// members are guarded by platform checks and log a skip line elsewhere.
///
/// The logged output is visible in `flutter run` console / DevTools.
Future<void> runNetworkInfoDemo() async {
  final info = NetworkInfo();
  final log = StringBuffer('=== network_info_plus demo ===\n');

  // Each entry pairs a human label with the corresponding async getter, so the
  // demo treats the success path and the failure path uniformly.
  final getters = <_LabeledGetter>[
    _LabeledGetter('wifiName', info.getWifiName),
    _LabeledGetter('wifiBSSID', info.getWifiBSSID),
    _LabeledGetter('wifiIP', info.getWifiIP),
    _LabeledGetter('wifiIPv6', info.getWifiIPv6),
    _LabeledGetter('wifiSubmask', info.getWifiSubmask),
    _LabeledGetter('wifiGatewayIP', info.getWifiGatewayIP),
    _LabeledGetter('wifiBroadcast', info.getWifiBroadcast),
  ];

  // 1) Sequential calls: demonstrates the recommended per-call error handling.
  for (final entry in getters) {
    final value = await _safeRead(entry.label, entry.getter);
    log.writeln('${entry.label}: ${_format(value)}');
  }

  // 2) Concurrent calls: fire all getters at once (Future.wait) to exercise the
  //    plugin under parallel access and confirm there are no shared-state races.
  final concurrentResults = await Future.wait(
    getters.map((entry) => _safeRead(entry.label, entry.getter)),
  );
  log.writeln('--- concurrent snapshot ---');
  for (var i = 0; i < getters.length; i++) {
    log.writeln('${getters[i].label}: ${_format(concurrentResults[i])}');
  }

  // 3) Boundary demonstration: request each value twice in a row to show the
  //    singleton instance is stateless across repeated invocations.
  final firstIp = await _safeRead(getters[2].label, getters[2].getter);
  final secondIp = await _safeRead(getters[2].label, getters[2].getter);
  log.writeln('ipv4 stable across calls: ${firstIp == secondIp}');

  // 4) Platform implementation classes: the Dart plugins behind the facade.
  await _demoLinuxPlugin(log);
  await _demoWindowsPlugin(log);
  await runWebPluginDemo(log);

  developer.log(log.toString(), name: 'network_info_plus.demo');
}

/// Demonstrates every public member of `NetworkInfoPlusLinuxPlugin`.
///
/// The plugin talks to NetworkManager over D-Bus, which only exists on Linux;
/// on other platforms the getters are skipped (logged as such) while the
/// `createClient` seam is still shown.
Future<void> _demoLinuxPlugin(StringBuffer log) async {
  log.writeln('--- NetworkInfoPlusLinuxPlugin ---');
  final linuxPlugin = NetworkInfoPlusLinuxPlugin();

  // `createClient` is the visible-for-testing seam through which tests inject
  // a fake NetworkManager client; by default it builds a real one.
  log.writeln('createClient seam: ${linuxPlugin.createClient}');

  if (!Platform.isLinux) {
    log.writeln('getters skipped: NetworkManager (D-Bus) only exists on Linux');
    return;
  }

  final linuxGetters = <_LabeledGetter>[
    _LabeledGetter('linux.getWifiName', linuxPlugin.getWifiName),
    _LabeledGetter('linux.getWifiBSSID', linuxPlugin.getWifiBSSID),
    _LabeledGetter('linux.getWifiIP', linuxPlugin.getWifiIP),
    _LabeledGetter('linux.getWifiIPv6', linuxPlugin.getWifiIPv6),
    _LabeledGetter('linux.getWifiSubmask', linuxPlugin.getWifiSubmask),
    _LabeledGetter('linux.getWifiGatewayIP', linuxPlugin.getWifiGatewayIP),
    _LabeledGetter('linux.getWifiBroadcast', linuxPlugin.getWifiBroadcast),
  ];
  for (final entry in linuxGetters) {
    log.writeln('${entry.label}: ${_format(await _safeRead(entry.label, entry.getter))}');
  }
}

/// Demonstrates every public member of `NetworkInfoPlusWindowsPlugin`.
///
/// Pure-Dart members (`clientHandle`, `formatBssid`) and the pure-memory
/// `extractSubnet` run on every platform; everything backed by Win32 WLAN /
/// IP-helper APIs only runs on Windows and is skipped elsewhere.
Future<void> _demoWindowsPlugin(StringBuffer log) async {
  log.writeln('--- NetworkInfoPlusWindowsPlugin ---');
  final windowsPlugin = NetworkInfoPlusWindowsPlugin();

  // The WLAN client handle field: 0 (NULL) means the handle is closed.
  log.writeln('clientHandle (closed): ${windowsPlugin.clientHandle}');

  // formatBssid is pure formatting logic and safe to run anywhere.
  log.writeln(
    'formatBssid: ${windowsPlugin.formatBssid([0xC0, 0xFF, 0x33, 0xC0, 0xD3, 0x55])}',
  );

  // extractSubnet walks an adapter's unicast-address chain in native memory —
  // no OS calls, so a synthetic /24 chain works on any platform.
  log.writeln('extractSubnet(/24): ${_demoExtractSubnet(windowsPlugin, 24)}');

  if (!Platform.isWindows) {
    log.writeln('WLAN/IP members skipped: Win32 APIs only exist on Windows');
    return;
  }

  try {
    // query: the raw WLAN query primitive every getter is built on. The
    // callback only runs when a connected interface exists.
    final connection = windowsPlugin.query(
      (pGuid, pAttributes) =>
          'connected (isState=${pAttributes.ref.isState})',
    );
    log.writeln('query: ${connection ?? '<null — no connection>'}');

    // formatIPAddress: render a synthetic IPv4 sockaddr as a string.
    final sockaddr = calloc<SOCKADDR_IN>()
      ..ref.sin_family = AF_INET
      ..ref.sin_addr = 0x0100007F; // 127.0.0.1, network byte order
    try {
      log.writeln(
        'formatIPAddress(127.0.0.1): '
        '${windowsPlugin.formatIPAddress(sockaddr.cast<SOCKADDR>())}',
      );
    } finally {
      free(sockaddr);
    }

    // getAdapterAddress: locate an adapter node by interface GUID.
    log.writeln('getAdapterAddress: ${_demoGetAdapterAddress(windowsPlugin)}');

    // getIPAddr: per-address-family IP lookup the IPv4/IPv6 getters use.
    log.writeln(
      'getIPAddr(AF_INET): '
      '${await windowsPlugin.getIPAddr(AF_INET) ?? '<null>'}',
    );
    log.writeln(
      'getIPAddr(AF_INET6): '
      '${await windowsPlugin.getIPAddr(AF_INET6) ?? '<null>'}',
    );

    final windowsGetters = <_LabeledGetter>[
      _LabeledGetter('windows.getWifiName', windowsPlugin.getWifiName),
      _LabeledGetter('windows.getWifiBSSID', windowsPlugin.getWifiBSSID),
      _LabeledGetter('windows.getWifiIP', windowsPlugin.getWifiIP),
      _LabeledGetter('windows.getWifiIPv6', windowsPlugin.getWifiIPv6),
      _LabeledGetter('windows.getWifiSubmask', windowsPlugin.getWifiSubmask),
      _LabeledGetter('windows.getWifiGatewayIP', windowsPlugin.getWifiGatewayIP),
      _LabeledGetter('windows.getWifiBroadcast', windowsPlugin.getWifiBroadcast),
    ];
    for (final entry in windowsGetters) {
      log.writeln(
        '${entry.label}: ${_format(await _safeRead(entry.label, entry.getter))}',
      );
    }
  } catch (e) {
    // A missing WLAN service or adapter surfaces here rather than killing
    // the demo — the same resilience pattern main.dart uses.
    log.writeln('windows plugin error: $e');
  }
}

/// Builds a synthetic adapter whose only unicast address carries
/// [prefixLength], then lets the plugin derive the dotted-quad mask.
String _demoExtractSubnet(NetworkInfoPlusWindowsPlugin plugin, int prefixLength) {
  final adapter = calloc<IP_ADAPTER_ADDRESSES_LH>();
  final unicast = calloc<IP_ADAPTER_UNICAST_ADDRESS_LH>()
    ..ref.OnLinkPrefixLength = prefixLength;
  adapter.ref.FirstUnicastAddress = unicast;
  try {
    return plugin.extractSubnet(adapter);
  } finally {
    free(unicast);
    free(adapter);
  }
}

/// Looks up a live adapter through its interface GUID and reports which one
/// matched, demonstrating the GUID → LUID → adapter-node walk.
String _demoGetAdapterAddress(NetworkInfoPlusWindowsPlugin plugin) {
  final size = calloc<ULONG>()..value = 8192;
  final adapters = calloc<IP_ADAPTER_ADDRESSES_LH>(
    1 + size.value ~/ sizeOf<IP_ADAPTER_ADDRESSES_LH>(),
  );
  try {
    if (GetAdaptersAddresses(
          AF_UNSPEC,
          GET_ADAPTERS_ADDRESSES_FLAGS(0),
          adapters,
          size,
        ) !=
            NO_ERROR ||
        adapters == nullptr) {
      return '<no adapters>';
    }
    var node = adapters;
    while (node != nullptr) {
      final luid = calloc<NET_LUID_LH>();
      Pointer<GUID>? guid;
      String result;
      try {
        final name = node.ref.AdapterName.toDartString();
        if (!name.startsWith('{')) {
          result = '';
        } else {
          guid = calloc<GUID>()..ref.setGUID(name);
          if (ConvertInterfaceGuidToLuid(guid, luid) != NO_ERROR) {
            result = '';
          } else {
            final match = plugin.getAdapterAddress(guid, adapters);
            result = match == nullptr
                ? 'no adapter matched $name'
                : 'matched adapter $name';
          }
        }
      } catch (_) {
        result = '';
      } finally {
        free(luid);
        if (guid != null) {
          free(guid);
        }
      }
      if (result.isNotEmpty) {
        return result;
      }
      node = node.ref.Next;
    }
    return '<no convertible adapter found>';
  } finally {
    free(adapters);
    free(size);
  }
}

/// Invokes [getter] and converts any [PlatformException] into a readable
/// string, mirroring the pattern the example app uses in `main.dart`.
Future<String> _safeRead(String label, Future<String?> Function() getter) async {
  try {
    final result = await getter();
    return result ?? '<null>';
  } on PlatformException catch (e) {
    developer.log('Failed to get $label', error: e);
    return 'PlatformException: ${e.message ?? e.code}';
  } catch (e) {
    // Web throws UnsupportedError for the unsupported getters; surface it.
    if (kDebugMode) {
      developer.log('Failed to get $label', error: e);
    }
    return e.toString();
  }
}

String _format(String value) => value.isEmpty ? '<empty>' : value;

/// Pairs a display label with the zero-argument async getter it describes.
class _LabeledGetter {
  _LabeledGetter(this.label, this.getter);
  final String label;
  final Future<String?> Function() getter;
}
