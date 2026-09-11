// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('browser')
library;

// networkInformationToConnectivityResult 的 web 测试：
// 覆盖 type / effectiveType / downlink+rtt / 默认回退全部分支。
// 仅在 web 测试运行器下编译执行；VM 运行器在编译前依据 @TestOn 跳过。
//
// 运行方式：flutter test --platform chrome test/src/web/
import 'dart:html' as html show NetworkInformation;

import 'package:connectivity_plus/src/web/utils/connectivity_result.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('networkInformationToConnectivityResult', () {
    test('should return [none] when downlink and rtt are both zero', () {
      final info = _FakeNetworkInformation()
        ..downlink = 0
        ..rtt = 0
        ..type = 'wifi';
      expect(
        networkInformationToConnectivityResult(info),
        [ConnectivityResult.none],
      );
    });

    test(
      'should map type "wifi" to [wifi] when reported by NetworkInformation',
      () {
        final info = _FakeNetworkInformation()
          ..downlink = 10
          ..rtt = 100
          ..type = 'wifi';
        expect(
          networkInformationToConnectivityResult(info),
          [ConnectivityResult.wifi],
        );
      },
    );

    test(
      'should map type "ethernet" to [ethernet] when reported by '
      'NetworkInformation',
      () {
        final info = _FakeNetworkInformation()
          ..downlink = 10
          ..rtt = 100
          ..type = 'ethernet';
        expect(
          networkInformationToConnectivityResult(info),
          [ConnectivityResult.ethernet],
        );
      },
    );

    test(
      'should map type "bluetooth" to [bluetooth] when reported by '
      'NetworkInformation',
      () {
        final info = _FakeNetworkInformation()
          ..downlink = 10
          ..rtt = 100
          ..type = 'bluetooth';
        expect(
          networkInformationToConnectivityResult(info),
          [ConnectivityResult.bluetooth],
        );
      },
    );

    test(
      'should map cellular/mixed/other/unknown types to [mobile] when '
      'reported',
      () {
        for (final type in ['cellular', 'mixed', 'other', 'unknown']) {
          final info = _FakeNetworkInformation()
            ..downlink = 10
            ..rtt = 100
            ..type = type;
          expect(
            networkInformationToConnectivityResult(info),
            [ConnectivityResult.mobile],
            reason: 'type=$type',
          );
        }
      },
    );

    test('should map type "wimax" to [wifi] when reported', () {
      final info = _FakeNetworkInformation()
        ..downlink = 10
        ..rtt = 100
        ..type = 'wimax';
      expect(
        networkInformationToConnectivityResult(info),
        [ConnectivityResult.wifi],
      );
    });

    test(
      'should map type "none" to [none] even when downlink and rtt are '
      'non-zero',
      () {
        final info = _FakeNetworkInformation()
          ..downlink = 10
          ..rtt = 100
          ..type = 'none';
        expect(
          networkInformationToConnectivityResult(info),
          [ConnectivityResult.none],
        );
      },
    );

    test('should fall back to [other] when the type value is unrecognized', () {
      final info = _FakeNetworkInformation()
        ..downlink = 10
        ..rtt = 100
        ..type = 'carrier-pigeon';
      expect(
        networkInformationToConnectivityResult(info),
        [ConnectivityResult.other],
      );
    });

    test(
      'should use effectiveType to map 2g/3g/4g/slow-2g to [mobile] when '
      'type is null',
      () {
        for (final effectiveType in ['slow-2g', '2g', '3g', '4g']) {
          final info = _FakeNetworkInformation()
            ..downlink = 10
            ..rtt = 100
            ..type = null
            ..effectiveType = effectiveType;
          expect(
            networkInformationToConnectivityResult(info),
            [ConnectivityResult.mobile],
            reason: 'effectiveType=$effectiveType',
          );
        }
      },
    );

    test(
      'should map unrecognized effectiveType values to [wifi] when type is '
      'null',
      () {
        final info = _FakeNetworkInformation()
          ..downlink = 10
          ..rtt = 100
          ..type = null
          ..effectiveType = 'unknown-effective';
        expect(
          networkInformationToConnectivityResult(info),
          [ConnectivityResult.wifi],
        );
      },
    );

    test('should return [none] when both type and effectiveType are null', () {
      final info = _FakeNetworkInformation()
        ..downlink = 10
        ..rtt = 100
        ..type = null
        ..effectiveType = null;
      expect(
        networkInformationToConnectivityResult(info),
        [ConnectivityResult.none],
      );
    });
  });
}

/// NetworkInformation 的可控假实现，便于注入各字段值。
class _FakeNetworkInformation implements html.NetworkInformation {
  num? _downlink = 0;
  int? _rtt = 0;
  String? _type;
  String? _effectiveType;

  @override
  num? get downlink => _downlink;
  set downlink(num? v) => _downlink = v;

  @override
  int? get rtt => _rtt;
  set rtt(int? v) => _rtt = v;

  @override
  String? get type => _type;
  set type(String? v) => _type = v;

  @override
  String? get effectiveType => _effectiveType;
  set effectiveType(String? v) => _effectiveType = v;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
