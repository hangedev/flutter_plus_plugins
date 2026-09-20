<p align="center">
  <h1 align="center"> <code>connectivity_plus</code> </h1>
</p>

This project is based on [connectivity_plus](https://pub.dev/packages/connectivity_plus).

## 1. Installation and Usage

### 1.1 Installation

Go to the project directory and add the following dependencies in pubspec.yaml

<!-- tabs:start -->

#### pubspec.yaml

```yaml
...

dependencies:
  connectivity_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/connectivity_plus/connectivity_plus
      # ref: connectivity_plus-7.2.0-ohos.1.0.0
      ref: TAG  # Select the TAG according to the TAG version mapping table below

...
```

Execute Command

```bash
flutter pub get
```

### TAG Version Mapping

| Flutter Framework Version | TAG                                       | Branch   |
|---------------------------|-------------------------------------------|----------|
| 3.7                       | connectivity_plus-5.0.1-ohos-1.0.0-beta.1 | master   |
| 3.22                      | connectivity_plus-7.2.0-ohos.1.0.0        | br_3.41  |
| 3.27                      | connectivity_plus-7.2.0-ohos.1.0.0        | br_3.41  |
| 3.35                      | connectivity_plus-7.2.0-ohos.1.0.0        | br_3.41  |
| 3.41                      | connectivity_plus-7.2.0-ohos.1.0.0        | br_3.41  |
| 3.44                      | connectivity_plus-7.2.0-ohos.1.0.0        | br_3.41  |

<!-- tabs:end -->

### 1.2 Usage

For use cases see [example](example/lib/main.dart).

Import the package:

```dart
import 'package:connectivity_plus/connectivity_plus.dart';
```

Check the currently available connection types:

```dart
final List<ConnectivityResult> result = await Connectivity().checkConnectivity();

if (result.contains(ConnectivityResult.wifi)) {
  // Wi-Fi is available.
} else if (result.contains(ConnectivityResult.mobile)) {
  // Mobile network available.
} else if (result.contains(ConnectivityResult.none)) {
  // No active network.
}
```

Listen for connectivity changes (the stream applies `Stream.distinct`, so consecutive identical states are not emitted twice):

```dart
final connectivity = Connectivity();
final subscription =
    connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) {
  print('Connectivity changed: $result');
});

// Cancel the subscription when it is no longer needed.
subscription.cancel();
```

## 2. Constraints

### 2.1 Compatibility

This document is verified based on the following versions:

1. Flutter: 3.22.1-ohos-1.0.1; SDK: 5.0.5(17); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;
2. Flutter: 3.27.5-ohos-0.0.1; SDK: 5.0.5(17); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;
3. Flutter: 3.35.7-ohos-0.0.1; SDK: 5.0.5(17); IDE: DevEco Studio: 6.0.1.260; ROM: 6.0.0.120 SP6;
4. Flutter: 3.41.10-ohos-0.0.1; SDK: 5.0.5(17); IDE: DevEco Studio 26.0.0 Beta2; ROM: 7.0.0.105 SP10;
5. Flutter: 3.44.9+ohos-0.0.1-canary1; SDK: 5.0.5(17); IDE: DevEco Studio 26.0.0 Beta2; ROM: 6.23.0.100 SP6;


### 2.2 Permission Requirements

####  2.2.1 Add permissions to the module.json5 file in the entry directory.

Open  `entry/src/main/module.json5` and add the following information:

```diff
...
"requestPermissions": [
  {"name" :  "ohos.permission.INTERNET"}
]
```


## 3. API

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### Connectivity API
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| Connectivity()      | Constructs a singleton instance of [Connectivity]. Constructing it twice returns the same instance. | function | / | Connectivity | yes |
| onConnectivityChanged | Fires whenever the connectivity state changes. On iOS, the connectivity status might not update when WiFi status changes, this is a known issue that only affects simulators. The returned list is never empty; when there is no connectivity it contains a single `none` element. | function | / | Stream<List<ConnectivityResult>> | yes |
| checkConnectivity   | Checks the connection status of the device. Do not use the result of this function to decide whether you can reliably make a network request. It only gives you the radio status. The returned list is never empty; when there is no connectivity it contains a single `none` element. | function | / | Future<List<ConnectivityResult>> | yes |

---

## 4. Properties

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### ConnectivityResult Filters
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| bluetooth           | Device connected via bluetooth      | enum     | /     | /       | yes          |
| wifi                | Device connected via Wi-Fi          | enum     | /     | /       | yes          |
| ethernet            | Device connected to ethernet network| enum     | /     | /       | yes          |
| mobile              | Device connected to cellular network| enum     | /     | /       | yes          |
| none                | Device not connected to any network | enum     | /     | /       | yes          |
| vpn                 | Device connected to a VPN (Note: iOS/macOS returns [other]) | enum | / | / | yes      |
| other               | Device is connected to an unknown network | enum | /     | /       | yes          |
| satellite           | Device connected to a satellite network (supported on Android 15+ and iOS; not supported on OHOS and never reported) | enum | /     | /       | no           |

## 5. Known Issues

- On OHOS, the `bluetooth` and `vpn` connectivity types rely on `NetBearType.BEARER_BLUETOOTH` and `NetBearType.BEARER_VPN`, which are available since API 12. On devices with an OHOS SDK below API 12, these two connection types are not reported (the active bearer falls back to `wifi` / `ethernet` / `mobile` / `other`).
- Do not use the connectivity result as the sole indicator of whether a network request will succeed. Connection type availability does not guarantee Internet access (e.g. a Wi-Fi behind a captive portal may still have no Internet).

## 6. Others

- **OHOS behavior alignment**: The OHOS implementation maps `@ohos.net.connection` bearer types to `ConnectivityResult` values and, like Android, can return multiple connection types at once (e.g. `wifi` + `vpn`). When the device has a network connection but no recognized bearer type, it returns `other` instead of `none`.
- **Required permission**: `ohos.permission.INTERNET` is only required if the host application itself performs network access.

## 7. License

This project is licensed under [The BSD-3-Clause (license)](LICENSE).
