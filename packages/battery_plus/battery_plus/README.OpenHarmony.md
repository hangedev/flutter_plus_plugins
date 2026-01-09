<p align="center">
  <h1 align="center"> <code>battery_plus</code> </h1>
</p>

This project is based on [battery_plus](https://pub.dev/packages/battery_plus).

## 1. Installation and Usage

### 1.1 Installation

Go to the project directory and add the following dependencies in pubspec.yaml

<!-- tabs:start -->

#### pubspec.yaml

```yaml
...

dependencies:
  battery_plus:
    git:
      url: https://gitcode.com/openharmony-sig/flutter_plus_plugins.git
      path: packages/battery_plus/battery_plus
      ref: br_battery_plus-v7.0.0_ohos

...
```

Execute Command

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 Usage

For use cases [example](example/lib/main.dart).

## 2. Constraints

### 2.1 Compatibility

This document is verified based on the following versions:

1. Flutter: 3.22.1-ohos-1.0.1; SDK: 5.0.0(12); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;
2. Flutter: 3.27.5-ohos-0.0.2; SDK: 5.0.0(12); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;
3. Flutter: 3.35.7-ohos-0.0.1; SDK: 5.0.0(12); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;

## 3. API

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### Battery API

| Name                  | Description                              | Type     | Input | Output               | ohos Support |
|-----------------------|------------------------------------------|----------|-------|----------------------|--------------|
| batteryLevel          | get battery level                        | function | /     | Future<int>          | yes          |
| isInBatterySaveMode   | check if device is on battery save mode  | function | /     | Future<bool>         | yes          |
| batteryState          | Get battery state                        | function | /     | Future<BatteryState> | yes          |
| onBatteryStateChanged | Fires whenever the battery state changes | function | /     | Stream<BatteryState> | yes          |

### BatteryState

| Name                 | Description                                                                | Type | Input | Output | ohos Support          |
|----------------------|----------------------------------------------------------------------------|------|-------|--------|-----------------------|
| full                 | The battery is completely full of energy                                   | enum | /     | /      | yes                   |
| charging             | The battery is currently storing energy                                    | enum | /     | /      | yes                   |
| connectedNotCharging | Device is connected to external power source, but not charging the battery | enum | /     | /      | [no](#4-Known-Issues) |
| discharging          | The battery is currently losing energy                                     | enum | /     | /      | yes                   |
| unknown              | The state of the battery is unknown                                        | enum | /     | /      | yes                   |

## 4. Known Issues

- [ ] There are only 4 battery states in ohos, [BatteryState module introduction](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-battery-info#batterychargestate)

## 5. Others

## 6. License

This project is licensed under [The BSD-3-Clause (license)](LICENSE).
