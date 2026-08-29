import 'dart:convert' show jsonEncode;
import 'dart:io' show Directory, File, Platform;

import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:package_info_plus_platform_interface/package_info_data.dart';
import 'package:package_info_plus_platform_interface/package_info_platform_interface.dart';

/// The fake `/proc` layout the linux plugin resolves through:
/// `/proc/self/exe` → `<dir>/data/flutter_assets/version.json`.
///
/// On a Windows host a rooted path such as `/proc/self/exe` resolves
/// relative to the current drive (e.g. `D:\proc\self\exe`), so creating
/// this tree makes the full success path of `getAll` runnable off Linux.
/// On a real Linux host `/proc` is kernel procfs and cannot be faked:
/// creating the tree fails and the success-path group skips instead of
/// failing.
final _fakeExe = File('/proc/self/exe');
final _fakeAssetsDir = Directory('/proc/self/data/flutter_assets');
final _fakeVersionJson = File('/proc/self/data/flutter_assets/version.json');

bool _createFakeProcTree() {
  try {
    _fakeAssetsDir.createSync(recursive: true);
    if (!_fakeExe.existsSync()) {
      _fakeExe.createSync();
    }
    return true;
  } on Object {
    return false;
  }
}

void _removeFakeProcTree() {
  // Best effort: on hosts without the tree both calls fail harmlessly
  // (a non-empty or kernel-owned `/proc` refuses deletion and is left
  // untouched).
  try {
    Directory('/proc/self').deleteSync(recursive: true);
  } on Object {
    // Nothing to clean up.
  }
  try {
    Directory('/proc').deleteSync();
  } on Object {
    // Left behind when non-empty — fine.
  }
}

void main() {
  // Probe once whether the host lets us stage the fake tree, then
  // restore a clean host: the fallback test below must observe the
  // tree as absent, and the success-path group recreates it around
  // every test.
  final fakeProcAvailable = _createFakeProcTree();
  _removeFakeProcTree();

  group('PackageInfoPlusLinuxPlugin', () {
    test('should register as the platform instance', () {
      PackageInfoPlusLinuxPlugin.registerWith();
      expect(PackageInfoPlatform.instance, isA<PackageInfoPlusLinuxPlugin>());
    });

    test('should fall back to empty values when the /proc lookup fails',
        () async {
      final plugin = PackageInfoPlusLinuxPlugin();

      final data = await plugin.getAll();
      expect(data, isA<PackageInfoData>());

      if (!Platform.isLinux) {
        // `/proc/self/exe` only exists on Linux: everywhere else the
        // lookup fails and the plugin falls back to empty values
        // instead of throwing.
        expect(data.appName, '');
        expect(data.packageName, '');
        expect(data.version, '');
        expect(data.buildNumber, '');
        expect(data.buildSignature, '');
      }
    });

    group(
      'with a faked /proc layout',
      skip: fakeProcAvailable
          ? false
          : 'host forbids creating the fake /proc tree',
      () {
        setUp(_createFakeProcTree);
        tearDown(_removeFakeProcTree);

        test('should populate every field from version.json', () async {
          _fakeVersionJson.writeAsStringSync(jsonEncode(<String, dynamic>{
            'app_name': 'linux_app',
            'package_name': 'io.flutter.plugins.linuxapp',
            'version': '4.2.0',
            'build_number': '42',
          }));

          final data = await PackageInfoPlusLinuxPlugin().getAll();

          expect(data.appName, 'linux_app');
          expect(data.packageName, 'io.flutter.plugins.linuxapp');
          expect(data.version, '4.2.0');
          expect(data.buildNumber, '42');
          // The linux implementation reports no build signature.
          expect(data.buildSignature, '');
        });

        test('should default keys missing from version.json to empty values',
            () async {
          _fakeVersionJson.writeAsStringSync(
            jsonEncode(<String, dynamic>{'app_name': 'linux_app'}),
          );

          final data = await PackageInfoPlusLinuxPlugin().getAll();

          expect(data.appName, 'linux_app');
          expect(data.version, '');
          expect(data.buildNumber, '');
          expect(data.packageName, '');
          expect(data.buildSignature, '');
        });

        test('should fall back to empty values for malformed version.json',
            () async {
          // Broken JSON makes the decode throw inside the lookup, which
          // the plugin swallows and reports as empty data.
          _fakeVersionJson.writeAsStringSync('this is not a json payload');

          final data = await PackageInfoPlusLinuxPlugin().getAll();

          expect(data.appName, '');
          expect(data.packageName, '');
          expect(data.version, '');
          expect(data.buildNumber, '');
          expect(data.buildSignature, '');
        });
      },
    );
  });
}
