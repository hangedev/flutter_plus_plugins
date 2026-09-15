import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/src/share_plus_windows.dart';
import 'package:share_plus/src/windows_version_helper.dart';
import 'package:share_plus_platform_interface/method_channel/method_channel_share.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';

import 'url_launcher_mock.dart';

void main() {
  late SharePlatform originalPlatform;

  setUp(() => originalPlatform = SharePlatform.instance);

  tearDown(() => SharePlatform.instance = originalPlatform);

  group('SharePlusWindowsPlugin registration', () {
    test(
      'should register the fallback plugin below Windows 10 RS5',
      () {
        SharePlusWindowsPlugin.registerWith();
        expect(SharePlatform.instance, isA<SharePlusWindowsPlugin>());
      },
      skip: VersionHelper.instance.isWindows10RS5OrGreater,
    );

    test(
      'should keep the MethodChannelShare on Windows 10 RS5 or greater',
      () {
        SharePlusWindowsPlugin.registerWith();
        expect(SharePlatform.instance, isA<MethodChannelShare>());
      },
      skip: !VersionHelper.instance.isWindows10RS5OrGreater,
    );

    test('should register the fallback plugin when the version is below RS5', () {
      // Force the version check to behave as an older Windows so the
      // registerWith body is exercised, then restore the global state.
      final savedVersionFlag =
          VersionHelper.instance.isWindows10RS5OrGreater;
      VersionHelper.instance.isWindows10RS5OrGreater = false;
      try {
        SharePlusWindowsPlugin.registerWith();
        expect(SharePlatform.instance, isA<SharePlusWindowsPlugin>());
      } finally {
        SharePlatform.instance = originalPlatform;
        VersionHelper.instance.isWindows10RS5OrGreater = savedVersionFlag;
      }
    });
  });

  // The fallback share() logic is plain Dart; exercising it directly (with a
  // mock launcher) is independent of the host Windows version.
  group('SharePlusWindowsPlugin.share', () {
    test('should be constructable with a custom url launcher', () {
      final mock = MockUrlLauncherPlatform();
      final plugin = SharePlusWindowsPlugin(mock);

      expect(plugin, isA<SharePlusWindowsPlugin>());
      // The custom launcher is exposed verbatim on the plugin.
      expect(plugin.urlLauncher, same(mock));
    });

    test('should url-encode ampersands in subject and body', () async {
      final mock = MockUrlLauncherPlatform();

      await SharePlusWindowsPlugin(mock).share(
        ShareParams(text: 'foo&bar', subject: 'bar&foo'),
      );

      expect(mock.url, 'mailto:?subject=bar%26foo&body=foo%26bar');
    });

    // see https://github.com/dart-lang/sdk/issues/43838#issuecomment-823551891
    test('should url-encode spaces in subject and body', () async {
      final mock = MockUrlLauncherPlatform();

      await SharePlusWindowsPlugin(mock).share(
        ShareParams(text: 'foo bar', subject: 'bar foo'),
      );

      expect(mock.url, 'mailto:?subject=bar%20foo&body=foo%20bar');
    });

    test('should encode a uri into the mailto body', () async {
      final mock = MockUrlLauncherPlatform();

      await SharePlusWindowsPlugin(mock).share(
        ShareParams(uri: Uri.parse('http://example.com')),
      );

      expect(mock.url, 'mailto:?body=http%3A%2F%2Fexample.com');
    });

    test('should throw UnimplementedError when sharing files', () async {
      final mock = MockUrlLauncherPlatform();

      expect(
        () => SharePlusWindowsPlugin(mock).share(
          ShareParams(files: [XFile('a.png')]),
        ),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('should throw when the url launcher fails', () async {
      final mock = MockUrlLauncherPlatform()..canLaunchMockValue = false;

      expect(
        () =>
            SharePlusWindowsPlugin(mock).share(ShareParams(text: 'hello')),
        throwsA(isA<Exception>()),
      );
    });

    test('should report unavailable on a successful share', () async {
      final mock = MockUrlLauncherPlatform();

      final result =
          await SharePlusWindowsPlugin(mock).share(ShareParams(text: 'hello'));

      expect(result, ShareResult.unavailable);
    });
  });
}
