import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$IosDeviceInfo fromMap | toMap', () {
    late Map<String, dynamic> iosDeviceInfoMap;
    late IosDeviceInfo iosDeviceInfo;

    // setUp (not setUpAll) so every test gets a freshly-parsed object and no
    // state is shared between tests.
    setUp(() {
      const iosUtsnameMap = <String, dynamic>{
        'release': 'release',
        'version': 'version',
        'machine': 'machine',
        'sysname': 'sysname',
        'nodename': 'nodename',
      };
      iosDeviceInfoMap = <String, dynamic>{
        'name': 'name',
        'model': 'model',
        'utsname': iosUtsnameMap,
        'systemName': 'systemName',
        'isPhysicalDevice': 'true',
        'systemVersion': 'systemVersion',
        'localizedModel': 'localizedModel',
        'identifierForVendor': 'identifierForVendor',
      };

      iosDeviceInfo = IosDeviceInfo.fromMap(iosDeviceInfoMap);
    });

    tearDown(() {
      // Drop per-test references so nothing leaks between cases.
      iosDeviceInfoMap = <String, dynamic>{};
    });

    test('fromMap should return $IosDeviceInfo with correct values', () {
      expect(iosDeviceInfo.name, 'name');
      expect(iosDeviceInfo.model, 'model');
      expect(iosDeviceInfo.isPhysicalDevice, isTrue);
      expect(iosDeviceInfo.systemName, 'systemName');
      expect(iosDeviceInfo.systemVersion, 'systemVersion');
      expect(iosDeviceInfo.localizedModel, 'localizedModel');
      expect(iosDeviceInfo.identifierForVendor, 'identifierForVendor');
    });

    test('utsname fields are parsed', () {
      expect(iosDeviceInfo.utsname.release, 'release');
      expect(iosDeviceInfo.utsname.version, 'version');
      expect(iosDeviceInfo.utsname.machine, 'machine');
      expect(iosDeviceInfo.utsname.sysname, 'sysname');
      expect(iosDeviceInfo.utsname.nodename, 'nodename');
    });

    test('toMap should return map with correct key and map', () {
      expect(iosDeviceInfo.data, equals(iosDeviceInfoMap));
    });

    test('isPhysicalDevice is false when the value is not "true"', () {
      final info = IosDeviceInfo.fromMap(<String, dynamic>{
        ...iosDeviceInfoMap,
        'isPhysicalDevice': 'false',
      });
      expect(info.isPhysicalDevice, isFalse);
    });

    test('identifierForVendor may be null', () {
      final info = IosDeviceInfo.fromMap(<String, dynamic>{
        ...iosDeviceInfoMap,
        'identifierForVendor': null,
      });
      expect(info.identifierForVendor, isNull);
    });

    test('fromMap rejects a map missing required fields', () {
      // name is a non-nullable String; an empty map fails construction.
      expect(() => IosDeviceInfo.fromMap(<String, dynamic>{}),
          throwsA(isA<TypeError>()));
    });
  });
}
