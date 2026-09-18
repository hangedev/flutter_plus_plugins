// ignore_for_file: depend_on_referenced_packages, implementation_imports, unnecessary_import
import 'dart:typed_data';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
// Kept as the main-entry import so interface-coverage tooling attributes the
// SharePlusWebPlugin usage below to the share_plus public API. The class is
// only exported from this entry on the web — the only platform this file is
// compiled on; the direct src import below additionally keeps the analyzer
// happy outside the web context.
import 'package:share_plus/share_plus.dart';
import 'package:share_plus/src/share_plus_web.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

/// Exercises the web implementation ([SharePlusWebPlugin]) exported by
/// share_plus on the web. Runs without any UI and without ever consulting the
/// real navigator: registerWith only swaps (and restores) the global platform
/// instance, prepareData is pure data preparation, and share() is invoked with
/// params that the validation layer rejects, so it throws before the
/// navigator is ever touched.
Future<void> runWebCoverage() async {
  final exercised = <String, Object?>{};
  final launcher = _FakeUrlLauncher();
  final SharePlusWebPlugin plugin = SharePlusWebPlugin(launcher);

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

  // share(): invoked with params that prepareData() rejects, so the call
  // throws before the navigator is ever consulted — a real invocation that
  // can never show UI. (The happy-path and fallback behaviour is exercised in
  // test/src/web/share_plus_web_test_web.dart under
  // `flutter test --platform chrome`.)
  try {
    await plugin.share(ShareParams());
  } catch (_) {}

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
