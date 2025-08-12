<p align="center">
  <h1 align="center"> <code>connectivity_plus</code> </h1>
</p>

本项目基于 [connectivity_plus](https://pub.dev/packages/connectivity_plus) 开发。

## 1. 安装与使用

### 1.1 安装方式

进入到工程目录并在 pubspec.yaml 中添加以下依赖：

<!-- tabs:start -->

#### pubspec.yaml

```yaml
...

dependencies:
  connectivity_plus:
    git: 
      url: https://gitcode.com/openharmony-sig/flutter_plus_plugins.git
      path: packages/connectivity_plus/connectivity_plus
      ref: br_connectivity_plus-v6.1.0_ohos

...
```

执行命令

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 使用案例

使用案例详见 [example](example/lib/main.dart)

## 2. 约束与限制

### 2.1 兼容性

在以下版本中已测试通过

1. Flutter: 3.22.1-ohos-1.0.1; SDK: 5.0.0(12); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;


### 2.2 权限要求

####  2.2.1 在 entry 目录下的module.json5中添加权限

打开 `entry/src/main/module.json5`，添加：

```diff
...
"requestPermissions": [
  {"name" :  "ohos.permission.INTERNET"}
]
```

## 3. API

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

### Connectivity API 
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| Connectivity()      | 构造 [Connectivity] 的单例实例 | function | / | Connectivity | yes |
| onConnectivityChanged | 当连接状态发生变化时触发。在 iOS 上，WiFi 状态变化时连接状态可能不会更新，这是仅影响模拟器的已知问题。 | function | / | Stream<ConnectivityResult> | yes |
| checkConnectivity   | 检查设备连接状态。不要根据此函数的结果判断是否能可靠发起网络请求，它仅提供无线电状态信息。 | function | / | Future<ConnectivityResult> | yes |

---

## 4. 属性

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

### ConnectivityResult Filters 
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| bluetooth           | 通过蓝牙连接的设备      | enum     | /     | /       | yes          |
| wifi                | 通过 Wi-Fi 连接的设备          | enum     | /     | /       | yes          |
| ethernet            | 连接到以太网的设备| enum     | /     | /       | yes          |
| mobile              | 连接到蜂窝网络的设备| enum     | /     | /       | yes          |
| none                | 未连接到任何网络的设备 | enum     | /     | /       | yes          |
| vpn                 | 连接到 VPN 的设备（注意：iOS/macOS 返回 [other]） | enum | / | / | yes      |
| other               | 连接到未知网络的设备 | enum | /     | /       | yes          |

## 5. 遗留问题

## 6. 其他

## 7. 开源协议

本项目基于 [The BSD-3-Clause (license)](LICENSE) ，请自由地享受和参与开源。
