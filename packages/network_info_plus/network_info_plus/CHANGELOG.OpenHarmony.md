## network_info_plus-8.2.1-ohos-1.0.1 - 2026.9

### Added
* Upgrade content ([185](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/pull/185)).
After upgrading the plugin network_info_plus to 8.2.1, the SDK constraints were raised to Dart >=3.10.0 <4.0.0, Flutter >=3.38.1, and it requires win32 >=6.0.1.
example's win32 dependency was upgraded from ^5.5.3 to ^6.4.0 (actually resolved to 6.4.0).
example/lib/network_info_demo.dart: removed the deleted winsock2.dart import; GetAdaptersAddresses was changed to the 4-parameter signature.
test/src/network_info_plus_windows_test.dart: the same two fixes as above; the clientHandle assertion was changed to use isValid (in 6.x, HANDLE is a Pointer-type extension type and cannot be compared with NULL).
test/network_info_plus_windows_test.dart: skip 3 Wi-Fi integration tests when there is no WLAN connection (this machine has no wireless network adapter, which is an environment limitation rather than a code bug).

## network_info_plus-7.0.0-ohos-1.0.1 - 2026.9

### Fixed

* Consistency ([180](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/pull/180)).
Both the ref in the dependency snippet and the "TAG Version Correspondence Table" list a TAG that does not actually exist (with -1.0.1), but the "Change Log" in the same document, the version in ohos/oh-package.json5, and the TAG actually tagged in the repository are all -1.0.0. The version numbers in these four places contradict each other, and users pulling by the documented ref will fail. This is the most prominent inconsistency at present. All -1.0.1 references in the documentation should be unified back to -1.0.0, or it should be confirmed whether a new -1.0.1 TAG is really going to be released.
The Dart public API is uniformly Future<String?>, and across platforms the channel layer is also normalized to string|null or PlatformException, so overall it is consistent. The only deviation is getWifiSubmask: on the ArkTS side the method signature is a non-nullable Promise<string>, but the channel layer returns null when the string is empty — i.e., "non-null signature, actually nullable." The documentation adds a note about this, making it barely self-consistent, but leaves the contradiction for the reader to resolve. No other platform has this problem.

* Memory Leaks ([180](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/pull/180)).
Already fixed; there are currently no leak points. onDetachedFromEngine clears the handler and sets this.channel to null; replyWith / replyWithAsync check whether channel is null before every callback, so after the engine is detached, result.success() / error() are no longer triggered, and the MethodChannel reference will not remain.
NetworkInfo._singleton is a static cache, but it only holds a delegation to NetworkInfoPlatform.instance and has no mutable local state, so it does not constitute a leak. The test cases already reset the platform instance via tearDown.
Other Implementation Modules (Linux/Windows/Web)
They do not hold long-lived resources that need to be manually released, so there is no leak risk.

* Documentation Quality ([180](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/pull/180)).
This is the part of the documentation module that should be fixed first: in addition to the aforementioned phantom -1.0.1 TAG, the existing TAG table has too few columns (only three: "Flutter Framework Version / TAG / Branch"), and the two TAG rows are completely identical, failing to distinguish the upstream network_info_plus version from the OHOS adaptation version, and also omitting the beta/legacy rows, so the comparison information density is insufficient. It is suggested to restore the structure of "TAG / Branch / Upstream Version / Adaptation Version / Status."
Environment Configuration / Return Type Mapping Table / Change Log
These three sections are the main additions to the documentation in this round, and the content is solid: DevEco installation, SDK configuration, ohpm, HAR compilation, flutter run --local-engine, and hvigorw assembleHar are all covered; the Dart↔ArkTS return type mapping table explains how the historical number sentinel was normalized to null; the change log gives key changes such as the channel name spelling fix. The quality is good, so they can be kept as is.
It has been renamed from underscore naming to dot-separated README.OpenHarmony.md, and a package-level documentation index table has been added, so the problem is basically resolved.

* Test Case Coverage ([180](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/pull/180)).
Full enum values, all branches of parseLocationAuthorizationStatus, the abstract platform interface, and the MethodChannel implementation are all covered, with full coverage. No remaining issues.
The normal/empty/null/exception propagation paths of all 7 getters are covered, and tearDown has been added to prevent state leakage. No remaining issues.
By injecting nm (NetworkManager) through a mock, all 7 getters, broadcast address bit operations, and no-connection/empty-data scenarios are fully covered, with coverage close to full; moreover, the tests genuinely exposed the defect that getWifiSubmask/getWifiBroadcast throw TypeError when there is no data, and pinned down the behavior. The only uncovered part is the default createClient factory (requires real D-Bus, unreachable), which is a reasonable omission.
The pure logic formatBssid is covered; for real-time WLAN queries, the handling is "skip if there is no adapter, assert only if there is a value." Due to the limitation that FFI cannot inject a mock without modifying lib/, coverage of the FFI/WLAN call body is limited, which is a structural limitation.
The UnsupportedError behavior of the 3 getters and registerWith are covered, and @TestOn('browser') is automatically excluded on the desktop runner, which is expected.

* Stability ([180](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/pull/180)).
It has been significantly hardened: all critical paths are wrapped in try-catch, exceptions are uniformly converted to PlatformException, ipToInt performs null/segment-count/range validation, and getBroadcastIP has removed the as string assertion. There are no new stability risks.






