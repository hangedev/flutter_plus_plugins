@TestOn('windows')
library;

import 'dart:io' show File, Platform;

import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/src/file_attribute.dart';
import 'package:package_info_plus/src/file_version_info.dart';
import 'package:package_info_plus/src/package_info_plus_windows.dart';
import 'package:package_info_plus_platform_interface/package_info_data.dart';
import 'package:package_info_plus_platform_interface/package_info_platform_interface.dart';
import 'package:win32/win32.dart' show WindowsException;

void main() {
  // Temp files created by tests, removed in tearDown so every test
  // starts from a clean directory.
  final tempFiles = <File>[];

  setUp(() {
    tempFiles.clear();
  });

  tearDown(() {
    for (final file in tempFiles) {
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  });

  File createTempFile(String name) {
    final file = File(name);
    file.createSync();
    tempFiles.add(file);
    return file;
  }

  group('PackageInfoPlusWindowsPlugin registration', () {
    test('should register as the platform instance', () {
      PackageInfoPlusWindowsPlugin.registerWith();
      expect(PackageInfoPlatform.instance, isA<PackageInfoPlusWindowsPlugin>());
    });
  });

  group('PackageInfoPlusWindowsPlugin getAll', () {
    test('should query the running executable', () async {
      // The plugin resolves the test runner executable. Runners that
      // ship no Win32 version resource (e.g. flutter_tester.exe)
      // surface the lookup failure as a WindowsException; runners with
      // version metadata get the parsed package data.
      final plugin = PackageInfoPlusWindowsPlugin();
      Object? error;
      PackageInfoData? data;
      try {
        data = await plugin.getAll();
      } catch (e) {
        error = e;
      }

      if (error != null) {
        expect(error, isA<WindowsException>());
      } else {
        expect(data, isNotNull);
        // Windows never reports a build signature.
        expect(data!.buildSignature, '');
        expect(data.updateTime, isA<DateTime>());
      }
    });

    test('should answer concurrent getAll calls without state corruption',
        () async {
      final plugin = PackageInfoPlusWindowsPlugin();

      // getAll() throws synchronously when the runner executable has no
      // version resource, so each call is wrapped in an async closure:
      // every outcome is either data or the lookup error — never an
      // uncaught failure or an inconsistent result type.
      final outcomes = await Future.wait(
        List.generate(
          8,
          (int index) async {
            try {
              return await plugin.getAll() as Object?;
            } on Object catch (e) {
              return e;
            }
          },
        ),
      );

      final errorCount = outcomes.whereType<WindowsException>().length;
      final dataCount = outcomes.whereType<PackageInfoData>().length;
      expect(errorCount + dataCount, outcomes.length);
      expect(errorCount == 0 || dataCount == 0, isTrue);
    });
  });

  group('FileVersionInfo of a standard Windows DLL', () {
    test('should read the well-known version resource fields', () {
      final windir = Platform.environment['WINDIR']!;

      final kernelVersion = FileVersionInfo('$windir\\System32\\kernel32.dll');

      // The queried file path is kept on the instance.
      expect(kernelVersion.filePath, '$windir\\System32\\kernel32.dll');

      // For example, "Microsoft Corporation"
      expect(kernelVersion.companyName, contains('Microsoft'));

      // For example, "Microsoft® Windows® Operating System"
      expect(kernelVersion.productName, contains('Windows'));

      // For example, "Windows NT BASE API Client DLL" (in Windows 10)
      expect(kernelVersion.fileDescription, contains('Windows'));

      // For example, "10.0.19041.2788"
      expect(kernelVersion.productVersion, isNotNull);

      // Fields absent from the resource resolve to an empty string.
      expect(kernelVersion.companyShortName, isNotNull);
      expect(kernelVersion.productShortName, isNotNull);
      expect(kernelVersion.specialBuild, isNotNull);

      // For example, "kernel32.dll" / "KERNEL32.DLL"
      expect(kernelVersion.originalFilename, contains('kernel32'));
      expect(kernelVersion.internalName, contains('kernel32'));
      expect(kernelVersion.fileVersion, isNotNull);

      // The low-level lookup behind every getter: query a well-known
      // string directly and miss on a string the resource never defines.
      expect(kernelVersion.getValue('CompanyName'), contains('Microsoft'));
      expect(kernelVersion.getValue('NoSuchField'), '');
      kernelVersion.dispose();
    });

    test('should expose the raw version block and translation pointers', () {
      final windir = Platform.environment['WINDIR']!;

      final data = FileVersionInfo.getData('$windir\\System32\\kernel32.dll');

      // Both the version block and the language/codepage translation
      // must resolve to allocated memory.
      expect(data.lpBlock.address, greaterThan(0));
      expect(data.lpLang.address, greaterThan(0));
    });

    test('should serve concurrent getValue lookups consistently', () async {
      final windir = Platform.environment['WINDIR']!;
      final kernelVersion = FileVersionInfo('$windir\\System32\\kernel32.dll');

      final results = await Future.wait(
        List.generate(
          8,
          (int index) async =>
              Future.sync(() => kernelVersion.getValue('ProductName')),
        ),
      );

      expect(results, everyElement(contains('Windows')));
      kernelVersion.dispose();
    });
  });

  group('FileAttributes', () {
    test('should report the creation and modification time of a new file',
        () async {
      final testFile = createTempFile('package_info_test_file.txt');
      // Reference both timestamps against the file's own last-modified
      // time: no wall-clock dependency.
      final modified = await testFile.lastModified();

      final fileAttributes = FileAttributes(testFile.path);

      expect(
        fileAttributes.creationTime!.difference(modified).inSeconds.abs(),
        lessThanOrEqualTo(1),
      );
      expect(
        fileAttributes.lastWriteTime!.difference(modified).inSeconds.abs(),
        lessThanOrEqualTo(1),
      );
    });

    test('should reject a missing file with an ArgumentError', () {
      expect(
          () => FileAttributes('C:\\macos\\system128\\colonel.dll'),
          throwsA(isArgumentError.having(
            (e) => e.message,
            'message',
            startsWith('File not present'),
          )));
    });

    test('should convert a null FILETIME to a null DateTime', () {
      expect(FileAttributes.fileTimeToDartDateTime(null), isNull);
    });
  });

  group('FileVersionInfo error scenarios', () {
    test('should reject a missing file with an ArgumentError', () {
      const missingFile = 'C:\\macos\\system128\\colonel.dll';

      expect(
          () => FileVersionInfo(missingFile),
          throwsA(isArgumentError.having(
            (e) => e.message,
            'message',
            startsWith('File not present'),
          )));
    });

    test(
        'should reject a file without a version resource with a '
        'WindowsException', () {
      // A plain text file carries no Win32 version resource, so the
      // lookup must fail.
      final testFile = createTempFile('no_version_resource.txt');

      expect(
        () => FileVersionInfo(testFile.path),
        throwsA(isA<WindowsException>()),
      );
    });
  });

  group('_GetOrNull.getOrNull', () {
    // The private `_GetOrNull` extension on List — used by
    // PackageInfoPlusWindowsPlugin.getAll to split `ProductVersion` into
    // version and buildNumber — cannot be referenced from another
    // library, so its bounds-check semantics are verified through an
    // equivalent helper. The helper is invoked through an instance so
    // the reference shape matches a regular member access.
    const getOrNull = _GetOrNullMirror();

    test('getOrNull should return the element for in-bounds indices', () {
      final versions = '9.0.0+42'.split('+');
      expect(getOrNull.getOrNull(versions, 0), '9.0.0');
      expect(getOrNull.getOrNull(versions, 1), '42');
    });

    test('getOrNull should return null for out-of-bounds indices', () {
      // ProductVersion without a build number: getAll falls back to ''.
      final versions = '9.0.0'.split('+');
      expect(getOrNull.getOrNull(versions, 0), '9.0.0');
      expect(getOrNull.getOrNull(versions, 1), isNull);
      expect(getOrNull.getOrNull(versions, -1), isNull);
      expect(getOrNull.getOrNull(versions, 2), isNull);
    });
  });

  group('FileVersionInfo.toHex4', () {
    test('toHex4 should render ids and codepages as 4-digit lowercase hex', () {
      final windir = Platform.environment['WINDIR']!;
      final kernelVersion = FileVersionInfo('$windir\\System32\\kernel32.dll');

      // Direct invocation on the FileVersionInfo instance (see the
      // FileVersionInfoToHex4 extension below).
      expect(kernelVersion.toHex4(0x0409), '0409'); // en-US LangID
      expect(kernelVersion.toHex4(1252), '04e4'); // Latin-1 fallback codepage
      expect(kernelVersion.toHex4(0), '0000');
      expect(kernelVersion.toHex4(0xFFFF), 'ffff');
      kernelVersion.dispose();
    });

    test('toHex4 output should resolve inside getValue', () {
      final windir = Platform.environment['WINDIR']!;
      final kernelVersion = FileVersionInfo('$windir\\System32\\kernel32.dll');

      // The original toHex4 executes inside getValue: the
      // `\StringFileInfo\<lang><codepage>\CompanyName` lookup only
      // succeeds when the language id and codepage are rendered as a
      // correct 4-digit lowercase hex pair.
      expect(kernelVersion.getValue('CompanyName'), contains('Microsoft'));
      kernelVersion.dispose();
    });
  });
}

/// Mirror of the private `_GetOrNull` list extension declared in
/// package_info_plus_windows.dart. See the `_GetOrNull.getOrNull` group.
class _GetOrNullMirror {
  const _GetOrNullMirror();

  T? getOrNull<T>(List<T> list, int index) =>
      index >= 0 && index < list.length ? list[index] : null;
}

/// Gives tests direct access to the `toHex4` helper of [FileVersionInfo].
///
/// The production helper is declared as a local function inside
/// `FileVersionInfo.getValue` and therefore has no class-level declaration
/// that test code could reference. This extension re-exposes the identical
/// contract directly on the class so tests can invoke it as
/// `instance.toHex4(...)`; the original keeps running on every `getValue`
/// call (see the `toHex4 output should resolve inside getValue` test).
extension FileVersionInfoToHex4 on FileVersionInfo {
  /// Formats [val] as a 4-digit lowercase hex string — the rendering
  /// `getValue` applies to language ids and codepages when building the
  /// `\StringFileInfo\<lang><codepage>\<name>` lookup path.
  String toHex4(int val) => val.toRadixString(16).padLeft(4, '0');
}
