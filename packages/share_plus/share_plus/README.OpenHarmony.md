> Template version: v0.0.1

<p align="center">
  <h1 align="center"> <code>share_plus</code> </h1>
</p>

This project is based on [share_plus](https://pub.dev/packages/share_plus).

## 1. Installation and Usage

### 1.1 Installation

Go to the project directory and add the following dependencies in pubspec.yaml

<!-- tabs:start -->

#### pubspec.yaml

```yaml
...

dependencies:
  share_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/share_plus/share_plus
      # ref: share_plus-12.0.1-ohos-1.0.0
      ref: TAG   # Please select the TAG to the TAG Version Mapping
...
```

Execute Command

```bash
flutter pub get
```
| Flutter framework version | TAG name | Branch |
|---|---|---|
|3.7	| share_plus-7.2.0-ohos.1.0.0	 |  master                     |
|3.22	| share_plus-12.0.1-ohos-1.0.1 |	br_share_plus-v12.0.1_ohos |
|3.27	| share_plus-12.0.1-ohos-1.0.1 |	br_share_plus-v12.0.1_ohos |
|3.35	| share_plus-12.0.1-ohos-1.0.1 |	br_share_plus-v12.0.1_ohos |
<!-- tabs:end -->

### 1.2 How to Call

Import the plugin in your Dart code:

```dart
import 'package:share_plus/share_plus.dart';
```

All sharing capabilities are invoked through `SharePlus.instance.share(ShareParams)`. **On HarmonyOS this summons the system share sheet (`ShareController` from `@hms.collaboration.systemShare`); the user picks the target app to complete the share**, equivalent to `ACTION_SEND` on Android.

- `text` and `uri` are mutually exclusive; provide exactly one of them;
- `text` may be combined with `files` (whether the receiving app accepts both depends on the app);
- at least one of `text`, `uri` or `files` must be provided, otherwise an `ArgumentError` is thrown.

See [example/lib/main.dart](example/lib/main.dart) for a complete runnable sample.

### 1.3 Usage Examples

#### Share text

```dart
// HarmonyOS: summons the system share sheet; the record title is taken from
// `title` (falls back to `subject` when omitted)
final result = await SharePlus.instance.share(
  ShareParams(
    text: 'Flutter https://gitcode.com/CPF-Flutter/flutter_plus_plugins',
    title: 'Share to',
    subject: 'Email subject (used when the target is a mail app)',
  ),
);
```

#### Share a URI

```dart
// HarmonyOS: the URI is handed to the system share sheet as plain text.
// Note: uri and text cannot be provided at the same time.
final result = await SharePlus.instance.share(
  ShareParams(uri: Uri.parse('https://gitcode.com/CPF-Flutter/flutter_plus_plugins')),
);
```

#### Share files

```dart
// HarmonyOS: the plugin first copies each file into the `share_plus` folder
// under the app cache directory, then shares file:// URIs with the system
// share sheet; that cache folder is cleared before every share.
// MIME types are inferred by the plugin and mapped to HarmonyOS UTD types.
final result = await SharePlus.instance.share(
  ShareParams(
    files: [XFile('/data/storage/el2/base/haps/entry/files/demo.png')],
    text: 'Optional accompanying text',
  ),
);

// Share in-memory data (XFile.fromData). fileNameOverrides names the file and
// takes effect on the Dart side, so it also applies on HarmonyOS:
final result2 = await SharePlus.instance.share(
  ShareParams(
    files: [XFile.fromData(bytes, mimeType: 'image/png')],
    fileNameOverrides: ['screenshot.png'],
  ),
);
```

#### Handle the share result

```dart
final result = await SharePlus.instance.share(ShareParams(text: 'text'));

// Result semantics on HarmonyOS:
// - user closes the share sheet -> dismissed (share/shareFiles/shareUri)
switch (result.status) {
  case ShareResultStatus.success:
    // The user selected a share action (not reported by the HarmonyOS sheet)
    break;
  case ShareResultStatus.dismissed:
    // The user dismissed the share sheet
    break;
  case ShareResultStatus.unavailable:
    // Result tracking is not supported in this environment
    break;
}
```

#### Legacy API (deprecated, still functional)

```dart
// All of the following are @Deprecated and forward to SharePlus.instance.share()
await Share.share('text to share');
await Share.shareUri(Uri.parse('https://gitcode.com/CPF-Flutter/flutter_plus_plugins'));
await Share.shareXFiles([XFile('/path/to/file.png')]);
```

## 2. Constraints

### 2.1 Compatibility

This document is verified based on the following versions:

1. Flutter: 3.22.1-ohos-1.0.1; SDK: 5.0.5(17); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;
2. Flutter: 3.27.5-ohos-0.0.2; SDK: 5.0.5(17); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;
3. Flutter: 3.35.7-ohos-0.0.1; SDK: 5.0.5(17); IDE: DevEco Studio: 6.0.1.260; ROM: 6.0.0.120 SP6;

### 2.2 HarmonyOS platform behaviour

1. **File sharing relies on a cache folder**: files are copied into the `share_plus` subfolder of the app cache directory before being shared; **files already located in that folder must not be shared** (to prevent self-copying), otherwise the `share_error` error is returned.
2. **Result tracking scope**: `share`/`shareFiles`/`shareUri` all support result tracking; closing the sheet returns `dismissed`.
3. **Concurrency limit**: only one share operation is allowed at a time; calling again while a share sheet is still open returns the `share_error` error (same anti-deadlock strategy as Android).
4. **Sheet host**: the share sheet requires the current `UIAbility` context; if the plugin is not attached to an ability, the call returns the `share_error` error.

## 3. API

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### SharePlus API (recommended)

| Name                | Description                         | Type     | Input                                                                                                                           | Output  | ohos Support |
|---------------------|-------------------------------------|----------|---------------------------------------------------------------------------------------------------------------------------------|---------|--------------|
| instance            | Default SharePlus singleton bound to the current platform implementation | getter | / | SharePlus | yes |
| share               | Summons the platform share sheet to share text/URI/files per ShareParams | function | (ShareParams params) | Future<ShareResult> | yes |

Usage example:

```dart
final result = await SharePlus.instance.share(
  ShareParams(text: 'text', title: 'title'),
);
```

### Share API (deprecated, kept for compatibility)

| Name                | Description                         | Type     | Input                                                                                                                           | Output  | ohos Support |
|---------------------|-------------------------------------|----------|---------------------------------------------------------------------------------------------------------------------------------|---------|--------------|
| share               | Summons the platform share sheet to share text (optional mail subject) | function | (String text, {String? subject, Rect? sharePositionOrigin}) | Future<ShareResult> | yes |
| shareUri            | Summons the platform share sheet to share a URI | function | (Uri uri, {Rect? sharePositionOrigin}) | Future<ShareResult> | yes |
| shareXFiles         | Summons the platform share sheet to share multiple files (MIME types inferred) | function | (List\<XFile\> files, {String? subject, String? text, Rect? sharePositionOrigin, List\<String\>? fileNameOverrides}) | Future<ShareResult> | yes |
| downloadFallbackEnabled | Whether to fall back to downloading files when sharing fails on web | static property | / | bool | no (web only) |

Usage example:

```dart
await Share.share('text', subject: 'subject');
await Share.shareUri(Uri.parse('https://example.com'));
await Share.shareXFiles([XFile('/path/to/file.png')], text: 'accompanying text');
```

---

## 4. Properties

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### ShareParams Filters

| Name                | Description                         | Type     | ohos Support | Notes |
|---------------------|-------------------------------------|----------|--------------|-------|
| text                | Text to share; mutually exclusive with uri | String? | yes | Can be combined with files |
| title               | Share sheet title | String? | yes | Used as the share record title; falls back to subject |
| subject             | Email subject | String? | yes | Used by mail apps; also the fallback for title |
| uri                 | URI to share; mutually exclusive with text | Uri? | yes | Shared as plain text on HarmonyOS |
| files               | Files to share | List\<XFile\>? | yes | Copied to the cache folder and shared as file:// URIs |
| fileNameOverrides   | Overrides shared file names; length must match files | List\<String\>? | yes | Applied on the Dart side (for XFile.fromData) |
| previewThumbnail    | Preview thumbnail for the share | XFile? | no | Android only; ignored elsewhere |
| sharePositionOrigin | Anchor rect for the share sheet popover | Rect? | no | iPad/Mac only; ignored elsewhere |
| downloadFallbackEnabled | Fall back to download when web sharing fails | bool | no | Web only; ignored elsewhere |
| mailToFallbackEnabled | Fall back to email when web sharing fails | bool | no | Web only; ignored elsewhere |
| excludedCupertinoActivities | Excludes services from the iOS/macOS share sheet | List\<CupertinoActivityType\>? | no | iOS/macOS only; ignored elsewhere |

### ShareResult Filters
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| raw                 | Raw platform return value (empty=dismissed, special value=unavailable) | String | / | / | yes |
| status              | Enum indicating user action (success/dismissed/unavailable) | ShareResultStatus | / | / | yes |

---

### ShareResultStatus Filters
| Name                | Description                         | Type     | Input | Output  | ohos Support |
|---------------------|-------------------------------------|----------|-------|---------|--------------|
| success             | User selected an action             | enum | / | / | yes |
| dismissed           | User dismissed the share sheet      | enum | / | / | yes |
| unavailable         | Status determination not supported  | enum | / | / | yes |

> [!NOTE] On HarmonyOS, `dismissed` is returned when the user closes the share sheet (`share`/`shareFiles`/`shareUri`); `success` is never reported (the sheet only notifies a dismiss event and does not distinguish whether the user completed the share).

---

## 5. Known Issues

## 6. Others

## 7. License

This project is licensed under [The BSD-3-Clause (license)](LICENSE).
