// ignore_for_file: implementation_imports, unnecessary_import
// Browser-only tests for [SharePlusWebPlugin], executed through the
// conditional import in `share_plus_web_test.dart` under
// `flutter test --platform chrome test/src/web/`.
//
// The main-entry import below is what interface-coverage tooling attributes
// the SharePlusWebPlugin usage to; the direct src import additionally keeps
// the analyzer happy outside the web context (the main entry only exports the
// web plugin when compiled for the web).
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:share_plus/share_plus.dart';
import 'package:share_plus/src/share_plus_web.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

void main() {
  group('SharePlusWebPlugin', () {
    test('should be constructable with a custom url launcher', () {
      final SharePlusWebPlugin plugin = SharePlusWebPlugin(_FakeUrlLauncher());

      expect(plugin, isA<SharePlusWebPlugin>());
      expect(plugin.urlLauncher, isA<UrlLauncherPlatform>());
    });

    test('should register itself as the SharePlatform instance', () {
      final SharePlatform previous = SharePlatform.instance;
      try {
        SharePlusWebPlugin.registerWith(_FakeRegistrar());

        expect(SharePlatform.instance, isA<SharePlusWebPlugin>());
      } finally {
        SharePlatform.instance = previous;
      }
    });

    group('share', () {
      // Calls share() end-to-end up to the validation layer; no navigator is
      // consulted because prepareData rejects the empty params first.
      test('should throw ArgumentError when nothing is provided', () {
        final SharePlusWebPlugin plugin = SharePlusWebPlugin(_FakeUrlLauncher());

        expect(
          () => plugin.share(ShareParams()),
          throwsA(isA<ArgumentError>()),
        );
      });

      // In a headless browser the Web Share API either reports canShare false,
      // throws NoSuchMethodError (unsupported User Agent) or rejects the
      // share() call (no user activation) — every branch funnels into the
      // fallback layer, which is what these end-to-end cases pin down.
      test('should fall back to a mailto url when sharing text', () async {
        final _RecordingUrlLauncher launcher = _RecordingUrlLauncher();
        final SharePlusWebPlugin plugin = SharePlusWebPlugin(launcher);

        final result = await plugin.share(ShareParams(
          text: 'hello',
          mailToFallbackEnabled: true,
        ));

        expect(result, ShareResult.unavailable);
        expect(launcher.launchedUrls.single, 'mailto:?body=hello');
      });

      test('should url-encode subject and body in the mailto fallback',
          () async {
        final _RecordingUrlLauncher launcher = _RecordingUrlLauncher();
        final SharePlusWebPlugin plugin = SharePlusWebPlugin(launcher);

        await plugin.share(ShareParams(
          text: 'foo bar',
          subject: 'bar foo',
          mailToFallbackEnabled: true,
        ));

        expect(launcher.launchedUrls.single,
            'mailto:?subject=bar%20foo&body=foo%20bar');
      });

      test('should fall back to a mailto url when sharing a uri', () async {
        final _RecordingUrlLauncher launcher = _RecordingUrlLauncher();
        final SharePlusWebPlugin plugin = SharePlusWebPlugin(launcher);

        await plugin.share(ShareParams(
          uri: Uri.parse('https://example.com/path'),
          mailToFallbackEnabled: true,
        ));

        expect(launcher.launchedUrls.single,
            'mailto:?body=https%3A%2F%2Fexample.com%2Fpath');
      });

      test('should throw when the mailto fallback is disabled', () async {
        final _RecordingUrlLauncher launcher = _RecordingUrlLauncher();
        final SharePlusWebPlugin plugin = SharePlusWebPlugin(launcher);

        await expectLater(
          plugin.share(ShareParams(
            text: 'hello',
            mailToFallbackEnabled: false,
          )),
          throwsA(isA<Exception>()),
        );
        expect(launcher.launchedUrls, isEmpty);
      });

      test('should throw when the url launcher reports failure', () async {
        final _RecordingUrlLauncher launcher = _RecordingUrlLauncher()
          ..shouldLaunch = false;
        final SharePlusWebPlugin plugin = SharePlusWebPlugin(launcher);

        await expectLater(
          plugin.share(ShareParams(
            text: 'hello',
            mailToFallbackEnabled: true,
          )),
          throwsA(isA<Exception>()),
        );
        expect(launcher.launchedUrls.single, 'mailto:?body=hello');
      });

      test('should download files when the download fallback is enabled',
          () async {
        final _RecordingUrlLauncher launcher = _RecordingUrlLauncher();
        final SharePlusWebPlugin plugin = SharePlusWebPlugin(launcher);

        final result = await plugin.share(ShareParams(
          files: [
            XFile.fromData(Uint8List.fromList([1, 2, 3]), name: 'a.bin'),
          ],
          downloadFallbackEnabled: true,
        ));

        // The anchor download is a no-op in the test browser; the result of
        // the download fallback is still `unavailable`.
        expect(result, ShareResult.unavailable);
        expect(launcher.launchedUrls, isEmpty);
      });

      test('should throw when sharing files with no fallback enabled',
          () async {
        final _RecordingUrlLauncher launcher = _RecordingUrlLauncher();
        final SharePlusWebPlugin plugin = SharePlusWebPlugin(launcher);

        await expectLater(
          plugin.share(ShareParams(
            files: [
              XFile.fromData(Uint8List.fromList([1, 2, 3]), name: 'a.bin'),
            ],
            downloadFallbackEnabled: false,
          )),
          throwsA(isA<Exception>()),
        );
        expect(launcher.launchedUrls, isEmpty);
      });
    });

    group('prepareData', () {
      late SharePlusWebPlugin plugin;

      setUp(() => plugin = SharePlusWebPlugin(_FakeUrlLauncher()));

      test('should build url-only data when a uri is given', () async {
        final data = await plugin
            .prepareData(ShareParams(uri: Uri.parse('https://example.com')));

        expect(data.url, 'https://example.com');
        expect(data.text, isNull);
        expect(data.title, isNull);
      });

      test('should build text-only data when only text is given', () async {
        final data = await plugin.prepareData(ShareParams(text: 'hello'));

        expect(data.text, 'hello');
        expect(data.title, isNull);
      });

      test('should use subject (then title) as the share title', () async {
        final withSubject = await plugin
            .prepareData(ShareParams(text: 'hello', subject: 'subj'));
        expect(withSubject.title, 'subj');

        final withTitle =
            await plugin.prepareData(ShareParams(text: 'hello', title: 't'));
        expect(withTitle.title, 't');

        final withBoth = await plugin.prepareData(
            ShareParams(text: 'hello', subject: 'subj', title: 't'));
        // subject takes precedence over title.
        expect(withBoth.title, 'subj');
      });

      test('should include files (and overrides) in the data', () async {
        final data = await plugin.prepareData(ShareParams(
          files: [
            XFile.fromData(Uint8List.fromList([1, 2, 3]), name: 'a.png'),
          ],
          fileNameOverrides: ['renamed.png'],
          text: 'caption',
        ));

        expect(data.text, 'caption');
        expect(data.files.length, 1);
      });

      test('should throw ArgumentError when neither uri, text nor files given',
          () {
        expect(
          () => plugin.prepareData(ShareParams()),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError when both uri and text are given', () {
        expect(
          () => plugin.prepareData(
            ShareParams(uri: Uri.parse('https://e.com'), text: 't'),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}

class _FakeRegistrar implements Registrar {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeUrlLauncher implements UrlLauncherPlatform {
  @override
  dynamic noSuchMethod(Invocation invocation) => false;
}

/// Records every launchUrl call and returns [shouldLaunch].
class _RecordingUrlLauncher implements UrlLauncherPlatform {
  final launchedUrls = <String>[];
  bool shouldLaunch = true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchedUrls.add(url);
    return shouldLaunch;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
