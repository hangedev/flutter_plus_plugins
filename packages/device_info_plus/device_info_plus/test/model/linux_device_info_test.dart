// ignore_for_file: deprecated_member_use_from_same_package

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$LinuxDeviceInfo', () {
    LinuxDeviceInfo build() => LinuxDeviceInfo(
          name: 'name',
          version: 'version',
          id: 'id',
          idLike: ['idLike'],
          versionCodename: 'versionCodename',
          versionId: 'versionId',
          prettyName: 'prettyName',
          buildId: 'buildId',
          variant: 'variant',
          variantId: 'variantId',
          machineId: 'machineId',
        );

    test('toMap should return map with correct key and map', () {
      final linuxDeviceInfo = build();
      expect(linuxDeviceInfo.data, {
        'name': 'name',
        'version': 'version',
        'id': 'id',
        'idLike': ['idLike'],
        'versionCodename': 'versionCodename',
        'versionId': 'versionId',
        'prettyName': 'prettyName',
        'buildId': 'buildId',
        'variant': 'variant',
        'variantId': 'variantId',
        'machineId': 'machineId',
      });
    });

    test('field accessors return the constructor values', () {
      final info = build();
      expect(info.name, 'name');
      expect(info.version, 'version');
      expect(info.id, 'id');
      expect(info.idLike, ['idLike']);
      expect(info.versionCodename, 'versionCodename');
      expect(info.versionId, 'versionId');
      expect(info.prettyName, 'prettyName');
      expect(info.buildId, 'buildId');
      expect(info.variant, 'variant');
      expect(info.variantId, 'variantId');
      expect(info.machineId, 'machineId');
    });

    test('optional fields may be null', () {
      final info = LinuxDeviceInfo(
        name: 'Linux',
        id: 'linux',
        prettyName: 'Linux',
        machineId: null,
      );
      expect(info.version, isNull);
      expect(info.idLike, isNull);
      expect(info.versionCodename, isNull);
      expect(info.versionId, isNull);
      expect(info.buildId, isNull);
      expect(info.variant, isNull);
      expect(info.variantId, isNull);
      expect(info.machineId, isNull);
    });
  });
}
