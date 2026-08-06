> Template version: v0.0.1

<p align="center">
  <h1 align="center"> <code>sensors_plus</code> </h1>
</p>

This project is based on [sensors_plus](https://pub.dev/packages/sensors_plus).

## 1. Installation and Usage

### 1.1 Installation

Add the following dependency in pubspec.yaml:

<!-- tabs:start -->

#### pubspec.yaml

```yaml
...

dependencies:
  sensors_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/sensors_plus/sensors_plus
      ref: sensors_plus-7.0.0-ohos-1.0.1
...
```

Execute Command

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 TAG Version Mapping

| Flutter framework version | TAG name | Branch |
| --- | --- | --- |
| 3.22 | sensors_plus-7.0.0-ohos-1.0.1 | br_sensors_plus-v7.0.0_ohos |
| 3.27 | sensors_plus-7.0.0-ohos-1.0.1 | br_sensors_plus-v7.0.0_ohos |
| 3.35 | sensors_plus-7.0.0-ohos-1.0.1 | br_sensors_plus-v7.0.0_ohos |

### 1.3 OHOS Project Setup

1. Run `flutter create --platforms=ohos .` in the project root to generate the ohos project directory
2. Add sensor permissions in `ohos/entry/src/main/module.json5` (see §2.2)
3. Connect an OpenHarmony device and run:

```bash
cd example
flutter pub get
flutter run -d ohos
```

### 1.4 Usage

For a complete example, see [example/lib/main.dart](example/lib/main.dart)

## 2. Constraints

### 2.1 Compatibility

This document is verified based on the following versions:

1. Flutter: 3.22.1-ohos-1.0.1; SDK: 6.0.1.112(21); IDE: DevEco Studio: 6.0.1.260; ROM: 6.0.0.120 SP6;
2. Flutter: 3.27.5-ohos-0.0.1; SDK: 6.0.1.112(21); IDE: DevEco Studio: 6.0.1.260; ROM: 6.0.0.120 SP6;
3. Flutter: 3.35.8-ohos-0.0.1; SDK: 6.0.1.112(21); IDE: DevEco Studio: 6.0.1.260; ROM: 6.0.0.120 SP6;

### 2.2 Permission Requirements

#### 2.2.1 Add permissions to the module.json5 file in the entry directory

Open `ohos/entry/src/main/module.json5` and add the following under the `module` node:

```json5
"requestPermissions": [
  {"name": "ohos.permission.ACCELEROMETER"},
  {"name": "ohos.permission.GYROSCOPE"}
]
```

> **Note**: The accelerometer and user accelerometer require `ACCELEROMETER` permission, and the gyroscope requires `GYROSCOPE` permission. The magnetometer and barometer do not require additional permission declarations on current OHOS versions.

## 3. API

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### 3.1 Sensors API

| Name | Description | Type | Input | Output | ohos Support |
|------|-------------|------|-------|--------|--------------|
| accelerometerEventStream | A broadcast stream of events from the device accelerometer | function | samplingPeriod: Duration | Stream\<AccelerometerEvent\> | yes |
| gyroscopeEventStream | A broadcast stream of events from the device gyroscope | function | samplingPeriod: Duration | Stream\<GyroscopeEvent\> | yes |
| userAccelerometerEventStream | Events from the device accelerometer with gravity removed | function | samplingPeriod: Duration | Stream\<UserAccelerometerEvent\> | yes |
| magnetometerEventStream | A broadcast stream of events from the device magnetometer | function | samplingPeriod: Duration | Stream\<MagnetometerEvent\> | yes |
| barometerEventStream | A broadcast stream of events from the device barometer | function | samplingPeriod: Duration | Stream\<BarometerEvent\> | yes |

#### Parameter Description

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| samplingPeriod | Duration | No | SensorInterval.normalInterval (200ms) | Sensor sampling period; smaller values result in more frequent sampling |

#### Predefined Sampling Period Constants (SensorInterval)

| Constant | Value | Description |
|----------|-------|-------------|
| SensorInterval.gameInterval | 20ms | Game scenario, highest frequency |
| SensorInterval.uiInterval | ~66ms | UI animation scenario |
| SensorInterval.normalInterval | 200ms | Default scenario |
| SensorInterval.fastestInterval | 0ms | Fastest sampling |

#### Usage Examples

```dart
import 'package:sensors_plus/sensors_plus.dart';

// [OHOS] Listen to accelerometer with default sampling period (200ms)
// Note: ohos.permission.ACCELEROMETER must be declared in module.json5
accelerometerEventStream().listen((AccelerometerEvent event) {
  print('x: ${event.x}, y: ${event.y}, z: ${event.z}');
});

// [OHOS] Specify game-level sampling period (20ms) for latency-sensitive scenarios
// Shorter sampling periods consume more CPU and battery; choose the appropriate
// period for your use case
accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval)
    .listen((AccelerometerEvent event) {
  // Handle accelerometer event
});

// [OHOS] Listen to barometer
barometerEventStream(samplingPeriod: SensorInterval.normalInterval)
    .listen((BarometerEvent event) {
  print('pressure: ${event.pressure} hPa');
});

// [OHOS] Dynamically change sampling period
// Multiple calls to the same sensor return the same cached broadcast stream;
// changing samplingPeriod affects all listeners on that stream
accelerometerEventStream(samplingPeriod: SensorInterval.uiInterval);

// [OHOS] Error handling: some sensors may not be available on the device
// Listen to onError to handle sensor unavailability or permission issues
userAccelerometerEventStream().listen(
  (UserAccelerometerEvent event) {
    // Handle event
  },
  onError: (error) {
    // Handle sensor unavailable or permission not granted
    print('Sensor error: $error');
  },
  cancelOnError: true,
);
```

### 3.2 Sensors Singleton Class

The `Sensors` class is the implementation of sensor functionality, using a singleton pattern. Obtain the unique instance via `Sensors()`. All `*EventStream()` methods can be called through this instance, with behavior identical to the top-level functions.

```dart
final sensors = Sensors();

// Call via Sensors instance
sensors.accelerometerEventStream().listen((event) { ... });

// Equivalent to top-level function call
accelerometerEventStream().listen((event) { ... });
```

### 3.3 Deprecated APIs

The following top-level getters are marked as `@Deprecated`. Use the corresponding `*EventStream()` functions instead:

| Deprecated API | Replacement | Note |
|---------------|-------------|------|
| `accelerometerEvents` | `accelerometerEventStream()` | Top-level property, cannot specify sampling period |
| `gyroscopeEvents` | `gyroscopeEventStream()` | Top-level property, cannot specify sampling period |
| `userAccelerometerEvents` | `userAccelerometerEventStream()` | Top-level property, cannot specify sampling period |
| `magnetometerEvents` | `magnetometerEventStream()` | Top-level property, cannot specify sampling period |

> **Migration guide**: Replace `accelerometerEvents.listen(...)` with `accelerometerEventStream().listen(...)`. The new API supports the `samplingPeriod` parameter to control sampling frequency.

---

## 4. Properties

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### AccelerometerEvent Properties

| Name | Description | Type | ohos Support |
|------|-------------|------|--------------|
| x | Acceleration force along X-axis (m/s², includes gravity) | double | yes |
| y | Acceleration force along Y-axis (m/s², includes gravity) | double | yes |
| z | Acceleration force along Z-axis (m/s², includes gravity) | double | yes |
| timestamp | Event timestamp | DateTime | yes |

### GyroscopeEvent Properties

| Name | Description | Type | ohos Support |
|------|-------------|------|--------------|
| x | Rotation rate around X-axis (rad/s, describes "pitch") | double | yes |
| y | Rotation rate around Y-axis (rad/s, describes "yaw") | double | yes |
| z | Rotation rate around Z-axis (rad/s, describes "roll") | double | yes |
| timestamp | Event timestamp | DateTime | yes |

### UserAccelerometerEvent Properties

| Name | Description | Type | ohos Support |
|------|-------------|------|--------------|
| x | Acceleration force along X-axis (m/s², excludes gravity) | double | yes |
| y | Acceleration force along Y-axis (m/s², excludes gravity) | double | yes |
| z | Acceleration force along Z-axis (m/s², excludes gravity) | double | yes |
| timestamp | Event timestamp | DateTime | yes |

### MagnetometerEvent Properties

| Name | Description | Type | ohos Support |
|------|-------------|------|--------------|
| x | Ambient magnetic field along X-axis (μT) | double | yes |
| y | Ambient magnetic field along Y-axis (μT) | double | yes |
| z | Ambient magnetic field along Z-axis (μT) | double | yes |
| timestamp | Event timestamp | DateTime | yes |

### BarometerEvent Properties

| Name | Description | Type | ohos Support |
|------|-------------|------|--------------|
| pressure | Ambient air pressure around the sensor (unit: hPa) | double | yes |
| timestamp | Event timestamp | DateTime | yes |

---

## 5. Known Issues

None.

## 6. Others

The OpenHarmony implementation is based on the `@ohos.sensor` API. Accelerometer and gyroscope events use `sensor.on()` / `sensor.off()` for subscription and cancellation, and deliver sensor data to Flutter via EventChannel. The sampling period is configured through MethodChannel's `set*SamplingPeriod` methods, where the Duration value is converted to a nanosecond-level interval parameter on the OHOS side.

## 7. License

This project is licensed under [The MIT License](LICENSE).
