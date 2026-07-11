# plus_plugins

原始仓来源：[plus_plugins](https://github.com/fluttercommunity/plus_plugins)

## 仓库简介
plus_plugins是Flutter一系列插件的集合，旨在为Flutter开发者提供一系列增强功能和扩展插件。
该仓库为plus_plugins库适配OpenHarmony的仓库。

快速跳转：[`battery_plus`](#battery_plus) | [`connectivity_plus`](#connectivity_plus) | [`device_info_plus`](#device_info_plus) | [`network_info_plus`](#network_info_plus) | [`package_info_plus`](#package_info_plus) | [`sensors_plus`](#sensors_plus) | [`share_plus`](#share_plus) | [`android_intent_plus`](#android_intent_plus)


### `battery_plus`

Flutter 插件，用于访问 Android、iOS 和 ohos 上电池状态（已充满、充电中、放电中）的信息。

```yaml

dependencies:
  battery_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/battery_plus/battery_plus
      # ref: battery_plus-7.0.0-ohos-1.0.0-beta.1
      ref: TAG  # 请根据下方TAG版本对应表选择TAG
```

#### TAG 版本对应表

可通过分支超链跳转到对应目录下，查看代码和文档

| Flutter 框架版本 | TAG                                  | 分支                                                                                                                                                        |
|--------------|--------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------|
| 3.7          | battery_plus-4.1.0-ohos-1.0.0-beta.1 | [master](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/packages/battery_plus/battery_plus)                                             |
| 3.22         | battery_plus-7.0.0-ohos-1.0.0-beta.1 | [br_battery_plus-v7.0.0_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_battery_plus-v7.0.0_ohos/packages/battery_plus/battery_plus)   |
| 3.27         | battery_plus-7.0.0-ohos-1.0.0-beta.1 | [br_battery_plus-v7.0.0_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_battery_plus-v7.0.0_ohos/packages/battery_plus/battery_plus)   |
| 3.35         | battery_plus-7.0.0-ohos-1.0.0-beta.1 | [br_battery_plus-v7.0.0_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_battery_plus-v7.0.0_ohos/packages/battery_plus/battery_plus)   |

---

### `connectivity_plus`

Flutter 插件，用于发现 Android、iOS 和 ohos 上的网络状态（WiFi 和移动/蜂窝）连接。


```yaml

dependencies:
  connectivity_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/connectivity_plus/connectivity_plus
      # ref: br_connectivity_plus-7.0.0-ohos.1.0.0-beta.1
      ref: TAG   # 请根据下方TAG版本对应表选择TAG

```

#### TAG 版本对应表

可通过分支超链跳转到对应目录下，查看代码和文档

| Flutter 框架版本  | TAG                                          | 分支                                                                                                                                                                          |
|---------------|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 3.7           | connectivity_plus-5.0.1-ohos-1.0.0-beta.1    | [master](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/tree/master/packages/connectivity_plus/connectivity_plus)                                                     |
| 3.22          | br_connectivity_plus-7.0.0-ohos.1.0.0-beta.1 | [br_connectivity_plus-v7.0.0_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/tree/br_connectivity_plus-v7.0.0_ohos/packages/connectivity_plus/connectivity_plus) |
| 3.27          | br_connectivity_plus-7.0.0-ohos.1.0.0-beta.1 | [br_connectivity_plus-v7.0.0_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/tree/br_connectivity_plus-v7.0.0_ohos/packages/connectivity_plus/connectivity_plus) |
| 3.35          | br_connectivity_plus-7.0.0-ohos.1.0.0-beta.1 | [br_connectivity_plus-v7.0.0_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/tree/br_connectivity_plus-v7.0.0_ohos/packages/connectivity_plus/connectivity_plus) |

---

### `device_info_plus`

Flutter 插件，提供有关设备的详细信息（制造商、型号等）以及应用程序运行的 Android、iOS 和 ohos 版本。

```yaml

dependencies:
  device_info_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/device_info_plus/device_info_plus
      # ref: device_info_plus-12.3.0-ohos-1.0.0-beta.1
      ref: TAG   # 请根据下方TAG版本对应表选择TAG

```

#### TAG 版本对应表

可通过分支超链跳转到对应目录下，查看代码和文档

| Flutter 框架版本 | TAG                                        | 分支                                                                                                                                                                    |
|--------------|--------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 3.7          | device_info_plus-9.1.0-ohos-1.0.0-beta.1   | [master](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/packages/device_info_plus/device_info_plus)                                                     |
| 3.22         | device_info_plus-9.1.0-ohos-1.0.0-beta.1   | [master](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/packages/device_info_plus/device_info_plus)                                                     |
| 3.27         | device_info_plus-9.1.0-ohos-1.0.0-beta.1   | [master](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/packages/device_info_plus/device_info_plus)                                                     |
| 3.35         | device_info_plus-12.3.0-ohos-1.0.0-beta.1  | [br_device_info_plus-v12.3.0_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_device_info_plus-v12.3.0_ohos/packages/device_info_plus/device_info_plus) |

---

### `network_info_plus`

Flutter 插件，用于发现网络信息。

```yaml

dependencies:
  # master分支如下方式导入
  network_info_plus_ohos:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/network_info_plus/network_info_plus/network_info_plus_ohos
      # ref: network_info_plus-4.1.0-ohos-1.0.0-beta.1
      ref: TAG   # 请根据下方TAG版本对应表选择TAG

  # br_network_info_plus_v7.0.0_ohos分支如下方式导入
  network_info_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/network_info_plus/network_info_plus
      # ref: br_network_info_plus-7.0.0-ohos.1.0.0-beta.1
      ref: TAG   # 请根据下方TAG版本对应表选择TAG

```

#### TAG 版本对应表

可通过分支超链跳转到对应目录下，查看代码和文档

| Flutter 框架版本 | TAG                                          | 分支                                                                                                                                                                      |
|--------------|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 3.7          | network_info_plus-4.1.0-ohos-1.0.0-beta.1    | [master](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/packages/network_info_plus/network_info_plus)                                                     |
| 3.22         | network_info_plus-4.1.0-ohos-1.0.0-beta.1    | [master](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/packages/network_info_plus/network_info_plus)                                                     |
| 3.27         | br_network_info_plus-7.0.0-ohos.1.0.0-beta.1 | [br_network_info_plus_v7.0.0_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_network_info_plus_v7.0.0_ohos/packages/network_info_plus/network_info_plus) |
| 3.35         | br_network_info_plus-7.0.0-ohos.1.0.0-beta.1 | [br_network_info_plus_v7.0.0_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_network_info_plus_v7.0.0_ohos/packages/network_info_plus/network_info_plus) |

---

### `package_info_plus`

Flutter 插件，用于查询应用程序包信息。

```yaml

dependencies:
  package_info_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/package_info_plus/package_info_plus
      # ref: package_info_plus-9.0.0-ohos.1.0.0-beta.1
      ref: TAG   # 请根据下方TAG版本对应表选择TAG

```

#### TAG 版本对应表

可通过分支超链跳转到对应目录下，查看代码和文档

| Flutter 框架版本 | TAG                                       | 分支                                                                                                                                                                      |
|--------------|-------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 3.7          | package_info_plus-4.2.0-ohos-1.0.0-beta.1 | [master](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/packages/package_info_plus/package_info_plus)                                                     |
| 3.22         | package_info_plus-4.2.0-ohos.1.0.0-beta.1 | [master](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/packages/package_info_plus/package_info_plus)                                                     |
| 3.27         | package_info_plus-9.0.0-ohos.1.0.0-beta.1 | [br_package_info_plus-v9.0.0_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_package_info_plus-v9.0.0_ohos/packages/package_info_plus/package_info_plus) |
| 3.35         | package_info_plus-9.0.0-ohos.1.0.0-beta.1 | [br_package_info_plus-v9.0.0_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_package_info_plus-v9.0.0_ohos/packages/package_info_plus/package_info_plus) |

---

### `sensors_plus`

Flutter 插件，用于访问加速度计、陀螺仪和磁力计传感器。

```yaml

dependencies:
  # master分支如下方式导入
  sensors_plus_ohos:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/sensors_plus/sensors_plus/ohos
      # ref: sensors_plus-3.1.0-ohos.1.0.0-beta.1
      ref: TAG   # 请根据下方TAG版本对应表选择TAG

  # br_sensors_plus-v7.0.0_ohos分支如下方式导入
  sensors_plus_ohos:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/sensors_plus/sensors_plus
      # ref: sensors_plus-7.0.0-ohos.1.0.0-beta.1
      ref: TAG   # 请根据下方TAG版本对应表选择TAG

```

#### TAG 版本对应表

可通过分支超链跳转到对应目录下，查看代码和文档

| Flutter 框架版本 | TAG                                  | 分支                                                                                                                                                     |
|--------------|--------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 3.7          | sensors_plus-3.1.0-ohos.1.0.0-beta.1 | [master](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/packages/sensors_plus/sensors_plus)                                              |
| 3.22         | sensors_plus-7.0.0-ohos.1.0.0-beta.1 | [br_sensors_plus-v7.0.0_ohos](https://raw.gitcode.com/CPF-Flutter/flutter_plus_plugins/raw/br_sensors_plus-v7.0.0_ohos/packages/sensors_plus/sensors_plus) |
| 3.27         | sensors_plus-7.0.0-ohos.1.0.0-beta.1 | [br_sensors_plus-v7.0.0_ohos](https://raw.gitcode.com/CPF-Flutter/flutter_plus_plugins/raw/br_sensors_plus-v7.0.0_ohos/packages/sensors_plus/sensors_plus) |
| 3.35         | sensors_plus-7.0.0-ohos.1.0.0-beta.1 | [br_sensors_plus-v7.0.0_ohos](https://raw.gitcode.com/CPF-Flutter/flutter_plus_plugins/raw/br_sensors_plus-v7.0.0_ohos/packages/sensors_plus/sensors_plus) |

---

### `share_plus`

Flutter 插件，用于通过平台共享 UI 共享内容，在 Android 上使用 ACTION_SEND intent，在 iOS 上使用 UIActivityViewController，在 ohos 上使用 systemShare。

```yaml

dependencies:
  share_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/share_plus/share_plus
      # ref: sensors_plus-12.0.1-ohos.1.0.0-beta.1
      ref: TAG   # 请根据下方TAG版本对应表选择TAG

```

#### TAG 版本对应表

可通过分支超链跳转到对应目录下，查看代码和文档

| Flutter 框架版本 | TAG                                   | 分支                                                                                                                                            |
|--------------|---------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| 3.7          | sensors_plus-7.2.0-ohos.1.0.0-beta.1  | [master](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/packages/share_plus/share_plus)                                         |
| 3.22         | sensors_plus-12.0.1-ohos.1.0.0-beta.1 | [br_share_plus-v12.0.1_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_share_plus-v12.0.1_ohos/packages/share_plus/share_plus) |
| 3.27         | sensors_plus-12.0.1-ohos.1.0.0-beta.1 | [br_share_plus-v12.0.1_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_share_plus-v12.0.1_ohos/packages/share_plus/share_plus) |
| 3.35         | sensors_plus-12.0.1-ohos.1.0.0-beta.1 | [br_share_plus-v12.0.1_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_share_plus-v12.0.1_ohos/packages/share_plus/share_plus) |

---

### `android_intent_plus`

Flutter 插件，用于启动 Android Intent 和 ohos Want，不支持 iOS。

```yaml

dependencies:
  android_intent_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/android_intent_plus
      # ref: android_intent_plus-6.0.0-ohos.1.0.0-beta.1
      ref: TAG   # 请根据下方TAG版本对应表选择TAG

```

#### TAG 版本对应表

可通过分支超链跳转到对应目录下，查看代码和文档

| Flutter 框架版本 | TAG                                         | 分支                                                                                                                                                          |
|--------------|---------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 3.22         | android_intent_plus-6.0.0-ohos.1.0.0-beta.1 | [br_android_intent_plus-v6.0.0_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_android_intent_plus-v6.0.0_ohos/packages/android_intent_plus) |
| 3.27         | android_intent_plus-6.0.0-ohos.1.0.0-beta.1 | [br_android_intent_plus-v6.0.0_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_android_intent_plus-v6.0.0_ohos/packages/android_intent_plus) |
| 3.35         | android_intent_plus-6.0.0-ohos.1.0.0-beta.1 | [br_android_intent_plus-v6.0.0_ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_android_intent_plus-v6.0.0_ohos/packages/android_intent_plus) |

---
## License

BSD-3-Clause License

见 [LICENSE](LICENSE)
