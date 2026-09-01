// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  PackageInfo seedMock({
    String appName = 'package_info_example',
    String packageName = 'io.flutter.plugins.packageinfoexample',
    String version = '1.0',
    String buildNumber = '1',
    String buildSignature = 'a1b2c3d4e5f6a7b8',
    String? installerStore = '',
  }) {
    final info = PackageInfo(
      appName: appName,
      packageName: packageName,
      version: version,
      buildNumber: buildNumber,
      buildSignature: buildSignature,
      installerStore: installerStore,
    );
    PackageInfo.setMockInitialValues(
      appName: info.appName,
      packageName: info.packageName,
      version: info.version,
      buildNumber: info.buildNumber,
      buildSignature: info.buildSignature,
      installerStore: info.installerStore,
    );
    return info;
  }

  // Every test seeds its own mock values: no test depends on the state
  // left behind by a previous one.
  setUp(() {
    seedMock();
  });

  group('PackageInfo mock values', () {
    test('should return every documented property when mock values are set',
        () async {
      seedMock(
        appName: 'mock_package_info_example',
        packageName: 'io.flutter.plugins.mockpackageinfoexample',
        version: '1.1',
        buildNumber: '2',
        buildSignature: 'deadbeef',
        installerStore: null,
      );

      final info = await PackageInfo.fromPlatform();
      expect(info.appName, 'mock_package_info_example');
      expect(info.buildNumber, '2');
      expect(info.packageName, 'io.flutter.plugins.mockpackageinfoexample');
      expect(info.version, '1.1');
      expect(info.buildSignature, 'deadbeef');
      expect(info.installerStore, null);
    });

    test('should overwrite the singleton when mock values are set again',
        () async {
      seedMock(
        appName: 'first_app',
        packageName: 'io.flutter.plugins.first',
        version: '1.0',
        buildNumber: '1',
        buildSignature: 'first-signature',
        installerStore: 'com.first.store',
      );
      final first = await PackageInfo.fromPlatform();

      final second = seedMock(
        appName: 'second_app',
        packageName: 'io.flutter.plugins.second',
        version: '2.0',
        buildNumber: '2',
        buildSignature: 'second-signature',
        installerStore: 'com.second.store',
      );
      final secondInfo = await PackageInfo.fromPlatform();

      expect(identical(first, secondInfo), isFalse);
      expect(secondInfo.appName, 'second_app');
      expect(secondInfo.packageName, 'io.flutter.plugins.second');
      expect(secondInfo.version, '2.0');
      expect(secondInfo.buildNumber, '2');
      expect(secondInfo.buildSignature, 'second-signature');
      expect(secondInfo.installerStore, 'com.second.store');
      expect(secondInfo == second, isTrue);
    });
  });

  group('PackageInfo equality and hashing', () {
    test('should consider two instances equal when all fields match', () {
      final info1 = seedMock(buildSignature: '', installerStore: null);
      final info2 = seedMock(buildSignature: '', installerStore: null);
      expect(info1, info2);
      expect(info1.hashCode, info2.hashCode);
    });

    test('should report equality for the identical instance', () {
      final info = seedMock();
      expect(info == info, isTrue);
    });

    test('should report inequality against other types', () {
      const Object notAPackageInfo = 'not a PackageInfo';
      const Object? alsoNotAPackageInfo = null;
      expect(seedMock() == notAPackageInfo, isFalse);
      expect(seedMock() == alsoNotAPackageInfo, isFalse);
    });

    test('should report inequality when any single documented field differs',
        () {
      final base = seedMock();
      final modified = <String, PackageInfo Function()>{
        'appName': () => seedMock(appName: 'other_app'),
        'packageName': () => seedMock(packageName: 'io.other'),
        'version': () => seedMock(version: '2.0'),
        'buildNumber': () => seedMock(buildNumber: '2'),
        'buildSignature': () => seedMock(buildSignature: 'other-signature'),
        'installerStore': () => seedMock(installerStore: 'com.other.store'),
      };
      modified.forEach((field, build) {
        expect(base == build(), isFalse, reason: 'field: $field');
        expect(base.hashCode == build().hashCode, isFalse,
            reason: 'field: $field');
      });
    });
  });

  group('PackageInfo string representation', () {
    test(
        'should include every documented property in toString '
        'when all values are set', () {
      final info = seedMock(installerStore: 'com.huawei.appmarket');
      expect(
        info.toString(),
        'PackageInfo(appName: package_info_example, buildNumber: 1, '
        'packageName: io.flutter.plugins.packageinfoexample, version: 1.0, '
        'buildSignature: a1b2c3d4e5f6a7b8, '
        'installerStore: com.huawei.appmarket)',
      );
    });

    test('should render null optional fields in toString', () {
      final info = seedMock(
        buildSignature: '',
        installerStore: null,
      );
      expect(
        info.toString(),
        'PackageInfo(appName: package_info_example, buildNumber: 1, '
        'packageName: io.flutter.plugins.packageinfoexample, version: 1.0, '
        'buildSignature: , installerStore: null)',
      );
    });
  });

  group('PackageInfo data map', () {
    test('should return a map representation of every populated field',
        () async {
      seedMock(
        buildSignature: '',
        installerStore: null,
      );
      final info = await PackageInfo.fromPlatform();
      expect(info.data, {
        'appName': 'package_info_example',
        'packageName': 'io.flutter.plugins.packageinfoexample',
        'version': '1.0',
        'buildNumber': '1',
      });

      seedMock(
        appName: 'mock_package_info_example',
        packageName: 'io.flutter.plugins.mockpackageinfoexample',
        version: '1.1',
        buildNumber: '2',
        buildSignature: 'deadbeef',
        installerStore: 'testflight',
      );
      final info2 = await PackageInfo.fromPlatform();
      expect(info2.data, {
        'appName': 'mock_package_info_example',
        'packageName': 'io.flutter.plugins.mockpackageinfoexample',
        'version': '1.1',
        'buildNumber': '2',
        'buildSignature': 'deadbeef',
        'installerStore': 'testflight',
      });
    });

    test('should omit null optional fields from the map', () async {
      seedMock(
        buildSignature: '',
        installerStore: null,
      );
      final info = await PackageInfo.fromPlatform();
      expect(info.data, {
        'appName': 'package_info_example',
        'packageName': 'io.flutter.plugins.packageinfoexample',
        'version': '1.0',
        'buildNumber': '1',
      });
    });

    test('should keep the map stable through a JSON round-trip', () async {
      seedMock(
        appName: 'mock_package_info_example',
        packageName: 'io.flutter.plugins.mockpackageinfoexample',
        version: '1.1',
        buildNumber: '2',
        buildSignature: 'signature',
        installerStore: 'store',
      );
      final info = await PackageInfo.fromPlatform();

      final jsonData = jsonEncode(info.data);
      final parsedData = jsonDecode(jsonData);

      expect(parsedData, {
        'appName': 'mock_package_info_example',
        'packageName': 'io.flutter.plugins.mockpackageinfoexample',
        'version': '1.1',
        'buildNumber': '2',
        'buildSignature': 'signature',
        'installerStore': 'store',
      });
    });
  });

  group('boundary scenarios', () {
    test('should accept empty strings for every string field', () async {
      seedMock(
        appName: '',
        packageName: '',
        version: '',
        buildNumber: '',
        buildSignature: '',
        installerStore: '',
      );
      final info = await PackageInfo.fromPlatform();

      expect(info.appName, isEmpty);
      expect(info.packageName, isEmpty);
      expect(info.version, isEmpty);
      expect(info.buildNumber, isEmpty);
      expect(info.buildSignature, isEmpty);
      expect(info.data, {
        'appName': '',
        'packageName': '',
        'version': '',
        'buildNumber': '',
      });
    });

    test('should accept very long field values', () async {
      final longValue = 'a' * 4096;
      seedMock(
        appName: longValue,
        packageName: '$longValue.example',
        version: '99999.99999.99999+99999',
      );
      final info = await PackageInfo.fromPlatform();

      expect(info.appName, longValue);
      expect(info.packageName, '$longValue.example');
      expect(info.version, '99999.99999.99999+99999');
      expect(info.data['appName'], longValue);
    });
  });

  group('concurrent scenarios', () {
    test('should return value-equal results on concurrent calls', () async {
      final seeded = seedMock();
      final results = await Future.wait(
        List.generate(16, (_) => PackageInfo.fromPlatform()),
      );

      // The cached instance is shared, so every concurrent reader either
      // receives it or a value-equal instance.
      for (final result in results) {
        expect(identical(result, seeded) || result == seeded, isTrue);
      }
      expect(results.every((r) => r == results.first), isTrue);
    });

    test('should serve repeated concurrent map reads consistently', () async {
      seedMock();
      final info = await PackageInfo.fromPlatform();

      final maps = await Future.wait(List.generate(16, (_) async => info.data));
      for (final map in maps) {
        expect(map, maps.first);
      }
    });
  });

  // === 鸿蒙平台测试 ===
  group('Ohos PackageInfo', () {
    test('should expose every documented property of the Ohos payload',
        () async {
      // README.OpenHarmony.md §4 Properties — every entry must be
      // reachable on a PackageInfo obtained from the platform.
      seedMock(
        installerStore: '',
      );
      final info = await PackageInfo.fromPlatform();

      expect(info.appName, 'package_info_example');
      expect(info.packageName, 'io.flutter.plugins.packageinfoexample');
      expect(info.version, '1.0');
      expect(info.buildNumber, '1');
      expect(info.buildSignature, 'a1b2c3d4e5f6a7b8');
      expect(info.installerStore, '');
      expect(info.data, containsPair('appName', 'package_info_example'));
      expect(info.data,
          containsPair('packageName', 'io.flutter.plugins.packageinfoexample'));
      expect(info.data, containsPair('version', '1.0'));
      expect(info.data, containsPair('buildNumber', '1'));
      expect(info.data, containsPair('buildSignature', 'a1b2c3d4e5f6a7b8'));
    });

    test('should omit the empty installerStore Ohos reports from the map',
        () async {
      // The OHOS implementation reports an empty installerStore string;
      // it must not appear in the map representation.
      seedMock(
        buildSignature: '',
        installerStore: '',
      );
      final info = await PackageInfo.fromPlatform();

      expect(info.installerStore, '');
      expect(info.data.containsKey('installerStore'), isFalse);
      expect(info.data.containsKey('buildSignature'), isFalse);
    });
  });
}
