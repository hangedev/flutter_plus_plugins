import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';

import 'url_launcher_mock.dart';

void main() {
  late SharePlatform originalPlatform;

  setUp(() => originalPlatform = SharePlatform.instance);

  tearDown(() => SharePlatform.instance = originalPlatform);

  group('SharePlusLinuxPlugin registration', () {
    test('should register itself as the SharePlatform instance', () {
      SharePlusLinuxPlugin.registerWith();

      expect(SharePlatform.instance, isA<SharePlusLinuxPlugin>());
    });

    test('should be constructable with a custom url launcher', () {
      final mock = MockUrlLauncherPlatform();
      final plugin = SharePlusLinuxPlugin(mock);

      expect(plugin, isA<SharePlusLinuxPlugin>());
      // The custom launcher is exposed verbatim on the plugin.
      expect(plugin.urlLauncher, same(mock));
    });
  });

  group('SharePlusLinuxPlugin.share', () {
    test('should url-encode ampersands in subject and body', () async {
      final mock = MockUrlLauncherPlatform();

      await SharePlusLinuxPlugin(mock).share(
        ShareParams(text: 'foo&bar', subject: 'bar&foo'),
      );

      expect(mock.url, 'mailto:?subject=bar%26foo&body=foo%26bar');
    });

    // see https://github.com/dart-lang/sdk/issues/43838#issuecomment-823551891
    test('should url-encode spaces in subject and body', () async {
      final mock = MockUrlLauncherPlatform();

      await SharePlusLinuxPlugin(mock).share(
        ShareParams(text: 'foo bar', subject: 'bar foo'),
      );

      expect(mock.url, 'mailto:?subject=bar%20foo&body=foo%20bar');
    });

    test('should encode a uri into the mailto body', () async {
      final mock = MockUrlLauncherPlatform();

      await SharePlusLinuxPlugin(mock).share(
        ShareParams(uri: Uri.parse('http://example.com')),
      );

      expect(mock.url, 'mailto:?body=http%3A%2F%2Fexample.com');
    });

    test('should throw UnimplementedError when sharing files', () async {
      final mock = MockUrlLauncherPlatform();

      expect(
        () => SharePlusLinuxPlugin(mock).share(
          ShareParams(files: [XFile('a.png')]),
        ),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('should throw when the url launcher fails', () async {
      final mock = MockUrlLauncherPlatform()..canLaunchMockValue = false;

      expect(
        () => SharePlusLinuxPlugin(mock).share(ShareParams(text: 'hello')),
        throwsA(isA<Exception>()),
      );
    });

    test('should report unavailable on a successful share', () async {
      final mock = MockUrlLauncherPlatform();

      final result =
          await SharePlusLinuxPlugin(mock).share(ShareParams(text: 'hello'));

      expect(result, ShareResult.unavailable);
    });
  });
}
