# plus_plugins

Original repository source: [plus_plugins](https://github.com/fluttercommunity/plus_plugins)

## Repository Introduction

plus_plugins is a collection of plugins for Flutter, designed to provide Flutter developers with a range of enhancements and extensions.

This repository is for adapting the plus_plugins library to OpenHarmony.

Quick jump: [`battery_plus`](#battery_plus) | [`connectivity_plus`](#connectivity_plus) | [`device_info_plus`](#device_info_plus) | [`network_info_plus`](#network_info_plus) | [`package_info_plus`](#package_info_plus) | [`sensors_plus`](#sensors_plus) | [`share_plus`](#share_plus) | [`android_intent_plus`](#android_intent_plus)


### `battery_plus`

Flutter plugin for accessing information about the battery state(full, charging, discharging) on Android, iOS and ohos.

```yaml

dependencies:
  battery_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/battery_plus/battery_plus
      # ref: battery_plus-7.0.0-ohos-1.0.0-beta.1
      ref: TAG   # Please select the TAG to the TAG Version Mapping
```

#### TAG Version Mapping

can use branch hyperlinks to jump to the corresponding directory to view the code and documentation.

| Flutter Framework Version   | TAG                                  | Branch                                                                                                                                                  |
|-----------------------------|--------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------|
| 3.7                         | battery_plus-4.1.0-ohos-1.0.0-beta.1 | [master](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/packages/battery_plus/battery_plus)                                           |
| 3.22                        | battery_plus-7.0.0-ohos-1.0.0-beta.1 | [br_battery_plus-v7.0.0_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_battery_plus-v7.0.0_ohos/packages/battery_plus/battery_plus) |
| 3.27                        | battery_plus-7.0.0-ohos-1.0.0-beta.1 | [br_battery_plus-v7.0.0_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_battery_plus-v7.0.0_ohos/packages/battery_plus/battery_plus) |
| 3.35                        | battery_plus-7.0.0-ohos-1.0.0-beta.1 | [br_battery_plus-v7.0.0_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_battery_plus-v7.0.0_ohos/packages/battery_plus/battery_plus) |

---

### `connectivity_plus`

Flutter plugin for discovering the state of the network (WiFi & mobile/cellular) connectivity on Android, iOS and ohos.

```yaml

dependencies:
  connectivity_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/connectivity_plus/connectivity_plus
      # ref: br_connectivity_plus-7.0.0-ohos.1.0.0-beta.1
      ref: TAG   # Please select the TAG to the TAG Version Mapping

```

#### TAG Version Mapping

can use branch hyperlinks to jump to the corresponding directory to view the code and documentation.

| Flutter Framework Version  | TAG                                          | Branch                                                                                                                                                                      |
|----------------------------|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 3.7                        | connectivity_plus-5.0.1-ohos-1.0.0-beta.1    | [master](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/tree/master/packages/connectivity_plus/connectivity_plus)                                                     |
| 3.22                       | br_connectivity_plus-7.0.0-ohos.1.0.0-beta.1 | [br_network_info_plus_v7.0.0_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/tree/br_connectivity_plus-v7.0.0_ohos/packages/connectivity_plus/connectivity_plus) |
| 3.27                       | br_connectivity_plus-7.0.0-ohos.1.0.0-beta.1 | [br_network_info_plus_v7.0.0_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/tree/br_connectivity_plus-v7.0.0_ohos/packages/connectivity_plus/connectivity_plus) |
| 3.35                       | br_connectivity_plus-7.0.0-ohos.1.0.0-beta.1 | [br_network_info_plus_v7.0.0_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/tree/br_connectivity_plus-v7.0.0_ohos/packages/connectivity_plus/connectivity_plus) |

---

### `device_info_plus`

Flutter plugin providing detailed information about the device (make, model, etc.), Android, iOS, or ohos version the app is running on.

```yaml

dependencies:
  device_info_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/device_info_plus/device_info_plus
      # ref: device_info_plus-12.3.0-ohos-1.0.0-beta.1
      ref: TAG   # Please select the TAG to the TAG Version Mapping

```

#### TAG Version Mapping

can use branch hyperlinks to jump to the corresponding directory to view the code and documentation.

| Flutter Framework Version   | TAG                                        | Branch                                                                                                                                                                    |
|-----------------------------|--------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 3.7                         | device_info_plus-9.1.0-ohos-1.0.0-beta.1   | [master](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/packages/device_info_plus/device_info_plus)                                                     |
| 3.22                        | device_info_plus-9.1.0-ohos-1.0.0-beta.1   | [master](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/packages/device_info_plus/device_info_plus)                                                     |
| 3.27                        | device_info_plus-9.1.0-ohos-1.0.0-beta.1   | [master](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/packages/device_info_plus/device_info_plus)                                                     |
| 3.35                        | device_info_plus-12.3.0-ohos-1.0.0-beta.1  | [br_device_info_plus-v12.3.0_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_device_info_plus-v12.3.0_ohos/packages/device_info_plus/device_info_plus) |

---

### `network_info_plus`

Flutter plugin for discovering network info.

```yaml

dependencies:
  # Import via master branch as follows
  network_info_plus_ohos:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/network_info_plus/network_info_plus/network_info_plus_ohos
      # ref: network_info_plus-4.1.0-ohos-1.0.0-beta.1
      ref: TAG   # Please select the TAG to the TAG Version Mapping

  # Import via br_network_info_plus_v7.0.0_ohos branch as follows
  network_info_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/network_info_plus/network_info_plus
      # ref: br_network_info_plus-7.0.0-ohos.1.0.0-beta.1
      ref: TAG   # Please select the TAG to the TAG Version Mapping

```

#### TAG Version Mapping

can use branch hyperlinks to jump to the corresponding directory to view the code and documentation.

| Flutter Framework Version   | TAG                                          | Branch                                                                                                                                                                      |
|-----------------------------|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 3.7                         | network_info_plus-4.1.0-ohos-1.0.0-beta.1    | [master](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/packages/network_info_plus/network_info_plus)                                                     |
| 3.22                        | network_info_plus-4.1.0-ohos-1.0.0-beta.1    | [master](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/packages/network_info_plus/network_info_plus)                                                     |
| 3.27                        | br_network_info_plus-7.0.0-ohos.1.0.0-beta.1 | [br_network_info_plus_v7.0.0_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_network_info_plus_v7.0.0_ohos/packages/network_info_plus/network_info_plus) |
| 3.35                        | br_network_info_plus-7.0.0-ohos.1.0.0-beta.1 | [br_network_info_plus_v7.0.0_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_network_info_plus_v7.0.0_ohos/packages/network_info_plus/network_info_plus) |

---

### `package_info_plus`

Flutter plugin for querying information about the application package.

```yaml

dependencies:
  package_info_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/package_info_plus/package_info_plus
      # ref: package_info_plus-9.0.0-ohos.1.0.0-beta.1
      ref: TAG   # Please select the TAG to the TAG Version Mapping

```

#### TAG Version Mapping

can use branch hyperlinks to jump to the corresponding directory to view the code and documentation.

| Flutter Framework Version   | TAG                                       | Branch                                                                                                                                                                      |
|-----------------------------|-------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 3.7                         | package_info_plus-4.2.0-ohos-1.0.0-beta.1 | [master](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/packages/package_info_plus/package_info_plus)                                                     |
| 3.22                        | package_info_plus-4.2.0-ohos.1.0.0-beta.1 | [master](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/packages/package_info_plus/package_info_plus)                                                     |
| 3.27                        | package_info_plus-9.0.0-ohos.1.0.0-beta.1 | [br_package_info_plus-v9.0.0_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_package_info_plus-v9.0.0_ohos/packages/package_info_plus/package_info_plus) |
| 3.35                        | package_info_plus-9.0.0-ohos.1.0.0-beta.1 | [br_package_info_plus-v9.0.0_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_package_info_plus-v9.0.0_ohos/packages/package_info_plus/package_info_plus) |

---

### `sensors_plus`

Flutter plugin for accessing accelerometer, gyroscope, and magnetometer sensors.

```yaml

dependencies:
  # Import via master branch as follows
  sensors_plus_ohos:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/sensors_plus/sensors_plus/ohos
      # ref: sensors_plus-3.1.0-ohos.1.0.0-beta.1
      ref: TAG   # Please select the TAG to the TAG Version Mapping

  # Import via br_sensors_plus-v7.0.0_ohos branch as follows
  sensors_plus_ohos:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/sensors_plus/sensors_plus
      # ref: sensors_plus-7.0.0-ohos.1.0.0-beta.1
      ref: TAG   # Please select the TAG to the TAG Version Mapping

```

#### TAG Version Mapping

can use branch hyperlinks to jump to the corresponding directory to view the code and documentation.

| Flutter Framework Version   | TAG                                  | Branch                                                                                                                                                     |
|-----------------------------|--------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 3.7                         | sensors_plus-3.1.0-ohos.1.0.0-beta.1 | [master](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/packages/sensors_plus/sensors_plus)                                              |
| 3.22                        | sensors_plus-7.0.0-ohos.1.0.0-beta.1 | [br_sensors_plus-v7.0.0_ohos](https://raw.gitcode.com/CPF-Flutter/flutter_plus_plugins/raw/br_sensors_plus-v7.0.0_ohos/packages/sensors_plus/sensors_plus) |
| 3.27                        | sensors_plus-7.0.0-ohos.1.0.0-beta.1 | [br_sensors_plus-v7.0.0_ohos](https://raw.gitcode.com/CPF-Flutter/flutter_plus_plugins/raw/br_sensors_plus-v7.0.0_ohos/packages/sensors_plus/sensors_plus) |
| 3.35                        | sensors_plus-7.0.0-ohos.1.0.0-beta.1 | [br_sensors_plus-v7.0.0_ohos](https://raw.gitcode.com/CPF-Flutter/flutter_plus_plugins/raw/br_sensors_plus-v7.0.0_ohos/packages/sensors_plus/sensors_plus) |

---

### `share_plus`

Flutter plugin for sharing content via the platform share UI, using the ACTION_SEND intent on Android, UIActivityViewController on iOS, and systemShare on ohos.


```yaml

dependencies:
  share_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/share_plus/share_plus
      # ref: sensors_plus-12.0.1-ohos.1.0.0-beta.1
      ref: TAG   # Please select the TAG to the TAG Version Mapping

```

#### TAG Version Mapping

can use branch hyperlinks to jump to the corresponding directory to view the code and documentation.

| Flutter Framework Version   | TAG                                   | Branch                                                                                                                                            |
|-----------------------------|---------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| 3.7                         | sensors_plus-7.2.0-ohos.1.0.0-beta.1  | [master](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/packages/share_plus/share_plus)                                         |
| 3.22                        | sensors_plus-12.0.1-ohos.1.0.0-beta.1 | [br_share_plus-v12.0.1_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_share_plus-v12.0.1_ohos/packages/share_plus/share_plus) |
| 3.27                        | sensors_plus-12.0.1-ohos.1.0.0-beta.1 | [br_share_plus-v12.0.1_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_share_plus-v12.0.1_ohos/packages/share_plus/share_plus) |
| 3.35                        | sensors_plus-12.0.1-ohos.1.0.0-beta.1 | [br_share_plus-v12.0.1_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_share_plus-v12.0.1_ohos/packages/share_plus/share_plus) |

---

### `android_intent_plus`

Flutter plugin for launching Android Intents and ohos Want. Not supported on iOS.

```yaml

dependencies:
  android_intent_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/android_intent_plus
      # ref: android_intent_plus-6.0.0-ohos.1.0.0-beta.1
      ref: TAG   # Please select the TAG to the TAG Version Mapping

```

#### TAG Version Mapping

can use branch hyperlinks to jump to the corresponding directory to view the code and documentation.

| Flutter Framework Version   | TAG                                         | Branch                                                                                                                                                          |
|-----------------------------|---------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 3.22                        | android_intent_plus-6.0.0-ohos.1.0.0-beta.1 | [br_android_intent_plus-v6.0.0_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_android_intent_plus-v6.0.0_ohos/packages/android_intent_plus) |
| 3.27                        | android_intent_plus-6.0.0-ohos.1.0.0-beta.1 | [br_android_intent_plus-v6.0.0_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_android_intent_plus-v6.0.0_ohos/packages/android_intent_plus) |
| 3.35                        | android_intent_plus-6.0.0-ohos.1.0.0-beta.1 | [br_android_intent_plus-v6.0.0_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_android_intent_plus-v6.0.0_ohos/packages/android_intent_plus) |

---
## License

BSD-3-Clause License

See [LICENSE](LICENSE)
