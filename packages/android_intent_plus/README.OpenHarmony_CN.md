<p align="center">
  <h1 align="center"> <code>android_intent_plus</code> </h1>
</p>

本项目基于 [android_intent_plus](https://pub.dev/packages/android_intent_plus) 开发。

## 1. 安装与使用

### 1.1 安装方式

进入到工程目录并在 pubspec.yaml 中添加以下依赖：

<!-- tabs:start -->

#### pubspec.yaml

```yaml
...

dependencies:
  android_intent_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/android_intent_plus
      # ref: 根据下方表格选择不同框架适配的TAG版本
      ref: android_intent_plus-6.0.0-ohos-1.0.1

...
```

### TAG 版本对应表
| Flutter 框架版本 | TAG                | 分支     |
|--------------|--------------------|--------|
| 3.22        | android_intent_plus-6.0.0-ohos-1.0.1  | br_android_intent_plus-v6.0.0_ohos |
| 3.27        | android_intent_plus-6.0.0-ohos-1.0.1   | br_android_intent_plus-v6.0.0_ohos |
| 3.35        | android_intent_plus-6.0.0-ohos-1.0.1   | br_android_intent_plus-v6.0.0_ohos |

执行命令

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 升级迁移

1. 打开工程中的 pubspec.yaml，将依赖的 `ref` 修改为目标 TAG 版本（TAG 与 Flutter 框架版本的对应关系见上方表格）；若以源码方式接入，将仓库代码更新到对应 TAG 即可；
2. 执行以下命令更新依赖并清理构建缓存：

```bash
flutter pub get
flutter clean
```

3. 重新编译工程并验证插件功能是否正常；若版本间存在接口变更，请参考 [CHANGELOG.OpenHarmony.md](CHANGELOG.OpenHarmony.md) 调整业务代码。

### 1.3 环境配置（OpenHarmony）

在 OpenHarmony/HarmonyOS 平台使用本插件前，请先完成以下环境准备：

1. **安装 DevEco Studio**：从[官方渠道](https://developer.huawei.com/consumer/cn/deveco-studio/)下载并安装，安装步骤参考官方指南；
2. **配置 SDK**：首次启动 DevEco Studio 时根据向导配置，或进入 `File > Settings > SDK` 页面，下载与下方"兼容性"章节版本匹配的 HarmonyOS/OpenHarmony SDK；
3. **配置 Flutter ohos 环境**：参考 [Flutter使用指导文档](https://gitcode.com/CPF-Flutter/flutter_samples/blob/master/ohos/docs/07_plugin/ohos%E5%B9%B3%E5%8F%B0%E9%80%82%E9%85%8Dflutter%E4%B8%89%E6%96%B9%E5%BA%93%E6%8C%87%E5%AF%BC.md)完成 Flutter ohos 版本的环境搭建；
4. **编译构建**：进入 example 目录执行以下命令构建 HAP，也可以使用 DevEco Studio 打开 `example/ohos` 工程直接构建运行：

```bash
cd example
flutter pub get
flutter build hap --debug
```

更多通用适配指导请参考仓库根目录的 [GUIDE_DOCUMENT.md](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/GUIDE_DOCUMENT.md)。

### 1.4 使用方式

完整调用流程如下：

```dart
import 'package:android_intent_plus/android_intent.dart';

Future<void> openLink() async {
  final intent = AndroidIntent(
    action: 'ohos.want.action.viewData',
    data: 'https://flutter.dev',
  );
  await intent.launch();
}
```

除 `launch()` 外，还支持 `parseAndLaunch()`（解析 URI 字符串启动）、`launchChooser()`（启动系统选择器弹窗）、`sendBroadcast()`（以广播方式发送）等方法，详见下方 API 说明。

### 1.5 使用案例

使用案例详见 [example](example/lib/main.dart)

## 2. 约束与限制

### 2.1 兼容性

在以下版本中已测试通过

1. Flutter: 3.22.1-ohos-1.0.3; SDK: 5.0.5(17); IDE: DevEco Studio: 6.0.1.251; ROM: 6.0.0.115 SP16;
2. Flutter: 3.27.5-ohos-1.0.1; SDK: 5.0.5(17); IDE: DevEco Studio: 6.0.1.251; ROM: 6.0.0.115 SP16;
3. Flutter: 3.35.8-ohos-0.0.1; SDK: 5.0.5(17); IDE: DevEco Studio: 6.0.2.640; ROM: 6.0.0.328 SP22;

## 3. API

> [!TIP] "ohos 支持"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

### 3.1 接口说明

| 名称 | 描述 | 类型 | 输入 | 输出 | ohos 支持 |
| --------  | ----------- | -------- | -------- | ----------- | ------------ |
| `Future<void> launch()` | 触发一次通用 Intent 启动 | function | 无 | void | yes |
| `Future<void> parseAndLaunch(String uri)` | 解析 Intent URI 字符串并启动（ohos 平台解析的是 Want 的 JSON 字符串，与 Android 的 Intent URI 格式不同，详见第 4 节） | function | `String uri：Android 上为完整的 Intent URI，ohos 上为 Want 的 JSON 字符串` | void | partially |
| `Future<void> launchChooser(String title)` | 启动系统选择器弹窗（ohos 平台不会弹出系统选择器，效果等同于 `launch()`，`title` 参数不生效，详见第 4 节） | function | `String title：title 为选择器标题` | void | partially |
| `Future<void> sendBroadcast()` | 以广播方式发送 Intent（ohos 平台基于公共事件实现，仅映射 `arguments`/`arrayArguments` 中的特定字段，详见第 4 节） | function | 无 | void | partially |
| `Future<void> sendService() ` | 以 Service 方式启动 Intent | function | 无 | void | no |
| `Future<bool?> canResolveActivity()` | 判断是否能够处理该 activity，返回布尔值 | function | 无 | `bool?` | no |
| `Future<ResolvedActivity?> getResolvedActivity()` | 获取该 activity，返回 ResolvedActivity 对象 | function | 无 | `ResolvedActivity?` | no |

### 3.2 构造函数参数说明

`AndroidIntent` 构造函数共有 9 个业务参数，说明如下：

| 参数 | 类型 | 说明 |
| -------- | -------- | ----------- |
| `action` | `String?` | Intent 的一般性动作（如 `ohos.want.action.viewData`），与 `componentName` 至少需要指定其中一个 |
| `flags` | `List<int>?` | int 列表，会被按位合并转换为原生 flags，每个值必须为 2 的幂 |
| `category` | `String?` | Intent 的类别，用于对 `action` 进行附加限定，可空 |
| `data` | `String?` | `action` 所指向 URI 的字符串形式 |
| `arguments` | `Map<String, dynamic>?` | 等价于 extras，会被转换为 extras 数据随 Intent 一起传递 |
| `arrayArguments` | `Map<String, List<dynamic>>?` | 类似 `arguments`，但以数组形式作为 extras 传递 |
| `package` | `String?` | Intent 的包名，限定 `data` 仅在指定包内解析，可空 |
| `componentName` | `String?` | Intent 的组件名，指定处理该 Intent 的具体组件；设置时必须同时设置 `package` |
| `type` | `String?` | Intent 的显式 MIME 数据类型，可空 |

## 4. 遗留问题

### ohos不支持的接口:
- `Future<void> sendService() ` : 以 Service 方式启动 Intent，此功能仅2in1的企业应用支持
- `Future<bool?> canResolveActivity()` ：判断是否能够处理该activity，返回布尔值，此功能为ohos系统能力，仅系统应用支持
- `Future<ResolvedActivity?> getResolvedActivity()` ：获取该activity，返回ResolvedActivity，此功能为ohos系统能力，仅系统应用支持

### ohos平台与Android存在行为差异的接口:
- `Future<void> parseAndLaunch(String uri)` ：Android 端使用 `Intent.parseUri()` 解析格式为 `intent://...#Intent;...;end` 的 Intent URI；ohos 端解析的是描述 Want 的 JSON 字符串，支持字段：`action`、`uri`、`bundleName`、`abilityName`、`deviceId`、`type`、`flags`、`parameters`、`entities`、`moduleName`，非合法 JSON 时解析失败并返回 `parse_error`。示例：`{"action":"ohos.want.action.viewData","uri":"https://example.com","bundleName":"com.example.app"}`
- `Future<void> launchChooser(String title)` ：Android 端通过 `Intent.createChooser()` 包装 Intent 并弹出系统选择器；ohos 端直接启动 Ability，效果等同于 `launch()`，不会弹出选择器，`title` 参数不生效。
- `Future<void> sendBroadcast()` ：Android 端会将完整的 Intent extras 发送给广播接收器；ohos 端基于公共事件（`commonEventManager.publish()`）实现，`action` 作为公共事件名称，仅映射 `arguments`/`arrayArguments` 中以下字段：`code`、`data`、`subscriberPermissions`、`isOrdered`、`isSticky`、`parameters`，其余参数不生效。
## 5. 开源协议

本项目基于 [BSD-3-Clause License](LICENSE)，请自由地享受和参与开源。
