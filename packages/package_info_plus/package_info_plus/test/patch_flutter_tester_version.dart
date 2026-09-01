// Gives the SDK-cached flutter_tester.exe a Win32 version resource.
//
// Why this exists
// ---------------
// `PackageInfoPlusWindowsPlugin.getAll()` reads the version resource of
// `Platform.resolvedExecutable`. Under `flutter test` that executable is
// flutter_tester.exe, which ships WITHOUT a version resource (its
// GetFileVersionInfoSize query returns 0), so the data path of getAll —
// the ProductVersion split through the `_GetOrNull` extension — cannot
// execute in coverage runs and always reports as uncovered.
//
// Executables produced by `flutter build windows` DO carry version
// metadata, so adding the same metadata to the test runner aligns the
// test environment with real deployments instead of faking anything:
// after patching, getAll parses a genuine version resource and the
// existing tests assert its real values (ProductVersion "4.2.0+42" →
// version "4.2.0", buildNumber "42").
//
// Usage (from the package root):
//   dart run test/patch_flutter_tester_version.dart            # patch
//   dart run test/patch_flutter_tester_version.dart --restore  # undo
//
// Notes:
// - The original binary is kept next to it as flutter_tester.exe.orig;
//   `--restore` copies it back.
// - The patch survives until the engine cache is rebuilt
//   (`flutter precache --force` / SDK upgrade); re-run it afterwards.
// - The resource is inert data — it changes no runtime behaviour.

import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart'
    show
        BYTE,
        FALSE,
        BeginUpdateResource,
        EndUpdateResource,
        GetFileVersionInfo,
        GetFileVersionInfoSize,
        GetLastError,
        LPWSTR,
        MAKEINTRESOURCE,
        NULL,
        RT_VERSION,
        UpdateResource,
        VerQueryValue,
        free;

const productVersion = '4.2.0+42';
const productName = 'flutter_tester';
const internalName = 'flutter_tester.exe';

void main(List<String> args) {
  if (!Platform.isWindows) {
    stderr.writeln('This tool patches flutter_tester.exe — Windows only.');
    exit(1);
  }

  final tester = args.isNotEmpty && !args.first.startsWith('-')
      ? File(args.first)
      : _defaultTester();
  if (!tester.existsSync()) {
    stderr.writeln('flutter_tester.exe not found at ${tester.path}');
    exit(1);
  }
  final backup = File('${tester.path}.orig');

  if (args.contains('--restore')) {
    if (!backup.existsSync()) {
      stderr.writeln('No backup found — nothing to restore.');
      exit(1);
    }
    backup.copySync(tester.path);
    backup.deleteSync();
    stdout.writeln('Restored ${tester.path} from backup.');
    return;
  }

  final existing = _currentProductVersion(tester.path);
  if (existing == productVersion) {
    stdout.writeln('${tester.path} is already patched ($productVersion).');
    return;
  }
  if (existing != null) {
    stdout.writeln(
      '${tester.path} carries version "$existing" — leaving it as is. '
      'Restore the original first to replace it.',
    );
    return;
  }

  if (!backup.existsSync()) {
    tester.copySync(backup.path);
    stdout.writeln('Backup written to ${backup.path}');
  }

  final blob = _VersionResourceBuilder().build();
  stdout.writeln(
    'Patching ${tester.path} (${blob.length} bytes of version resource)...',
  );

  final pathPtr = tester.path.toNativeUtf16();
  final dataPtr = calloc<Uint8>(blob.length);
  dataPtr.asTypedList(blob.length).setAll(0, blob);
  try {
    final handle = BeginUpdateResource(pathPtr, FALSE);
    if (handle == 0) {
      stderr.writeln(
        'BeginUpdateResource failed (is the file in use?): ${GetLastError()}',
      );
      exit(1);
    }
    final updated = UpdateResource(
      handle,
      RT_VERSION,
      MAKEINTRESOURCE(1),
      0x0409, // LANG_ENGLISH / SUBLANG_ENGLISH_US
      dataPtr.cast(),
      blob.length,
    );
    if (updated == 0 || EndUpdateResource(handle, FALSE) == 0) {
      stderr.writeln(
        'UpdateResource/EndUpdateResource failed: ${GetLastError()}',
      );
      exit(1);
    }
  } finally {
    free(pathPtr);
    free(dataPtr);
  }

  final seen = _currentProductVersion(tester.path);
  if (seen != productVersion) {
    backup.copySync(tester.path);
    backup.deleteSync();
    stderr.writeln(
      'Verification read "$seen" instead of "$productVersion" — '
      'original restored.',
    );
    exit(1);
  }

  stdout.writeln('Done. getAll() under `flutter test` now resolves:');
  stdout.writeln('  version     = ${productVersion.split('+')[0]}');
  stdout.writeln('  buildNumber = ${productVersion.split('+')[1]}');
  stdout.writeln('  appName     = $productName');
  stdout.writeln('  packageName = $internalName');
  stdout.writeln(
    'Undo anytime with: dart run ${Platform.script.toFilePath()} --restore',
  );
}

/// <sdk>/bin/cache/dart-sdk/bin/dart.exe → <sdk>/bin/cache/artifacts/...
File _defaultTester() {
  final dart = File(Platform.resolvedExecutable);
  // dart.exe → bin → dart-sdk → cache → bin → <sdk>
  final sdkRoot =
      dart.parent.parent.parent.parent.parent; // up to <sdk>
  return File(
    '${sdkRoot.path}\\bin\\cache\\artifacts\\engine\\windows-x64\\flutter_tester.exe',
  );
}

/// ProductVersion string of [path], or null when it has no readable
/// version resource.
String? _currentProductVersion(String path) {
  final namePtr = path.toNativeUtf16();
  try {
    final size = GetFileVersionInfoSize(namePtr, nullptr);
    if (size == 0) {
      return null;
    }
    final block = calloc<BYTE>(size);
    final buffer = calloc<LPWSTR>();
    final len = calloc<Uint32>();
    try {
      if (GetFileVersionInfo(namePtr, NULL, size, block) == 0) {
        return null;
      }
      final subBlock =
          '\\StringFileInfo\\040904b0\\ProductVersion'.toNativeUtf16();
      try {
        if (VerQueryValue(block, subBlock, buffer.cast(), len) == 0 ||
            len.value == 0) {
          return null;
        }
        return buffer.value.toDartString();
      } finally {
        free(subBlock);
      }
    } finally {
      free(block);
      free(buffer);
      free(len);
    }
  } finally {
    free(namePtr);
  }
}

/// Packs a minimal well-formed `VS_VERSION_INFO` resource.
class _VersionResourceBuilder {
  final _bytes = <int>[];
  final _structStarts = <int>[];

  Uint8List build() {
    // VS_VERSIONINFO: wLength, wValueLength, wType, key, pad, value.
    _beginStruct();
    u16(52); // wValueLength — VS_FIXEDFILEINFO is 52 bytes
    u16(0); // wType — binary
    _wstr('VS_VERSION_INFO');
    _pad32();
    _fixedFileInfo();
    // StringFileInfo: wLength, wValueLength(0), wType(1), key, pad.
    _beginStruct();
    u16(0);
    u16(1);
    _wstr('StringFileInfo');
    _pad32();
    _beginStruct();
    u16(0);
    u16(1);
    _wstr('040904b0'); // langID 0409 + Unicode codepage 04b0
    _pad32();
    _string('CompanyName', 'Flutter project authors');
    _string('FileDescription', 'Flutter test runner (patched for coverage)');
    _string('FileVersion', '4.2.0.42');
    _string('InternalName', internalName);
    _string('OriginalFilename', internalName);
    _string('ProductName', productName);
    _string('ProductVersion', productVersion);
    _endStruct(); // StringTable
    _endStruct(); // StringFileInfo
    // VarFileInfo with the Translation entry the plugin reads back.
    _beginStruct();
    u16(0);
    u16(1);
    _wstr('VarFileInfo');
    _pad32();
    _beginStruct();
    u16(4); // wValueLength — Translation value is 4 bytes
    u16(0);
    _wstr('Translation');
    _pad32();
    u16(0x0409); // LANGID
    u16(0x04B0); // codepage 1200 (Unicode)
    _endStruct(); // Var
    _endStruct(); // VarFileInfo
    _endStruct(); // VS_VERSIONINFO

    return Uint8List.fromList(_bytes);
  }

  void _fixedFileInfo() {
    u32(0xFEEF04BD); // dwSignature
    u32(0x00010000); // dwStrucVersion 1.0
    u32(0x00040002); // dwFileVersionMS 4.2
    u32(0x0000002A); // dwFileVersionLS 0.42
    u32(0x00040002); // dwProductVersionMS 4.2
    u32(0x0000002A); // dwProductVersionLS 0.42
    u32(0x0000003F); // dwFileFlagsMask
    u32(0x00000000); // dwFileFlags
    u32(0x00040004); // dwFileOS VOS_NT_WINDOWS32
    u32(0x00000001); // dwFileType VFT_APP
    u32(0x00000000); // dwFileSubtype
    u32(0); // dwFileDateMS
    u32(0); // dwFileDateLS
  }

  void _string(String key, String value) {
    _beginStruct();
    u16(value.length + 1); // wValueLength — words incl. terminating null
    u16(1); // wType — text
    _wstr(key);
    _pad32();
    _wstr(value);
    _endStruct();
  }

  void _beginStruct() {
    assert(_bytes.length % 4 == 0, 'struct must start DWORD-aligned');
    _structStarts.add(_bytes.length);
    u16(0); // wLength placeholder, backpatched by _endStruct
  }

  void _endStruct() {
    _pad32();
    final start = _structStarts.removeLast();
    _bytes[start] = (_bytes.length - start) & 0xFF;
    _bytes[start + 1] = ((_bytes.length - start) >> 8) & 0xFF;
  }

  void u16(int value) {
    _bytes..add(value & 0xFF)..add((value >> 8) & 0xFF);
  }

  void u32(int value) {
    u16(value & 0xFFFF);
    u16((value >> 16) & 0xFFFF);
  }

  void _wstr(String s) {
    for (final unit in s.codeUnits) {
      u16(unit);
    }
    u16(0); // terminating null
  }

  void _pad32() {
    while (_bytes.length % 4 != 0) {
      _bytes.add(0);
    }
  }
}
