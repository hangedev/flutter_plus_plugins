<p align="center">
  <h1 align="center"> <code>network_info_plus</code> </h1>
</p>

This project is based on [network_info_plus](https://pub.dev/packages/network_info_plus).

## 1. Installation and Usage

### 1.1 Installation

Go to the project directory and add the following dependencies in pubspec.yaml

<!-- tabs:start -->

#### pubspec.yaml

```yaml
...

dependencies:
  network_info_plus_ohos:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins/tree/master/packages/network_info_plus.git
      path: packages/network_info_plus/network_info_plus/network_info_plus_ohos
...
```

Execute Command

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 Usage

For use cases [ohos/example](network_info_plus_ohos/example/lib/main.dart).

## 2. Constraints

### 2.1 Compatibility

This document is verified based on the following versions:

1. Flutter: 3.7.12-ohos-1.1.3; SDK: 5.0.0(12); IDE: DevEco Studio: 5.1.0.828; ROM: 5.1.0.130 SP8;
2. Flutter: 3.22.1-ohos-1.0.3; SDK: 5.0.0(12); IDE: DevEco Studio: 5.1.0.828; ROM: 5.1.0.130 SP8;

### 2.2 Permission Requirements

#### 2.2.1 Add permissions to the module.json5 file in the entry directory

Open  `entry/src/main/module.json5` and add the following information:

```diff
...
"requestPermissions": [
+  {
+    "name": "ohos.permission.GET_WIFI_INFO"
+  }
]
```

## 3. API

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### NetworkInfo API
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| getWifiName         | Obtains the wifi name (SSID) of the connected network | function | / | Future<String?> | yes |
| getWifiBSSID        | Obtains the wifi BSSID of the connected network | function | / | Future<String?> | yes |
| getWifiIP           | Obtains the IPv4 address of the connected wifi network | function | / | Future<String?> | yes |
| getWifiIPv6         | Obtains the IPv6 address of the connected wifi network | function | / | Future<String?> | yes |
| getWifiSubmask      | Obtains the submask of the connected wifi network | function | / | Future<String?> | yes |
| getWifiGatewayIP    | Obtains the gateway IP address of the connected wifi network | function | / | Future<String?> | yes |
| getWifiBroadcast    | Obtains the broadcast of the connected wifi network | function | / | Future<String?> | yes |

## 4. Known Issues

## 5. Others

## 6. License

This project is licensed under [The BSD-3-Clause (license)](network_info_plus_ohos/LICENSE).
