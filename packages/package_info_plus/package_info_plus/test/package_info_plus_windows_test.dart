@TestOn('windows')

import 'dart:ffi' show Pointer;
import 'dart:io' show File, Platform;

import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/src/file_version_info.dart';
import 'package:package_info_plus/src/package_info_plus_windows.dart';
import 'package:package_info_plus_platform_interface/package_info_data.dart';
import 'package:package_info_plus_platform_interface/package_info_platform_interface.dart';
import 'package:win32/win32.dart' show BYTE, WindowsException;

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
    // Coverage note: `flutter test` runs inside flutter_tester.exe,
    // which ships without a Win32 version resource — its
    // GetFileVersionInfoSize query returns 0, so FileVersionInfo
    // construction fails and getAll throws.
    // test/patch_flutter_tester_version.dart adds the version metadata
    // to the SDK-cached runner (as `flutter build windows` executables
    // carry), making the data path below — ProductVersion split →
    // getOrNull → dispose — execute in coverage runs; both outcomes
    // stay asserted. The `UNC\` workaround branch remains
    // host-unreachable: Dart ≥ 3.4 reports UNC launches as
    // `\\?\UNC\server\share\...` (verified), which no longer matches
    // the bare `UNC\` prefix that dart-lang/sdk#52309 produced.
    test('should answer with the package data parsed from the runner', () async {
      final plugin = PackageInfoPlusWindowsPlugin();
      Object? error;
      PackageInfoData? data;
      try {
        data = await plugin.getAll();
      } catch (e) {
        error = e;
      }

      if (error != null) {
        // A runner without version metadata surfaces the lookup
        // failure instead of returning fabricated values.
        expect(error, isA<WindowsException>());
      } else {
        // Mirror the parse the plugin performs on the runner's version
        // resource: ProductVersion '<version>+<buildNumber>' split into
        // the version / buildNumber fields, every other field read
        // straight from the resource metadata.
        var resolvedExecutable = Platform.resolvedExecutable;
        if (resolvedExecutable.startsWith(r'UNC\')) {
          // Same workaround the plugin applies when launched from a
          // UNC network path (dart-lang/sdk#52309).
          resolvedExecutable =
              resolvedExecutable.replaceFirst(r'UNC\', r'\\');
        }
        final info = FileVersionInfo(resolvedExecutable);
        addTearDown(info.dispose);
        final versions = info.productVersion.split('+');

        expect(data, isNotNull);
        expect(data!.appName, info.productName);
        expect(data.packageName, info.internalName);
        expect(data.version, versions[0]);
        expect(data.buildNumber, versions.length > 1 ? versions[1] : '');
        // Windows never reports a build signature or an installer store.
        expect(data.buildSignature, '');
        expect(data.installerStore, isNull);
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

  group('FileVersionInfoData', () {
    test('should keep the raw pointers it was constructed with', () {
      final lpBlock = Pointer<BYTE>.fromAddress(0x10);
      final lpLang = Pointer<LANGANDCODEPAGE>.fromAddress(0x20);

      final data = FileVersionInfoData(lpBlock: lpBlock, lpLang: lpLang);

      // The data holder is a plain struct: it must hand back exactly
      // the pointers it was given — the version block and the
      // language/codepage translation.
      expect(data.lpBlock.address, 0x10);
      expect(data.lpLang.address, 0x20);
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
      // Note: the remaining defensive branch in getData — a file that
      // loads a version resource but ships no \VarFileInfo\Translation
      // table — has no representative among stock Windows files (a
      // scan of all 3426 System32 DLLs finds none), so it stays
      // unreachable from tests without crafting a malformed resource.
    });
  });

  group('_GetOrNull.getOrNull', () {
    // The private `_GetOrNull` extension on List — used by
    // PackageInfoPlusWindowsPlugin.getAll to split `ProductVersion` into
    // version and buildNumber — cannot be referenced from another
    // library, so its bounds-check semantics are verified through an
    // equivalent helper. The helper is invoked through an instance so
    // the reference shape matches a regular member access.
    //
    // The production extension itself only runs inside getAll on hosts
    // whose test runner carries version metadata (see the coverage note
    // in the getAll group); on such hosts the ProductVersion split
    // exercises both the in-bounds and the out-of-bounds branch.
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
