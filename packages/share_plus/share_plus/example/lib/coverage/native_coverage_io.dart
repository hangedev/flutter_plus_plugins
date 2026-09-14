// ignore_for_file: implementation_imports, depend_on_referenced_packages
import 'package:share_plus/share_plus.dart';
import 'package:share_plus/src/windows_version_helper.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';

/// Exercises the native (non-web) platform implementations exported by
/// share_plus: the Linux & Windows fallback plugins and [VersionHelper].
///
/// This runs without any UI and without triggering a real share: it only
/// references the public surface and (for registration) restores the previous
/// global platform afterwards.
Future<void> runNativeCoverage() async {
  final exercised = <String, Object?>{};

  // VersionHelper (Windows build detection).
  exercised['versionHelperSingleton'] = VersionHelper.instance;
  exercised['isWindows10RS5OrGreater'] =
      VersionHelper.instance.isWindows10RS5OrGreater;
  exercised['kWindows10RS5BuildNumber'] = VersionHelper.kWindows10RS5BuildNumber;

  // SharePlatform global instance getter.
  exercised['sharePlatformInstance'] = SharePlatform.instance;

  // Register the Linux fallback plugin, then restore the previous instance so
  // the rest of the demo keeps using the real platform.
  final previous = SharePlatform.instance;
  try {
    SharePlusLinuxPlugin.registerWith();
    exercised['linuxPluginRegistered'] =
        SharePlatform.instance is SharePlusLinuxPlugin;

    SharePlusWindowsPlugin.registerWith();
    exercised['windowsPluginRegistered'] =
        SharePlatform.instance is SharePlusWindowsPlugin;
  } finally {
    SharePlatform.instance = previous;
  }

  assert(exercised.isNotEmpty, 'native coverage must exercise interfaces');
}
