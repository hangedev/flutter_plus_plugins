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
      url: https://gitcode.com/openharmony-sig/flutter_plus_plugins.git
      path: packages/android_intent_plus
      ref: br_android_intent_plus-v6.0.0_ohos

...
```

Execute Command

```bash
flutter pub get
```

## 2. Constraints

### 2.1 Compatibility

This document is verified based on the following versions:

1. Flutter: 3.22.1-ohos-1.0.3; SDK: 5.1.1(19); IDE: DevEco Studio: 6.0.1.251; ROM: 6.0.0.115 SP16;
2. Flutter: 3.27.5-ohos-1.0.1; SDK: 5.1.1(19); IDE: DevEco Studio: 6.0.1.251; ROM: 6.0.0.115 SP16;
3. Flutter: 3.35.8-ohos-0.0.1; SDK: 6.0.2(22); IDE: DevEco Studio: 6.0.2.640; ROM: 6.0.0.328 SP22;

## 3. API

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### android_intent_plus

| Name      | Description | Type     |  Input   | Output      | ohos Support |
| --------  | ----------- | -------- | -------- | ----------- | ------------ |
| `Future<void> launch()`       | Trigger a generic Intent launch    | function | 无 | void | yes |
| `Future<void> parseAndLaunch(String uri)` | Parse the Intent URI string and launch  | function | `String uri:uri 为完整的 Intent URI`  | void  | yes |
| `Future<void> launchChooser(String title)`  | Launch the system selector pop-up    | function | `String title：title 为选择器标题` | void  | yes |
| `Future<void> sendBroadcast()`  | Send Intent via broadcast  | function |  无  | void  | yes |
| `Future<void> sendService() `  | Start Intent in Service mode | function |  无  | void  | no |
| `Future<ResolvedActivity?> canResolveActivity()`  | Determine whether the activity can be processed and return a boolean value | function |  无  | void  | no |
| `Future<ResolvedActivity?> getResolvedActivity()`  | Get the activity and return a Uint8List  | function |  无  | void  | no |

## 4. Known Issues

### Interfaces not supported by ohos:
- `Future<void> sendService() ` : Launching Intent in Service mode is only supported by 2in1 enterprise applications
- `Future<bool?> canResolveActivity()` ：Determine whether the activity can be processed and return a boolean value. This function is an OHOS system capability and is only supported by system applications
- `Future<ResolvedActivity?> getResolvedActivity()` ：Get the activity and return a ResolvedActivity. This feature is an OHOS system capability and is only supported by system applications

## 5. License

This project is licensed under [BSD-3-Clause License](LICENSE).
