# Changelog for OpenHarmony

## android_intent_plus-6.0.0-ohos-1.0.1 - 2026.9

### Fixed

* Consistency: ([181](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/pull/181)).
Align parseAndLaunch exception propagation with Android (OHOS native side).
WantSender.ets:225-230: parse() no longer swallows JSON parsing exceptions and returns an empty Want; instead, it throws, consistent with the behavior of Android Intent.parseUri throwing URISyntaxException.
MethodCallHandlerImpl.ets:75-87: parseAndLaunch separately catches parsing failures, reports parse_error / "Failed to parse URI" / exception details, and the error triple is exactly the same as Android; send failures still go through the outer generic error code.
Verified: hvigor assembleHap builds successfully; the behavior of valid input paths remains unchanged, and lib/ has zero changes.

* Test case coverage: ([181](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/pull/181)).
category field coverage (a veto item): triple coverage via constructor parameter passing + field reference + parameter map assertions, with interface coverage reaching 18/18 = 100%.
Timeout exceptions: the mock channel never returns, verifying that launch() / getResolvedActivity() throw TimeoutException on timeout.
Concurrency scenarios: concurrent launch of multiple Intents, as well as concurrent mixed sending of the four methods (Future.wait with verify one by one).
Boundary scenarios: arguments / arrayArguments parameter passing, category being null and non-null, convertFlags minimum and large values.
Added tearDown paired with setUp for cleanup; all new test cases use BDD-style naming.
Additional: ResolvedActivity's == / hashCode / toString test group, parseAndLaunch platform guard tests, and the Ohos AndroidIntent HarmonyOS platform group.
Verified: all 37 tests pass, flutter analyze has zero warnings, line coverage is 64/65 (android_intent.dart:164 is unreachable on the host due to the hardcoded const LocalPlatform(), and is covered by device-side integration tests).

* Documentation quality: ([181](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/pull/181)).
Added "1.2 Upgrade Migration": TAG version switching steps, flutter pub get / flutter clean, and reference to CHANGELOG for API changes between versions.
Added "1.3 Environment Configuration (OpenHarmony)": DevEco Studio installation, SDK configuration, Flutter ohos environment setup guide, flutter build hap --debug build command, and GUIDE_DOCUMENT.md link.
Added "1.4 Usage": complete Dart call example (ohos.want.action.viewData + launch()) and an overview of each method; the original usage case is renumbered as 1.5.
API section corrections and completions:
Corrected erroneous entries in the interface table: canResolveActivity() return type was incorrectly Future<ResolvedActivity?> and is corrected to Future<bool?>; getResolvedActivity() output was incorrectly "Uint8List" and is corrected to "ResolvedActivity object"; mixed Chinese and English in the Input/Output columns ("No") was standardized.
The ohos support level of parseAndLaunch / launchChooser / sendBroadcast was truthfully corrected from "yes" to "partially", with notes explaining the reasons for the differences.
Added "3.2 Constructor Parameter Description": types and constraints of the 9 business parameters (action / flags / category / data / arguments / arrayArguments / package / componentName / type).

## v1.0.0 (2026-08)
- release version android_intent_plus-6.0.0-ohos-1.0.0

## v1.0.0-beta.1 (2026-07)

* TAG 6.0.0-ohos-1.0.0-beta.1
