import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';

import 'fake_share_platform.dart';

// On Android the platform only keeps a single pending share at a time: starting
// a new share forces the previous one to resolve with `ShareResult.unavailable`.
// These tests emulate that contract at the platform layer so the documented
// concurrency behaviour is covered without a real device.
void main() {
  group('concurrency', () {
    test(
      'should resolve the preempted share as unavailable when a newer share starts',
      () async {
        final platform = ConcurrencyEmulatingPlatform(
          resultToReturn:
              const ShareResult('raw', ShareResultStatus.success),
          resolveDelay: const Duration(milliseconds: 60),
        );
        final sharePlus = SharePlus.custom(platform);

        // Kick off the first share but do NOT await it yet.
        final first = sharePlus.share(ShareParams(text: 'first'));
        // Yield so the platform records it as pending.
        await Future<void>.delayed(const Duration(milliseconds: 5));
        // A second share preempts the first.
        final second = sharePlus.share(ShareParams(text: 'second'));

        final firstResult = await first;
        final secondResult = await second;

        expect(firstResult.status, ShareResultStatus.unavailable);
        expect(secondResult.status, ShareResultStatus.success);
      },
    );

    test('should resolve a single share normally when nothing preempts it',
        () async {
      final platform = ConcurrencyEmulatingPlatform(
        resultToReturn:
            const ShareResult('raw', ShareResultStatus.success),
        resolveDelay: const Duration(milliseconds: 10),
      );
      final sharePlus = SharePlus.custom(platform);

      final result = await sharePlus.share(ShareParams(text: 'only'));

      expect(result.status, ShareResultStatus.success);
    });

    test('should forward params for every concurrent invocation', () async {
      final platform = ConcurrencyEmulatingPlatform(
        resolveDelay: const Duration(milliseconds: 30),
      );
      final sharePlus = SharePlus.custom(platform);

      final first = sharePlus.share(ShareParams(text: 'first'));
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await sharePlus.share(ShareParams(text: 'second'));
      await first;

      expect(platform.recordedCalls.length, 2);
      expect(platform.recordedCalls[0].text, 'first');
      expect(platform.recordedCalls[1].text, 'second');
    });
  });
}
