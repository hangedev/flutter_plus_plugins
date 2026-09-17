> 模板版本: v0.0.1

<p align="center">
  <h1 align="center"> <code>sensors_plus</code> </h1>
</p>

本项目基于 [sensors_plus](https://pub.dev/packages/sensors_plus) 开发。

## 1. 安装与使用

### 1.1 安装方式

进入到工程目录并在 pubspec.yaml 中添加以下依赖：

<!-- tabs:start -->

#### pubspec.yaml

```yaml
...

dependencies:
  sensors_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/sensors_plus/sensors_plus
      ref: TAG #根据下面框架版本选择TAG

...
```

执行命令

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 TAG 版本对应表

| Flutter 框架版本 | TAG 名称 | 分支名 |
| --- | --- | --- |
| 3.22 | sensors_plus-7.1.0-ohos-1.0.0 | br_3.41 |
| 3.27 | sensors_plus-7.1.0-ohos-1.0.0 | br_3.41 |
| 3.35 | sensors_plus-7.1.0-ohos-1.0.0 | br_3.41 |  
| 3.41 | sensors_plus-7.1.0-ohos-1.0.0 | br_3.41 |
| 3.44 | sensors_plus-7.1.0-ohos-1.0.0 | br_3.41 |

### 1.3 OHOS 工程配置

1. 在项目根目录执行 `flutter create --platforms=ohos .` 生成 ohos 工程目录
2. 在 `ohos/entry/src/main/module.json5` 中添加传感器权限（见 §2.2）
3. 连接鸿蒙设备后执行以下命令构建运行：

```bash
cd example
flutter pub get
flutter run -d ohos
```

### 1.4 使用案例

完整示例参见 [example/lib/main.dart](example/lib/main.dart)

## 2. 约束与限制

### 2.1 兼容性

在以下版本中已测试通过

1. Flutter: 3.22.1-ohos-1.0.1; SDK: 5.0.5(17); IDE: DevEco Studio: 6.0.1.260; ROM: 6.0.0.120 SP6;
2. Flutter: 3.27.5-ohos-0.0.1; SDK: 5.0.5(17); IDE: DevEco Studio: 6.0.1.260; ROM: 6.0.0.120 SP6;
3. Flutter: 3.35.8-ohos-0.0.1; SDK: 5.0.5(17); IDE: DevEco Studio: 6.0.1.260; ROM: 6.0.0.120 SP6;
4. Flutter: 3.41.10-ohos-0.0.1; SDK: 5.0.5(17); IDE: DevEco Studio: 6.1.0.830; ROM: 6.23.0.100 SP6;
5. Flutter: 3.44.9+ohos-0.0.1-canary1; SDK: 5.0.5(17); IDE: DevEco Studio 26.0.0 Beta2; ROM: 6.23.0.100 SP6;

### 2.2 权限要求

#### 2.2.1 在 entry 目录下的 module.json5 中添加权限

打开 `ohos/entry/src/main/module.json5`，在 `module` 节点下添加权限声明：

```json5
"requestPermissions": [
  {"name": "ohos.permission.ACCELEROMETER"},
  {"name": "ohos.permission.GYROSCOPE"}
]
```

> **说明**：加速度计和用户加速度计使用 `ACCELEROMETER` 权限，陀螺仪使用 `GYROSCOPE` 权限。磁力计和气压计在当前 OHOS 版本上无需额外权限声明。

## 3. API

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

### 3.1 Sensors API

| Name | Description | Type | Input | Output | ohos Support |
|------|-------------|------|-------|--------|--------------|
| accelerometerEventStream | 获取设备加速度计的广播流事件 | function | samplingPeriod: Duration | Stream\<AccelerometerEvent\> | yes |
| gyroscopeEventStream | 获取设备陀螺仪的广播流事件 | function | samplingPeriod: Duration | Stream\<GyroscopeEvent\> | yes |
| userAccelerometerEventStream | 获取去除重力影响的设备加速度计事件流 | function | samplingPeriod: Duration | Stream\<UserAccelerometerEvent\> | yes |
| magnetometerEventStream | 获取设备磁力计的广播流事件 | function | samplingPeriod: Duration | Stream\<MagnetometerEvent\> | yes |
| barometerEventStream | 获取设备气压计的广播流事件 | function | samplingPeriod: Duration | Stream\<BarometerEvent\> | yes |

#### 参数说明

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| samplingPeriod | Duration | 否 | SensorInterval.normalInterval (200ms) | 传感器采样周期，值越小采样越频繁 |

#### 预定义采样周期常量（SensorInterval）

| 常量名 | 值 | 说明 |
|--------|-----|------|
| SensorInterval.gameInterval | 20ms | 游戏场景，最高频率 |
| SensorInterval.uiInterval | ~66ms | UI 动画场景 |
| SensorInterval.normalInterval | 200ms | 默认场景 |
| SensorInterval.fastestInterval | 0ms | 最快采样 |

#### 调用示例

```dart
import 'package:sensors_plus/sensors_plus.dart';

// [OHOS] 使用默认采样周期（200ms）监听加速度计
// 注意：需要先在 module.json5 中声明 ohos.permission.ACCELEROMETER 权限
accelerometerEventStream().listen((AccelerometerEvent event) {
  print('x: ${event.x}, y: ${event.y}, z: ${event.z}');
});

// [OHOS] 指定游戏级采样周期（20ms），适合对延迟敏感的场景
// 采样周期越短，CPU 和电量消耗越大，请在合适的场景选择合适的周期
accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval)
    .listen((AccelerometerEvent event) {
  // 处理加速度计事件
});

// [OHOS] 监听气压计
barometerEventStream(samplingPeriod: SensorInterval.normalInterval)
    .listen((BarometerEvent event) {
  print('pressure: ${event.pressure} hPa');
});

// [OHOS] 动态切换采样周期
// 同一传感器的多次调用返回的是同一个缓存的广播流（broadcast stream），
// 切换 samplingPeriod 会影响该流上的所有监听者
accelerometerEventStream(samplingPeriod: SensorInterval.uiInterval);

// [OHOS] 错误处理：设备可能不支持某些传感器
// 监听 onError 回调以处理传感器不可用的情况
userAccelerometerEventStream().listen(
  (UserAccelerometerEvent event) {
    // 处理事件
  },
  onError: (error) {
    // 传感器不可用或权限未授予时的处理
    print('Sensor error: $error');
  },
  cancelOnError: true,
);
```

### 3.2 Sensors 单例类

`Sensors` 类是传感器功能的实现类，采用单例模式，通过 `Sensors()` 获取唯一实例。所有 `*EventStream()` 方法均可通过该实例调用，行为与顶层函数完全一致。

```dart
final sensors = Sensors();

// 通过 Sensors 实例调用
sensors.accelerometerEventStream().listen((event) { ... });

// 与顶层函数调用等效
accelerometerEventStream().listen((event) { ... });
```

### 3.3 已弃用 API

以下顶层 Getter 已标记为 `@Deprecated`，建议使用对应的 `*EventStream()` 函数替代：

| 已弃用 API | 替代 API | 说明 |
|-----------|---------|------|
| `accelerometerEvents` | `accelerometerEventStream()` | 顶层属性，无法指定采样周期 |
| `gyroscopeEvents` | `gyroscopeEventStream()` | 顶层属性，无法指定采样周期 |
| `userAccelerometerEvents` | `userAccelerometerEventStream()` | 顶层属性，无法指定采样周期 |
| `magnetometerEvents` | `magnetometerEventStream()` | 顶层属性，无法指定采样周期 |

> **迁移建议**：将 `accelerometerEvents.listen(...)` 替换为 `accelerometerEventStream().listen(...)`，新 API 支持通过 `samplingPeriod` 参数控制采样频率。

---

## 4. 属性

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

### AccelerometerEvent 属性

| Name | Description | Type | ohos Support |
|------|-------------|------|--------------|
| x | X轴方向加速度力（含重力，单位m/s²） | double | yes |
| y | Y轴方向加速度力（含重力，单位m/s²） | double | yes |
| z | Z轴方向加速度力（含重力，单位m/s²） | double | yes |
| timestamp | 事件的时间戳 | DateTime | yes |

### GyroscopeEvent 属性

| Name | Description | Type | ohos Support |
|------|-------------|------|--------------|
| x | X轴旋转速率（单位rad/s，描述"俯仰角"） | double | yes |
| y | Y轴旋转速率（单位rad/s，描述"偏航角"） | double | yes |
| z | Z轴旋转速率（单位rad/s，描述"翻滚角"） | double | yes |
| timestamp | 事件的时间戳 | DateTime | yes |

### UserAccelerometerEvent 属性

| Name | Description | Type | ohos Support |
|------|-------------|------|--------------|
| x | X轴方向加速度力（不含重力，单位m/s²） | double | yes |
| y | Y轴方向加速度力（不含重力，单位m/s²） | double | yes |
| z | Z轴方向加速度力（不含重力，单位m/s²） | double | yes |
| timestamp | 事件的时间戳 | DateTime | yes |

### MagnetometerEvent 属性

| Name | Description | Type | ohos Support |
|------|-------------|------|--------------|
| x | X轴环境磁场强度（单位μT） | double | yes |
| y | Y轴环境磁场强度（单位μT） | double | yes |
| z | Z轴环境磁场强度（单位μT） | double | yes |
| timestamp | 事件的时间戳 | DateTime | yes |

### BarometerEvent 属性

| Name | Description | Type | ohos Support |
|------|-------------|------|--------------|
| pressure | 传感器周围的气压（单位 hPa） | double | yes |
| timestamp | 事件的时间戳 | DateTime | yes |

---

## 5. 遗留问题

无。

## 6. 其他

本插件鸿蒙化实现基于 OpenHarmony `@ohos.sensor` 接口，加速度计和陀螺仪使用 `sensor.on()` / `sensor.off()` 进行事件订阅与取消，通过 EventChannel 将传感器数据传递至 Flutter 侧。采样周期通过 MethodChannel 的 `set*SamplingPeriod` 方法设置，OHOS 侧将 Duration 值转换为纳秒级间隔参数。

## 7. 开源协议

本项目基于 [The MIT License](LICENSE) ，请自由地享受和参与开源。
