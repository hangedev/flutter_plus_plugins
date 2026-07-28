// ignore_for_file: deprecated_member_use_from_same_package

import 'package:device_info_plus/src/model/ohos_device_info.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sample map covering every field exposed by [OhosDeviceInfo.fromMap].
///
/// Note the `ODID` key is uppercase in the platform map (see `fromMap`), while
/// every other key is camelCase — this is covered explicitly below.
const _fakeOhosDeviceInfo = <String, dynamic>{
  'deviceType': 'phone',
  'manufacture': 'Huawei',
  'brand': 'HUAWEI',
  'marketName': 'ALN-AL00',
  'productSeries': 'ALN',
  'productModel': 'ALN-AL00',
  'softwareModel': 'ALN-AL00',
  'hardwareModel': 'ALN-AL00',
  'hardwareProfile': ' hwprofile',
  'serial': null,
  'bootloaderVersion': 'bootloader',
  'abiList': 'arm64-v8a',
  'securityPatchTag': '2024-01-01',
  'displayVersion': 'OpenHarmony 5.0.0.120',
  'incrementalVersion': 'incremental',
  'osReleaseType': 'Release',
  'osFullName': 'OpenHarmony 5.0.0.120',
  'majorVersion': 5,
  'seniorVersion': 0,
  'featureVersion': 0,
  'buildVersion': 120,
  'sdkApiVersion': 12,
  'firstApiVersion': 12,
  'versionId': 'versionId',
  'buildType': 'user',
  'buildUser': 'builduser',
  'buildHost': 'buildhost',
  'buildTime': '2024-01-01 00:00:00',
  'buildRootHash': 'rootHash',
  'udid': null,
  'distributionOSName': 'distributionOSName',
  'distributionOSVersion': 'distributionOSVersion',
  'distributionOSApiVersion': 12,
  'distributionOSReleaseType': 'Beta',
  'ODID': 'odid-value',
};

void main() {
  group('$OhosDeviceInfo', () {
    group('fromMap', () {
      final info = OhosDeviceInfo.fromMap(_fakeOhosDeviceInfo);

      test('parses all String fields', () {
        expect(info.deviceType, 'phone');
        expect(info.manufacture, 'Huawei');
        expect(info.brand, 'HUAWEI');
        expect(info.marketName, 'ALN-AL00');
        expect(info.productSeries, 'ALN');
        expect(info.productModel, 'ALN-AL00');
        expect(info.softwareModel, 'ALN-AL00');
        expect(info.hardwareModel, 'ALN-AL00');
        expect(info.hardwareProfile, ' hwprofile');
        expect(info.bootloaderVersion, 'bootloader');
        expect(info.abiList, 'arm64-v8a');
        expect(info.securityPatchTag, '2024-01-01');
        expect(info.displayVersion, 'OpenHarmony 5.0.0.120');
        expect(info.incrementalVersion, 'incremental');
        expect(info.osReleaseType, 'Release');
        expect(info.osFullName, 'OpenHarmony 5.0.0.120');
        expect(info.versionId, 'versionId');
        expect(info.buildType, 'user');
        expect(info.buildUser, 'builduser');
        expect(info.buildHost, 'buildhost');
        expect(info.buildTime, '2024-01-01 00:00:00');
        expect(info.buildRootHash, 'rootHash');
        expect(info.distributionOSName, 'distributionOSName');
        expect(info.distributionOSVersion, 'distributionOSVersion');
        expect(info.distributionOSReleaseType, 'Beta');
      });

      test('parses all int fields', () {
        expect(info.majorVersion, 5);
        expect(info.seniorVersion, 0);
        expect(info.featureVersion, 0);
        expect(info.buildVersion, 120);
        expect(info.sdkApiVersion, 12);
        expect(info.firstApiVersion, 12);
        expect(info.distributionOSApiVersion, 12);
      });

      test('reads odID from the uppercase ODID key', () {
        // fromMap maps `map['ODID']` (uppercase) to the `odID` field.
        expect(info.odID, 'odid-value');
        // and the lowercase `odID` key is NOT used.
        const lowercase = <String, dynamic>{'odID': 'wrong'};
        expect(OhosDeviceInfo.fromMap(lowercase).odID, isNull);
      });

      test('serial and udid are null on ohos (no platform API)', () {
        expect(info.serial, isNull);
        expect(info.udid, isNull);
      });

      test('data round-trips the original map', () {
        expect(info.data, _fakeOhosDeviceInfo);
      });
    });

    group('boundary cases', () {
      test('empty map yields all-null fields', () {
        final info = OhosDeviceInfo.fromMap(<String, dynamic>{});
        expect(info.deviceType, isNull);
        expect(info.manufacture, isNull);
        expect(info.majorVersion, isNull);
        expect(info.sdkApiVersion, isNull);
        expect(info.distributionOSApiVersion, isNull);
        expect(info.odID, isNull);
        expect(info.serial, isNull);
        expect(info.udid, isNull);
        expect(info.data, isEmpty);
      });

      test('explicitly-null values are preserved', () {
        final info = OhosDeviceInfo.fromMap(<String, dynamic>{
          'deviceType': null,
          'majorVersion': null,
          'ODID': null,
        });
        expect(info.deviceType, isNull);
        expect(info.majorVersion, isNull);
        expect(info.odID, isNull);
      });

      test('int fields accept arbitrary dynamic ints', () {
        final info = OhosDeviceInfo.fromMap(<String, dynamic>{
          'majorVersion': 0,
          'sdkApiVersion': 999,
        });
        expect(info.majorVersion, 0);
        expect(info.sdkApiVersion, 999);
      });
    });
  });
}
