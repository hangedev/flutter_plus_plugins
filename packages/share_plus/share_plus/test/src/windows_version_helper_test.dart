import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/src/windows_version_helper.dart';

void main() {
  group('VersionHelper', () {
    test('should expose a process-wide singleton instance', () {
      expect(VersionHelper.instance, isA<VersionHelper>());
      expect(identical(VersionHelper.instance, VersionHelper.instance), isTrue);
    });

    test('should define the Windows 10 RS5 build number constant', () {
      expect(VersionHelper.kWindows10RS5BuildNumber, 17763);
    });

    test(
      'should report a boolean for isWindows10RS5OrGreater on every platform',
      () {
        // The value is only meaningful on Windows, but the field always exists
        // and must be a stable bool.
        expect(VersionHelper.instance.isWindows10RS5OrGreater, isA<bool>());

        if (Platform.isWindows) {
          // Consistency: re-reading the singleton yields the same answer.
          final first = VersionHelper.instance.isWindows10RS5OrGreater;
          expect(VersionHelper.instance.isWindows10RS5OrGreater, first);
        } else {
          expect(VersionHelper.instance.isWindows10RS5OrGreater, isFalse);
        }
      },
    );
  });
}
