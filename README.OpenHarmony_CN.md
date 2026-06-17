# plus_plugins

原始仓来源：[plus_plugins](https://github.com/fluttercommunity/plus_plugins)

## 仓库简介
plus_plugins是Flutter一系列插件的集合，旨在为Flutter开发者提供一系列增强功能和扩展插件。
该仓库为plus_plugins库适配OpenHarmony的仓库。


### `battery_plus`

Flutter 插件，用于访问 Android、iOS 和 ohos 上电池状态（已充满、充电中、放电中）的信息。

[查看代码](/packages/battery_plus)       [查看使用文档](/packages/battery_plus/battery_plus/README.OpenHarmony_CN.md)

#### Platform Support

| Android | iOS | MacOS | Web | Linux | Windows | ohos |
| :-----: | :-: | :---: | :-: | :---: | :-----: | :-----: |
|   ✅   | ✅  |  ✅   | ✅  |  ✅   |  ✅  | ✅  |

---

### `connectivity_plus`

Flutter 插件，用于发现 Android、iOS 和 ohos 上的网络状态（WiFi 和移动/蜂窝）连接。

[查看代码](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_connectivity_plus-v7.0.0_ohos/packages/connectivity_plus/)       [查看使用文档](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_connectivity_plus-v7.0.0_ohos/packages/connectivity_plus/connectivity_plus/README.OpenHarmony_CN.md)

#### Platform Support

| Android | iOS | MacOS | Web | Linux | Windows | ohos |
| :-----: | :-: | :---: | :-: | :---: | :-----: |:-----: |
|   ✅    | ✅  |  ✅   | ✅  |  ✅   |   ✅    | ✅  |


---

### `device_info_plus`

Flutter 插件，提供有关设备的详细信息（制造商、型号等）以及应用程序运行的 Android、iOS 和 ohos 版本。

[查看代码](/packages/device_info_plus)       [查看使用文档](/packages/device_info_plus/device_info_plus/README.OpenHarmony_CN.md)

#### Platform Support

| Android | iOS | MacOS | Web | Linux | Windows | ohos |
| :-----: | :-: | :---: | :-: | :---: | :-----: | :-----: |
|   ✅    | ✅  |  ✅   | ✅  |  ✅   |   ✅    | ✅  |
---

### `network_info_plus`

Flutter 插件，用于发现网络信息。

[查看代码](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_network_info_plus_v7.0.0_ohos/packages/network_info_plus/)       [查看使用文档](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/br_network_info_plus_v7.0.0_ohos/packages/network_info_plus/network_info_plus/README.OpenHarmony.md)

#### Platform Support

| Android | iOS | MacOS | Web | Linux | Windows | ohos |
| :-----: | :-: | :---: | :-: | :---: | :-----: | :-----: |
|   ✅    | ✅   |  ✅   | ❌  |  ✅   |   ✅    | ✅  |

---

### `package_info_plus`

Flutter 插件，用于查询应用程序包信息。

[查看代码](/packages/package_info_plus)       [查看使用文档](/packages/package_info_plus/package_info_plus/README.OpenHarmony_CN.md)

#### Platform Support

| Android | iOS | MacOS | Web | Linux | Windows | ohos |
| :-----: | :-: | :---: | :-: | :---: | :-----: | :-----: |
|   ✅    | ✅  |  ✅   | ✅  |  ✅   |   ✅    | ✅  |

---

### `sensors_plus`

Flutter 插件，用于访问加速度计、陀螺仪和磁力计传感器。

[查看代码](/packages/sensors_plus)       [查看使用文档](/packages/sensors_plus/sensors_plus/README.OpenHarmony_CN.md)

#### Platform Support

| Android | iOS | MacOS | Web | Linux | Windows | ohos |
| :-----: | :-: | :---: | :-: | :---: | :-----: | :-----: |
|   ✅    | ✅  |   ❌    | ✅  |   ❌    |    ❌     | ✅  |

---

### `share_plus`

Flutter 插件，用于通过平台共享 UI 共享内容，在 Android 上使用 ACTION_SEND intent，在 iOS 上使用 UIActivityViewController,在 ohos 上使用 systemShare。

[查看代码](/packages/share_plus)       [查看使用文档](/packages/share_plus/share_plus/README.OpenHarmony_CN.md)

#### Platform Support

| Android | iOS | MacOS | Web | Linux | Windows | ohos |
| :-----: | :-: | :---: | :-: | :---: | :-----: | :-----: |
|   ✅   | ✅  |  ✅   | ✅  |  ✅   |   ✅    | ✅  |

---

### `android_alarm_manager_plus`

Flutter 插件，用于访问 Android AlarmManager 服务，并在警报触发时在后台运行 Dart 代码。

[查看代码](/packages/android_alarm_manager_plus)       [查看使用文档](/packages/android_alarm_manager_plus/README.md)

#### Platform Support

| Android | ohos |
| :-----: | :-----: |
|   ✅    | ❌ |

---

### `android_intent_plus`

Flutter 插件，用于启动 Android Intent 和 ohos Want，不支持 iOS。

[查看代码](/packages/android_intent_plus)       [查看使用文档](/packages/android_intent_plus/README.md)

#### Platform Support

| Android | ohos |
| :-----: | :-----: |
|   ✅    | 适配中 |


## License

BSD-3-Clause License

见 [LICENSE](LICENSE)
