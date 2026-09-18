> 模板版本: v0.0.1

<p align="center">
  <h1 align="center"> <code>share_plus</code> </h1>
</p>

本项目基于 [share_plus](https://pub.dev/packages/share_plus) 开发。

## 1. 安装与使用

### 1.1 安装方式

进入到工程目录并在 pubspec.yaml 中添加以下依赖：

<!-- tabs:start -->

#### pubspec.yaml

```yaml
...

dependencies:
  share_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/share_plus/share_plus
      ref: TAG   # 请根据下方TAG版本对应表选择TAG
...
```

执行命令

```bash
flutter pub get
```

| Flutter 框架版本 | TAG 名称 | 分支名 |
|---|---|---|
|3.41	| share_plus-13.3.0-ohos-1.0.0 |	br_3.41 |
|3.44	| share_plus-13.3.0-ohos-1.0.0 |	br_3.41 |
<!-- tabs:end -->

### 1.2 调用方式

在 Dart 代码中引入插件：

```dart
import 'package:share_plus/share_plus.dart';
```

所有分享能力统一通过 `SharePlus.instance.share(ShareParams)` 调用。**鸿蒙平台上该调用会拉起系统分享面板（`@hms.collaboration.systemShare` 的 `ShareController`），由用户选择接收方应用完成分享**，效果对标 Android 的 `ACTION_SEND`。

- 分享文本与 URI 互斥，二者只能提供其一；
- `text` 可以与 `files` 组合使用（接收方应用是否同时支持取决于其自身实现）；
- 至少提供 `text`、`uri`、`files` 其中之一，否则抛出 `ArgumentError`。

完整可运行示例参见 [example/lib/main.dart](example/lib/main.dart)。

### 1.3 调用示例

#### 分享文本

```dart
// 鸿蒙：拉起系统分享面板，面板记录标题取 title（缺省时回落到 subject）
final result = await SharePlus.instance.share(
  ShareParams(
    text: 'Flutter https://gitcode.com/CPF-Flutter/flutter_plus_plugins',
    title: '分享到',
    subject: '邮件主题（接收方为邮件应用时使用）',
  ),
);
```

#### 分享 URI

```dart
// 鸿蒙：URI 以纯文本方式交给系统分享面板
// 注意：uri 与 text 不能同时提供
final result = await SharePlus.instance.share(
  ShareParams(uri: Uri.parse('https://gitcode.com/CPF-Flutter/flutter_plus_plugins')),
);
```

#### 分享文件

```dart
// 鸿蒙：插件先把文件拷贝到应用缓存目录 share_plus 下，再生成 file:// URI
// 交给系统分享面板；每次分享前会自动清理该缓存目录。
// mimeTypes 由插件根据文件名/内容推断，并映射为鸿蒙 UTD 类型。
final result = await SharePlus.instance.share(
  ShareParams(
    files: [XFile('/data/storage/el2/base/haps/entry/files/demo.png')],
    text: '附带说明文字（可选）',
  ),
);

// 分享内存中的数据（XFile.fromData），fileNameOverrides 用于指定文件名，
// 在 Dart 侧生效，鸿蒙平台同样适用：
final result2 = await SharePlus.instance.share(
  ShareParams(
    files: [XFile.fromData(bytes, mimeType: 'image/png')],
    fileNameOverrides: ['screenshot.png'],
  ),
);
```

#### 处理分享结果

```dart
final result = await SharePlus.instance.share(ShareParams(text: 'text'));

// 鸿蒙平台结果语义：
// - 分享面板被用户关闭 → dismissed（share/shareFiles/shareUri）
switch (result.status) {
  case ShareResultStatus.success:
    // 用户选择了某个分享动作（鸿蒙面板关闭时不会返回此状态）
    break;
  case ShareResultStatus.dismissed:
    // 用户关闭了分享面板
    break;
  case ShareResultStatus.unavailable:
    // 当前环境不支持结果跟踪
    break;
}
```

#### 兼容旧版 API（已废弃，仍可用）

```dart
// 以下方法均已标记 @Deprecated，内部等价转发到 SharePlus.instance.share()
await Share.share('要分享的文本');
await Share.shareUri(Uri.parse('https://gitcode.com/CPF-Flutter/flutter_plus_plugins'));
await Share.shareXFiles([XFile('/path/to/file.png')]);
```

## 2. 约束与限制

### 2.1 兼容性

在以下版本中已测试通过

1. Flutter: 3.41.10-ohos-0.0.1; SDK: 5.0.5(17); IDE: DevEco Studio: 6.1.0.830; ROM: 6.23.0.100 SP6;
2. Flutter: 3.44.9+ohos-0.0.1-canary1; SDK: 5.0.5(17); IDE: DevEco Studio 26.0.0 Beta2; ROM: 6.23.0.100 SP6;

### 2.2 鸿蒙平台行为差异

1. **文件分享依赖缓存目录**：文件会先拷贝到应用缓存目录 `share_plus` 子目录下再分享；**不允许分享位于该缓存目录内的文件**（防止自我复制），否则返回错误 `share_error`。
2. **结果跟踪范围**：`share`/`shareFiles`/`shareUri` 均支持结果跟踪，分享面板关闭时返回 `dismissed`。
3. **并发限制**：同一时刻只允许一个分享操作，上一个分享面板未关闭时再次调用会返回错误 `share_error`（与 Android 防死锁策略一致）。
4. **面板宿主**：分享面板需要当前 `UIAbility` 上下文；插件未挂载到 Ability 时调用会返回错误 `share_error`。

## 3. API

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

### SharePlus API（推荐）

| Name                | Description                         | Type     | Input                                                                                                                           | Output  | ohos Support |
|---------------------|-------------------------------------|----------|---------------------------------------------------------------------------------------------------------------------------------|---------|--------------|
| instance            | SharePlus 默认单例，绑定当前平台实现 | getter | / | SharePlus | yes |
| share               | 拉起平台分享面板，按 ShareParams 分享文本/URI/文件 | function | (ShareParams params) | Future<ShareResult> | yes |

使用示例：

```dart
final result = await SharePlus.instance.share(
  ShareParams(text: 'text', title: 'title'),
);
```

### Share API（已废弃，兼容保留）

| Name                | Description                         | Type     | Input                                                                                                                           | Output  | ohos Support |
|---------------------|-------------------------------------|----------|---------------------------------------------------------------------------------------------------------------------------------|---------|--------------|
| share               | 拉起平台分享面板以分享文本（可选邮件主题） | function | (String text, {String? subject, Rect? sharePositionOrigin}) | Future<ShareResult> | yes |
| shareUri            | 拉起平台分享面板以分享 URI | function | (Uri uri, {Rect? sharePositionOrigin}) | Future<ShareResult> | yes |
| shareXFiles         | 拉起平台分享面板以分享多个文件（自动推断 MIME 类型） | function | (List\<XFile\> files, {String? subject, String? text, Rect? sharePositionOrigin, List\<String\>? fileNameOverrides}) | Future<ShareResult> | yes |
| downloadFallbackEnabled | Web 平台分享失败时是否回退为下载文件 | static property | / | bool | no（仅 Web 生效） |

使用示例：

```dart
await Share.share('text', subject: 'subject');
await Share.shareUri(Uri.parse('https://example.com'));
await Share.shareXFiles([XFile('/path/to/file.png')], text: '附带文字');
```

---

## 4. 属性

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

### ShareParams Filters

| Name                | Description                         | Type     | ohos Support | 说明 |
|---------------------|-------------------------------------|----------|--------------|------|
| text                | 要分享的文本，与 uri 互斥 | String? | yes | 可与 files 组合 |
| title               | 分享面板标题 | String? | yes | 作为分享记录标题，缺省时回落到 subject |
| subject             | 邮件主题 | String? | yes | 接收方为邮件类应用时使用，并作为 title 的兜底 |
| uri                 | 要分享的 URI，与 text 互斥 | Uri? | yes | 鸿蒙上以纯文本方式分享 |
| files               | 要分享的文件列表 | List\<XFile\>? | yes | 拷贝到缓存目录后以 file:// URI 分享 |
| fileNameOverrides   | 覆盖分享文件名，长度须与 files 一致 | List\<String\>? | yes | 在 Dart 侧生效（XFile.fromData 场景） |
| previewThumbnail    | 分享预览缩略图 | XFile? | no | 仅 Android 生效，其他平台忽略 |
| sharePositionOrigin | 分享面板弹出的锚点矩形 | Rect? | no | 仅 iPad/Mac 生效，其他平台忽略 |
| downloadFallbackEnabled | Web 分享失败时回退为下载 | bool | no | 仅 Web 生效，其他平台忽略 |
| mailToFallbackEnabled | Web 分享失败时回退为邮件 | bool | no | 仅 Web 生效，其他平台忽略 |
| excludedCupertinoActivities | 排除 iOS/macOS 分享面板中的服务 | List\<CupertinoActivityType\>? | no | 仅 iOS/macOS 生效，其他平台忽略 |

### ShareResult Filters

| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| raw                 | 原始平台返回值（空字符串=用户取消分享，特殊值=功能不可用） | String | / | / | yes |
| status              | 枚举指示用户操作（成功/取消/不可用） | ShareResultStatus | / | / | yes |

---

### ShareResultStatus Filters

| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| success             | 用户选择了某个分享动作 | enum | / | / | yes |
| dismissed           | 用户取消了分享操作 | enum | / | / | yes |
| unavailable         | 状态无法确定（平台不支持） | enum | / | / | yes |

> [!NOTE] 鸿蒙平台上 `dismissed` 在用户关闭分享面板时返回（`share`/`shareFiles`/`shareUri`）；`success` 不会出现（面板关闭仅通知 dismiss 事件，不区分用户是否完成分享）。

---

## 5. 遗留问题

## 6. 其他

## 7. 开源协议

本项目基于 [The BSD-3-Clause (license)](LICENSE) ，请自由地享受和参与开源。
