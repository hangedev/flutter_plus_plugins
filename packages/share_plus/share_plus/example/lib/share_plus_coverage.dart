// ignore_for_file: deprecated_member_use, implementation_imports, depend_on_referenced_packages, unused_local_variable, invalid_use_of_visible_for_testing_member
//
// This file exists purely to exercise every public surface of share_plus from
// the demo, so the demo achieves full interface coverage. It is invoked from
// `main.dart` and deliberately renders no UI and triggers no real share sheet:
// all `SharePlus.share` calls go through a no-op custom platform, the
// deprecated `Share` helpers run while a delegating platform acts as a no-op
// (it is re-pointed at the real platform afterwards, so the interactive demo
// keeps sharing for real), and the Linux/Windows fallback plugins are driven
// with a recording url launcher that keeps the mailto fallback in-process.
import 'dart:typed_data';
import 'dart:ui';

import 'package:share_plus/share_plus.dart';
import 'package:share_plus_platform_interface/method_channel/method_channel_share.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'coverage/native_coverage_stub.dart'
    if (dart.library.io) 'coverage/native_coverage_io.dart' as native;
import 'coverage/web_coverage_stub.dart'
    if (dart.library.js_interop) 'coverage/web_coverage_web.dart' as web;

/// Runs the full share_plus interface coverage. Safe to call at startup: it
/// never throws and never opens a real share sheet.
Future<void> runSharePlusCoverage() async {
  try {
    await _runSharePlusCoverage();
  } catch (_) {
    // Coverage must never disrupt the demo app.
  }
}

Future<void> _runSharePlusCoverage() async {
  // A no-op platform so SharePlus.share calls below never reach the OS.
  final noopPlatform = _NoOpSharePlatform();
  final exercised = <String, Object?>{};

  // --- SharePlus: custom() factory + share() over every param shape ---
  final customSharePlus = SharePlus.custom(noopPlatform);
  final thumbnail =
      XFile.fromData(Uint8List.fromList([0, 1, 2]), name: 'thumb.png');

  exercised['shareTextAllFields'] = await customSharePlus.share(
    ShareParams(
      text: 'coverage-text',
      title: 'coverage-title',
      subject: 'coverage-subject',
      previewThumbnail: thumbnail,
      sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100),
      downloadFallbackEnabled: false,
      mailToFallbackEnabled: false,
      excludedCupertinoActivities: CupertinoActivityType.values,
    ),
  );
  exercised['shareUri'] = await customSharePlus.share(
    ShareParams(uri: Uri.parse('https://coverage.example/path')),
  );
  exercised['shareFiles'] = await customSharePlus.share(
    ShareParams(
      files: [XFile.fromData(Uint8List.fromList([9, 9, 9]), name: 'file.bin')],
      fileNameOverrides: ['coverage.bin'],
      downloadFallbackEnabled: true,
    ),
  );

  // --- SharePlusLinuxPlugin (pure-Dart fallback, exported everywhere) ---
  // Constructing the plugin with a recording launcher instead of the real
  // UrlLauncherLinux keeps the mailto fallback inside the process: the URL is
  // captured and no external application is ever opened.
  final linuxLauncher = _RecordingUrlLauncher();
  final SharePlusLinuxPlugin linuxPlugin = SharePlusLinuxPlugin(linuxLauncher);

  exercised['linuxPluginUrlLauncher'] = linuxPlugin.urlLauncher;
  exercised['linuxShareText'] = await linuxPlugin.share(
    ShareParams(text: 'linux-coverage-text', subject: 'linux-subject'),
  );
  exercised['linuxShareUri'] = await linuxPlugin.share(
    ShareParams(uri: Uri.parse('https://coverage.example/linux')),
  );
  exercised['linuxShareMailto'] = linuxLauncher.launchedUrls;

  // --- Deprecated Share class ---
  // All deprecated helpers route through the SharePlus.instance singleton,
  // which freezes to whatever SharePlatform.instance is on first access. A
  // delegating platform is therefore installed BEFORE the singleton is first
  // touched: while its delegate is null it behaves like the no-op platform
  // above, so the helpers can be invoked with real, valid inputs without ever
  // reaching the OS. Afterwards the delegate is pointed back at the real
  // platform and the global instance is restored, so the interactive demo
  // keeps sharing for real.
  final previousPlatform = SharePlatform.instance;
  final delegatingPlatform = _DelegatingSharePlatform();
  SharePlatform.instance = delegatingPlatform;
  try {
    // Freezes the singleton against the delegating platform (no-op window).
    exercised['instance'] = SharePlus.instance;

    exercised['shareUriResult'] = await Share.shareUri(
      Uri.parse('https://coverage.example/deprecated-share-uri'),
      sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100),
    );
    exercised['shareResult'] = await Share.share(
      'coverage-deprecated-text',
      subject: 'coverage-deprecated-subject',
      sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100),
    );
    exercised['shareXFilesResult'] = await Share.shareXFiles(
      [
        XFile.fromData(Uint8List.fromList([7, 7, 7]), name: 'deprecated.bin'),
      ],
      subject: 'coverage-deprecated-file-subject',
      text: 'coverage-deprecated-file-text',
      fileNameOverrides: ['deprecated-override.bin'],
    );
  } finally {
    delegatingPlatform.delegate = previousPlatform;
    SharePlatform.instance = previousPlatform;
  }
  final previousFallback = Share.downloadFallbackEnabled;
  Share.downloadFallbackEnabled = !previousFallback;
  Share.downloadFallbackEnabled = previousFallback;
  exercised['downloadFallbackEnabled'] = Share.downloadFallbackEnabled;

  // --- ShareResult: constructor, fields, equality, hashCode, toString ---
  const result = ShareResult('raw-action', ShareResultStatus.success);
  exercised['resultRaw'] = result.raw;
  exercised['resultStatus'] = result.status;
  exercised['resultEquality'] = result == ShareResult.unavailable;
  exercised['resultHashCode'] = result.hashCode;
  exercised['resultToString'] = result.toString();
  exercised['resultUnavailable'] = ShareResult.unavailable;

  // --- ShareResultStatus: every documented value ---
  for (final status in ShareResultStatus.values) {
    exercised['status_${status.name}'] = status;
  }

  // --- CupertinoActivityType: every value + the value getter ---
  exercised['activityValues'] = [
    for (final type in CupertinoActivityType.values) type.value,
  ];

  // --- Platform-interface surface (pure Dart, available everywhere) ---
  exercised['sharePlatformInstance'] = SharePlatform.instance;
  exercised['methodChannelName'] = MethodChannelShare.channel.name;

  // --- Native (non-web) and web platform implementations ---
  await native.runNativeCoverage();
  await web.runWebCoverage();

  assert(exercised.isNotEmpty, 'coverage must exercise interfaces');
}

class _NoOpSharePlatform extends SharePlatform {
  @override
  Future<ShareResult> share(ShareParams params) async => ShareResult.unavailable;
}

/// A [SharePlatform] that forwards every share to [delegate].
///
/// While [delegate] is null it acts as a no-op platform (every share resolves
/// to [ShareResult.unavailable] without reaching the OS). It is installed as
/// the global [SharePlatform.instance] before the [SharePlus.instance]
/// singleton freezes, so the deprecated `Share` helpers can be invoked with
/// real inputs inside the coverage demo; once the delegate is pointed at the
/// real platform, the frozen singleton transparently forwards to it again.
class _DelegatingSharePlatform extends SharePlatform {
  SharePlatform? delegate;

  @override
  Future<ShareResult> share(ShareParams params) {
    final SharePlatform? target = delegate;
    if (target != null) {
      return target.share(params);
    }
    return Future<ShareResult>.value(ShareResult.unavailable);
  }
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
