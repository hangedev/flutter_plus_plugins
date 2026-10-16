## package_info_plus-10.2.1-ohos-1.0.0 - 2026.10

### Added

* Add unit tests for the OHOS plugin.([201](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/pull/201)).
* Versions and Dependencies ([191](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/pull/191)).
Main package 9.0.0 → 10.2.1, platform interface package 3.2.1 → 4.1.0
Higher environment requirements: Dart ≥3.10, Flutter ≥3.38.1
Key dependency upgrades: win32 5.x → 6.0.x (breaking), http ^1.6.0, web ^1.1.1, with meta/path/ffi etc. upgraded to the latest in sync

* Platform Adaptation ([191](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/pull/191)).
Android: Gradle scripts migrated from Groovy to Kotlin DSL (build.gradle → build.gradle.kts), support for built-in Kotlin, removal of the old gradle-wrapper
iOS/macOS: SPM configuration adapted to Flutter 3.44, raising the minimum version requirements for Apple platforms (iOS 13 / macOS 10.15)
Windows: FFI code such as file_attribute.dart and file_version_info.dart adapted to the win32 6.0 API


## package_info_plus-9.0.0-ohos-1.0.1

### Fixed

* Fix inconsistencies between README.OpenHarmony.md / README.OpenHarmony_CN.md API documentation and source code:
  - Correct installTime/updateTime type from String to DateTime?
  - Supplement baseUrl parameter description in fromPlatform signature
* Add usage instructions and three annotated code examples (basic info, OpenHarmony install/update time, data serialization); unify Chinese table column names to Chinese in CN version
* Strengthen unit test quality: supplement API/plugin/channel/exception-path tests per documentation; add exception, boundary, and concurrency scenarios; optimize test independence and repeatability (42 test cases all passed)
* Add example demo for full API calls (package_info_api_demo.dart)

## package_info_plus-9.0.0-ohos-1.0.0

* TAG package_info_plus-9.0.0-ohos-1.0.0
