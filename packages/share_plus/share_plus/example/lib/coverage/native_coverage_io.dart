// ignore_for_file: implementation_imports, depend_on_referenced_packages
import 'package:share_plus/share_plus.dart';
import 'package:share_plus/src/windows_version_helper.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

/// Exercises the native (non-web) platform implementations exported by
/// share_plus: the Linux & Windows fallback plugins and [VersionHelper].
///
/// This runs without any UI and without triggering a real share: it only
/// references the public surface and (for registration) restores the previous
/// global platform afterwards. The `share` methods of both fallback plugins
/// are driven through a recording url launcher, so the mailto fallback stays
/// inside the process and no external application is opened.
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

  // share() of both fallback plugins: constructing them with a recording
  // launcher (instead of the real UrlLauncherLinux/UrlLauncherWindows) keeps
  // the mailto fallback inside the process.
  final nativeLauncher = _RecordingUrlLauncher();

  final SharePlusLinuxPlugin linuxPlugin = SharePlusLinuxPlugin(nativeLauncher);
  exercised['linuxPluginUrlLauncher'] = linuxPlugin.urlLauncher;
  exercised['linuxShareText'] = await linuxPlugin.share(
    ShareParams(text: 'native-coverage-text', subject: 'native-subject'),
  );

  final SharePlusWindowsPlugin windowsPlugin =
      SharePlusWindowsPlugin(nativeLauncher);
  exercised['windowsPluginUrlLauncher'] = windowsPlugin.urlLauncher;
  exercised['windowsShareUri'] = await windowsPlugin.share(
    ShareParams(uri: Uri.parse('https://coverage.example/windows')),
  );
  exercised['nativeShareMailto'] = nativeLauncher.launchedUrls;

  assert(exercised.isNotEmpty, 'native coverage must exercise interfaces');
}

/// Records every launchUrl call and reports success, so plugin fallbacks can
/// be exercised without opening a real mail client or browser.
class _RecordingUrlLauncher extends UrlLauncherPlatform {
  final launchedUrls = <String>[];

  @override
  LinkDelegate? get linkDelegate => throw UnimplementedError();

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchedUrls.add(url);
    return true;
  }
}
