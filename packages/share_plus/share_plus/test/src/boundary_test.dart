import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';

import 'fake_share_platform.dart';

// Boundary / edge-case inputs. These exercise the public API with the kinds of
// payloads that stress validation, encoding and (on real platforms) the share
// sheet itself.
void main() {
  late RecordingSharePlatform platform;
  late SharePlus sharePlus;

  setUp(() {
    platform = RecordingSharePlatform(
      resultToReturn:
          const ShareResult('raw', ShareResultStatus.success),
    );
    sharePlus = SharePlus.custom(platform);
  });

  group('boundary inputs', () {
    test('should accept a very long text payload', () async {
      final longText = 'a' * 100000;

      final result = await sharePlus.share(ShareParams(text: longText));

      expect(result.status, ShareResultStatus.success);
      expect(platform.lastParams?.text?.length, 100000);
    });

    test('should accept multi-byte / emoji text', () async {
      const emoji = '😀🚀🎉 ñ é ü 你好 𝕏';

      await sharePlus.share(ShareParams(text: emoji));

      expect(platform.lastParams?.text, emoji);
    });

    test('should accept a single-character text', () async {
      await sharePlus.share(ShareParams(text: 'x'));

      expect(platform.lastParams?.text, 'x');
    });

    test('should accept a large in-memory file', () async {
      final bigBytes = Uint8List(1024 * 1024); // ~1MB of zeros
      final file = XFile.fromData(bigBytes, name: 'big.bin');

      await sharePlus.share(ShareParams(files: [file]));

      expect(platform.lastParams?.files?.single, file);
    });

    test('should accept many files at once', () async {
      final files = List.generate(
        50,
        (i) => XFile.fromData(Uint8List.fromList([i]), name: 'f$i.bin'),
      );

      await sharePlus.share(
        ShareParams(files: files, fileNameOverrides: files.map((f) => f.name).toList()),
      );

      expect(platform.lastParams?.files?.length, 50);
      expect(platform.lastParams?.fileNameOverrides?.length, 50);
    });

    test('should accept a uri with query and fragment', () async {
      final uri = Uri.parse(
        'https://example.com/path?q=hello&w=world#section',
      );

      await sharePlus.share(ShareParams(uri: uri));

      expect(platform.lastParams?.uri, uri);
    });

    test('should accept every CupertinoActivityType as excluded', () async {
      await sharePlus.share(
        ShareParams(
          text: 'exclude-all',
          excludedCupertinoActivities: CupertinoActivityType.values,
        ),
      );

      expect(platform.lastParams?.excludedCupertinoActivities?.length,
          CupertinoActivityType.values.length);
    });
  });

  group('error paths', () {
    test('should propagate platform exceptions', () async {
      platform.errorToThrow = StateError('boom');

      expect(
        () => sharePlus.share(ShareParams(text: 'x')),
        throwsA(isA<StateError>()),
      );
    });
  });
}
