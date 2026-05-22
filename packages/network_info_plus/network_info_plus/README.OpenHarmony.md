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
      url: https://gitcode.com/openharmony-sig/fluttertpc_network_info_plus.git
      # ref: br_network_info_plus-7.0.0-ohos.1.0.0-beta.1
      ref: TAG   # Please select the TAG to the TAG Version Mapping
...
```

Execute Command

```bash
flutter pub get
```

### TAG Version Mapping

| Flutter Framework Version | TAG                                          | Branch                           |
|---------------------------|----------------------------------------------|----------------------------------|
| 3.27                      | br_network_info_plus-7.0.0-ohos.1.0.0-beta.1 | br_network_info_plus_v7.0.0_ohos |
| 3.35                      | br_network_info_plus-7.0.0-ohos.1.0.0-beta.1 | br_network_info_plus_v7.0.0_ohos |

<!-- tabs:end -->

### 1.2 Usage

For use cases [ohos/example](example/lib/main.dart).

## 2. Constraints

### 2.1 Compatibility

This document is verified based on the following versions:

1. Flutter: 3.27.5-ohos-0.0.1; SDK: 5.0.0(12); IDE: DevEco Studio: 5.1.0.828; ROM: 5.1.0.130 SP8;
2. Flutter: 3.35.7-ohos-0.0.1; SDK: 6.0.1(21); IDE: DevEco Studio: 6.0.1.260; ROM: 6.0.0.120 SP6;

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

This project is licensed under [The BSD-3-Clause (license)](LICENSE).
