// [SharePlusWebPlugin] is only exported by `package:share_plus/share_plus.dart`
// where `dart:js_interop` is available, so its tests live in
// `share_plus_web_test_web.dart` and are wired in through a conditional
// import. On the VM the import resolves to `share_plus_web_test_stub.dart`
// instead. This keeps `flutter test` green on every platform while
// `flutter test --platform chrome test/src/web/` runs the real browser suite.
import 'share_plus_web_test_stub.dart'
    if (dart.library.js_interop) 'share_plus_web_test_web.dart' as web_tests;

void main() => web_tests.main();
