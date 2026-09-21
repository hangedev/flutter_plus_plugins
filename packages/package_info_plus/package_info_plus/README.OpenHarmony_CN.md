> 模板版本: v0.0.1

<p align="center">
  <h1 align="center"> <code>package_info_plus</code> </h1>
</p>

本项目基于 [package_info_plus](https://pub.dev/packages/package_info_plus) 开发。

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
      ref: TAG   # 请根据下方TAG版本对应表选择TAG
...
```

执行命令

```bash
flutter pub get
```
TAG 版本对应表

| Flutter 框架版本 | TAG | 分支 |
| --- | --- | --- |
|3.7	|package_info_plus-4.2.0-ohos-1.0.0-beta.1	|master                           |
|3.22	|package_info_plus-4.2.0-ohos.1.0.0-beta.1	|master                           |
|3.27	|package_info_plus-4.2.0-ohos.1.0.0-beta.1	|master                           |
|3.35	|package_info_plus-9.0.0-ohos-1.0.1	        |br_package_info_plus-v9.0.0_ohos |
|3.41	| package_info_plus-10.2.1-ohos-1.0.0 |	br_3.41 |
|3.44	| package_info_plus-10.2.1-ohos-1.0.0 |	br_3.41 |
<!-- tabs:end -->

### 1.2 使用案例

完整工程示例详见 [example](example/lib/main.dart)，API 全量调用示例详见 [example/lib/package_info_api_demo.dart](example/lib/package_info_api_demo.dart)。

#### 调用方式说明

1. 在调用处导入库：`import 'package:package_info_plus/package_info_plus.dart';`
2. `PackageInfo.fromPlatform()` 为异步方法，需在 `async` 方法内 `await` 调用，或在 `FutureBuilder` 中使用；
3. 首次调用经平台通道获取结果并缓存，后续调用直接返回同一实例，各属性可同步读取；
4. 可选参数 `baseUrl` 仅 Web 平台生效，鸿蒙平台无需传入。

#### 场景一：获取应用基础信息（基础功能）

```dart
import 'package:package_info_plus/package_info_plus.dart';

Future<void> readPackageInfo() async {
  // 异步获取平台包信息：首次调用走平台通道，之后返回缓存实例
  final info = await PackageInfo.fromPlatform();

  // 各字段均为同步读取
  print('应用名称: ${info.appName}');       // 例如: package_info_example
  print('包名: ${info.packageName}');       // 例如: com.example.package_info_example
  print('版本号: ${info.version}');         // 例如: 1.0.0
  print('构建编号: ${info.buildNumber}');   // 例如: 1
  print('构建签名: ${info.buildSignature}');// 鸿蒙平台返回应用的证书指纹
}
```

#### 场景二：鸿蒙平台读取安装/更新时间

```dart
import 'package:package_info_plus/package_info_plus.dart';

Future<void> readInstallTime() async {
  final info = await PackageInfo.fromPlatform();

  // installTime / updateTime 的类型是 DateTime?（非字符串），鸿蒙平台必有值
  final installed = info.installTime;
  if (installed != null) {
    // 直接按日期处理，例如格式化输出：2026-01-01 12:00:00
    print('安装时间: ${installed.toLocal()}');
  }
  final updated = info.updateTime;
  if (updated != null) {
    print('更新时间: ${updated.toLocal()}');
  }

  // installerStore 在鸿蒙平台固定返回空字符串，不能作为安装来源判断依据
  print('安装来源: "${info.installerStore}"');
}
```

#### 场景三：通过 data 映射批量序列化/上报

```dart
import 'dart:convert';

import 'package:package_info_plus/package_info_plus.dart';

Future<void> reportVersion() async {
  final info = await PackageInfo.fromPlatform();

  // data 属性提供 Map<String, dynamic> 视图，可直接 JSON 序列化后上报
  final payload = jsonEncode(info.data);
  print(payload);
  // 鸿蒙平台示例输出（时间字段为 ISO-8601 字符串，空值字段自动省略）：
  // {"appName":"package_info_example","packageName":"com.example.package_info_example",
  //  "version":"1.0.0","buildNumber":"1","buildSignature":"a1b2c3d4e5f6a7b8",
  //  "installTime":"2025-12-31T23:59:59.000","updateTime":"2026-01-01T12:00:00.000"}
}
```

> [!NOTE]
> 无需额外准备：插件不涉及任何权限声明与原生配置，添加依赖并执行 `flutter pub get` 后即可直接调用。

## 2. 约束与限制

### 2.1 兼容性

在以下版本中已测试通过

1. Flutter: 3.41.10-ohos-0.0.1; SDK: 5.0.5(17); IDE: DevEco Studio: 6.1.0.830; ROM: 6.23.0.100 SP6;
2. Flutter: 3.44.9+ohos-0.0.1-canary1; SDK: 5.0.5(17); IDE: DevEco Studio 26.0.0 Beta2; ROM: 6.23.0.100 SP6;


## 3. API

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

### PackageInfo API
| 名称               | 说明                                 | 类型               | 输入                        | 输出         | ohos 支持 |
|--------------------|--------------------------------------|--------------------|-----------------------------|--------------|-----------|
| fromPlatform       | 获取并缓存平台特定的包信息           | Future<PackageInfo> | baseUrl: String?（仅 Web 生效，可省略） | PackageInfo  | yes       |

## 4. 属性

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

### PackageInfo 属性
| 名称           | 说明                               | 类型                 | ohos 支持 |
|----------------|------------------------------------|----------------------|-----------|
| appName        | 获取应用名称                       | String               | yes       |
| packageName    | 获取包名称                         | String               | yes       |
| version        | 获取包版本号                       | String               | yes       |
| buildNumber    | 获取构建编号                       | String               | yes       |
| buildSignature | 获取构建签名                       | String               | yes       |
| installerStore | 获取安装商店信息                   | String?              | no        |
| installTime    | 获取安装时间                       | DateTime?            | yes       |
| updateTime     | 获取更新时间                       | DateTime?            | yes       |
| data           | 获取包信息的 Map 表示形式          | Map<String, dynamic> | yes       |

## 5. 遗留问题

## 6. 其他

## 7. 开源协议

本项目基于 [The BSD-3-Clause (license)](LICENSE) ，请自由地享受和参与开源。
