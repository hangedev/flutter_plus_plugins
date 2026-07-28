// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:math' as math;

import 'package:device_info_plus/src/model/android_device_info.dart';
import 'package:flutter_test/flutter_test.dart';

part '../model/android_device_info_fake.dart';

void main() {
  group('$AndroidDeviceInfo fromMap | toMap', () {
    test('fromMap should return $AndroidDeviceInfo with correct values', () {
      final androidDeviceInfo =
          AndroidDeviceInfo.fromMap(_fakeAndroidDeviceInfo);

      expect(androidDeviceInfo.id, 'id');
      expect(androidDeviceInfo.host, 'host');
      expect(androidDeviceInfo.tags, 'tags');
      expect(androidDeviceInfo.type, 'type');
      expect(androidDeviceInfo.model, 'model');
      expect(androidDeviceInfo.board, 'board');
      expect(androidDeviceInfo.brand, 'Google');
      expect(androidDeviceInfo.device, 'device');
      expect(androidDeviceInfo.product, 'product');
      expect(androidDeviceInfo.display, 'display');
      expect(androidDeviceInfo.hardware, 'hardware');
      expect(androidDeviceInfo.bootloader, 'bootloader');
      expect(androidDeviceInfo.isPhysicalDevice, isTrue);
      expect(androidDeviceInfo.fingerprint, 'fingerprint');
      expect(androidDeviceInfo.manufacturer, 'manufacturer');
      expect(androidDeviceInfo.supportedAbis, _fakeSupportedAbis);
      expect(androidDeviceInfo.systemFeatures, _fakeSystemFeatures);
      expect(androidDeviceInfo.supported32BitAbis, _fakeSupported32BitAbis);
      expect(androidDeviceInfo.supported64BitAbis, _fakeSupported64BitAbis);
      expect(androidDeviceInfo.version.sdkInt, 16);
      expect(androidDeviceInfo.version.baseOS, 'baseOS');
      expect(androidDeviceInfo.version.previewSdkInt, 30);
      expect(androidDeviceInfo.version.release, 'release');
      expect(androidDeviceInfo.version.codename, 'codename');
      expect(androidDeviceInfo.version.incremental, 'incremental');
      expect(androidDeviceInfo.version.securityPatch, 'securityPatch');
      expect(androidDeviceInfo.displayMetrics.widthPx, 1080);
      expect(androidDeviceInfo.displayMetrics.heightPx, 2220);
      expect(androidDeviceInfo.displayMetrics.xDpi, 530.0859);
      expect(androidDeviceInfo.displayMetrics.yDpi, 529.4639);
      expect(androidDeviceInfo.serialNumber, 'SERIAL');
    });

    test('toMap should return map with correct key and map', () {
      final androidDeviceInfo =
          AndroidDeviceInfo.fromMap(_fakeAndroidDeviceInfo);

      expect(androidDeviceInfo.data, _fakeAndroidDeviceInfo);
    });
  });

  group('$AndroidDisplayMetrics', () {
    final metrics =
        AndroidDeviceInfo.fromMap(_fakeAndroidDeviceInfo).displayMetrics;

    test('widthInches is widthPx / xDpi', () {
      expect(metrics.widthInches, closeTo(1080.0 / 530.0859, 1e-9));
    });

    test('heightInches is heightPx / yDpi', () {
      expect(metrics.heightInches, closeTo(2220.0 / 529.4639, 1e-9));
    });

    test('sizeInches is the diagonal', () {
      final expected = math.sqrt(
        (1080.0 / 530.0859) * (1080.0 / 530.0859) +
            (2220.0 / 529.4639) * (2220.0 / 529.4639),
      );
      expect(metrics.sizeInches, closeTo(expected, 1e-9));
    });

    test('toMap round-trips the raw metrics', () {
      expect(metrics.toMap(), _fakeDisplayMetrics);
    });
  });

  group('$AndroidBuildVersion', () {
    test('toMap serializes the version fields', () {
      final version =
          AndroidDeviceInfo.fromMap(_fakeAndroidDeviceInfo).version;
      expect(version.toMap(), _fakeAndroidBuildVersion);
    });
  });

  group('$AndroidDeviceInfo boundary cases', () {
    const versionMap = <String, dynamic>{
      'baseOS': 'baseOS',
      'codename': 'codename',
      'incremental': 'incremental',
      'previewSdkInt': 30,
      'release': 'release',
      'sdkInt': 16,
      'securityPatch': 'securityPatch',
    };
    // All non-nullable fields populated; list fields omitted so their
    // `?? <String>[]` defaults are exercised.
    const baseMap = <String, dynamic>{
      'id': 'id',
      'host': 'host',
      'tags': 'tags',
      'type': 'type',
      'model': 'model',
      'board': 'board',
      'brand': 'brand',
      'device': 'device',
      'product': 'product',
      'display': 'display',
      'hardware': 'hardware',
      'bootloader': 'bootloader',
      'fingerprint': 'fingerprint',
      'manufacturer': 'manufacturer',
      'isPhysicalDevice': true,
      'serialNumber': 'SERIAL',
      'version': versionMap,
      'displayMetrics': _fakeDisplayMetrics,
    };

    test('fromMap rejects a map missing the version sub-map', () {
      // AndroidBuildVersion requires non-null String fields, so an empty map
      // (version defaults to {}) fails construction.
      expect(() => AndroidDeviceInfo.fromMap(<String, dynamic>{}),
          throwsA(isA<TypeError>()));
    });

    test('missing list fields default to empty', () {
      final info = AndroidDeviceInfo.fromMap(baseMap);
      expect(info.supportedAbis, isEmpty);
      expect(info.supported32BitAbis, isEmpty);
      expect(info.supported64BitAbis, isEmpty);
      expect(info.systemFeatures, isEmpty);
    });

    test('_fromList stops at the first null entry', () {
      final info = AndroidDeviceInfo.fromMap(<String, dynamic>{
        ...baseMap,
        'supportedAbis': <dynamic>['arm64-v8a', null, 'x86'],
        'systemFeatures': <dynamic>['FEATURE_A', null, 'FEATURE_B'],
      });
      // takeWhile((item) => item != null) truncates at the first null.
      expect(info.supportedAbis, ['arm64-v8a']);
      expect(info.systemFeatures, ['FEATURE_A']);
    });

    test('lists are unmodifiable', () {
      final info = AndroidDeviceInfo.fromMap(_fakeAndroidDeviceInfo);
      expect(() => info.supportedAbis.add('armeabi'), throwsUnsupportedError);
      expect(
          () => info.systemFeatures.add('FEATURE_X'), throwsUnsupportedError);
    });
  });
}
