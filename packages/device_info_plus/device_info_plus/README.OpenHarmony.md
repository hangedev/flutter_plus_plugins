<p align="center">
  <h1 align="center"> <code>device_info_plus</code> </h1>
</p>

This project is based on [device_info_plus](https://pub.dev/packages/device_info_plus).

## 1. Installation and Usage

### 1.1 Installation

Go to the project directory and add the following dependencies in pubspec.yaml

<!-- tabs:start -->

#### pubspec.yaml

```yaml
...

dependencies:
  device_info_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/device_info_plus/device_info_plus
      # ref: Select the TAG version that matches your Flutter framework version from the table below
      ref: device_info_plus-9.1.0-ohos-1.0.0
...
```

Execute Command

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2  TAG naming rule: `original-library-version-ohos-version-betax`. For changes between TAGs, see CHANGELOG.OpenHarmony.md.

| Flutter Framework Version | TAG Name | Branch |
|---|---|---|
| 3.7  | device_info_plus-9.1.0-ohos-1.0.0 | master |
| 3.22 | device_info_plus-9.1.0-ohos-1.0.0 | master |
| 3.27 | device_info_plus-9.1.0-ohos-1.0.0 | master |

### 1.3 Usage

```dart
import 'package:device_info_plus/device_info_plus.dart';

// 1. Create the plugin instance (cheap to create, safe to reuse).
final deviceInfo = DeviceInfoPlugin();

// 2. Request ohos device information.
final OhosDeviceInfo info = await deviceInfo.ohosInfo;

// 3. Read the fields you need (all fields are nullable — see section 4).
print('model=${info.productModel}');   // e.g. "ALN-AL00"
print('os=${info.osFullName}');        // e.g. "OpenHarmony 5.0.0.120"
print('serial=${info.serial}');        // unavailable on ohos (always null)
print('udid=${info.udid}');            // unavailable on ohos (always null)
```

> `DeviceInfoPlugin()` performs no work on construction, so it is safe to
> instantiate repeatedly. Results are cached per platform after the first call.
> To obtain platform-agnostic information, use `await deviceInfo.deviceInfo`
> (auto-adapts to the running platform); to access the raw map, use `info.data`.

A complete runnable sample is available at
[example/lib/main.dart](example/lib/main.dart).

### 1.4 OHOS Environment Configuration

The plugin targets the OpenHarmony (ohos) platform, which is **not** supported
by the standard Flutter SDK. You must set up the Flutter-OHOS toolchain first:

1. **Install DevEco Studio** — use a version consistent with the compatibility
   table in section 2 (e.g. 5.0.13.200). Download it from the official
   OpenHarmony / Huawei developer site.
2. **Configure the OpenHarmony SDK** — in DevEco Studio open
   `File → Settings → OpenHarmony SDK` (macOS: `Preferences`) and install the
   SDK matching the table (5.0.0(12) / API 12).
3. **Install the Flutter-OHOS fork** — follow the official adaptation guide
   ([Flutter使用指导文档](https://gitcode.com/CPF-Flutter/flutter_samples/blob/master/ohos/docs/07_plugin/ohos%E5%B9%B3%E5%8F%B0%E9%80%82%E9%85%8Dflutter%E4%B8%89%E6%96%B9%E5%BA%93%E6%8C%87%E5%AF%BC.md))
   to install the Flutter-OHOS SDK and register it for the project.
4. **Fetch dependencies** — run `flutter pub get` in the project directory.
5. **Build & run**:
   - CLI: connect an ohos device/emulator and run `flutter run`;
   - IDE: open [example/ohos](example/ohos) in DevEco Studio and build the HAP.

## 2. Constraints

### 2.1 Compatibility

This document is verified against the following versions:

1. Flutter: 3.7.12-ohos-1.0.6; SDK: 5.0.0(12); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;
2. Flutter: 3.22.1-ohos-1.0.1; SDK: 5.0.0(12); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;
3. Flutter: 3.27.5-ohos-0.0.2; SDK: 5.0.0(12); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;

### 2.2 Incompatibility Notes

- The standard Flutter SDK **cannot** build for ohos; the Flutter-OHOS fork is
  required (see section 1.3).
- Minimum toolchain (per `pubspec.yaml`): Dart SDK ≥ 2.18.0 < 4.0.0,
  Flutter ≥ 3.3.0.
- `serial` / `udid` are **unavailable on ohos**: `@ohos.deviceInfo` exposes no
  corresponding API. The fields exist in the Dart model for cross-platform API
  consistency but always return `null` on ohos. Use `odID`
  (`OhosDeviceInfo.odID`) as the ohos device identifier instead. See
  [Known Issues](#5-known-issues).
- This plugin is packaged as a HAR (`ohos/src/main/module.json5`,
  `"type": "har"`); it cannot grant permissions on behalf of the consuming
  app. Any required permission must be declared by the app itself.

### 2.3 Upgrade & Migration

- To upgrade the plugin, change the `git` dependency `ref`/`url` in
  `pubspec.yaml` and run `flutter pub get`; review
  [CHANGELOG.md](CHANGELOG.md) for breaking changes.
- When upgrading the Flutter-OHOS fork or the OpenHarmony SDK, re-verify the
  project against the compatibility table above.
- If a build behaves unexpectedly after an upgrade, clean the build artifacts
  (delete `ohos/build`, `ohos/oh_modules`, `.dart_tool`) and rebuild in
  DevEco Studio.

## 3. API

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### DeviceInfoPlugin API
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| deviceInfo          | Retrieves platform-agnostic device information (auto-adapts for Web/Android/iOS/Linux/macOS/ohos/Windows) | function | / | Future<BaseDeviceInfo> | yes |
| androidInfo         | Retrieves Android device information from `android.os.Build` | function | / | Future<AndroidDeviceInfo> | no |
| iosInfo             | Retrieves iOS device information from `UIDevice` | function | / | Future<IosDeviceInfo> | no |
| linuxInfo           | Retrieves Linux device information from `/etc/os-release` | function | / | Future<LinuxDeviceInfo> | no |
| webBrowserInfo      | Retrieves web browser information from `Navigator` | function | / | Future<WebBrowserInfo> | no |
| macOsInfo           | Retrieves macOS device information from Sysctl | function | / | Future<MacOsDeviceInfo> | no |
| ohosInfo            | Retrieves OpenHarmony device information | function | / | Future<OhosDeviceInfo> | yes |
| windowsInfo         | Retrieves Windows device information | function | / | Future<WindowsDeviceInfo> | no |

---

### OhosDeviceInfo API
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| fromMap             | Constructs an `OhosDeviceInfo` from a raw data map (used internally by the plugin) | function (static) | Map<String, dynamic> | OhosDeviceInfo | yes |

---

### BaseDeviceInfo API
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| toMap             | Returns the raw device information data map (deprecated, use `data` instead) | function | / | Map<String, dynamic> | yes |
| toString          | Returns string representation of the device info | function | / | String | yes |

---

## 4. Properties

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.
>
> **Note on nullability**: every field below is nullable (`String?` / `int?`), matching the Dart model in `lib/src/model/ohos_device_info.dart`. The platform may omit some fields (notably `serial` / `udid` for non-system apps — see Known Issues), so always use null-safe access (`info.productModel ?? 'unknown'`).

### OhosDeviceInfo Filters
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| deviceType          | Gets the device type (e.g. phone/tablet/wearable) | String?  | /     | /       | yes          |
| manufacture         | Gets the manufacturer name          | String?  | /     | /       | yes          |
| brand               | Gets the brand name                 | String?  | /     | /       | yes          |
| marketName          | Gets the marketing name             | String?  | /     | /       | yes          |
| productSeries       | Gets the product series             | String?  | /     | /       | yes          |
| productModel        | Gets the product model              | String?  | /     | /       | yes          |
| softwareModel       | Gets the software model             | String?  | /     | /       | yes          |
| hardwareModel       | Gets the hardware model             | String?  | /     | /       | yes          |
| hardwareProfile     | Gets hardware capabilities profile  | String?  | /     | /       | yes          |
| serial              | Device serial number — unavailable on ohos (`@ohos.deviceInfo` exposes no corresponding API); always null on ohos | String?  | /     | /       | no            |
| bootloaderVersion   | Gets the bootloader version         | String?  | /     | /       | yes          |
| abiList             | Gets supported ABI list             | String?  | /     | /       | yes          |
| securityPatchTag    | Gets security patch version         | String?  | /     | /       | yes          |
| displayVersion      | Gets user-visible version string    | String?  | /     | /       | yes          |
| incrementalVersion  | Gets incremental version number     | String?  | /     | /       | yes          |
| osReleaseType       | Gets OS release type (e.g. "Beta")  | String?  | /     | /       | yes          |
| osFullName          | Gets full OS version name           | String?  | /     | /       | yes          |
| majorVersion        | Gets OS major version number        | int?     | /     | /       | yes          |
| seniorVersion       | Gets OS senior version number       | int?     | /     | /       | yes          |
| featureVersion      | Gets OS feature version number      | int?     | /     | /       | yes          |
| buildVersion        | Gets OS build version number        | int?     | /     | /       | yes          |
| sdkApiVersion       | Gets SDK API version                | int?     | /     | /       | yes          |
| firstApiVersion     | Gets earliest supported API version | int?     | /     | /       | yes          |
| versionId           | Gets version identifier string      | String?  | /     | /       | yes          |
| buildType           | Gets build type (e.g. "user/debug") | String?  | /     | /       | yes          |
| buildUser           | Gets build user account name        | String?  | /     | /       | yes          |
| buildHost           | Gets build host machine name        | String?  | /     | /       | yes          |
| buildTime           | Gets build timestamp string         | String?  | /     | /       | yes          |
| buildRootHash       | Gets hash of build root directory   | String?  | /     | /       | yes          |
| udid                | Device UDID — unavailable on ohos (`@ohos.deviceInfo` exposes no corresponding API); always null on ohos | String?  | /     | /       | no            |
| distributionOSName  | Gets distribution OS name           | String?  | /     | /       | yes          |
| distributionOSVersion | Gets distribution OS version      | String?  | /     | /       | yes          |
| distributionOSApiVersion | Gets distribution OS API version | int?   | /     | /       | yes          |
| distributionOSReleaseType | Gets distribution OS release type | String? | /     | /       | yes          |
| odID                | Gets ODID (OpenHarmony Device ID)   | String?  | /     | /       | yes          |

---

### BaseDeviceInfo Filters
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| data                | Gets the raw device information data map | Map<String, dynamic> | / | / | yes |

---

## 5. Known Issues

- **`serial` / `udid` are unavailable on ohos.** `@ohos.deviceInfo` exposes no
  corresponding API for the device serial number or UDID, so these two fields
  always return `null` on the ohos platform. They are retained in the Dart
  model (`String? serial` / `String? udid`) purely for cross-platform API
  consistency, and the native handler does not populate them. For an
  OpenHarmony device identifier, use `odID` (`OhosDeviceInfo.odID`) instead.

## 6. Others

## 7. License

This project is licensed under [The BSD-3-Clause (license)](LICENSE).
