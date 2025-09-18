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
      url: https://gitcode.com/openharmony-sig/flutter_plus_plugins.git
      path: packages/connectivity_plus/connectivity_plus
      ref: br_connectivity_plus-v6.1.0_ohos
      
...
```

Execute Command

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 Usage

For use cases [example](example/lib/main.dart)

## 2. Constraints

### 2.1 Compatibility

This document is verified based on the following versions:

1. Flutter: 3.22.1-ohos-1.0.1; SDK: 5.0.0(12); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;

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
| Connectivity()      | Constructs a singleton instance of [Connectivity] | function | / | Connectivity | yes |
| onConnectivityChanged | Fires whenever the connectivity state changes. On iOS, the connectivity status might not update when WiFi status changes, this is a known issue that only affects simulators. | function | / | Stream<ConnectivityResult> | yes |
| checkConnectivity   | Checks the connection status of the device. Do not use the result of this function to decide whether you can reliably make a network request. It only gives you the radio status. | function | / | Future<ConnectivityResult> | yes |

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

## 5. Known Issues

## 6. Others

## 7. License

This project is licensed under [The BSD-3-Clause (license)](LICENSE).
