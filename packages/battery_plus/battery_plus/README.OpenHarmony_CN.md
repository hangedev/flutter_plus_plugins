<p align="center">
  <h1 align="center"> <code>battery_plus</code> </h1>
</p>

本项目基于 [battery_plus](https://pub.dev/packages/battery_plus) 开发。

## 1. 安装与使用

### 1.1 安装方式

在 pubspec.yaml 中添加依赖：

<!-- tabs:start -->

#### pubspec.yaml

```yaml
dependencies:
  battery_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/battery_plus/battery_plus
      ref: TAG # 请根据下方TAG版本对应表选择TAG
```

执行：

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 TAG 版本对应表

| Flutter 框架版本 | TAG 名称 | 分支名 |
| --- | --- | --- |
| 3.22 | battery_plus-7.1.1-ohos-1.0.0 | br_3.41 |
| 3.27 | battery_plus-7.1.1-ohos-1.0.0 | br_3.41 |
| 3.35 | battery_plus-7.1.1-ohos-1.0.0 | br_3.41 |
| 3.41 | battery_plus-7.1.1-ohos-1.0.0 | br_3.41 |
| 3.44 | battery_plus-7.1.1-ohos-1.0.0 | br_3.41 |

### 1.3 OHOS 环境配置

OHOS 平台实现为联合插件，`flutter pub get` 后自动注册。运行示例应用还需：

1. 安装 DevEco Studio 及 HarmonyOS SDK（见 [2.1 兼容性](#21-兼容性)）。
2. 获取 OHOS 依赖：

   ```bash
   cd example/ohos
   ohpm install
   ```

3. DevEco Studio 打开 `example/ohos`（或 `flutter build hap`），部署到设备/模拟器。

> 插件使用 `@ohos.batteryInfo`（电量与充电状态）和 `@ohos.power`（节能模式），均为非敏感只读 API，无需在 `module.json5` 声明权限。

### 1.4 使用案例

使用 `battery_plus` 分为四步：

**第一步 — 导入并实例化**

```dart
import 'package:battery_plus/battery_plus.dart';

// Battery 为单例，构造函数始终返回同一实例。
final Battery _battery = Battery();
```

**第二步 — 读取数值**

每个 getter 返回 `Future`，用 `await` 获取结果。

```dart
final int level = await _battery.batteryLevel;           // 电量，0–100
final BatteryState state = await _battery.batteryState;  // 充电状态
final bool saveMode = await _battery.isInBatterySaveMode; // 节能模式
```

**第三步 — 监听状态变化**

```dart
StreamSubscription<BatteryState>? _subscription;

_subscription = _battery.onBatteryStateChanged.listen((BatteryState state) {
  // 响应充电状态变化
});
```

**第四步 — 取消订阅**

```dart
@override
void dispose() {
  _subscription?.cancel(); // 务必取消，避免内存泄漏
  super.dispose();
}
```

完整示例见 [example/lib/main.dart](example/lib/main.dart)。

## 2. 约束与限制

### 2.1 兼容性

在以下版本中已测试通过：

1. Flutter: 3.22.1-ohos-1.0.1; SDK: 5.0.5(17); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;
2. Flutter: 3.27.5-ohos-0.0.2; SDK: 5.0.5(17); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;
3. Flutter: 3.35.7-ohos-0.0.1; SDK: 5.0.5(17); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;
4. Flutter: 3.41.10-ohos-0.0.1; SDK: 5.0.5(17); IDE: DevEco Studio: 6.1.0.830; ROM: 6.23.0.100 SP6;
5. Flutter: 3.44.9+ohos-0.0.1-canary1; SDK: 5.0.5(17); IDE: DevEco Studio 26.0.0 Beta2; ROM: 6.23.0.100 SP6;

## 3. API

> [!TIP] "ohos Support"列为 yes 表示支持；no 表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android。

### 3.1 Battery API

| Name | Description | Type | Input | Output | 取值范围 / 说明 | ohos Support |
|---|---|---|---|---|---|---|
| batteryLevel | 获取电池电量 | function | / | Future<int> | 0–100，整数百分比 | yes |
| isInBatterySaveMode | 是否处于节能模式 | function | / | Future<bool> | true/false | yes |
| batteryState | 获取电池状态 | function | / | Future<BatteryState> | 见 3.2 | yes |
| onBatteryStateChanged | 监听电池状态改变 | function | / | Stream<BatteryState> | 状态变化时推送 | yes |

### 3.2 BatteryState

| Name | Description | Type | ohos Support |
|---|---|---|---|
| full | 电池满电 | enum | yes |
| charging | 充电中 | enum | yes |
| connectedNotCharging | 连接外部电源但未充电 | enum | [no](#5-遗留问题) |
| discharging | 耗电中 | enum | yes |
| unknown | 未知状态 | enum | yes |

### 3.3 异常处理

底层系统值无法获取时，平台实现以 `PlatformException` 拒绝 `Future`（或在流上发送错误事件），`code` 为 **`UNAVAILABLE`**，与 Android/iOS 一致。

```dart
try {
  final int level = await _battery.batteryLevel;
} on PlatformException catch (e) {
  // e.code == 'UNAVAILABLE'
}
```

| 失败场景 | 触发位置 | code |
|---|---|---|
| 电量 / 充电状态无法读取 | `batteryLevel` / `batteryState` | `UNAVAILABLE` |
| 节能模式无法查询 | `isInBatterySaveMode` | `UNAVAILABLE` |
| 流推送中读取失败 | `onBatteryStateChanged` 流错误 | `UNAVAILABLE` |

### 3.4 OHOS 原生接口（BatteryPlusPlugin）

原生实现位于 [BatteryPlusPlugin.ets](ohos/src/main/ets/components/plugin/BatteryPlusPlugin.ets)，实现 `FlutterPlugin`、`MethodCallHandler`、`StreamHandler` 三个接口：

| 方法 | 说明 |
|---|---|
| onAttachedToEngine | 注册 MethodChannel 与 EventChannel |
| onDetachedFromEngine | 释放通道、定时器、EventSink |
| onMethodCall | 处理 `getBatteryLevel`/`getBatteryState`/`isInBatterySaveMode`，失败报 `UNAVAILABLE` |
| getChargingStatus | 将 `batteryInfo.BatteryChargeState` 映射为协议字符串 |
| getBatteryMode | 查询 `power.getPowerMode()` 判断节能模式 |
| onListen | 启动轮询定时器，推送初始状态与后续变化 |
| onCancel | 停止定时器，释放 EventSink |

## 4. 鸿蒙示例

鸿蒙示例为 [example/](example/) 下的 Flutter 应用，Dart 入口 [example/lib/main.dart](example/lib/main.dart)，原生壳工程 [example/ohos/](example/ohos/)。

**场景一 — 读取当前电量与状态**

```dart
final Battery _battery = Battery();              // (1) 单例
final int level = await _battery.batteryLevel;    // (2) 电量
final BatteryState state = await _battery.batteryState; // (3) 状态
```

**场景二 — 监听充电状态变化**

```dart
// 订阅状态变化，state 取值: full / charging / discharging / unknown
// （connectedNotCharging 在 OHOS 上不会产生，见遗留问题）
final StreamSubscription<BatteryState> sub =
    _battery.onBatteryStateChanged.listen((BatteryState state) {
  // 响应新状态
});
// 不再需要时取消
sub.cancel();
```

原生侧实现见 [3.4](#34-ohos-原生接口batteryplusplugin)。

## 5. 遗留问题

- [ ] OHOS 仅支持 4 种电池状态，`BatteryState.connectedNotCharging` 不支持，OHOS 对无法表示的状态返回 `unknown`。详见 [BatteryState 模块介绍](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-battery-info#batterychargestate)。

## 6. 其他

## 7. 开源协议

本项目基于 [The BSD-3-Clause (license)](LICENSE)，请自由地享受和参与开源。
