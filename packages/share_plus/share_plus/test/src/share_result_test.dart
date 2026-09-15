// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';

void main() {
  group('ShareResult', () {
    test(
      'should expose the raw value and status passed to the constructor',
      () {
        const result = ShareResult('raw-action', ShareResultStatus.success);

        expect(result.raw, 'raw-action');
        expect(result.status, ShareResultStatus.success);
      },
    );

    test('should be equal when raw and status match', () {
      const a = ShareResult('x', ShareResultStatus.success);
      const b = ShareResult('x', ShareResultStatus.success);
      const other = ShareResult('x', ShareResultStatus.dismissed);

      expect(a, equals(b));
      expect(a == b, isTrue);
      expect(a == other, isFalse);
      expect(a == a, isTrue); // identical
      expect(a == Object(), isFalse);
    });

    test('should have a hashCode consistent with equality', () {
      const a = ShareResult('x', ShareResultStatus.success);
      const b = ShareResult('x', ShareResultStatus.success);

      expect(a.hashCode, b.hashCode);
    });

    test('should render a human-readable toString', () {
      const result = ShareResult('raw', ShareResultStatus.dismissed);

      expect(
        result.toString(),
        'ShareResult(raw: raw, status: ShareResultStatus.dismissed)',
      );
    });

    test('should expose the canonical unavailable result', () {
      expect(ShareResult.unavailable.raw,
          'dev.fluttercommunity.plus/share/unavailable');
      expect(ShareResult.unavailable.status, ShareResultStatus.unavailable);
    });
  });

  group('ShareResultStatus', () {
    test('should define all three documented statuses', () {
      expect(ShareResultStatus.values, contains(ShareResultStatus.success));
      expect(ShareResultStatus.values, contains(ShareResultStatus.dismissed));
      expect(ShareResultStatus.values, contains(ShareResultStatus.unavailable));
      expect(ShareResultStatus.values.length, 3);
    });

    test('should be distinguishable by identity', () {
      expect(ShareResultStatus.success, isNot(ShareResultStatus.dismissed));
      expect(ShareResultStatus.dismissed, isNot(ShareResultStatus.unavailable));
      expect(ShareResultStatus.success, isNot(ShareResultStatus.unavailable));
    });
  });

  group('ShareParams', () {
    test(
      'should default the web fallbacks to enabled and others to null',
      () {
        final params = ShareParams(text: 'hello');

        expect(params.downloadFallbackEnabled, isTrue);
        expect(params.mailToFallbackEnabled, isTrue);
        expect(params.text, 'hello');
        expect(params.title, isNull);
        expect(params.subject, isNull);
        expect(params.previewThumbnail, isNull);
        expect(params.sharePositionOrigin, isNull);
        expect(params.uri, isNull);
        expect(params.files, isNull);
        expect(params.fileNameOverrides, isNull);
        expect(params.excludedCupertinoActivities, isNull);
      },
    );

    test('should store every configurable field', () {
      final thumbnail = XFile.fromData(Uint8List(4), name: 'thumb.png');
      const origin = Rect.fromLTWH(1, 2, 3, 4);
      final file = XFile('a.png');
      final params = ShareParams(
        text: 'text',
        title: 'title',
        subject: 'subject',
        previewThumbnail: thumbnail,
        sharePositionOrigin: origin,
        uri: Uri.parse('https://example.com'),
        files: [file],
        fileNameOverrides: ['renamed.png'],
        downloadFallbackEnabled: false,
        mailToFallbackEnabled: false,
        excludedCupertinoActivities: [CupertinoActivityType.airDrop],
      );

      expect(params.text, 'text');
      expect(params.title, 'title');
      expect(params.subject, 'subject');
      expect(params.previewThumbnail, same(thumbnail));
      expect(params.sharePositionOrigin, origin);
      expect(params.uri, Uri.parse('https://example.com'));
      expect(params.files, [file]);
      expect(params.fileNameOverrides, ['renamed.png']);
      expect(params.downloadFallbackEnabled, isFalse);
      expect(params.mailToFallbackEnabled, isFalse);
      expect(params.excludedCupertinoActivities,
          [CupertinoActivityType.airDrop]);
    });

    test('should allow both uri and text to be null when files are provided',
        () {
      final params = ShareParams(files: []);

      expect(params.uri, isNull);
      expect(params.text, isNull);
      expect(params.files, isEmpty);
    });
  });
}
