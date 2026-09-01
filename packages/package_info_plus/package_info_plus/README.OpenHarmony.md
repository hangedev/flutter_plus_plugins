<p align="center">
  <h1 align="center"> <code>package_info_plus</code> </h1>
</p>

This project is based on [package_info_plus](https://pub.dev/packages/package_info_plus) (upstream 4.2.0) and adds OpenHarmony (ohos) platform support.

## 1. Installation and Usage

### 1.1 Installation

Go to the project directory and add the following dependencies in pubspec.yaml:

<!-- tabs:start -->

#### pubspec.yaml

```yaml
...

dependencies:
  package_info_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/package_info_plus/package_info_plus
      # ref: select the TAG that matches your Flutter-OHOS framework
      ref: TAG

...
```

Execute Command

```bash
flutter pub get
```

<!-- tabs:end -->

TAG Version Mapping

| Flutter Version | TAG | Branch |
| --- | --- | --- |
|3.7	|package_info_plus-4.2.0-ohos-1.0.0	|master                           |
|3.22	|package_info_plus-4.2.0-ohos-1.0.0	|master                           |
|3.27	|package_info_plus-4.2.0-ohos-1.0.0	|master                           |
|3.35	|package_info_plus-9.0.0-ohos-1.0.0	|br_package_info_plus-v9.0.0_ohos |

### 1.2 Usage

All scenarios below are one-shot reads — this plugin exposes no streams or
long-lived listeners; results are delivered through `Future` callbacks.

#### Scenario 1: basic `await` call

```dart
import 'package:package_info_plus/package_info_plus.dart';

// 1. Fetch package information from the platform. One MethodChannel
//    ('dev.fluttercommunity.plus/package_info' → getAll) round-trip;
//    the result is cached, later calls return the same instance.
final info = await PackageInfo.fromPlatform();

// 2. Read the fields you need. On ohos every value is resolved by the
//    native side from AppScope/app.json5 of the application:
print(info.appName);        // label       → e.g. "example"
print(info.packageName);    // bundleName  → e.g. "io.flutter.plugins.example"
print(info.version);        // versionName → e.g. "1.2.3"
print(info.buildNumber);    // versionCode → e.g. "4" (stringified)
print(info.buildSignature); // signing certificate fingerprint (hex);
                            // empty when the bundle carries no signature info
print(info.installerStore); // always null on ohos — no store is reported
```

#### Scenario 2: `.then` callback style

```dart
// The platform query is asynchronous; register callbacks instead of
// blocking the caller.
PackageInfo.fromPlatform().then((PackageInfo info) {
  // Runs once the native getAll call has answered.
  setState(() => _packageInfo = info);
}).catchError((Object e) {
  // The ohos side surfaces bundle query failures as a PlatformException
  // ('Name not found').
  debugPrint('PackageInfo.fromPlatform failed: $e');
});
```

#### Scenario 3: `FutureBuilder` in the widget tree

```dart
// fromPlatform() is cached, so it is safe to call on every build — the
// first call triggers the channel round-trip, later calls resolve
// immediately with the cached instance.
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

#### Scenario 4: map / JSON serialization

```dart
final info = await PackageInfo.fromPlatform();

// `data` returns a Map<String, dynamic> view of every populated field;
// empty optional fields (buildSignature, installerStore) are omitted.
final map = info.data;
// → {appName: ..., packageName: ..., version: ..., buildNumber: ...}

final json = jsonEncode(info.data); // ready for reporting / analytics
```

#### Scenario 5: mock values in tests

```dart
// Seeds the cached singleton so no platform channel is hit; test-only
// (@visibleForTesting). A later fromPlatform() returns these values.
PackageInfo.setMockInitialValues(
  appName: 'test_app',
  packageName: 'dev.fluttercommunity.plus.testapp',
  version: '1.0.0',
  buildNumber: '42',
  buildSignature: 'a1b2c3d4e5f6a7b8',
  installerStore: null,
);
```

A complete runnable sample is available at
[example/lib/main.dart](example/lib/main.dart).

### 1.3 OHOS Environment Configuration

The plugin targets the OpenHarmony (ohos) platform, which is **not**
supported by the standard Flutter SDK. You must set up the Flutter-OHOS
toolchain first:

1. **Install DevEco Studio** — use a version consistent with the
   compatibility table in section 2. Download it from the official
   OpenHarmony / Huawei developer site.
2. **Configure the OpenHarmony SDK** — in DevEco Studio open
   `File → Settings → OpenHarmony SDK` (macOS: `Preferences`) and install
   the SDK matching the table.
3. **Install the Flutter-OHOS fork** — follow the official adaptation guide
   ([Flutter使用指导文档](https://gitcode.com/CPF-Flutter/flutter_samples/blob/master/ohos/docs/07_plugin/ohos%E5%B9%B3%E5%8F%B0%E9%80%82%E9%85%8Dflutter%E4%B8%89%E6%96%B9%E5%BA%93%E6%8C%87%E5%AF%BC.md))
   to install the Flutter-OHOS SDK and register it for the project.
4. **Fetch dependencies** — run `flutter pub get` in the project directory.
5. **Build & run**:
   - CLI: connect an ohos device/emulator and run `flutter run`;
   - IDE: open [example/ohos](example/ohos) in DevEco Studio and build the
     HAP (the plugin itself requires no ohos permissions — it only reads
     the app's own bundle info through `@ohos.bundle.bundleManager`).

## 2. Constraints

### 2.1 Compatibility

This document is verified against the following versions:

1. Flutter: 3.7.12-ohos-1.0.6; SDK: 5.0.5(17); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;
2. Flutter: 3.22.1-ohos-1.0.1; SDK: 5.0.5(17); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;
3. Flutter: 3.27.5-ohos-0.0.1; IDE: DevEco Studio: 6.0.2.640; ROM: OpenHarmony 7.0.0.102 (API 26);

### 2.2 Incompatibility Notes

- The standard Flutter SDK **cannot** build for ohos; the Flutter-OHOS fork
  is required (see section 1.4).
- Minimum toolchain (per `pubspec.yaml`): Dart SDK ≥ 2.18.0 < 4.0.0,
  Flutter ≥ 3.3.0.
- `installerStore` is **unavailable on ohos**:
  `@ohos.bundle.bundleManager` exposes no installer-source API for the
  running bundle, so the field always resolves to `null` on ohos. It is
  kept in the Dart API for cross-platform consistency.
- `buildSignature` on ohos is the fingerprint of the signing certificate.
  It is reported only when the bundle carries signature info; unsigned
  builds resolve it to an empty string.
- This ohos adaptation is based on upstream package_info_plus **4.2.0**.
  The `installTime` / `updateTime` fields and the
  `fromPlatform(baseUrl: ...)` parameter of the 9.x line are **not** part
  of this version's API.
- The plugin is packaged as a HAR; it declares no ohos permissions and
  cannot grant permissions on behalf of the consuming app (none are
  needed).

### 2.3 Upgrade & Migration

- To upgrade the plugin, change the `git` dependency `ref`/`url` in
  `pubspec.yaml` and run `flutter pub get`; review
  [CHANGELOG.md](CHANGELOG.md) for breaking changes.
- When upgrading the Flutter-OHOS fork or the OpenHarmony SDK, re-verify
  the project against the compatibility table above.
- If a build behaves unexpectedly after an upgrade (e.g. stale plugin
  code), clean the build artifacts (delete `ohos/build`, `ohos/oh_modules`
  and `.dart_tool`, in both the app and the plugin) and rebuild.

## 3. API

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### PackageInfo API (static)

| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| fromPlatform        | Retrieves package information from the platform through the `getAll` method channel and caches the result; subsequent calls return the cached instance | future (static) | / | Future&lt;PackageInfo&gt; | yes |
| setMockInitialValues | Overwrites the cached singleton with mock values; test-only (`@visibleForTesting`) | function (static) | appName, packageName, version, buildNumber, buildSignature, installerStore | void | yes |

### PackageInfo API (instance)

| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| PackageInfo         | Constructs an instance with the given values (kept for testing; platform data comes from `fromPlatform`) | constructor | appName, packageName, version, buildNumber, buildSignature, installerStore | PackageInfo | yes |
| ==                  | Value equality over every documented field | operator | Object | bool | yes |
| hashCode            | Hash code consistent with `==` | getter | / | int | yes |
| toString            | String representation listing every field (`PackageInfo(appName: ..., buildNumber: ..., ...)`) | function | / | String | yes |

## 4. Properties

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### PackageInfo Properties

| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| appName             | Gets the application name           | String   | /     | /       | yes |
| packageName         | Gets the package name (bundle identifier) | String | /    | /       | yes |
| version             | Gets the package version            | String   | /     | /       | yes |
| buildNumber         | Gets the build number               | String   | /     | /       | yes |
| buildSignature      | Gets the build signature            | String   | /     | /       | yes |
| installerStore      | Gets the installer store information — unavailable on ohos, always `null` | String? | / | / | no |
| data                | Gets the map representation of every populated field (empty optional fields are omitted) | Map&lt;String, dynamic&gt; | / | / | yes |

### Value mapping on ohos

Every field is resolved by the native implementation
([ohos/src/main/ets/.../PackageInfoPlugin.ets](ohos/src/main/ets/dev/fluttercommunity/plus/packageinfo/PackageInfoPlugin.ets))
through `@ohos.bundle.bundleManager.getBundleInfoForSelfSync`:

| Property | ohos source | Example value ([example](example/ohos/AppScope/app.json5) app) |
|----------|-------------|------------------|
| appName | `AppScope/app.json5` → `app.label` resource (`$string:app_name`) | `example` |
| packageName | `AppScope/app.json5` → `app.bundleName` | `io.flutter.plugins.example` |
| version | `AppScope/app.json5` → `app.versionName` | `1.2.3` |
| buildNumber | `AppScope/app.json5` → `app.versionCode` (stringified) | `4` |
| buildSignature | `signatureInfo.fingerprint` of the signing certificate (hex) | non-empty for a signed HAP, e.g. `"A1B2C3..."` |
| installerStore | not reported — `@ohos.bundle.bundleManager` exposes no installer source | `null` |

## 5. Known Issues

- **`installerStore` is unavailable on ohos.** The ohos bundle manager
  provides no installer-source API, so the field always resolves to `null`
  on the ohos platform. It is retained in the Dart API purely for
  cross-platform consistency.
- **`buildSignature` depends on signature info.** It carries the signing
  certificate fingerprint and resolves to an empty string when the bundle
  carries no signature info (e.g. some unsigned debug builds).
- **9.x-only fields are absent.** This version is based on upstream 4.2.0;
  `installTime` / `updateTime` and `fromPlatform(baseUrl: ...)` do not
  exist here.

## 6. Others

- Source repository: [flutter_plus_plugins](https://gitcode.com/CPF-Flutter/flutter_plus_plugins)
  — issues and MRs are welcome.
- Sibling ohos-adapted plugins in this repository: `device_info_plus`,
  `battery_plus`, `connectivity_plus`, `network_info_plus`,
  `share_plus`, `sensors_plus`, …
- The plugin is verified on device by
  [example/integration_test/package_info_plus_test.dart](example/integration_test/package_info_plus_test.dart).

## 7. License

This project is licensed under [The BSD-3-Clause (license)](LICENSE).
