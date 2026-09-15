import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus_platform_interface/method_channel/method_channel_share.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MethodChannelShare platform;
  late String lastMethod;
  late Object? lastArguments;
  Object? channelReply;

  setUp(() {
    platform = MethodChannelShare();
    lastMethod = '';
    lastArguments = null;
    channelReply = 'dev.fluttercommunity.plus/share/unavailable';
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(MethodChannelShare.channel,
            (MethodCall call) async {
      lastMethod = call.method;
      lastArguments = call.arguments;
      return channelReply;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(MethodChannelShare.channel, null);
  });

  group('MethodChannelShare', () {
    test('should expose the documented method channel name', () {
      expect(MethodChannelShare.channel.name, 'dev.fluttercommunity.plus/share');
    });

    test('should map a non-sentinel result to status success', () async {
      channelReply = 'some-action';

      final result = await platform.share(ShareParams(text: 't'));

      expect(result.raw, 'some-action');
      expect(result.status, ShareResultStatus.success);
      expect(lastMethod, 'share');
      expect((lastArguments as Map)['text'], 't');
    });

    test('should map an empty result to status dismissed', () async {
      channelReply = '';

      final result = await platform.share(ShareParams(text: 't'));

      expect(result.raw, '');
      expect(result.status, ShareResultStatus.dismissed);
    });

    test(
      'should map a null result to the unavailable sentinel and status',
      () async {
        channelReply = null;

        final result = await platform.share(ShareParams(text: 't'));

        expect(result.raw, 'dev.fluttercommunity.plus/share/unavailable');
        expect(result.status, ShareResultStatus.unavailable);
      },
    );

    test('should derive the mimeType from the path when none is given',
        () async {
      await withTempFile('tempfile-83649z.png', (File fd) async {
        await platform.share(ShareParams(files: [XFile(fd.path)]));

        final args = lastArguments as Map;
        expect(args['paths'], [fd.path]);
        expect(args['mimeTypes'], ['image/png']);
      });
    });

    test('should honour an explicitly provided mimeType', () async {
      await withTempFile('tempfile-83649a.png', (File fd) async {
        await platform.share(
          ShareParams(files: [XFile(fd.path, mimeType: '*/*')]),
        );

        expect((lastArguments as Map)['mimeTypes'], ['*/*']);
      });
    });

    test('should send origin and excluded activities when provided', () async {
      await platform.share(
        ShareParams(
          uri: Uri.parse('https://pub.dev'),
          sharePositionOrigin: const Rect.fromLTWH(1, 2, 3, 4),
          excludedCupertinoActivities: [
            CupertinoActivityType.airDrop,
            CupertinoActivityType.mail,
          ],
        ),
      );

      final args = lastArguments as Map;
      expect(args['uri'], 'https://pub.dev');
      expect(args['originX'], 1.0);
      expect(args['originY'], 2.0);
      expect(args['originWidth'], 3.0);
      expect(args['originHeight'], 4.0);
      expect(args['excludedCupertinoActivities'], ['airDrop', 'mail']);
    });

    test('should pass title and subject when provided', () async {
      await platform.share(
        ShareParams(text: 't', title: 'A Title', subject: 'A Subject'),
      );

      final args = lastArguments as Map;
      expect(args['title'], 'A Title');
      expect(args['subject'], 'A Subject');
      expect(args['text'], 't');
    });
  });
}

/// Creates a real temporary file so the [MethodChannelShare] file handling
/// (which asserts on non-empty paths) has something concrete to work with.
Future<T> withTempFile<T>(
  String name,
  Future<T> Function(File file) body,
) async {
  final file = File(name);
  try {
    file.createSync();
    return await body(file);
  } finally {
    if (file.existsSync()) {
      file.deleteSync();
    }
  }
}
