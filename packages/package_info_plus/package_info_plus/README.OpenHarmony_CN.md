<p align="center">
  <h1 align="center"> <code>package_info_plus</code> </h1>
</p>

本项目基于 [package_info_plus](https://pub.dev/packages/package_info_plus)（上游 4.2.0 版本）开发，新增 OpenHarmony（ohos）平台支持。

## 1. 安装与使用

### 1.1 安装方式

进入到工程目录并在 pubspec.yaml 中添加以下依赖：

<!-- tabs:start -->

#### pubspec.yaml

```yaml
...

dependencies:
  package_info_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/package_info_plus/package_info_plus
      # ref: 根据下方表格选择不同框架适配的TAG版本
      ref: TAG   

...
```

执行命令

```bash
flutter pub get
```

<!-- tabs:end -->
TAG 版本对应表

| Flutter 框架版本 | TAG | 分支 |
| --- | --- | --- |
|3.7	|package_info_plus-4.2.0-ohos-1.0.0	|master                           |
|3.22	|package_info_plus-4.2.0-ohos-1.0.0	|master                           |
|3.27	|package_info_plus-4.2.0-ohos-1.0.0	|master                           |
|3.35	|package_info_plus-9.0.0-ohos-1.0.0	|br_package_info_plus-v9.0.0_ohos |

### 1.2 使用案例

以下所有场景均为一次性读取——本插件不提供流（Stream）或常驻监听，
结果统一通过 `Future` 回调返回。

#### 场景一：`await` 基础调用

```dart
import 'package:package_info_plus/package_info_plus.dart';

// 1. 从平台获取包信息。仅一次 MethodChannel
//    （'dev.fluttercommunity.plus/package_info' → getAll）往返；
//    结果会被缓存，后续调用返回同一实例。
final info = await PackageInfo.fromPlatform();

// 2. 读取所需字段。ohos 侧由原生实现从应用的
//    AppScope/app.json5 中解析出各字段：
print(info.appName);        // label       → 如 "example"
print(info.packageName);    // bundleName  → 如 "io.flutter.plugins.example"
print(info.version);        // versionName → 如 "1.2.3"
print(info.buildNumber);    // versionCode → 如 "4"（转成字符串）
print(info.buildSignature); // 签名证书指纹（十六进制）；
                            // 包体不含签名信息时为空字符串
print(info.installerStore); // ohos 上恒为 null —— 不上报安装商店信息
```

#### 场景二：`.then` 回调方式

```dart
// 平台查询是异步的，注册回调而不是阻塞调用方。
PackageInfo.fromPlatform().then((PackageInfo info) {
  // 原生 getAll 返回后触发。
  setState(() => _packageInfo = info);
}).catchError((Object e) {
  // ohos 侧把包信息查询失败以 PlatformException（'Name not found'）抛出。
  debugPrint('PackageInfo.fromPlatform failed: $e');
});
```

#### 场景三：在组件树中使用 `FutureBuilder`

```dart
// fromPlatform() 带缓存，每次 build 调用都是安全的——首次调用触发
// 平台通道往返，之后的调用直接返回缓存实例。
FutureBuilder<PackageInfo>(
  future: PackageInfo.fromPlatform(),
  builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    if (!snapshot.hasData) {
      return const CircularProgressIndicator();
    }
    final info = snapshot.data!;
    return Text('${info.appName} ${info.version}+${info.buildNumber}');
  },
)
```

#### 场景四：Map / JSON 序列化

```dart
final info = await PackageInfo.fromPlatform();

// `data` 返回已填充字段的 Map<String, dynamic> 视图；
// 为空的可选字段（buildSignature、installerStore）不会出现在 Map 中。
final map = info.data;
// → {appName: ..., packageName: ..., version: ..., buildNumber: ...}

final json = jsonEncode(info.data); // 可直接用于上报 / 埋点
```

#### 场景五：测试中使用 mock 值

```dart
// 向缓存单例注入 mock 值，不会命中平台通道；仅用于测试
// （@visibleForTesting）。之后的 fromPlatform() 返回这些值。
PackageInfo.setMockInitialValues(
  appName: 'test_app',
  packageName: 'dev.fluttercommunity.plus.testapp',
  version: '1.0.0',
  buildNumber: '42',
  buildSignature: 'a1b2c3d4e5f6a7b8',
  installerStore: null,
);
```

完整可运行示例见 [example/lib/main.dart](example/lib/main.dart)。

### 1.3 OHOS 环境配置

本插件面向 OpenHarmony（ohos）平台，标准 Flutter SDK **不**支持该平台，
需先搭建 Flutter-OHOS 工具链：

1. **安装 DevEco Studio** — 版本与第 2 节兼容性表格保持一致，从
   OpenHarmony / 华为开发者官网下载。
2. **配置 OpenHarmony SDK** — 在 DevEco Studio 中打开
   `File → Settings → OpenHarmony SDK`（macOS 为 `Preferences`），
   安装与表格匹配的 SDK。
3. **安装 Flutter-OHOS 集成 SDK** — 按官方适配指导
   （[Flutter使用指导文档](https://gitcode.com/CPF-Flutter/flutter_samples/blob/master/ohos/docs/07_plugin/ohos%E5%B9%B3%E5%8F%B0%E9%80%82%E9%85%8Dflutter%E4%B8%89%E6%96%B9%E5%BA%93%E6%8C%87%E5%AF%BC.md)）
   安装并注册 Flutter-OHOS SDK。
4. **拉取依赖** — 在工程目录执行 `flutter pub get`。
5. **构建与运行**：
   - 命令行：连接 ohos 设备/模拟器后执行 `flutter run`；
   - IDE：用 DevEco Studio 打开 [example/ohos](example/ohos) 构建 HAP
     （插件本身不需要任何 ohos 权限——仅通过
     `@ohos.bundle.bundleManager` 读取应用自身的包信息）。

## 2. 约束与限制

### 2.1 兼容性

在以下版本中已测试通过：

1. Flutter: 3.7.12-ohos-1.0.6; SDK: 5.0.5(17); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;
2. Flutter: 3.22.1-ohos-1.0.1; SDK: 5.0.5(17); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;
3. Flutter: 3.27.5-ohos-0.0.1; IDE: DevEco Studio: 6.0.2.640; ROM: OpenHarmony 7.0.0.102 (API 26);

### 2.2 不兼容说明

- 标准 Flutter SDK **无法**构建 ohos 目标，必须使用 Flutter-OHOS 集成
  SDK（见 1.4 节）。
- 最低工具链要求（见 `pubspec.yaml`）：Dart SDK ≥ 2.18.0 < 4.0.0，
  Flutter ≥ 3.3.0。
- `installerStore` 在 **ohos 上不可用**：`@ohos.bundle.bundleManager`
  未提供查询安装来源的 API，该字段在 ohos 上恒为 `null`；保留在 Dart API
  中仅为保持跨平台一致性。
- ohos 上 `buildSignature` 为签名证书指纹，仅在包体携带签名信息时上报，
  无签名信息时为空字符串。
- 本 ohos 适配基于上游 package_info_plus **4.2.0**：9.x 高版本中的
  `installTime` / `updateTime` 字段与 `fromPlatform(baseUrl: ...)` 参数
  **不属于**本版本 API。
- 插件以 HAR 形式打包，不声明任何 ohos 权限，也不能替宿主应用申请权限
  （本插件无需权限）。

### 2.3 升级与迁移

- 升级插件：修改 `pubspec.yaml` 中 git 依赖的 `ref`/`url` 后执行
  `flutter pub get`，并查阅 [CHANGELOG.md](CHANGELOG.md) 了解破坏性变更。
- 升级 Flutter-OHOS 集成 SDK 或 OpenHarmony SDK 后，请按上方兼容性表格
  重新验证工程。
- 升级后若构建行为异常（如插件代码未更新），请清理构建产物（删除应用与
  插件两侧的 `ohos/build`、`ohos/oh_modules` 及 `.dart_tool`）后重新构建。

## 3. API

> [!TIP] "ohos支持"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

### PackageInfo 静态 API

| 名称               | 描述                           | 类型           | 输入                                                          | 输出                 | ohos支持 |
|--------------------|--------------------------------|----------------|---------------------------------------------------------------|----------------------|----------|
| fromPlatform       | 通过 `getAll` 方法通道从平台获取包信息并缓存结果，后续调用返回缓存实例 | 静态 Future    | /                                                             | Future&lt;PackageInfo&gt; | yes      |
| setMockInitialValues | 用 mock 值覆盖缓存的单例，仅用于测试（`@visibleForTesting`） | 静态方法       | appName, packageName, version, buildNumber, buildSignature, installerStore | void                 | yes      |

### PackageInfo 实例 API

| 名称       | 描述                                                         | 类型        | 输入                                                        | 输出       | ohos支持 |
|------------|--------------------------------------------------------------|-------------|-------------------------------------------------------------|------------|----------|
| PackageInfo | 使用给定值构造实例（保留用于测试；平台数据请通过 `fromPlatform` 获取） | 构造函数    | appName, packageName, version, buildNumber, buildSignature, installerStore | PackageInfo | yes      |
| ==         | 基于全部字段的值相等判断                                     | 运算符      | Object                                                      | bool       | yes      |
| hashCode   | 与 `==` 一致的哈希值                                         | getter      | /                                                           | int        | yes      |
| toString   | 列出全部字段的字符串表示（`PackageInfo(appName: ..., buildNumber: ..., ...)`） | 方法        | /                                                           | String     | yes      |

## 4. 属性

> [!TIP] "ohos支持"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

### PackageInfo 属性列表

| 名称           | 描述                                                 | 类型                  | 输入 | 输出 | ohos支持 |
|----------------|------------------------------------------------------|-----------------------|------|------|----------|
| appName        | 获取应用名称                                         | String                | /    | /    | yes      |
| packageName    | 获取包名（应用唯一标识）                             | String                | /    | /    | yes      |
| version        | 获取包版本号                                         | String                | /    | /    | yes      |
| buildNumber    | 获取构建编号                                         | String                | /    | /    | yes      |
| buildSignature | 获取构建签名                                         | String                | /    | /    | yes      |
| installerStore | 获取安装商店信息 —— ohos 上不可用，恒为 `null`       | String?               | /    | /    | no       |
| data           | 获取已填充字段的 Map 表示（为空的可选字段不包含在内） | Map&lt;String, dynamic&gt; | /    | /    | yes      |

### ohos 取值正向对照

各字段均由原生实现
（[ohos/src/main/ets/.../PackageInfoPlugin.ets](ohos/src/main/ets/dev/fluttercommunity/plus/packageinfo/PackageInfoPlugin.ets)）
通过 `@ohos.bundle.bundleManager.getBundleInfoForSelfSync` 解析：

| 属性          | ohos 数据来源                                          | 示例值（[example](example/ohos/AppScope/app.json5) 应用） |
|---------------|--------------------------------------------------------|--------------------------------------|
| appName       | `AppScope/app.json5` → `app.label` 资源（`$string:app_name`） | `example`                            |
| packageName   | `AppScope/app.json5` → `app.bundleName`                | `io.flutter.plugins.example`         |
| version       | `AppScope/app.json5` → `app.versionName`               | `1.2.3`                              |
| buildNumber   | `AppScope/app.json5` → `app.versionCode`（转为字符串） | `4`                                  |
| buildSignature | 签名证书指纹 `signatureInfo.fingerprint`（十六进制）   | 已签名 HAP 非空，如 `"A1B2C3..."`    |
| installerStore | 不上报 —— `@ohos.bundle.bundleManager` 无安装来源 API  | `null`                               |

## 5. 遗留问题

- **`installerStore` 在 ohos 上不可用。** ohos 包管理未提供安装来源查询
  API，该字段在 ohos 平台恒为 `null`；保留在 Dart API 中仅为保持跨平台
  一致性。
- **`buildSignature` 依赖签名信息。** 该字段为签名证书指纹，包体不携带
  签名信息时（如部分未签名的调试包）为空字符串。
- **不含 9.x 专有字段。** 本版本基于上游 4.2.0，`installTime` /
  `updateTime` 字段与 `fromPlatform(baseUrl: ...)` 参数在本版本中不存在。

## 6. 其他

- 源码仓库：[flutter_plus_plugins](https://gitcode.com/CPF-Flutter/flutter_plus_plugins)，
  欢迎提 issue 与 MR。
- 本仓库内其他 ohos 适配插件：`device_info_plus`、`battery_plus`、
  `connectivity_plus`、`network_info_plus`、`share_plus`、`sensors_plus` 等。
- 插件通过
  [example/integration_test/package_info_plus_test.dart](example/integration_test/package_info_plus_test.dart)
  在真机上持续验证。

## 7. 开源协议

本项目基于 [The BSD-3-Clause (license)](LICENSE) ，请自由地享受和参与开源。
