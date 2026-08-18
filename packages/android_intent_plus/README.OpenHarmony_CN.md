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
      ref: android_intent_plus-6.0.0-ohos-1.0.0

...
```

### TAG 版本对应表
| Flutter 框架版本 | TAG                | 分支     |
|--------------|--------------------|--------|
| 3.22        | android_intent_plus-6.0.0-ohos-1.0.0   | br_android_intent_plus-v6.0.0_ohos |
| 3.27        | android_intent_plus-6.0.0-ohos-1.0.0   | br_android_intent_plus-v6.0.0_ohos |
| 3.35        | android_intent_plus-6.0.0-ohos-1.0.0   | br_android_intent_plus-v6.0.0_ohos |

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

1. Flutter: 3.22.1-ohos-1.0.3; SDK: 5.0.0(12); IDE: DevEco Studio: 6.0.1.251; ROM: 6.0.0.115 SP16;
2. Flutter: 3.27.5-ohos-1.0.1; SDK: 5.0.0(12); IDE: DevEco Studio: 6.0.1.251; ROM: 6.0.0.115 SP16;
3. Flutter: 3.35.8-ohos-0.0.1; SDK: 6.0.2(22); IDE: DevEco Studio: 6.0.2.640; ROM: 6.0.0.328 SP22;

## 3. API

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

### android_intent_plus

| Name | Description | Type | Input | Output | ohos Support |
| --------  | ----------- | -------- | -------- | ----------- | ------------ |
| `Future<void> launch()` | 触发一次通用 Intent 启动 | function | 无 | void | yes |
| `Future<void> parseAndLaunch(String uri)` | 解析 Intent URI 字符串并启动 | function | `String uri:uri 为完整的 Intent URI` | void | yes |
| `Future<void> launchChooser(String title)` | 启动系统选择器弹窗 | function | `String title：title 为选择器标题` | void | yes |
| `Future<void> sendBroadcast()` | 以广播方式发送 Intent | function | 无 | void | yes |
| `Future<void> sendService() ` | 以 Service 方式启动 Intent | function | 无 | void | no |
| `Future<ResolvedActivity?> canResolveActivity()` | 判断是否能够处理该activity，返回布尔值 | function | 无 | void | no |
| `Future<ResolvedActivity?> getResolvedActivity()` | 获取该activity，返回Uint8List | function | 无 | void | no |


## 4. 遗留问题

### ohos不支持的接口:
- `Future<void> sendService() ` : 以 Service 方式启动 Intent，此功能仅2in1的企业应用支持
- `Future<bool?> canResolveActivity()` ：判断是否能够处理该activity，返回布尔值，此功能为ohos系统能力，仅系统应用支持
- `Future<ResolvedActivity?> getResolvedActivity()` ：获取该activity，返回ResolvedActivity，此功能为ohos系统能力，仅系统应用支持


## 5. 开源协议

本项目基于 [BSD-3-Clause License](LICENSE)，请自由地享受和参与开源。
