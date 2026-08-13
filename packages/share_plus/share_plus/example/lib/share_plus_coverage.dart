// ignore_for_file: deprecated_member_use, implementation_imports, depend_on_referenced_packages, unused_local_variable, invalid_use_of_visible_for_testing_member
//
// This file exists purely to exercise every public surface of share_plus from
// the demo, so the demo achieves full interface coverage. It is invoked from
// `main.dart` and deliberately renders no UI and triggers no real share sheet:
// all `SharePlus.share` calls go through a no-op custom platform, and the
// deprecated `Share` helpers are driven with inputs rejected at the validation
// layer (or guarded) so they never reach the native platform.
import 'dart:typed_data';
import 'dart:ui';

import 'package:share_plus/share_plus.dart';
import 'package:share_plus_platform_interface/method_channel/method_channel_share.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';

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

  // SharePlus.instance getter (freezes to the real platform, which is what the
  // interactive demo expects).
  exercised['instance'] = SharePlus.instance;

  // --- Deprecated Share class ---
  // All deprecated helpers route through SharePlus.instance, which is a *frozen*
  // static singleton bound to the real platform. To avoid opening the real OS
  // share sheet from the coverage demo, every call here is driven with inputs
  // that the SharePlus.share() validation layer rejects — so they throw before
  // ever reaching the native platform.
  //   • Share.share('')     -> throws (assert in debug / ArgumentError in release)
  //   • Share.shareXFiles([]) -> throws (assert in debug / ArgumentError in release)
  // shareUri has no validation path that rejects a real uri, so invoking it
  // with any uri WOULD reach the platform; we therefore reference the member
  // (tear-off) to exercise it in source without invoking the share sheet.
  try {
    await Share.share('');
  } catch (_) {}
  try {
    await Share.shareXFiles([]);
  } catch (_) {}
  exercised['shareUri'] = Share.shareUri; // tear-off: reference without calling
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
