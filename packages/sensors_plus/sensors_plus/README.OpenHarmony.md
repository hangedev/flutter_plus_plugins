> Template version: v0.0.1

<p align="center">
  <h1 align="center"> <code>sensors_plus</code> </h1>
</p>

This project is based on [sensors_plus](https://pub.dev/packages/sensors_plus).

## 1. Installation and Usage

### 1.1 Installation

Go to the project directory and add the following dependencies in pubspec.yaml

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

Execute Command

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 Usage

For use cases [ohos/example](ohos/example/lib/main.dart)

## 2. Constraints

### 2.1 Compatibility

This document is verified based on the following versions:

1. Flutter: 3.22.1-ohos-1.0.1; SDK: 6.0.1.112(21); IDE: DevEco Studio: 6.0.1.260; ROM: 6.0.0.120 SP6;
2. Flutter: 3.27.5-ohos-0.0.1; SDK: 6.0.1.112(21); IDE: DevEco Studio: 6.0.1.260; ROM: 6.0.0.120 SP6;
3. Flutter: 3.35.8-ohos-0.0.1; SDK: 6.0.1.112(21); IDE: DevEco Studio: 6.0.1.260; ROM: 6.0.0.120 SP6;

### 2.2 Permission Requirements

####  2.2.1 Add permissions to the module.json5 file in the entry directory.

Open  `entry/src/main/module.json5` and add the following information:

```diff
...
"requestPermissions": [
  {"name" :  "ohos.permission.ACCELEROMETER"},
  {"name" :  "ohos.permission.GYROSCOPE"}
]
```

## 3. API

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### Sensors API
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| accelerometerEventStream | A broadcast stream of events from the device accelerometer | function | / | Stream<AccelerometerEvent> | yes |
| gyroscopeEventStream     | A broadcast stream of events from the device gyroscope | function | / | Stream<GyroscopeEvent> | yes |
| userAccelerometerEventStream | Events from the device accelerometer with gravity removed | function | / | Stream<UserAccelerometerEvent> | yes |
| magnetometerEventStream  | A broadcast stream of events from the device magnetometer | function | / | Stream<MagnetometerEvent> | yes |
| barometerEventStream    | A broadcast stream of events from the device barometer | function | / | Stream<BarometerEvent> | yes |

---

## 4. Properties

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### AccelerometerEvent Filters
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| x                   | Acceleration force along X-axis (m/s², includes gravity) | double | / | / | yes |
| y                   | Acceleration force along Y-axis (m/s², includes gravity) | double | / | / | yes |
| z                   | Acceleration force along Z-axis (m/s², includes gravity) | double | / | / | yes |

---

### GyroscopeEvent Filters
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| x                   | Rotation rate around X-axis (rad/s, describes "pitch") | double | / | / | yes |
| y                   | Rotation rate around Y-axis (rad/s, describes "yaw") | double | / | / | yes |
| z                   | Rotation rate around Z-axis (rad/s, describes "roll") | double | / | / | yes |

---

### UserAccelerometerEvent Filters
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| x                   | Acceleration force along X-axis (m/s², excludes gravity) | double | / | / | yes |
| y                   | Acceleration force along Y-axis (m/s², excludes gravity) | double | / | / | yes |
| z                   | Acceleration force along Z-axis (m/s², excludes gravity) | double | / | / | yes |

---

### MagnetometerEvent Filters
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| x                   | Ambient magnetic field along X-axis (μT) | double | / | / | yes |
| y                   | Ambient magnetic field along Y-axis (μT) | double | / | / | yes |
| z                   | Ambient magnetic field along Z-axis (μT) | double | / | / | yes |

---

### MagnetometerEvent Filters
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| pressure            | Ambient air pressure around the sensor (unit: hPa) | double   | / | / | yes          |
| timestamp           | Event timestamp                     | DateTime | / | / | yes          |

---

## 5. Known Issues

## 6. Others

## 7. License

This project is licensed under [The BSD-3-Clause (license)](ohos/LICENSE).
