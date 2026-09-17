<p align="center">
  <h1 align="center"> <code>network_info_plus</code> </h1>
</p>

本项目基于 [network_info_plus](https://pub.dev/packages/network_info_plus) 开发，已适配 OpenHarmony / HarmonyOS（ohos）平台。

## 1. 安装与使用

### 1.1 安装方式

进入到工程目录并在 pubspec.yaml 中添加以下依赖：

<!-- tabs:start -->

#### pubspec.yaml

```yaml
dependencies:
  network_info_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/network_info_plus/network_info_plus
      # network_info_plus-7.0.0-ohos-1.0.1
      ref: TAG   # 请根据下方TAG版本对应表选择TAG
```

执行命令：

```bash
flutter pub get
```

<!-- tabs:end -->

> **说明** 请依赖 **`network_info_plus`**（不要依赖单独的
> `network_info_plus_ohos` 包）。ohos 实现已内置于主包的 `ohos/` 目录下，
> 通过 `pubspec.yaml` 中的 `flutter.plugin.platforms.ohos` 自动注册。

### 1.2 快速开始（可直接运行）

```dart
import 'package:network_info_plus/network_info_plus.dart';

final info = NetworkInfo();

Future<void> readNetworkInfo() async {
  // 所有 getter 均为可空：未连接 WiFi / 无有效值时返回 null；
  // 当底层 OHOS API 调用失败（如权限被拒）时抛出 PlatformException。
  final name      = await info.getWifiName();      // SSID，  如 "HomeWifi"
  final bssid     = await info.getWifiBSSID();     // BSSID，如 "aa:bb:cc:dd:ee:ff"
  final ipv4      = await info.getWifiIP();        // IPv4， 如 "192.168.1.5"
  final ipv6      = await info.getWifiIPv6();      // IPv6， 如 "2001:db8::1"
  final submask   = await info.getWifiSubmask();   // 掩码， 如 "255.255.255.0"
  final gateway   = await info.getWifiGatewayIP(); // 网关， 如 "192.168.1.1"
  final broadcast = await info.getWifiBroadcast(); // 广播， 如 "192.168.1.255"
}
```

完整可运行示例见 [example/lib/main.dart](example/lib/main.dart)，以及
全 API 无界面演示 [example/lib/network_info_demo.dart](example/lib/network_info_demo.dart)。

### 1.3 使用案例

使用案例详见 [ohos/example](example/)。

## 2. 约束与限制

### 2.1 TAG 版本对应表

| Flutter 框架版本 | TAG 名称 | 分支名 |
| --- | --- | --- |
| 3.41 | network_info_plus-8.2.1-ohos-1.0.1 | br_3.41 |
| 3.44 | network_info_plus-8.2.1-ohos-1.0.1 | br_3.41 |

### 2.2 兼容性
在以下版本中已测试通过:

1. Flutter: 3.41.10-ohos-0.0.1; SDK: 5.0.5(17); IDE: DevEco Studio: 6.1.0.830; ROM: 6.23.0.100 SP6;
2. Flutter: 3.44.9+ohos-0.0.1-canary1; SDK: 5.0.5(17); IDE: DevEco Studio 26.0.0 Beta2; ROM: 6.23.0.100 SP6;


### 2.3 权限要求

#### 2.3.1 在 entry 目录下的 module.json5 中添加权限

插件读取系统 WiFi 信息，需要 `ohos.permission.GET_WIFI_INFO` 权限。打开
`entry/src/main/module.json5`，在 `requestPermissions` 下添加：

```diff
...
"module": {
  ...
  "requestPermissions": [
+   {
+     "name": "ohos.permission.GET_WIFI_INFO",
+     "reason": "$string:reason_get_wifi_info",
+     "usedScene": {
+       "abilities": [ "EntryAbility" ],
+       "when": "always"
+     }
+   }
  ]
}
```

> `GET_WIFI_INFO` 为 `normal` 级权限，安装时授予，无需运行时弹窗。若你的应用
> 同时需要建立 socket，请保留 `ohos.permission.INTERNET`（示例工程同时声明了
> 这两个权限）。

## 3. OHOS 环境配置

本节介绍在 OpenHarmony / HarmonyOS 设备或模拟器上构建并运行插件所需的宿主工具链。

### 3.1 安装 DevEco Studio

1. 从 HarmonyOS 官方开发者站点下载与上述已验证版本匹配的 **DevEco Studio**
   （如 5.1.0.828 或 6.0.1.260）。
2. 首次启动时，DevEco 会安装 HarmonyOS **SDK** 与 **命令行工具**。在
   *File → Project Structure → Project SDKs* 中确认已配置
   `compatibleSdkVersion` ≥ `5.0.0(12)` 的 **HarmonyOS SDK**。
3. 安装随 DevEco 提供的 **ohpm**（OpenHarmony 包管理器）CLI，用于解析
   `ohos/oh-package.json5` 依赖。

### 3.2 安装支持 ohos 的 Flutter SDK

使用 CPF-Flutter fork 中支持 ohos 目标的 Flutter SDK（如
`3.27.5-ohos-0.0.1` 或 `3.35.7-ohos-0.0.1`）。校验：

```bash
flutter --version        # 必须显示 "-ohos-" 构建
flutter doctor           # 应检测到 DevEco/ohpm
```

### 3.3 编译 HAR / 运行示例

构建宿主应用时，ohos 构建会将插件原生侧编译为 **HAR**
（`network_info_plus.har`），通常无需手动构建 HAR。在已连接设备或模拟器上
构建并运行示例：

```bash
cd example
flutter pub get
flutter run -d <设备-id>            # -d entry-hap / hdc 设备号
```

如需使用自定义引擎（如未发布的 Flutter ohos 引擎），显式传入：

```bash
flutter run --local-engine-src-path <引擎源码路径> --local-engine=ohos_arm64
```

如需单独产出插件 HAR（供非 Flutter 的 HarmonyOS 应用或本地查看使用），在
DevEco Studio 中打开 `ohos/` 模块，执行 **Build → Build Hap(s)/APP(s) →
Build Hap(s)**，或使用命令行：

```bash
cd ohos
hvigorw --mode module -p module=network_info_plus@default assembleHar
```

## 4. API

> [!TIP] **ohos Support** 列为 **yes** 表示 ohos 平台支持该方法；**no** 表示不支持；
> **partially** 表示部分支持。Dart 侧使用方式跨平台一致，效果对标 iOS / Android。

### 4.1 NetworkInfo API

| 名称 | 描述 | 入参 | 返回类型（Dart） | ohos Support |
|------|------|------|------------------|--------------|
| `getWifiName()` | 获取已连接网络的 WiFi 名称（SSID） | / | `Future<String?>` | yes |
| `getWifiBSSID()` | 获取已连接网络的 WiFi BSSID | / | `Future<String?>` | yes |
| `getWifiIP()` | 获取已连接 WiFi 网络的 IPv4 地址 | / | `Future<String?>` | yes |
| `getWifiIPv6()` | 获取已连接 WiFi 网络的 IPv6 地址 | / | `Future<String?>` | yes |
| `getWifiSubmask()` | 获取已连接 WiFi 网络的子网掩码 | / | `Future<String?>` | yes |
| `getWifiGatewayIP()` | 获取已连接 WiFi 网络的网关 IP 地址 | / | `Future<String?>` | yes |
| `getWifiBroadcast()` | 获取已连接 WiFi 网络的广播地址 | / | `Future<String?>` | yes |

### 4.2 返回类型映射（Dart ↔ ArkTS）

公开 Dart API 始终返回 `Future<String?>`，但 ArkTS（ohos）实现层使用不同的
具体类型。下表说明两层之间的映射关系，明确通过 MethodChannel 传递的内容：

| 方法 | Dart（公开 API） | ArkTS 实现（ohos） | 经 MethodChannel 传递为 |
|------|------------------|--------------------|------------------------|
| `getWifiName` | `Future<String?>` | `Promise<string>` | `result.success(string \| null)` |
| `getWifiBSSID` | `Future<String?>` | `Promise<string>` | `result.success(string \| null)` |
| `getWifiIP` | `Future<String?>` | `string \| null` | `result.success(string \| null)` |
| `getWifiBroadcast` | `Future<String?>` | `string \| null` | `result.success(string \| null)` |
| `getWifiSubmask` | `Future<String?>` | `string`（无值时为 `''`） | `result.success(string \| null)` |
| `getWifiGatewayIP` | `Future<String?>` | `string \| null` | `result.success(string \| null)` |
| `getWifiIPv6` | `Future<String?>` | `string \| null` | `result.success(string \| null)` |
| *（任一方法失败时）* | 抛出 `PlatformException` | ArkTS 内抛出 | `result.error("network_info_error", …)` |

**关键说明：**

- **Dart 侧统一可空。** 未连接 WiFi 或对应字段无值时方法返回 `null`；当底层
  OHOS API 失败（如权限被拒、WiFi 服务不可用）时**抛出** `PlatformException`
  （错误码 `network_info_error`）。
- **不会有 `number` 到达 Dart。** 早期适配曾内部使用数值哨兵 `0`
  （即历史上的 `Promise<string|number|null>`）。当前适配在跨通道前将任何假值
  归一化为 `null`，因此 Dart 侧只能观察到 `String?` 或 `PlatformException`。
- **`getWifiSubmask`** 在 ohos 侧无掩码时返回 `''`，经通道转发为 `null`，
  以保持统一的可空契约。

## 5. 遗留问题

- 在模拟器上，`getWifiName` / `getWifiBSSID` 可能返回 `null`（未真实关联
  WiFi 时无法获取 SSID），与 iOS / Android 模拟器行为一致。
- `getWifiIPv6` 仅在设备已分配 IPv6 链路本地或全局地址时有值。

## 6. 其他

### 6.1 变更记录

- **7.0.0-ohos-1.0.0** — 对齐上游 `network_info_plus` 7.0.0；支持 Flutter
  ohos 3.27.5 / 3.35.7。原生错误现以 `PlatformException`（码
  `network_info_error`）上抛；通道名与异常处理已加固。修复
  `network_inf` → `network_info` 通道名拼写错误（此前该错误导致 Flutter 与
  ohos 无法通信）。
- **7.0.0-ohos-1.0.0-beta.1** — v7 ohos 首个 Beta。
- **4.1.0-ohos-1.0.0** — 首个 ohos 适配，基于上游 4.1.0。

## 7. 开源协议

本项目基于 [The BSD-3-Clause (license)](LICENSE)，请自由地享受和参与开源。
