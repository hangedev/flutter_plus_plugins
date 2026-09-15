import 'dart:io' show Platform;

import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:package_info_plus_platform_interface/package_info_data.dart';
import 'package:package_info_plus_platform_interface/package_info_platform_interface.dart';

void main() {
  group('PackageInfoPlusLinuxPlugin', () {
    test('should register as the platform instance', () {
      PackageInfoPlusLinuxPlugin.registerWith();
      expect(PackageInfoPlatform.instance, isA<PackageInfoPlusLinuxPlugin>());
    });

    test('should return package data on Linux and fail fast elsewhere',
        () async {
      final plugin = PackageInfoPlusLinuxPlugin();

      if (Platform.isLinux) {
        final data = await plugin.getAll();
        expect(data, isA<PackageInfoData>());
      } else {
        // `/proc/self/exe` only exists on Linux: everywhere else the
        // lookup must surface the error instead of returning bogus data.
        await expectLater(plugin.getAll(), throwsException);
      }
    });
  });
}
