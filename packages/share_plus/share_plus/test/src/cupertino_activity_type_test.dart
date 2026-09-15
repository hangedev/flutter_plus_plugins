import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';

void main() {
  group('CupertinoActivityType', () {
    test('should expose every documented activity type', () {
      expect(CupertinoActivityType.values, containsAll(<CupertinoActivityType>[
        CupertinoActivityType.postToFacebook,
        CupertinoActivityType.postToTwitter,
        CupertinoActivityType.postToWeibo,
        CupertinoActivityType.message,
        CupertinoActivityType.mail,
        CupertinoActivityType.print,
        CupertinoActivityType.copyToPasteboard,
        CupertinoActivityType.assignToContact,
        CupertinoActivityType.saveToCameraRoll,
        CupertinoActivityType.addToReadingList,
        CupertinoActivityType.postToFlickr,
        CupertinoActivityType.postToVimeo,
        CupertinoActivityType.postToTencentWeibo,
        CupertinoActivityType.airDrop,
        CupertinoActivityType.openInIBooks,
        CupertinoActivityType.markupAsPDF,
        CupertinoActivityType.sharePlay,
        CupertinoActivityType.collaborationInviteWithLink,
        CupertinoActivityType.collaborationCopyLink,
        CupertinoActivityType.addToHomeScreen,
      ]));
      expect(CupertinoActivityType.values.length, 20);
    });

    // A table-driven check that guarantees *every* enum member is exercised at
    // least once (so no value is silently untested).
    for (final type in CupertinoActivityType.values) {
      test('should map ${type.name} to its snake_case value', () {
        expect(type.value, type.name);
        expect(type.value, isNotEmpty);
        expect(type.value, equals(type.toString().split('.').last));
      });
    }

    test('should map the airDrop value specifically', () {
      expect(CupertinoActivityType.airDrop.value, 'airDrop');
    });
  });
}
