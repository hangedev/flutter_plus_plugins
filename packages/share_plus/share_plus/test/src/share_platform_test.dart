// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus_platform_interface/method_channel/method_channel_share.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';

import 'fake_share_platform.dart';

void main() {
  group('SharePlatform', () {
    late SharePlatform original;

    setUp(() => original = SharePlatform.instance);

    tearDown(() => SharePlatform.instance = original);

    test('should default its instance to a MethodChannelShare', () {
      expect(SharePlatform.instance, isA<MethodChannelShare>());
    });

    test('should construct a new platform instance via the constructor', () {
      final platform = SharePlatform();

      expect(platform, isA<SharePlatform>());
    });

    test('should allow swapping the global instance', () {
      final replacement = RecordingSharePlatform();

      SharePlatform.instance = replacement;

      expect(identical(SharePlatform.instance, replacement), isTrue);
    });

    test('should reject non-platform objects via verifyToken', () {
      // A class that merely *implements* the interface does not carry the
      // PlatformInterface token, so assigning it must throw.
      expect(
        () => SharePlatform.instance = _TokenlessFake(),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should delegate instance.share to the registered platform',
        () async {
      final stub = RecordingSharePlatform(
        resultToReturn:
            const ShareResult('raw', ShareResultStatus.dismissed),
      );

      // SharePlatform.share forwards to the static instance, so we exercise it
      // through the global instance swap.
      SharePlatform.instance = stub;
      final result = await SharePlatform.instance.share(ShareParams(text: 't'));

      expect(result.status, ShareResultStatus.dismissed);
      expect(stub.lastParams?.text, 't');
    });

    test('a fresh SharePlatform instance should forward share() to _instance',
        () async {
      final stub = RecordingSharePlatform(
        resultToReturn: const ShareResult('x', ShareResultStatus.success),
      );
      SharePlatform.instance = stub;

      // `SharePlatform()` creates a lightweight wrapper; calling share on it
      // delegates to the static [_instance].
      final wrapper = SharePlatform();
      final result = await wrapper.share(ShareParams(text: 'forwarded'));

      expect(result.raw, 'x');
      expect(stub.lastParams?.text, 'forwarded');
    });
  });
}

class _TokenlessFake implements SharePlatform {
  @override
  Future<ShareResult> share(ShareParams params) async => ShareResult.unavailable;
}
