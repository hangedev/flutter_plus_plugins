<p align="center">
  <h1 align="center"> <code>android_intent_plus</code> </h1>
</p>

This project is based on [android_intent_plus](https://pub.dev/packages/android_intent_plus) .

## 1. Installation and Usage

### 1.1 Installation

Go to the project directory and add the following dependencies in pubspec.yaml

<!-- tabs:start -->

#### pubspec.yaml

```yaml
...

dependencies:
  android_intent_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/android_intent_plus
      # ref: Select the TAG version that matches your Flutter framework version from the table below
      ref: android_intent_plus-6.0.0-ohos-1.0.1

...
```

### TAG Version Mapping

| Flutter Framework Version | TAG                     | Branch |
|--------------|-------------------------|------|
| 3.22         | android_intent_plus-6.0.0-ohos-1.0.1 | br_android_intent_plus-v6.0.0_ohos |
| 3.27         | android_intent_plus-6.0.0-ohos-1.0.1 | br_android_intent_plus-v6.0.0_ohos |
| 3.35         | android_intent_plus-6.0.0-ohos-1.0.1| br_android_intent_plus-v6.0.0_ohos |

Execute Command

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 Upgrade and Migration

1. Open pubspec.yaml in your project and change the dependency `ref` to the target TAG version (see the table above for the mapping between TAGs and Flutter framework versions). If the plugin is integrated from source code, update the repository to the corresponding TAG instead;
2. Execute the following commands to update dependencies and clean build caches:

```bash
flutter pub get
flutter clean
```

3. Rebuild the project and verify that the plugin works as expected. If there are API changes between versions, adjust your code according to [CHANGELOG.OpenHarmony.md](CHANGELOG.OpenHarmony.md).

### 1.3 Environment Setup (OpenHarmony)

Before using this plugin on OpenHarmony/HarmonyOS, complete the following environment setup:

1. **Install DevEco Studio**: download and install it from the [official website](https://developer.huawei.com/consumer/en/deveco-studio/), following the official installation guide;
2. **Configure the SDK**: follow the wizard on the first launch of DevEco Studio, or open `File > Settings > SDK` to download the HarmonyOS/OpenHarmony SDK that matches the versions listed in the Compatibility section below;
3. **Set up the Flutter ohos environment**: follow the [Flutter plugin adaptation guide](https://gitcode.com/CPF-Flutter/flutter_samples/blob/master/ohos/docs/07_plugin/ohos%E5%B9%B3%E5%8F%B0%E9%80%82%E9%85%8Dflutter%E4%B8%89%E6%96%B9%E5%BA%93%E6%8C%87%E5%AF%BC.md) to set up the Flutter ohos environment;
4. **Build**: go to the example directory and run the following commands to build the HAP, or open the `example/ohos` project in DevEco Studio to build and run directly:

```bash
cd example
flutter pub get
flutter build hap --debug
```

For more general adaptation guidance, see [GUIDE_DOCUMENT.md](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/GUIDE_DOCUMENT.md) in the repository root directory.

### 1.4 Usage

The complete calling flow is as follows:

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

In addition to `launch()`, methods such as `parseAndLaunch()` (parse an Intent URI string and launch), `launchChooser()` (launch the system chooser pop-up) and `sendBroadcast()` (send via broadcast) are also available. See the API section below for details.

### 1.5 Example

See [example](example/lib/main.dart) for a complete usage example.

## 2. Constraints

### 2.1 Compatibility

This document is verified based on the following versions:

1. Flutter: 3.22.1-ohos-1.0.3; SDK: 5.0.5(17); IDE: DevEco Studio: 6.0.1.251; ROM: 6.0.0.115 SP16;
2. Flutter: 3.27.5-ohos-1.0.1; SDK: 5.0.5(17); IDE: DevEco Studio: 6.0.1.251; ROM: 6.0.0.115 SP16;
3. Flutter: 3.35.8-ohos-0.0.1; SDK: 5.0.5(17); IDE: DevEco Studio: 6.0.2.640; ROM: 6.0.0.328 SP22;

## 3. API

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### 3.1 API Reference

| Name | Description | Type | Input | Output | ohos Support |
| --------  | ----------- | -------- | -------- | ----------- | ------------ |
| `Future<void> launch()` | Trigger a generic Intent launch | function | None | void | yes |
| `Future<void> parseAndLaunch(String uri)` | Parse the Intent URI string and launch (on ohos the uri is parsed as a JSON string of Want fields instead of an Android Intent URI, see section 4) | function | `String uri: the full Intent URI on Android, a JSON string of Want fields on ohos` | void | partially |
| `Future<void> launchChooser(String title)` | Launch the system selector pop-up (on ohos no selector pop-up is shown, the behavior is the same as `launch()` and `title` is ignored, see section 4) | function | `String title: the selector title` | void | partially |
| `Future<void> sendBroadcast()` | Send Intent via broadcast (on ohos implemented with common events, only specific fields of `arguments`/`arrayArguments` are mapped, see section 4) | function | None | void | partially |
| `Future<void> sendService() ` | Start Intent in Service mode | function | None | void | no |
| `Future<bool?> canResolveActivity()` | Determine whether the activity can be processed and return a boolean value | function | None | `bool?` | no |
| `Future<ResolvedActivity?> getResolvedActivity()` | Get the activity and return a ResolvedActivity object | function | None | `ResolvedActivity?` | no |

### 3.2 Constructor Parameters

The `AndroidIntent` constructor has 9 business parameters, described as follows:

| Parameter | Type | Description |
| -------- | -------- | ----------- |
| `action` | `String?` | The general verb the intent should perform (e.g. `ohos.want.action.viewData`). Either `action` or `componentName` must be specified |
| `flags` | `List<int>?` | A list of ints that is converted into native flags by bitwise combination; each value must be a power of 2 |
| `category` | `String?` | The category of the intent, an optional additional constant qualifying the given `action`, can be null |
| `data` | `String?` | The string form of the URI that the `action` is pointed towards |
| `arguments` | `Map<String, dynamic>?` | The equivalent of `extras`, converted into an extras bundle and passed along with the intent |
| `arrayArguments` | `Map<String, List<dynamic>>?` | Similar to `arguments`, but passed to the intent as array extras |
| `package` | `String?` | The package of the intent, which restricts `data` resolution to the given package, can be null |
| `componentName` | `String?` | The component name of the intent, the exact component that should handle the intent; when set, `package` must also be provided |
| `type` | `String?` | An explicit MIME data type of the intent, can be null |

## 4. Known Issues

### Interfaces not supported by ohos:
- `Future<void> sendService() ` : Launching Intent in Service mode is only supported by 2in1 enterprise applications
- `Future<bool?> canResolveActivity()` : Determine whether the activity can be processed and return a boolean value. This function is an OHOS system capability and is only supported by system applications
- `Future<ResolvedActivity?> getResolvedActivity()` : Get the activity and return a ResolvedActivity. This feature is an OHOS system capability and is only supported by system applications

### Interfaces with behavioral differences from Android on ohos:
- `Future<void> parseAndLaunch(String uri)` : On Android the uri is parsed with `Intent.parseUri()`, using the Intent URI format `intent://...#Intent;...;end`. On ohos the uri is parsed as a JSON string describing a Want, supporting the fields `action`, `uri`, `bundleName`, `abilityName`, `deviceId`, `type`, `flags`, `parameters`, `entities`, `moduleName`. A string that is not valid JSON fails with a `parse_error`. Example: `{"action":"ohos.want.action.viewData","uri":"https://example.com","bundleName":"com.example.app"}`
- `Future<void> launchChooser(String title)` : On Android the intent is wrapped with `Intent.createChooser()` and a system selector pop-up is displayed. On ohos the ability is started directly, which is equivalent to `launch()`; no selector pop-up is shown and the `title` parameter is ignored.
- `Future<void> sendBroadcast()` : On Android the full Intent extras are delivered to broadcast receivers. On ohos the broadcast is implemented with `commonEventManager.publish()` and `action` is used as the common event name; only the following keys of `arguments`/`arrayArguments` are mapped to the common event: `code`, `data`, `subscriberPermissions`, `isOrdered`, `isSticky`, `parameters`. Other extras are ignored.

## 5. License

This project is licensed under [BSD-3-Clause License](LICENSE).
