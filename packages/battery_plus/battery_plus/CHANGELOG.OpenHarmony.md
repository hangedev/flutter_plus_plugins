## battery_plus-7.1.1-ohos-1.0.0 - 2026.10

### Added

* Add unit tests for the OHOS plugin.([202](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/pull/202)).
* battery_plus 7.0.0 → 7.1.1, aligned with the upstream plus_plugins) Changes: ([190](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/pull/190)).
Android
Comprehensive migration of build scripts from Groovy to Kotlin DSL: the build.gradle/settings.gradle files for both the plugin and the example have been changed to .kts, and the plugin side has removed its bundled Gradle wrapper.
Adaptation to built-in Kotlin: android.newDsl=false and android.builtInKotlin=false have been added to the example's gradle.properties.
Example Gradle wrapper 8.13 → 8.14.
iOS / macOS (adaptation to Flutter 3.44's SPM)
Package.swift refactoring: added a local FlutterFramework dependency.
Minimum Apple platform version iOS 12.0 → 13.0, with the README documentation updated accordingly.
The example iOS project files (pbxproj / Info.plist / AppDelegate.swift) have been adjusted in sync with the SPM changes.

battery_plus-7.0.0-ohos-1.0.1

* Consistency Issues
The OHOS implementation exhibited significant behavioral deviations from Android/iOS counterparts across exception handling, state mapping, and naming conventions:

Missing exception handling: getBatteryLevel, getBatteryState, and isInBatterySaveMode lacked try-catch blocks, while Android/iOS uniformly throw "UNAVAILABLE" error codes when data is unavailable

Incomplete error code mapping: OHOS had no corresponding error code mapping, causing inconsistent behavior across platforms

Invalid default value: getChargingStatus returned empty string instead of "unknown", causing Dart-side parseBatteryState to throw ArgumentError, inconsistent with Android's convertBatteryStatus returning null and publishBatteryStatus reporting errors

Incorrect cleanup logic: onDetachedFromEngine erroneously cleaned methodChannel instead of eventChannel (this.methodChannel?.setMethodCallHandler(null) should have been this.eventChannel?.setStreamHandler(null)), failing to clean up EventChannel resources

Fixes applied:

Wrapped onMethodCall entirely in try-catch, propagating all exceptions via result.error('UNAVAILABLE', ...)

Changed getChargingStatus default branch and initial value to 'unknown'

Corrected eventChannel cleanup logic using shared disposeStream() method

* Memory Leaks
Critical issues centered on incomplete lifecycle resource release and closure circular references:

Incomplete resource cleanup: onDetachedFromEngine only canceled MethodChannel handler, leaving timerId timer running, battery_events not nullified, EventChannel StreamHandler not canceled, and chargeMode not reset — timer continued running after plugin卸载

EventSink reference leak: After clearInterval in onCancel, EventSink reference remained, closures could still reference the object via this.battery_events

Circular reference: chargeModeCallback arrow function captured this, while this held the callback property, forming Plugin → callback → this cycle; timer kept it alive

Multiple timer registration: onListen could register multiple times, overwriting timerId without clearing previous timers via clearInterval

Fixes applied:

Extracted disposeStream() shared cleanup method

Called cleanup in onDetachedFromEngine, onCancel, and at the start of onListen

Ensured timer clearing, EventSink nullification, and deduplication state reset in one operation

Added null checks and try-catch in chargeModeCallback, actively calling disposeStream() on exceptions to terminate streams

* Documentation Quality
Original documentation suffered from:

Missing usage examples and incomplete call instructions (only 1/4 steps documented)

Missing OHOS environment configuration

Omitted critical exception attributes

No table of contents; inconsistent Chinese/English mixing

Hongmeng example was only a single link; key code comments missing

Fixes applied:

Added complete table of contents with anchor links for all sections in both documents

Expanded usage guide from single-line link to complete four-step guide: import package → instantiate Battery → read values → listen to state changes, each with annotated code examples

Added OHOS environment configuration section covering DevEco Studio installation, ohpm dependency acquisition, build/deployment steps, and permissions

Added exception handling section documenting all failure scenarios with PlatformException error code "UNAVAILABLE" and corresponding trigger locations, including try-catch code examples

Hongmeng example section now includes annotated inline key code snippets with numbered comments, explaining OHOS-specific behaviors (e.g., connectedNotCharging not emitted), referencing native BatteryPlusPlugin.ets implementation

Language consistency: English documents fully in English, Chinese documents fully in Chinese

* Test Coverage
Coverage stood at 92.86% with Demo coverage at 35.71%, neither reaching 100%. Critical gaps included:

Fatal omission: BatteryState.connectedNotCharging completely untested — never explicitly referenced in any test source or demo

Platform-specific gap: This value is valid on Linux/macOS (pendingCharge mapping) but OHOS doesn't support it, yet Dart definition remains

Missing exception scenarios: No PlatformException, error handling, or timeout tests

Missing boundary scenarios: No batteryLevel=0/100 extreme values, no exhaustive enum value testing

Missing concurrency scenarios: No multi-instance or multiple listener tests

Test organization issues: No group() organization, no BDD style, no tearDown cleanup (Battery singleton persisted across tests), shared mutable state

Fixes applied:

battery_plus_linux_test.dart: Reorganized with group(), exhaustively tested all 7 UPowerDeviceState → BatteryState mappings (including pendingCharge→connectedNotCharging fix), added batteryLevel boundaries 0/100, connection failure exception propagation, multi-listener concurrency tests

battery_test.dart: Reorganized with group() + setUp/tearDown resetting platform instances, exhaustive loop over all 5 BatteryState.values enums (including connectedNotCharging), added PlatformException rejection paths, batteryLevel boundary values, multi-listener concurrency, singleton identity tests

Demo coverage: Added battery_demo_coverage.dart explicitly referencing all 5 BatteryState enum values and BatteryPlusLinuxPlugin's 4 interfaces, calling in main.dart initState without UI rendering

* Stability
Exception handling and resource release were almost entirely absent, with multiple chain breaks:

No try-catch in onMethodCall: All @ohos API calls exposed, any exception would leave Flutter side with neither success nor error, MethodChannel Future hanging indefinitely or timing out

Broken exception propagation chain: Native exceptions couldn't be converted to Flutter PlatformException via result.error(), affecting all call chains

Incomplete resource release: eventChannel stream handler not canceled (code bug), timerId not cleared, battery_events not nullified, channel references not nullified

Timer callback without exception protection: getChargingStatus() exceptions would break timer callbacks unrecoverably

Missing logging: No hilog/logger calls for debugging and troubleshooting

Fixes applied:

Wrapped onMethodCall entirely in try-catch with defensive checks per case (batteryLevel<0, chargingStatus empty), exceptions uniformly propagated via result.error('UNAVAILABLE', ...) to Flutter side

Added try-catch in chargeModeCallback with hilog logging, EventSink error events, and disposeStream() call on exceptions

Added hilog logging throughout file covering critical path errors and lifecycle events

Complete cleanup via disposeStream() in onDetachedFromEngine covering timers, EventSink, deduplication state, and both methodChannel/eventChannel cleanup

* Code Quality
Multiple quality issues identified:

Type safety: onListen/onCancel used Any type (equivalent to any), type safety risks; callMethod, powerMode local variables lacked type annotations

Logical error: onDetachedFromEngine line 63 incorrectly cleaned eventChannel as methodChannel operation

Missing exception handling: onMethodCall, getBatteryMode lacked try-catch

Formatting issues: 7 missing semicolons

Documentation gaps: 8 public methods missing JSDoc comments

Naming violations: battery_events (should be batteryEvents), battertChargeState typo (should be batteryChargeState)

Fixes applied:

Changed onListen/onCancel parameter types to ESObject (consistent with SDK StreamHandler interface), removed unnecessary Callback import

Added type annotations to all local variables

Corrected onDetachedFromEngine cleanup logic, eventChannel now calls setStreamHandler(null)

Unified equality comparisons using ===/!==

Completed all missing semicolons

Added JSDoc comments to all public methods and fields

Unified naming to camelCase (batteryEvents, batteryChargeState, lastChargingStatus), corrected typo




