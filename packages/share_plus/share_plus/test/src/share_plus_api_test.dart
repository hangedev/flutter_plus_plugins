// ignore_for_file: deprecated_member_use_from_same_package, deprecated_member_use
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';
import 'package:share_plus_platform_interface/method_channel/method_channel_share.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';

import 'fake_share_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RecordingSharePlatform recordingPlatform;

  setUp(() {
    recordingPlatform = RecordingSharePlatform(
      resultToReturn:
          const ShareResult('success-raw', ShareResultStatus.success),
    );
  });

  group('SharePlus', () {
    test('should expose a default singleton instance', () {
      expect(SharePlus.instance, isA<SharePlus>());
    });

    test('should build an independent instance via the custom factory', () async {
      final custom = SharePlus.custom(recordingPlatform);

      expect(custom, isNot(same(SharePlus.instance)));
      // Using the custom instance must not touch the global platform.
      final before = SharePlatform.instance;
      final result = await custom.share(ShareParams(text: 'hello'));
      expect(result.status, ShareResultStatus.success);
      expect(recordingPlatform.lastParams?.text, 'hello');
      expect(SharePlatform.instance, same(before));
    });

    test('should forward text params and return the platform result', () async {
      final sharePlus = SharePlus.custom(recordingPlatform);
      const origin = Rect.fromLTWH(1, 2, 3, 4);

      final result = await sharePlus.share(
        ShareParams(
          text: 'hello',
          subject: 'subject',
          title: 'title',
          sharePositionOrigin: origin,
          excludedCupertinoActivities: [CupertinoActivityType.mail],
        ),
      );

      expect(result.raw, 'success-raw');
      expect(result.status, ShareResultStatus.success);
      final params = recordingPlatform.lastParams!;
      expect(params.text, 'hello');
      expect(params.subject, 'subject');
      expect(params.title, 'title');
      expect(params.sharePositionOrigin, origin);
      expect(params.excludedCupertinoActivities, [CupertinoActivityType.mail]);
    });

    test('should forward uri params to the platform', () async {
      final sharePlus = SharePlus.custom(recordingPlatform);
      final uri = Uri.parse('https://example.com/path');

      await sharePlus.share(ShareParams(uri: uri));

      expect(recordingPlatform.lastParams?.uri, uri);
    });

    test('should forward files and fileNameOverrides to the platform', () async {
      final sharePlus = SharePlus.custom(recordingPlatform);
      final files = [
        XFile('a.png', name: 'a.png'),
        XFile.fromData(Uint8List.fromList([1, 2, 3]), name: 'b.bin'),
      ];

      await sharePlus.share(
        ShareParams(files: files, fileNameOverrides: ['x.png', 'y.bin']),
      );

      expect(recordingPlatform.lastParams?.files, files);
      expect(
          recordingPlatform.lastParams?.fileNameOverrides, ['x.png', 'y.bin']);
    });

    group('share should reject invalid params', () {
      late SharePlus sharePlus;

      setUp(() => sharePlus = SharePlus.custom(recordingPlatform));

      test('when none of uri/files/text are provided', () {
        expect(
          () => sharePlus.share(ShareParams()),
          throwsA(isA<ArgumentError>()),
        );
        expect(recordingPlatform.recordedCalls, isEmpty);
      });

      test('when both uri and text are provided', () {
        expect(
          () => sharePlus.share(
            ShareParams(uri: Uri.parse('https://e.com'), text: 't'),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('when text is provided but empty', () {
        expect(
          () => sharePlus.share(ShareParams(text: '')),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('when files are provided but empty', () {
        expect(
          () => sharePlus.share(ShareParams(files: [])),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('when an empty files list is provided alongside text', () {
        // Text alone is valid, but an empty files list is still rejected.
        expect(
          () => sharePlus.share(ShareParams(text: 'text', files: [])),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('when fileNameOverrides length differs from files length', () {
        expect(
          () => sharePlus.share(
            ShareParams(
              files: [XFile('a.png')],
              fileNameOverrides: ['one', 'two'],
            ),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });

  // The deprecated [Share] helpers route through [SharePlus.instance], which
  // captures the default [MethodChannelShare] at class-load time. We therefore
  // verify them end-to-end by mocking [MethodChannelShare.channel].
  group('Share (deprecated)', () {
    late List<MethodCall> channelCalls;

    setUp(() {
      channelCalls = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannelShare.channel,
              (MethodCall call) async {
        channelCalls.add(call);
        return 'success-raw';
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannelShare.channel, null);
    });

    test('downloadFallbackEnabled should be read and written', () {
      final previous = Share.downloadFallbackEnabled;
      try {
        Share.downloadFallbackEnabled = false;
        expect(Share.downloadFallbackEnabled, isFalse);
        Share.downloadFallbackEnabled = true;
        expect(Share.downloadFallbackEnabled, isTrue);
      } finally {
        Share.downloadFallbackEnabled = previous;
      }
    });

    test('share should delegate to the method channel with text', () async {
      final result = await Share.share('hello', subject: 'subject');

      expect(result.status, ShareResultStatus.success);
      expect(result.raw, 'success-raw');
      expect(channelCalls.single.method, 'share');
      expect(channelCalls.single.arguments, isA<Map>());
      final args = channelCalls.single.arguments as Map;
      expect(args['text'], 'hello');
      expect(args['subject'], 'subject');
    });

    test('share should forward the sharePositionOrigin', () async {
      const origin = Rect.fromLTWH(5, 6, 7, 8);

      await Share.share('hello', sharePositionOrigin: origin);

      final args = channelCalls.single.arguments as Map;
      expect(args['originX'], 5.0);
      expect(args['originY'], 6.0);
      expect(args['originWidth'], 7.0);
      expect(args['originHeight'], 8.0);
    });

    test('shareUri should delegate with the given uri', () async {
      final uri = Uri.parse('https://example.com');

      await Share.shareUri(uri);

      expect(channelCalls.single.method, 'share');
      expect((channelCalls.single.arguments as Map)['uri'],
          'https://example.com');
    });

    test('shareXFiles should delegate with files, text and overrides',
        () async {
      await Share.shareXFiles(
        [XFile('a.png'), XFile('b.png')],
        subject: 'subject',
        text: 'caption',
        fileNameOverrides: ['a.png', 'b.png'],
      );

      final args = channelCalls.single.arguments as Map;
      expect(args['paths'], ['a.png', 'b.png']);
      expect(args['mimeTypes'], ['image/png', 'image/png']);
      expect(args['subject'], 'subject');
      expect(args['text'], 'caption');
    });
  });
}
