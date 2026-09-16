<p align="center">
  <h1 align="center"> <code>connectivity_plus</code> </h1>
</p>

本项目基于 [connectivity_plus](https://pub.dev/packages/connectivity_plus) 开发。

## 1. 安装与使用

### 1.1 安装方式

进入到工程目录并在 pubspec.yaml 中添加以下依赖：

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
      ref: TAG  # 请根据下方TAG版本对应表选择TAG

...
```

执行命令

```bash
flutter pub get
```

### TAG 版本对应表

| Flutter 框架版本 | TAG                                       | 分支    |
|------------------|-------------------------------------------|---------|
| 3.7              | connectivity_plus-5.0.1-ohos-1.0.0-beta.1 | master  |
| 3.22             | connectivity_plus-7.2.0-ohos.1.0.0        | br_3.41 |
| 3.27             | connectivity_plus-7.2.0-ohos.1.0.0        | br_3.41 |
| 3.35             | connectivity_plus-7.2.0-ohos.1.0.0        | br_3.41 |
| 3.41             | connectivity_plus-7.2.0-ohos.1.0.0        | br_3.41 |

<!-- tabs:end -->

### 1.2 使用案例

使用案例详见 [example](example/lib/main.dart)。

导入依赖：

```dart
import 'package:connectivity_plus/connectivity_plus.dart';
```

查询当前可用的连接类型：

```dart
final List<ConnectivityResult> result = await Connectivity().checkConnectivity();

if (result.contains(ConnectivityResult.wifi)) {
  // Wi-Fi 可用。
} else if (result.contains(ConnectivityResult.mobile)) {
  // 移动网络可用。
} else if (result.contains(ConnectivityResult.none)) {
  // 无活动网络。
}
```

监听连接状态变化（流内部已应用 `Stream.distinct`，连续相同的状态不会重复发射）：

```dart
final connectivity = Connectivity();
final subscription =
    connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) {
  print('Connectivity changed: $result');
});

// 不再需要监听时取消订阅。
subscription.cancel();
```

## 2. 约束与限制

### 2.1 兼容性

在以下版本中已测试通过：

1. Flutter: 3.22.1-ohos-1.0.1; SDK: 5.0.5(17); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;
2. Flutter: 3.27.5-ohos-0.0.1; SDK: 5.0.5(17); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;
3. Flutter: 3.35.7-ohos-0.0.1; SDK: 5.0.5(17); IDE: DevEco Studio: 6.0.1.260; ROM: 6.0.0.120 SP6;
4. Flutter: 3.41.10-ohos-0.0.1; SDK: 5.0.5(17); IDE: DevEco Studio 26.0.0 Beta2; ROM: 7.0.0.105 SP10;

### 2.2 权限要求

####  2.2.1 在 entry 目录下的 module.json5中添加权限

打开 `entry/src/main/module.json5`，添加：

```diff
...
"requestPermissions": [
  {"name" :  "ohos.permission.INTERNET"}
]
```

## 3. API

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

### Connectivity API
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| Connectivity()      | 构造 [Connectivity] 的单例实例，二次构造返回同一实例。 | function | / | Connectivity | yes |
| onConnectivityChanged | 当连接状态发生变化时触发。在 iOS 上，WiFi 状态变化时连接状态可能不会更新，这是仅影响模拟器的已知问题。返回的列表永不为空，无连接时仅含单个 `none` 元素。 | function | / | Stream<List<ConnectivityResult>> | yes |
| checkConnectivity   | 检查设备连接状态。不要根据此函数的结果判断是否能可靠发起网络请求，它仅提供无线电状态信息。返回的列表永不为空，无连接时仅含单个 `none` 元素。 | function | / | Future<List<ConnectivityResult>> | yes |

---

## 4. 属性

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

### ConnectivityResult Filters
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| bluetooth           | 通过蓝牙连接的设备      | enum     | /     | /       | yes          |
| wifi                | 通过 Wi-Fi 连接的设备          | enum     | /     | /       | yes          |
| ethernet            | 连接到以太网的设备| enum     | /     | /       | yes          |
| mobile              | 连接到蜂窝网络的设备| enum     | /     | /       | yes          |
| none                | 未连接到任何网络的设备 | enum     | /     | /       | yes          |
| vpn                 | 连接到 VPN 的设备（注意：iOS/macOS 返回 [other]） | enum | / | / | yes      |
| other               | 连接到未知网络的设备 | enum | /     | /       | yes          |
| satellite           | 通过卫星网络连接的设备（Android 15+ / iOS 支持；OHOS 不支持，不会上报该类型） | enum | /     | /       | no           |

## 5. 遗留问题

- 在 OHOS 上，`bluetooth` 与 `vpn` 连接类型依赖 `NetBearType.BEARER_BLUETOOTH` 与 `NetBearType.BEARER_VPN`，二者自 API 12 起可用。在低于 API 12 的 OHOS 设备上不会上报这两种连接类型（活动承载会回退为 `wifi` / `ethernet` / `mobile` / `other`）。
- 请勿仅依据连接状态判断网络请求是否会成功。连接类型可用并不保证具备互联网访问能力（例如处于强制门户后的 Wi-Fi 可能仍无互联网）。

## 6. 其他

- **OHOS 行为对齐**：OHOS 实现将 `@ohos.net.connection` 的承载类型映射为 `ConnectivityResult` 值，与 Android 一致，可同时返回多种连接类型（如 `wifi` + `vpn`）。当设备已联网但无已识别的承载类型时，返回 `other` 而非 `none`。
- **所需权限**：`ohos.permission.INTERNET` 仅在宿主应用自身需要进行网络访问时才需要。

## 7. 开源协议

本项目基于 [The BSD-3-Clause (license)](LICENSE) ，请自由地享受和参与开源。
