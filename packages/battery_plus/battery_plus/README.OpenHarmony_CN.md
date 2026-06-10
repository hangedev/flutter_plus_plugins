<p align="center">
  <h1 align="center"> <code>battery_plus</code> </h1>
</p>

本项目基于 [battery_plus](https://pub.dev/packages/battery_plus) 开发。

## 1. 安装与使用

### 1.1 安装方式

进入到工程目录并在 pubspec.yaml 中添加以下依赖：

<!-- tabs:start -->

#### pubspec.yaml

```yaml
...

dependencies:
  battery_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/battery_plus/battery_plus
      ref: br_battery_plus-v6.1.0_ohos

...
```

执行命令

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 使用案例

使用案例详见 [example](example/lib/main.dart)。

## 2. 约束与限制

### 2.1 兼容性

在以下版本中已测试通过：

1. Flutter: 3.22.1-ohos-1.0.1; SDK: 5.0.0(12); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;
2. Flutter: 3.27.5-ohos-0.0.2; SDK: 5.0.0(12); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;

## 3. API

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

### Battery API

| Name                  | Description    | Type     | Input | Output               | ohos Support |
|-----------------------|----------------|----------|-------|----------------------|--------------|
| batteryLevel          | 获取电池等级         | function | /     | Future<int>          | yes          |
| isInBatterySaveMode   | 判断当前设备是否处于节能模式 | function | /     | Future<bool>         | yes          |
| batteryState          | 获取电池状态         | function | /     | Future<BatteryState> | yes          |
| onBatteryStateChanged | 监听电池状态改变       | function | /     | Stream<BatteryState> | yes          |

### BatteryState

| Name                 | Description    | Type | Input | Output | ohos Support  |
|----------------------|----------------|------|-------|--------|---------------|
| full                 | 电池处于满电状态       | enum | /     | /      | yes           |
| charging             | 电池处于充电状态       | enum | /     | /      | yes           |
| connectedNotCharging | 连接了外部电源，但未进行充电 | enum | /     | /      | [no](#4-遗留问题) |
| discharging          | 电池处于耗电状态       | enum | /     | /      | yes           |
| unknown              | 电池处于未知状态       | enum | /     | /      | yes           |

## 4. 遗留问题

- [ ] ohos 中电池只有4种状态，[BatteryState 模块介绍](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-battery-info#batterychargestate)

## 5. 其他

## 6. 开源协议

本项目基于 [The BSD-3-Clause (license)](LICENSE) ，请自由地享受和参与开源。
