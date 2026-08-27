> Template version: v0.0.1

<p align="center">
  <h1 align="center"> <code>package_info_plus</code> </h1>
</p>

This project is based on [package_info_plus](https://pub.dev/packages/package_info_plus).

## 1. Installation and Usage

### 1.1 Installation

Go to the project directory and add the following dependencies in pubspec.yaml

<!-- tabs:start -->

#### pubspec.yaml

```yaml
...

dependencies:
  package_info_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/package_info_plus/package_info_plus
      ref: TAG 
...
```

Execute Command

```bash
flutter pub get
```
TAG Version Mapping

| Flutter Version | TAG | Branch |
| --- | --- | --- |
|3.7	|package_info_plus-4.2.0-ohos-1.0.0-beta.1	|master                           |
|3.22	|package_info_plus-4.2.0-ohos.1.0.0-beta.1	|master                           |
|3.27	|package_info_plus-4.2.0-ohos.1.0.0-beta.1	|master                           |
|3.35	|package_info_plus-9.0.0-ohos-1.0.1	        |br_package_info_plus-v9.0.0_ohos |
<!-- tabs:end -->

### 1.2 Usage

For the full sample app see [example](example/lib/main.dart); for an invocation of every documented API see [example/lib/package_info_api_demo.dart](example/lib/package_info_api_demo.dart).

#### How to call

1. Import the library where you use it: `import 'package:package_info_plus/package_info_plus.dart';`
2. `PackageInfo.fromPlatform()` is asynchronous — `await` it inside an `async` method, or consume it in a `FutureBuilder`;
3. The first call goes through the platform channel and the result is cached; subsequent calls return the same instance and every property can then be read synchronously;
4. The optional `baseUrl` parameter is web only — omit it on OpenHarmony.

#### Scenario 1: read the basic application information

```dart
import 'package:package_info_plus/package_info_plus.dart';

Future<void> readPackageInfo() async {
  // Fetch the package info asynchronously: the first call goes through
  // the platform channel, later calls return the cached instance.
  final info = await PackageInfo.fromPlatform();

  // Every property is a synchronous read.
  print('App name: ${info.appName}');        // e.g. package_info_example
  print('Package name: ${info.packageName}');// e.g. com.example.package_info_example
  print('Version: ${info.version}');         // e.g. 1.0.0
  print('Build number: ${info.buildNumber}');// e.g. 1
  print('Signature: ${info.buildSignature}');// certificate fingerprint on OHOS
}
```

#### Scenario 2: read the install/update time on OpenHarmony

```dart
import 'package:package_info_plus/package_info_plus.dart';

Future<void> readInstallTime() async {
  final info = await PackageInfo.fromPlatform();

  // installTime / updateTime are DateTime? (not strings); both are
  // always reported on the OHOS platform.
  final installed = info.installTime;
  if (installed != null) {
    // Handle them as dates, e.g. print 2026-01-01 12:00:00
    print('Installed at: ${installed.toLocal()}');
  }
  final updated = info.updateTime;
  if (updated != null) {
    print('Updated at: ${updated.toLocal()}');
  }

  // installerStore is always an empty string on OHOS; do not use it to
  // detect the installation source.
  print('Installer store: "${info.installerStore}"');
}
```

#### Scenario 3: serialize the data map for reporting

```dart
import 'dart:convert';

import 'package:package_info_plus/package_info_plus.dart';

Future<void> reportVersion() async {
  final info = await PackageInfo.fromPlatform();

  // The data property is a Map<String, dynamic> view that serializes
  // to JSON directly.
  final payload = jsonEncode(info.data);
  print(payload);
  // Sample output on OHOS (timestamps as ISO-8601 strings, empty
  // optional fields omitted):
  // {"appName":"package_info_example","packageName":"com.example.package_info_example",
  //  "version":"1.0.0","buildNumber":"1","buildSignature":"a1b2c3d4e5f6a7b8",
  //  "installTime":"2025-12-31T23:59:59.000","updateTime":"2026-01-01T12:00:00.000"}
}
```

> [!NOTE]
> No extra preparation required: the plugin declares no permissions and needs no native configuration — add the dependency, run `flutter pub get`, and call the API directly.

## 2. Constraints

### 2.1 Compatibility

This document is verified based on the following versions:

1. Flutter: 3.35.7-ohos-0.0.1; SDK: 6.0.1(21); IDE: DevEco Studio: 6.0.1.260; ROM: 6.0.0.120 SP6;


## 3. API

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### PackageInfo API
| Name          | Description                               | Type                | Input                                  | Output      | ohos Support |
|---------------|-------------------------------------------|---------------------|----------------------------------------|-------------|--------------|
| fromPlatform  | Retrieves and caches platform-specific package information | Future<PackageInfo> | baseUrl: String? (web only, optional) | PackageInfo | yes         |

## 4. Properties

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### PackageInfo Properties
| Name           | Description                             | Type                 | Input | Output | ohos Support |
|----------------|-----------------------------------------|----------------------|-------|--------|--------------|
| appName        | Gets application name                   | String               | /     | /      | yes          |
| packageName    | Gets package name                       | String               | /     | /      | yes          |
| version        | Gets package version                    | String               | /     | /      | yes          |
| buildNumber    | Gets build number                       | String               | /     | /      | yes          |
| buildSignature | Gets build signature                    | String               | /     | /      | yes          |
| installTime    | Gets install time                       | DateTime?            | /     | /      | yes          |
| updateTime     | Gets update time                        | DateTime?            | /     | /      | yes          |
| installerStore | Gets installer store information        | String?              | /     | /      | no           |
| data           | Gets map representation of package info | Map<String, dynamic> | /     | /      | yes          |

## 5. Known Issues

## 6. Others

## 7. License

This project is licensed under [The BSD-3-Clause (license)](LICENSE).
