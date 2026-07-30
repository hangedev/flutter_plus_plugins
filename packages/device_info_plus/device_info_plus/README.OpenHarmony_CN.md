<p align="center">
  <h1 align="center"> <code>device_info_plus</code> </h1>
</p>

本项目基于 [device_info_plus](https://pub.dev/packages/device_info_plus) 开发。

## 1. 安装与使用

### 1.1 安装方式

进入到工程目录并在 pubspec.yaml 中添加以下依赖：

<!-- tabs:start -->

#### pubspec.yaml

```yaml
...

dependencies:
  device_info_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/device_info_plus/device_info_plus
      # ref: 根据下方表格选择不同框架适配的TAG版本
      ref: device_info_plus-9.1.0-ohos-1.0.0-beta.2
...
```

执行命令

```bash
flutter pub get
```

<!-- tabs:end -->
### 1.2 TAG 命名规则：`原库版本-ohos-版本号-betax`，不同 TAG 之间的变更详见 CHANGELOG.OpenHarmony.md。

| Flutter 框架版本 | TAG 名称 | 分支名 |
|---|---|---|
| 3.7  | device_info_plus-9.1.0-ohos-1.0.0-beta.2 | master |
| 3.22 | device_info_plus-9.1.0-ohos-1.0.0-beta.2 | master |
| 3.27 | device_info_plus-9.1.0-ohos-1.0.0-beta.2 | master |

### 1.3 使用案例

```dart
import 'package:device_info_plus/device_info_plus.dart';

// 1. 创建插件实例（构造开销极低，可安全复用）。
final deviceInfo = DeviceInfoPlugin();

// 2. 获取 ohos 设备信息。
final OhosDeviceInfo info = await deviceInfo.ohosInfo;

// 3. 读取所需字段（所有字段均可空，详见第 4 节）。
print('model=${info.productModel}');   // 如 "ALN-AL00"
print('os=${info.osFullName}');        // 如 "OpenHarmony 5.0.0.120"
print('serial=${info.serial}');        // ohos 不可用（始终为 null）
print('udid=${info.udid}');            // ohos 不可用（始终为 null）
```

> `DeviceInfoPlugin()` 构造时不做任何工作，可重复实例化。首次调用后结果会按平台缓存。
> 若需获取跨平台信息可使用 `await deviceInfo.deviceInfo`（自动适配当前平台）；若需原始字典可使用 `info.data`。

完整可运行示例见 [example/lib/main.dart](example/lib/main.dart)。

### 1.4 OHOS 环境配置

本插件面向 OpenHarmony（ohos）平台，**标准** Flutter SDK 并不支持该平台，需先搭建 Flutter-OHOS 工具链：

1. **安装 DevEco Studio** — 版本需与第 2 节兼容性表一致（如 5.0.13.200），可从 OpenHarmony / 华为开发者官网下载。
2. **配置 OpenHarmony SDK** — 在 DevEco Studio 中打开 `File → Settings → OpenHarmony SDK`（macOS 为 `Preferences`），安装与表格一致的 SDK（5.0.0(12) / API 12）。
3. **安装 Flutter-OHOS 分支** — 按照官方适配指导（[Flutter使用指导文档](https://gitcode.com/CPF-Flutter/flutter_samples/blob/master/ohos/docs/07_plugin/ohos%E5%B9%B3%E5%8F%B0%E9%80%82%E9%85%8Dflutter%E4%B8%89%E6%96%B9%E5%BA%93%E6%8C%87%E5%AF%BC.md)）安装 Flutter-OHOS SDK 并为工程注册。
4. **拉取依赖** — 在工程目录执行 `flutter pub get`。
5. **编译与运行**：
   - 命令行：连接 ohos 设备/模拟器后执行 `flutter run`；
   - IDE：在 DevEco Studio 中打开 [example/ohos](example/ohos) 并构建 HAP。

## 2. 约束与限制

### 2.1 兼容性

在以下版本中已测试通过：

1. Flutter: 3.7.12-ohos-1.0.6; SDK: 5.0.0(12); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;
2. Flutter: 3.22.1-ohos-1.0.1; SDK: 5.0.0(12); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;
3. Flutter: 3.27.5-ohos-0.0.2; SDK: 5.0.0(12); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;

### 2.2 不兼容情况说明

- **标准** Flutter SDK **无法**构建 ohos 应用，必须使用 Flutter-OHOS 分支（见 1.3 节）。
- 工具链最低版本（依据 `pubspec.yaml`）：Dart SDK ≥ 2.18.0 < 4.0.0，Flutter ≥ 3.3.0。
- `serial` / `udid` 在 ohos 上**不可用**：`@ohos.deviceInfo` 无对应 API。这两个字段仅为保持跨平台 API 一致而保留在 Dart 模型中，在 ohos 上始终返回 `null`；如需 ohos 设备标识，请改用 `odID`（`OhosDeviceInfo.odID`）。详见[遗留问题](#5-遗留问题)。
- 本插件以 HAR 形式打包（`ohos/src/main/module.json5` 中 `"type": "har"`），无法代宿主应用申请权限，所需权限须由应用自行声明。

### 2.3 升级迁移指导

- 升级插件时，修改 `pubspec.yaml` 中 `git` 依赖的 `ref`/`url` 后执行 `flutter pub get`，并查阅 [CHANGELOG.md](CHANGELOG.md) 了解破坏性变更。
- 升级 Flutter-OHOS 分支或 OpenHarmony SDK 时，请按上方兼容性表重新验证工程。
- 若升级后构建出现异常，清理构建产物（删除 `ohos/build`、`ohos/oh_modules`、`.dart_tool`）后在 DevEco Studio 重新构建。

## 3. API

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

### DeviceInfoPlugin API
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| deviceInfo          | 获取跨平台设备信息（自动适配 Web/Android/iOS/Linux/macOS/ohos/Windows） | function | / | Future<BaseDeviceInfo> | yes |
| androidInfo         | 从 `android.os.Build` 获取 Android 设备信息 | function | / | Future<AndroidDeviceInfo> | no |
| iosInfo             | 从 `UIDevice` 获取 iOS 设备信息 | function | / | Future<IosDeviceInfo> | no |
| linuxInfo           | 从 `/etc/os-release` 获取 Linux 设备信息 | function | / | Future<LinuxDeviceInfo> | no |
| webBrowserInfo      | 从 `Navigator` 获取浏览器信息 | function | / | Future<WebBrowserInfo> | no |
| macOsInfo           | 从 Sysctl 获取 macOS 设备信息 | function | / | Future<MacOsDeviceInfo> | no |
| ohosInfo            | 获取 OpenHarmony 设备信息 | function | / | Future<OhosDeviceInfo> | yes |
| windowsInfo         | 获取 Windows 设备信息 | function | / | Future<WindowsDeviceInfo> | no |

---

### OhosDeviceInfo API
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| fromMap             | 由原始数据字典构造 `OhosDeviceInfo`（插件内部使用） | function（静态） | Map<String, dynamic> | OhosDeviceInfo | yes |

---

### BaseDeviceInfo API
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| toMap            | 返回原始设备信息数据字典（已弃用，请改用 `data`） | function | / | Map<String, dynamic> | yes |
| toString          | 返回设备信息的字符串表示 | function | / | String | yes |

---

## 4. 属性

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。
>
> **可空性说明**：下表所有字段均为可空类型（`String?` / `int?`），与 `lib/src/model/ohos_device_info.dart` 中的 Dart 模型一致。平台可能省略部分字段（尤其是非系统应用的 `serial` / `udid`，见遗留问题），请务必使用空安全访问（如 `info.productModel ?? 'unknown'`）。

### OhosDeviceInfo Filters
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| deviceType          | 获取设备类型（如手机/平板/穿戴设备） | String?  | /     | /       | yes          |
| manufacture         | 获取厂商名称 | String?  | /     | /       | yes          |
| brand               | 获取品牌名称 | String?  | /     | /       | yes          |
| marketName          | 获取产品市场名称 | String?  | /     | /       | yes          |
| productSeries       | 获取产品系列 | String?  | /     | /       | yes          |
| productModel        | 获取产品型号 | String?  | /     | /       | yes          |
| softwareModel       | 获取软件版本型号 | String?  | /     | /       | yes          |
| hardwareModel       | 获取硬件版本型号 | String?  | /     | /       | yes          |
| hardwareProfile     | 获取硬件能力配置 | String?  | /     | /       | yes          |
| serial              | 设备序列号——ohos 不可用（`@ohos.deviceInfo` 无对应 API），始终为 null | String?  | /     | /       | no            |
| bootloaderVersion   | 获取引导程序版本 | String?  | /     | /       | yes          |
| abiList             | 获取支持的 ABI 列表 | String?  | /     | /       | yes          |
| securityPatchTag    | 获取安全补丁版本 | String?  | /     | /       | yes          |
| displayVersion      | 获取用户可见版本号 | String?  | /     | /       | yes          |
| incrementalVersion  | 获取增量版本号 | String?  | /     | /       | yes          |
| osReleaseType       | 获取 OS 发布类型（如 Beta） | String?  | /     | /       | yes          |
| osFullName          | 获取完整操作系统名称 | String?  | /     | /       | yes          |
| majorVersion        | 获取操作系统主版本号 | int?     | /     | /       | yes          |
| seniorVersion       | 获取操作系统次版本号 | int?     | /     | /       | yes          |
| featureVersion      | 获取功能版本号 | int?     | /     | /       | yes          |
| buildVersion        | 获取构建版本号 | int?     | /     | /       | yes          |
| sdkApiVersion       | 获取 SDK API 版本号 | int?     | /     | /       | yes          |
| firstApiVersion     | 获取最早支持的 API 版本号 | int?     | /     | /       | yes          |
| versionId           | 获取版本标识字符串 | String?  | /     | /       | yes          |
| buildType           | 获取构建类型（如 user/debug） | String?  | /     | /       | yes          |
| buildUser           | 获取构建用户账号名 | String?  | /     | /       | yes          |
| buildHost           | 获取构建主机名 | String?  | /     | /       | yes          |
| buildTime           | 获取构建时间戳字符串 | String?  | /     | /       | yes          |
| buildRootHash       | 获取构建根目录哈希值 | String?  | /     | /       | yes          |
| udid                | 设备 UDID——ohos 不可用（`@ohos.deviceInfo` 无对应 API），始终为 null | String?  | /     | /       | no            |
| distributionOSName  | 获取发行版操作系统名称 | String?  | /     | /       | yes          |
| distributionOSVersion | 获取发行版操作系统版本 | String?  | /     | /       | yes          |
| distributionOSApiVersion | 获取发行版操作系统 API 版本 | int?   | /     | /       | yes          |
| distributionOSReleaseType | 获取发行版操作系统发布类型 | String? | /     | /       | yes          |
| odID                | 获取 ODID（OpenHarmony 设备 ID） | String?  | /     | /       | yes          |

---

### BaseDeviceInfo Filters
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| data                | 获取原始设备信息数据字典 | Map<String, dynamic> | / | / | yes |

---

## 5. 遗留问题

- **`serial` / `udid` 在 ohos 上不可用。** `@ohos.deviceInfo` 没有提供设备序列号或 UDID 的对应 API，因此这两个字段在 ohos 平台始终返回 `null`。它们仅为保持跨平台 API 一致而保留在 Dart 模型中（`String? serial` / `String? udid`），原生 handler 也不会写入这两个字段。如需 OpenHarmony 设备标识，请改用 `odID`（`OhosDeviceInfo.odID`）。

## 6. 其他

## 7. 开源协议

本项目基于 [The BSD-3-Clause (license)](LICENSE) ，请自由地享受和参与开源。
