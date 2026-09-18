import 'package:flutter_test/flutter_test.dart';

/// VM stub for the browser-only [SharePlusWebPlugin] tests.
///
/// The web implementation of share_plus is not importable on the VM, so this
/// stub is what `share_plus_web_test.dart` resolves to outside the browser.
/// The real assertions live in `share_plus_web_test_web.dart` and run under
/// `flutter test --platform chrome test/src/web/`.
void main() {
  test('SharePlusWebPlugin tests only run on the web platform', () {
    // Nothing to exercise on the VM; see the library-level comment.
    expect(true, isTrue);
  });
}
