<p align="center">
  <h1 align="center"> <code>battery_plus</code> </h1>
</p>

This project is based on [battery_plus](https://pub.dev/packages/battery_plus).

## 1. Installation and Usage

### 1.1 Installation

Add the dependency in pubspec.yaml:

<!-- tabs:start -->

#### pubspec.yaml

```yaml
dependencies:
  battery_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/battery_plus/battery_plus
      ref: TAG # Please select the TAG to the TAG Version Mapping
```

Run:

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 TAG Version Mapping

| Flutter version | TAG name | Branch |
| --- | --- | --- |
| 3.22 | battery_plus-7.1.1-ohos-1.0.0 | br_3.41 |
| 3.27 | battery_plus-7.1.1-ohos-1.0.0 | br_3.41 |
| 3.35 | battery_plus-7.1.1-ohos-1.0.0 | br_3.41 |
| 3.41 | battery_plus-7.1.1-ohos-1.0.0 | br_3.41 |
| 3.44 | battery_plus-7.1.1-ohos-1.0.0 | br_3.41 |

### 1.3 OHOS Environment Configuration

The OHOS platform implementation is a federated plugin; it is registered automatically after `flutter pub get`. To run the example app:

1. Install DevEco Studio and the HarmonyOS SDK (see [2.1 Compatibility](#21-compatibility)).
2. Fetch the OHOS dependencies:

   ```bash
   cd example/ohos
   ohpm install
   ```

3. Open `example/ohos` in DevEco Studio (or run `flutter build hap`), then deploy to a device/emulator.

> The plugin uses `@ohos.batteryInfo` (battery SOC and charging state) and `@ohos.power` (power-save mode) — non-sensitive read-only APIs; no extra `module.json5` permissions are required.

### 1.4 Usage

Using `battery_plus` is a four-step process:

**Step 1 — Import and instantiate**

```dart
import 'package:battery_plus/battery_plus.dart';

// Battery is a singleton; the constructor always returns the same instance.
final Battery _battery = Battery();
```

**Step 2 — Read values**

Each getter returns a `Future`; `await` it to get the result.

```dart
final int level = await _battery.batteryLevel;            // 0–100
final BatteryState state = await _battery.batteryState;    // charging state
final bool saveMode = await _battery.isInBatterySaveMode;  // power-save mode
```

**Step 3 — Listen for state changes**

```dart
StreamSubscription<BatteryState>? _subscription;

_subscription = _battery.onBatteryStateChanged.listen((BatteryState state) {
  // react to the new charging state
});
```

**Step 4 — Cancel the subscription**

```dart
@override
void dispose() {
  _subscription?.cancel(); // always cancel to avoid leaks
  super.dispose();
}
```

A complete sample lives in [example/lib/main.dart](example/lib/main.dart).

## 2. Constraints

### 2.1 Compatibility

This document is verified based on the following versions:

1. Flutter: 3.22.1-ohos-1.0.1; SDK: 5.0.5(17); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;
2. Flutter: 3.27.5-ohos-0.0.2; SDK: 5.0.5(17); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;
3. Flutter: 3.35.7-ohos-0.0.1; SDK: 5.0.5(17); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;
4. Flutter: 3.41.10-ohos-0.0.1; SDK: 5.0.5(17); IDE: DevEco Studio: 6.1.0.830; ROM: 6.23.0.100 SP6;
5. Flutter: 3.44.9+ohos-0.0.1-canary1; SDK: 5.0.5(17); IDE: DevEco Studio 26.0.0 Beta2; ROM: 6.23.0.100 SP6;

## 3. API

> [!TIP] **ohos Support** = **yes**: supported; **no**: not supported; **partially**: partially supported. Usage is cross-platform; behaviour matches iOS/Android.

### 3.1 Battery API

| Name | Description | Type | Input | Output | Range / Notes | ohos Support |
|---|---|---|---|---|---|---|
| batteryLevel | get battery level | function | / | Future<int> | 0–100, integer percent | yes |
| isInBatterySaveMode | check power-save mode | function | / | Future<bool> | true/false | yes |
| batteryState | get battery state | function | / | Future<BatteryState> | see 3.2 | yes |
| onBatteryStateChanged | stream state changes | function | / | Stream<BatteryState> | emitted on change | yes |

### 3.2 BatteryState

| Name | Description | Type | ohos Support |
|---|---|---|---|
| full | battery fully charged | enum | yes |
| charging | charging | enum | yes |
| connectedNotCharging | connected to power but not charging | enum | [no](#5-known-issues) |
| discharging | discharging | enum | yes |
| unknown | unknown state | enum | yes |

### 3.3 Error Handling

When the underlying system value cannot be obtained, the platform implementation rejects the `Future` (or emits a stream error event) with a `PlatformException` whose `code` is **`UNAVAILABLE`** — matching Android/iOS.

```dart
try {
  final int level = await _battery.batteryLevel;
} on PlatformException catch (e) {
  // e.code == 'UNAVAILABLE'
}
```

| Failure scenario | Where it surfaces | code |
|---|---|---|
| Battery SOC / charging status cannot be read | `batteryLevel` / `batteryState` | `UNAVAILABLE` |
| Power-save mode cannot be queried | `isInBatterySaveMode` | `UNAVAILABLE` |
| Charging-status read fails while streaming | `onBatteryStateChanged` stream error | `UNAVAILABLE` |

### 3.4 OHOS Native Interface (BatteryPlusPlugin)

The native implementation is in [BatteryPlusPlugin.ets](ohos/src/main/ets/components/plugin/BatteryPlusPlugin.ets), implementing `FlutterPlugin`, `MethodCallHandler`, and `StreamHandler`:

| Method | Description |
|---|---|
| onAttachedToEngine | Register the MethodChannel and EventChannel |
| onDetachedFromEngine | Release channels, timer, and EventSink |
| onMethodCall | Handle `getBatteryLevel`/`getBatteryState`/`isInBatterySaveMode`; report `UNAVAILABLE` on failure |
| getChargingStatus | Map `batteryInfo.BatteryChargeState` to the protocol string |
| getBatteryMode | Query `power.getPowerMode()` to determine power-save mode |
| onListen | Start the polling timer; push the initial state and subsequent changes |
| onCancel | Stop the timer and release the EventSink |

## 4. OHOS Example

The OHOS example is the Flutter app under [example/](example/); Dart entry point is [example/lib/main.dart](example/lib/main.dart), native shell is [example/ohos/](example/ohos/).

**Scenario 1 — Read current level and state**

```dart
final Battery _battery = Battery();                    // (1) singleton
final int level = await _battery.batteryLevel;         // (2) level
final BatteryState state = await _battery.batteryState; // (3) state
```

**Scenario 2 — Listen for charging-state changes**

```dart
// state is one of: full / charging / discharging / unknown
// (connectedNotCharging is never produced on OHOS — see Known Issues)
final StreamSubscription<BatteryState> sub =
    _battery.onBatteryStateChanged.listen((BatteryState state) {
  // react to the new state
});
// cancel when no longer needed
sub.cancel();
```

See [3.4](#34-ohos-native-interface-batteryplusplugin) for the native implementation.

## 5. Known Issues

- [ ] OHOS supports only 4 battery states, so `BatteryState.connectedNotCharging` is **not** supported; the OHOS API reports `unknown` for any state it cannot represent. See [BatteryState module introduction](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-battery-info#batterychargestate).

## 6. Others

## 7. License

This project is licensed under [The BSD-3-Clause (license)](LICENSE).
