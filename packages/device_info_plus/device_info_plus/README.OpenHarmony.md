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
      ref: br_device_info_plus-v11.1.0_ohos
...
```

Execute Command

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 Usage

For use cases [example](example/lib/main.dart)

## 2. Constraints

### 2.1 Compatibility

This document is verified based on the following versions:

1. Flutter: 3.22.1-ohos-1.0.1; SDK: 5.0.0(12); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;

## 3. API

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### DeviceInfoPlugin API
| Name                | Description                                                                 | Type     | Input | Output                          | ohos Support |
|---------------------|-----------------------------------------------------------------------------|----------|-------|---------------------------------|--------------|
| ohosDeviceInfo      | Retrieves device information from `@ohos.deviceInfo` | function | /     | Future<OhosDeviceInfo>          | yes          |
| androidInfo         | Retrieves Android device information from `android.os.Build`                    | function | /     | Future<AndroidDeviceInfo>         | no          |
| iosInfo             | Retrieves iOS device information from `UIDevice`                              | function | /     | Future<IosDeviceInfo>             | no          |
| linuxInfo           | Retrieves Linux device information from `/etc/os-release`                     | function | /     | Future<LinuxDeviceInfo>           | no          |
| webBrowserInfo      | Retrieves web browser information from `Navigator`                             | function | /     | Future<WebBrowserInfo>            | no          |
| macOsInfo           | Retrieves macOS device information from Sysctl                                | function | /     | Future<MacOsDeviceInfo>           | no          |
| windowsInfo         | Retrieves Windows device information                                        | function | /     | Future<WindowsDeviceInfo>         | no          |
| deviceInfo          | Retrieves platform-agnostic device information (auto-adapts for OHOS/Android/iOS/etc) | function | /     | Future<BaseDeviceInfo>            | yes          |

---

### BaseDeviceInfo API
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| toMap             | Returns the raw device information data map (deprecated) | function | / | Map<String, dynamic> | yes |
| toString          | Returns string representation of the device info | function | / | String | yes |

---

## 4. Properties

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### OhosDeviceInfo Filters
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| deviceType          | Gets the device type (e.g. phone/tablet/wearable) | String   | /     | /       | yes          |
| manufacture         | Gets the manufacturer name          | String   | /     | /       | yes          |
| brand               | Gets the brand name                 | String   | /     | /       | yes          |
| marketName          | Gets the marketing name             | String   | /     | /       | yes          |
| productSeries       | Gets the product series             | String   | /     | /       | yes          |
| productModel        | Gets the product model              | String   | /     | /       | yes          |
| softwareModel       | Gets the software model             | String   | /     | /       | yes          |
| hardwareModel       | Gets the hardware model             | String   | /     | /       | yes          |
| hardwareProfile     | Gets hardware capabilities profile  | String   | /     | /       | yes          |
| bootloaderVersion   | Gets the bootloader version         | String   | /     | /       | yes          |
| abiList             | Gets supported ABI list             | String   | /     | /       | yes          |
| securityPatchTag    | Gets security patch version         | String   | /     | /       | yes          |
| displayVersion      | Gets user-visible version string    | String   | /     | /       | yes          |
| incrementalVersion  | Gets incremental version number     | String   | /     | /       | yes          |
| osReleaseType       | Gets OS release type (e.g. "Beta")  | String   | /     | /       | yes          |
| osFullName          | Gets full OS version name           | String   | /     | /       | yes          |
| majorVersion        | Gets OS major version number        | int      | /     | /       | yes          |
| seniorVersion       | Gets OS senior version number       | int      | /     | /       | yes          |
| featureVersion      | Gets OS feature version number      | int      | /     | /       | yes          |
| buildVersion        | Gets OS build version number        | int      | /     | /       | yes          |
| sdkApiVersion       | Gets SDK API version                | int      | /     | /       | yes          |
| firstApiVersion     | Gets earliest supported API version | int      | /     | /       | yes          |
| buildType           | Gets build type (e.g. "user/debug") | String   | /     | /       | yes          |
| buildTime           | Gets build timestamp string         | String   | /     | /       | yes          |
| odID                | Gets ODID (OpenHarmony Device ID)   | String   | /     | /       | yes          |

---

### BaseDeviceInfo Filters
| Name                | Description                         | Type               | Input | Output  | ohos Support |
|---------------------|-------------------------------------|--------------------|-------|---------|--------------|
| data                | Gets the raw device information data map | Map<String, dynamic> | /     | /       | yes          |

---

## 5. Known Issues

## 6. Others

## 7. License

This project is licensed under [The BSD-3-Clause (license)](LICENSE).
