// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$WindowsDeviceInfo', () {
    WindowsDeviceInfo build() => WindowsDeviceInfo(
          computerName: 'computerName',
          numberOfCores: 4,
          systemMemoryInMegabytes: 16,
          userName: 'userName',
          majorVersion: 10,
          minorVersion: 0,
          buildNumber: 10240,
          platformId: 1,
          csdVersion: 'csdVersion',
          servicePackMajor: 1,
          servicePackMinor: 0,
          suitMask: 1,
          productType: 1,
          reserved: 1,
          buildLab: '22000.co_release.210604-1628',
          buildLabEx: '22000.1.amd64fre.co_release.210604-1628',
          digitalProductId: Uint8List.fromList([1, 2, 3]),
          displayVersion: '21H2',
          editionId: 'Pro',
          installDate: DateTime(2022, 04, 02),
          productId: '00000-00000-0000-AAAAA',
          productName: 'Windows 10 Pro',
          registeredOwner: 'registeredOwner',
          releaseId: 'releaseId',
          deviceId: 'deviceId',
        );

    test('toMap should return map with correct key and map', () {
      final windowsDeviceInfo = build();
      expect(windowsDeviceInfo.data, {
        'computerName': 'computerName',
        'numberOfCores': 4,
        'systemMemoryInMegabytes': 16,
        'userName': 'userName',
        'majorVersion': 10,
        'minorVersion': 0,
        'buildNumber': 10240,
        'platformId': 1,
        'csdVersion': 'csdVersion',
        'servicePackMajor': 1,
        'servicePackMinor': 0,
        'suitMask': 1,
        'productType': 1,
        'reserved': 1,
        'buildLab': '22000.co_release.210604-1628',
        'buildLabEx': '22000.1.amd64fre.co_release.210604-1628',
        'digitalProductId': Uint8List.fromList([1, 2, 3]),
        'displayVersion': '21H2',
        'editionId': 'Pro',
        'installDate': DateTime(2022, 04, 02),
        'productId': '00000-00000-0000-AAAAA',
        'productName': 'Windows 10 Pro',
        'registeredOwner': 'registeredOwner',
        'releaseId': 'releaseId',
        'deviceId': 'deviceId',
      });
    });

    test('field accessors return the constructor values', () {
      final info = build();
      expect(info.computerName, 'computerName');
      expect(info.numberOfCores, 4);
      expect(info.systemMemoryInMegabytes, 16);
      expect(info.userName, 'userName');
      expect(info.majorVersion, 10);
      expect(info.minorVersion, 0);
      expect(info.buildNumber, 10240);
      expect(info.platformId, 1);
      expect(info.csdVersion, 'csdVersion');
      expect(info.servicePackMajor, 1);
      expect(info.servicePackMinor, 0);
      expect(info.suitMask, 1);
      expect(info.productType, 1);
      expect(info.reserved, 1);
      expect(info.buildLab, '22000.co_release.210604-1628');
      expect(info.buildLabEx, '22000.1.amd64fre.co_release.210604-1628');
      expect(info.digitalProductId, Uint8List.fromList([1, 2, 3]));
      expect(info.displayVersion, '21H2');
      expect(info.editionId, 'Pro');
      expect(info.installDate, DateTime(2022, 04, 02));
      expect(info.productId, '00000-00000-0000-AAAAA');
      expect(info.productName, 'Windows 10 Pro');
      expect(info.registeredOwner, 'registeredOwner');
      expect(info.releaseId, 'releaseId');
      expect(info.deviceId, 'deviceId');
    });
  });
}
