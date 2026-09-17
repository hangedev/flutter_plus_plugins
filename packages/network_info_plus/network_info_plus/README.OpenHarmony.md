<p align="center">
  <h1 align="center"> <code>network_info_plus</code> </h1>
</p>

This project is based on [network_info_plus](https://pub.dev/packages/network_info_plus), adapted for the OpenHarmony / HarmonyOS (ohos) platform.

## 1. Installation and Usage

### 1.1 Installation

Add the following dependency in pubspec.yaml:

<!-- tabs:start -->

#### pubspec.yaml

```yaml
dependencies:
  network_info_plus:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
      path: packages/network_info_plus/network_info_plus
      # ref: network_info_plus-7.0.0-ohos-1.0.1
      ref: TAG   # Please select the TAG to the TAG Version Mapping
```

Run:

```bash
flutter pub get
```

<!-- tabs:end -->

> **Note** Depend on **`network_info_plus`** (not a separate
> `network_info_plus_ohos` package). The ohos implementation ships inside the
> main package under `ohos/` and is auto-registered through the
> `flutter.plugin.platforms.ohos` entry in `pubspec.yaml`.

### 1.2 Quick start (runnable snippet)

```dart
import 'package:network_info_plus/network_info_plus.dart';

final info = NetworkInfo();

Future<void> readNetworkInfo() async {
  // Every getter is nullable: it returns null when there is no Wi-Fi
  // connection / no value, and throws PlatformException when the underlying
  // OHOS API fails (e.g. permission denied).
  final name      = await info.getWifiName();      // SSID,  e.g. "HomeWifi"
  final bssid     = await info.getWifiBSSID();     // BSSID, e.g. "aa:bb:cc:dd:ee:ff"
  final ipv4      = await info.getWifiIP();        // IPv4,  e.g. "192.168.1.5"
  final ipv6      = await info.getWifiIPv6();      // IPv6,  e.g. "2001:db8::1"
  final submask   = await info.getWifiSubmask();   // mask,  e.g. "255.255.255.0"
  final gateway   = await info.getWifiGatewayIP(); // gw,    e.g. "192.168.1.1"
  final broadcast = await info.getWifiBroadcast(); // bcast, e.g. "192.168.1.255"
}
```

For a complete runnable app see [example/lib/main.dart](example/lib/main.dart)
and the headless full-API demo at
[example/lib/network_info_demo.dart](example/lib/network_info_demo.dart).

### 1.3 Usage

See the example project under [ohos/example](example/).

## 2. Constraints

### 2.1 TAG Version Mapping

| Flutter framework version | TAG name | Branch |
| --- | --- | --- |
| 3.41 | network_info_plus-8.2.1-ohos-1.0.1 | br_3.41 |
| 3.44 | network_info_plus-8.2.1-ohos-1.0.1 | br_3.41 |

### 2.2 Compatibility

This document is verified based on the following versions:

1. Flutter: 3.41.10-ohos-0.0.1; SDK: 5.0.5(17); IDE: DevEco Studio: 6.1.0.830; ROM: 6.23.0.100 SP6;
2. Flutter: 3.44.9+ohos-0.0.1-canary1; SDK: 5.0.5(17); IDE: DevEco Studio 26.0.0 Beta2; ROM: 6.23.0.100 SP6;

### 2.3 Permission requirements

#### 2.3.1 Add permissions to `module.json5`

The plugin reads Wi-Fi information from the system, which requires the
`ohos.permission.GET_WIFI_INFO` permission. Open `entry/src/main/module.json5`
and add it under `requestPermissions`:

```diff
...
"module": {
  ...
  "requestPermissions": [
+   {
+     "name": "ohos.permission.GET_WIFI_INFO",
+     "reason": "$string:reason_get_wifi_info",
+     "usedScene": {
+       "abilities": [ "EntryAbility" ],
+       "when": "always"
+     }
+   }
  ]
}
```

> `GET_WIFI_INFO` is a `normal`-level permission granted at install time — no
> runtime dialog is needed. If your app also opens sockets, keep
> `ohos.permission.INTERNET` as well (the example app declares both).

## 3. OHOS Environment Setup

This section covers the host toolchain needed to build and run the plugin on an
OpenHarmony / HarmonyOS device or emulator.

### 3.1 Install DevEco Studio

1. Download **DevEco Studio** matching one of the verified versions above
   (e.g. 5.1.0.828 or 6.0.1.260) from the official HarmonyOS developer site.
2. On first launch, DevEco installs the HarmonyOS **SDK** and **command-line
   tools**. In *File → Project Structure → Project SDKs*, confirm an
   **HarmonyOS SDK** with `compatibleSdkVersion` ≥ `5.0.0(12)` is configured.
3. Install the **ohpm** (OpenHarmony Package Manager) CLI that ships with
   DevEco; it is used to resolve the `ohos/oh-package.json5` dependencies.

### 3.2 Install the ohos-aware Flutter SDK

Use a Flutter SDK from the CPF-Flutter fork that supports ohos targets
(e.g. `3.27.5-ohos-0.0.1` or `3.35.7-ohos-0.0.1`). Verify with:

```bash
flutter --version        # must show an "-ohos-" build
flutter doctor           # DevEco/ohpm should be detected
```

### 3.3 Build the HAR / run the example

The plugin's native side is compiled into a **HAR** (`network_info_plus.har`)
by the ohos build when you build the host app — there is normally no need to
build the HAR by hand. To build and run the example app on a connected device
or emulator:

```bash
cd example
flutter pub get
flutter run -d <device-id>            # -d entry-hap / hdc device id
```

If you need a custom engine (e.g. an unreleased Flutter ohos engine), pass it
explicitly:

```bash
flutter run --local-engine-src-path <engine-src> --local-engine=ohos_arm64
```

To produce the HAR for the plugin itself (for consumption by a non-Flutter
HarmonyOS app or local inspection), open the `ohos/` module in DevEco Studio
and run **Build → Build Hap(s)/APP(s) → Build Hap(s)**, or from the CLI:

```bash
cd ohos
hvigorw --mode module -p module=network_info_plus@default assembleHar
```

## 4. API

> [!TIP] If the value of **ohos Support** is **yes**, the ohos platform supports
> this method; **no** means not supported; **partially** means some capabilities
> are supported. The Dart-side usage is identical across platforms and behaves
> like the iOS / Android implementation.

### 4.1 NetworkInfo API

| Name | Description | Input | Output (Dart) | ohos Support |
|------|-------------|-------|---------------|--------------|
| `getWifiName()` | SSID of the connected network | / | `Future<String?>` | yes |
| `getWifiBSSID()` | BSSID of the connected network | / | `Future<String?>` | yes |
| `getWifiIP()` | IPv4 address of the connected Wi-Fi | / | `Future<String?>` | yes |
| `getWifiIPv6()` | IPv6 address of the connected Wi-Fi | / | `Future<String?>` | yes |
| `getWifiSubmask()` | Subnet mask of the connected Wi-Fi | / | `Future<String?>` | yes |
| `getWifiGatewayIP()` | Gateway IP address of the connected Wi-Fi | / | `Future<String?>` | yes |
| `getWifiBroadcast()` | Broadcast address of the connected Wi-Fi | / | `Future<String?>` | yes |

### 4.2 Return-type mapping (Dart ↔ ArkTS)

The public Dart API always returns `Future<String?>`, but the ArkTS (ohos)
implementation layer uses different concrete types. This table documents how
the two layers map, so you know exactly what crosses the MethodChannel:

| Method | Dart (public API) | ArkTS implementation (ohos) | Sent over MethodChannel as |
|--------|-------------------|------------------------------|----------------------------|
| `getWifiName` | `Future<String?>` | `Promise<string>` | `result.success(string \| null)` |
| `getWifiBSSID` | `Future<String?>` | `Promise<string>` | `result.success(string \| null)` |
| `getWifiIP` | `Future<String?>` | `string \| null` | `result.success(string \| null)` |
| `getWifiBroadcast` | `Future<String?>` | `string \| null` | `result.success(string \| null)` |
| `getWifiSubmask` | `Future<String?>` | `string` (`''` when none) | `result.success(string \| null)` |
| `getWifiGatewayIP` | `Future<String?>` | `string \| null` | `result.success(string \| null)` |
| `getWifiIPv6` | `Future<String?>` | `string \| null` | `result.success(string \| null)` |
| *(any, on failure)* | throws `PlatformException` | throws in ArkTS | `result.error("network_info_error", …)` |

**Key points:**

- **Nullable everywhere on Dart.** A method resolves to `null` when there is no
  connected Wi-Fi or no value for that field; it **throws** `PlatformException`
  (error code `network_info_error`) when the underlying OHOS API fails (e.g.
  permission denied, WiFi service unavailable).
- **No `number` reaches Dart.** Earlier adapters used a numeric sentinel
  (`0`) internally (the historical `Promise<string|number|null>`). The current
  adapter normalizes any falsy value to `null` before it crosses the channel,
  so the Dart side observes only `String?` or a `PlatformException`.
- **`getWifiSubmask`** returns `''` on the ohos side when there is no mask; it
  is forwarded as `null` to Dart for a consistent nullable contract.

## 5. Known Issues

- On emulators, `getWifiName` / `getWifiBSSID` may return `null` (the SSID is
  unavailable without a real Wi-Fi association), matching the iOS/Android
  emulator behavior.
- IPv6 (`getWifiIPv6`) is only populated when the device has an IPv6 link-local
  or global address assigned.

## 6. Others

### 6.1 Changelog

- **7.0.0-ohos-1.0.0** — Aligns with upstream `network_info_plus` 7.0.0;
  supports Flutter ohos 3.27.5 / 3.35.7. Native errors are now propagated as
  `PlatformException` (code `network_info_error`); channel name and error
  handling hardened. Fixes a `network_inf` → `network_info` channel-name typo
  that prevented Flutter ↔ ohos communication.
- **7.0.0-ohos-1.0.0-beta.1** — Initial v7 ohos beta.
- **4.1.0-ohos-1.0.0** — First ohos adaptation, based on upstream 4.1.0.

## 7. License

This project is licensed under [The BSD-3-Clause license](LICENSE).
