<p align="center">
  <h1 align="center"> <code>network_info_plus</code> </h1>
</p>

本项目基于 [network_info_plus](https://pub.dev/packages/network_info_plus) 开发。

## 1. 安装与使用

### 1.1 安装方式

进入到工程目录并在 pubspec.yaml 中添加以下依赖：

<!-- tabs:start -->

#### pubspec.yaml

```yaml
...

dependencies:
  network_info_plus_ohos:
    git:
      url: https://gitcode.com/CPF-Flutter/fluttertpc_network_info_plus.git
      path: packages/network_info_plus/network_info_plus/network_info_plus_ohos
      # ref: network_info_plus-4.1.0-ohos-1.0.0-beta.1
      ref: TAG  # 请根据下方TAG版本对应表选择TAG
...
```

执行命令

```bash
flutter pub get
```

### TAG 版本对应表

| Flutter 框架版本   | TAG                                          | 分支     |
|----------------|----------------------------------------------|--------|
| 3.7            | network_info_plus-4.1.0-ohos-1.0.0-beta.1    | master |
| 3.22           | network_info_plus-4.1.0-ohos-1.0.0-beta.1    | master |

<!-- tabs:end -->

### 1.2 使用案例

使用案例详见 [ohos/example](network_info_plus_ohos/example/lib/main.dart)。

## 2. 约束与限制

### 2.1 兼容性

在以下版本中已测试通过:

1. Flutter: 3.7.12-ohos-1.1.3; SDK: 5.0.0(12); IDE: DevEco Studio: 5.1.0.828; ROM: 5.1.0.130 SP8;
2. Flutter: 3.22.1-ohos-1.0.3; SDK: 5.0.0(12); IDE: DevEco Studio: 5.1.0.828; ROM: 5.1.0.130 SP8;

### 2.2 权限要求

#### 2.2.1 在 entry 目录下的module.json5中添加权限

打开 `entry/src/main/module.json5`，添加：

```diff
...
"requestPermissions": [
+  {
+    "name": "ohos.permission.GET_WIFI_INFO"
+  }
]
```

## 3. API

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

### NetworkInfo API
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| getWifiName         | 获取已连接网络的WiFi名称（SSID） | function | / | Future<String?> | yes |
| getWifiBSSID        | 获取已连接网络的WiFi BSSID | function | / | Future<String?> | yes |
| getWifiIP           | 获取已连接WiFi网络的IPv4地址 | function | / | Future<String?> | yes |
| getWifiIPv6         | 获取已连接WiFi网络的IPv6地址 | function | / | Future<String?> | yes |
| getWifiSubmask      | 获取已连接WiFi网络的子网掩码 | function | / | Future<String?> | yes |
| getWifiGatewayIP    | 获取已连接WiFi网络的网关IP地址 | function | / | Future<String?> | yes |
| getWifiBroadcast    | 获取已连接WiFi网络的广播地址 | function | / | Future<String?> | yes |

## 4. 遗留问题

## 5. 其他

## 6. 开源协议

本项目基于 [The BSD-3-Clause (license)](network_info_plus_ohos/LICENSE)，请自由地享受和参与开源。
