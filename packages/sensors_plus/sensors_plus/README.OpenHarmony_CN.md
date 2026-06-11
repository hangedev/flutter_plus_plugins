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
  sensors_plus_ohos:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/sensors_plus/sensors_plus/ohos
      ref: br_sensors_plus-v7.0.0_ohos

...
```

执行命令

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 使用案例

使用案例详见 [ohos/example](ohos/example/lib/main.dart)

## 2. 约束与限制

### 2.1 兼容性

在以下版本中已测试通过

1. Flutter: 3.22.1-ohos-1.0.1; SDK: 6.0.1.112(21); IDE: DevEco Studio: 6.0.1.260; ROM: 6.0.0.120 SP6;
2. Flutter: 3.27.5-ohos-0.0.1; SDK: 6.0.1.112(21); IDE: DevEco Studio: 6.0.1.260; ROM: 6.0.0.120 SP6;
3. Flutter: 3.35.8-ohos-0.0.1; SDK: 6.0.1.112(21); IDE: DevEco Studio: 6.0.1.260; ROM: 6.0.0.120 SP6;

### 2.2 权限要求

####  2.2.1 在 entry 目录下的module.json5中添加权限

打开 `entry/src/main/module.json5`，添加：

```diff
...
"requestPermissions": [
  {"name" :  "ohos.permission.ACCELEROMETER"},
  {"name" :  "ohos.permission.GYROSCOPE"}
]
```

## 3. API

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

### Sensors API
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| accelerometerEventStream | 获取设备加速度计的广播流事件 | function | / | Stream<AccelerometerEvent> | yes |
| gyroscopeEventStream     | 获取设备陀螺仪的广播流事件 | function | / | Stream<GyroscopeEvent> | yes |
| userAccelerometerEventStream | 获取去除重力影响的设备加速度计事件流 | function | / | Stream<UserAccelerometerEvent> | yes |
| magnetometerEventStream  | 获取设备磁力计的广播流事件 | function | / | Stream<MagnetometerEvent> | yes |
| barometerEventStream  | 获取的设备气压计事件 | function | / | Stream<BarometerEvent> | yes |

---

## 4. 属性

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

### AccelerometerEvent Filters
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| x                   | X轴方向加速度力（含重力，单位m/s²） | double | / | / | yes |
| y                   | Y轴方向加速度力（含重力，单位m/s²） | double | / | / | yes |
| z                   | Z轴方向加速度力（含重力，单位m/s²） | double | / | / | yes |

---

### GyroscopeEvent Filters
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| x                   | X轴旋转速率（单位rad/s，描述"俯仰角"） | double | / | / | yes |
| y                   | Y轴旋转速率（单位rad/s，描述"偏航角"） | double | / | / | yes |
| z                   | Z轴旋转速率（单位rad/s，描述"翻滚角"） | double | / | / | yes |

---

### UserAccelerometerEvent Filters
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| x                   | X轴方向加速度力（不含重力，单位m/s²） | double | / | / | yes |
| y                   | Y轴方向加速度力（不含重力，单位m/s²） | double | / | / | yes |
| z                   | Z轴方向加速度力（不含重力，单位m/s²） | double | / | / | yes |

---

### MagnetometerEvent Filters
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| x                   | X轴环境磁场强度（单位μT） | double | / | / | yes |
| y                   | Y轴环境磁场强度（单位μT） | double | / | / | yes |
| z                   | Z轴环境磁场强度（单位μT） | double | / | / | yes |

---

### MagnetometerEvent Filters
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| pressure            | 传感器周围的气压（单位 hPa） | double   | / | / | yes |
| timestamp           | 事件的时间戳                | DateTime | / | / | yes |

---

## 5. 遗留问题

## 6. 其他

## 7. 开源协议

本项目基于 [The BSD-3-Clause (license)](ohos/LICENSE) ，请自由地享受和参与开源。
