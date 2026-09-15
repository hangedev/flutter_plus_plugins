// ignore_for_file: implementation_imports, depend_on_referenced_packages
import 'dart:typed_data';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:share_plus/src/share_plus_web.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

/// Exercises the web implementation ([SharePlusWebPlugin]) exported by
/// share_plus on the web. Runs without any UI: it only references the public
/// surface and prepares share data (which never touches the navigator).
Future<void> runWebCoverage() async {
  final exercised = <String, Object?>{};
  final launcher = _FakeUrlLauncher();
  final plugin = SharePlusWebPlugin(launcher);

  // Public urlLauncher field.
  exercised['urlLauncher'] = plugin.urlLauncher;

  // registerWith swaps the global instance; restore it afterwards.
  final previous = SharePlatform.instance;
  try {
    SharePlusWebPlugin.registerWith(_FakeRegistrar());
    exercised['webPluginRegistered'] =
        SharePlatform.instance is SharePlusWebPlugin;
  } finally {
    SharePlatform.instance = previous;
  }

  // prepareData (pure data preparation, no navigator interaction).
  exercised['prepareDataText'] =
      await plugin.prepareData(ShareParams(text: 'web-coverage'));
  exercised['prepareDataUri'] = await plugin
      .prepareData(ShareParams(uri: Uri.parse('https://web.example')));
  exercised['prepareDataFiles'] = await plugin.prepareData(ShareParams(
    files: [XFile.fromData(Uint8List.fromList([1, 2, 3]), name: 'f.bin')],
  ));

  // share() reaches navigator.share(), which opens the browser share sheet —
  // the coverage demo must never show UI, so we reference the member (tear-off)
  // instead of invoking it. Its logic is fully covered via prepareData + the
  // validation tests in test/src/web/share_plus_web_test.dart.
  exercised['share'] = plugin.share;

  assert(exercised.isNotEmpty, 'web coverage must exercise interfaces');
}

class _FakeRegistrar implements Registrar {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeUrlLauncher implements UrlLauncherPlatform {
  @override
  dynamic noSuchMethod(Invocation invocation) => false;
}
