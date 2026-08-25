// ignore_for_file: deprecated_member_use_from_same_package

import 'package:device_info_plus/src/device_info_plus_linux.dart';
import 'package:device_info_plus_platform_interface/device_info_plus_platform_interface.dart';
import 'package:device_info_plus_platform_interface/method_channel/method_channel_device_info.dart';
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';

/// VM-runnable coverage for [DeviceInfoPlusLinuxPlugin]. The platform-tagged
/// `device_info_plus_linux_test.dart` runs only on Linux, so this file
/// exercises the file-parsing + caching + registration logic on any host using
/// an in-memory file system (no real OS files touched).
void main() {
  tearDown(() {
    // registerWith() mutates the global platform instance; always reset it so
    // the change never leaks into other test files.
    DeviceInfoPlatform.instance = MethodChannelDeviceInfo();
  });

  test('registerWith installs the linux plugin as the platform instance', () {
    DeviceInfoPlusLinuxPlugin.registerWith();
    expect(DeviceInfoPlatform.instance, isA<DeviceInfoPlusLinuxPlugin>());
  });

  group('DeviceInfoPlusLinuxPlugin (VM, in-memory fs)', () {
    test('parses /etc/os-release fields', () async {
      final fs = MemoryFileSystem.test();
      final file = fs.file('/etc/os-release')..createSync(recursive: true);
      file.writeAsStringSync('''
NAME="A Linux"
VERSION="1.2.3 LTS"
ID=foo
VERSION_ID="1.2.3"
PRETTY_NAME="A Linux 1.2.3 LTS"
''');

      final info = await DeviceInfoPlusLinuxPlugin(fileSystem: fs).linuxInfo();
      expect(info.name, 'A Linux');
      expect(info.version, '1.2.3 LTS');
      expect(info.id, 'foo');
      expect(info.versionId, '1.2.3');
      expect(info.prettyName, 'A Linux 1.2.3 LTS');
    });

    test('reads /etc/machine-id', () async {
      final fs = MemoryFileSystem.test();
      fs.file('/etc/machine-id')..createSync(recursive: true)..writeAsStringSync('machine-id');

      final info = await DeviceInfoPlusLinuxPlugin(fileSystem: fs).linuxInfo();
      expect(info.machineId, 'machine-id');
    });

    test('caches the result: second call does not re-read os-release', () async {
      final fs = MemoryFileSystem.test();
      final file = fs.file('/etc/os-release')..createSync(recursive: true);
      file.writeAsStringSync('ID=foo\nNAME="A Linux"');

      final plugin = DeviceInfoPlusLinuxPlugin(fileSystem: fs);
      final first = await plugin.linuxInfo();

      // Mutate the file AFTER the first read; the cache must ignore it.
      file.writeAsStringSync('ID=changed\nNAME="Changed"');
      final second = await plugin.linuxInfo();

      expect(identical(first, second), isTrue);
      expect(second.id, 'foo'); // cached, not the mutated value
    });

    test('falls back to defaults when release files are missing', () async {
      final fs = MemoryFileSystem.test();
      final info = await DeviceInfoPlusLinuxPlugin(fileSystem: fs).linuxInfo();
      expect(info.name, 'Linux');
      expect(info.id, 'linux');
      expect(info.prettyName, 'Linux');
      expect(info.version, isNull);
      expect(info.machineId, isNull);
    });
  });
}
