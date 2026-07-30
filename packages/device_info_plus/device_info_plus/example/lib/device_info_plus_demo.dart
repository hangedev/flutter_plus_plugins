// Demo that exercises the otherwise-uncovered OpenHarmony (Ohos) and Web APIs
// of device_info_plus. Run via [runDeviceInfoPlusDemo], which is called from
// `main.dart`'s `initPlatformState()` so its results merge into the existing
// `_deviceData` ListView at startup.
//
// Coverage:
// - OhosDeviceInfo.fromMap() / .toJson() / all 34 fields,
// - OhosAccessUDIDInfo.fromMap() / .toJson() / serial / udid,
// - DeviceInfoPlugin.ohosAccessUDIDInfo getter,
// - DeviceInfoPlusWebPlugin (registerWith / constructor / deviceInfo), via the
//   conditionally-imported web_plugin_demo library below.
//
// BaseDeviceInfo.toMap() is intentionally exercised (it is a deprecated alias
// of .data, but still part of the public API); suppress that single lint here.
// BaseDeviceInfo lives in the device_info_plus_platform_interface package, so
// the deprecation surfaces as `deprecated_member_use` (cross-package).
// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
// OhosDeviceInfo / OhosAccessUDIDInfo are not exported from the public API,
// so the example must reach into the model source directly.
// ignore: implementation_imports
import 'package:device_info_plus/src/model/ohos_device_info.dart';

// The web-plugin demo can only compile on the web (it imports dart:js_interop /
// package:web). Default to the non-web stub; use the web impl when
// dart.library.js_interop is available. Mirrors the package's own conditional
// export pattern.
import 'web_plugin_demo_stub.dart'
    if (dart.library.js_interop) 'web_plugin_demo_web.dart';

/// Runs the full device_info_plus Ohos + Web demo.
///
/// Returns a map of `demo.*` rows suitable for merging into the example app's
/// `_deviceData` ListView. Every section is self-contained and resilient to
/// platform/permission failures (errors are captured as row values rather than
/// propagated, so a single failing getter cannot blank the whole demo).
Future<Map<String, dynamic>> runDeviceInfoPlusDemo() async {
  final results = <String, dynamic>{};

  results.addAll(_demoOhosDeviceInfo());
  results.addAll(_demoOhosAccessUDIDInfoFromMap());
  results.addAll(_demoBaseDeviceInfo());
  await _demoOhosAccessUDIDInfoGetter(results);
  results.addAll(await runWebPluginDemo());

  return results;
}

/// Exercises the [BaseDeviceInfo] surface that the other sections leave out:
/// the `.data` getter, the legacy `toMap()` (kept as a deprecated alias of
/// `data`), and `toString()`. Built from a synthetic map so it is device- and
/// platform-independent.
Map<String, dynamic> _demoBaseDeviceInfo() {
  const data = <String, dynamic>{
    'base.key': 'base-value',
    'base.count': 2,
  };
  final info = BaseDeviceInfo(data);

  return <String, dynamic>{
    'demo.base.data.sameMap': identical(info.data, data),
    // toMap() is @Deprecated in favour of .data, but it is part of the public
    // API and must keep returning the underlying map — exercise it here.
    'demo.base.toMap.sameMap': identical(info.toMap(), data),
    'demo.base.toString.containsClass':
        info.toString().contains('BaseDeviceInfo'),
  };
}

/// Exercises [OhosDeviceInfo.fromMap], every field, and [OhosDeviceInfo.toJson]
/// (round-trip + key count). Uses a synthetic sample map so it succeeds on
/// every platform, independent of any device.
Map<String, dynamic> _demoOhosDeviceInfo() {
  final sample = <String, dynamic>{
    // String fields
    'deviceType': 'DEMO-phone',
    'manufacture': 'DEMO-manufacture',
    'brand': 'DEMO-brand',
    'marketName': 'DEMO-marketName',
    'productSeries': 'DEMO-productSeries',
    'productModel': 'DEMO-productModel',
    'softwareModel': 'DEMO-softwareModel',
    'hardwareModel': 'DEMO-hardwareModel',
    'bootloaderVersion': 'DEMO-bootloaderVersion',
    'abiList': 'DEMO-abiList',
    'securityPatchTag': 'DEMO-securityPatchTag',
    'displayVersion': 'DEMO-displayVersion',
    'incrementalVersion': 'DEMO-incrementalVersion',
    'osReleaseType': 'DEMO-osReleaseType',
    'osFullName': 'DEMO-osFullName',
    'versionId': 'DEMO-versionId',
    'buildType': 'DEMO-buildType',
    'buildUser': 'DEMO-buildUser',
    'buildHost': 'DEMO-buildHost',
    'buildTime': 'DEMO-buildTime',
    'buildRootHash': 'DEMO-buildRootHash',
    'distributionOSName': 'DEMO-distributionOSName',
    'distributionOSVersion': 'DEMO-distributionOSVersion',
    'distributionOSReleaseType': 'DEMO-distributionOSReleaseType',
    // int fields
    'majorVersion': 5,
    'seniorVersion': 0,
    'featureVersion': 1,
    'buildVersion': 99,
    'sdkApiVersion': 12,
    'firstApiVersion': 9,
    'distributionOSApiVersion': 12,
    // bool field
    'isPhysicalDevice': true,
  };

  final info = OhosDeviceInfo.fromMap(sample);

  final out = <String, dynamic>{
    // --- fromMap: all 34 fields (raw values; renderer stringifies) ---
    'demo.ohos.fromMap.deviceType': info.deviceType,
    'demo.ohos.fromMap.manufacture': info.manufacture,
    'demo.ohos.fromMap.brand': info.brand,
    'demo.ohos.fromMap.marketName': info.marketName,
    'demo.ohos.fromMap.productSeries': info.productSeries,
    'demo.ohos.fromMap.productModel': info.productModel,
    'demo.ohos.fromMap.softwareModel': info.softwareModel,
    'demo.ohos.fromMap.hardwareModel': info.hardwareModel,
    'demo.ohos.fromMap.bootloaderVersion': info.bootloaderVersion,
    'demo.ohos.fromMap.abiList': info.abiList,
    'demo.ohos.fromMap.securityPatchTag': info.securityPatchTag,
    'demo.ohos.fromMap.displayVersion': info.displayVersion,
    'demo.ohos.fromMap.incrementalVersion': info.incrementalVersion,
    'demo.ohos.fromMap.osReleaseType': info.osReleaseType,
    'demo.ohos.fromMap.osFullName': info.osFullName,
    'demo.ohos.fromMap.majorVersion': info.majorVersion,
    'demo.ohos.fromMap.seniorVersion': info.seniorVersion,
    'demo.ohos.fromMap.featureVersion': info.featureVersion,
    'demo.ohos.fromMap.buildVersion': info.buildVersion,
    'demo.ohos.fromMap.sdkApiVersion': info.sdkApiVersion,
    'demo.ohos.fromMap.firstApiVersion': info.firstApiVersion,
    'demo.ohos.fromMap.versionId': info.versionId,
    'demo.ohos.fromMap.buildType': info.buildType,
    'demo.ohos.fromMap.buildUser': info.buildUser,
    'demo.ohos.fromMap.buildHost': info.buildHost,
    'demo.ohos.fromMap.buildTime': info.buildTime,
    'demo.ohos.fromMap.buildRootHash': info.buildRootHash,
    'demo.ohos.fromMap.distributionOSName': info.distributionOSName,
    'demo.ohos.fromMap.distributionOSVersion': info.distributionOSVersion,
    'demo.ohos.fromMap.distributionOSApiVersion': info.distributionOSApiVersion,
    'demo.ohos.fromMap.distributionOSReleaseType':
        info.distributionOSReleaseType,
    'demo.ohos.fromMap.isPhysicalDevice': info.isPhysicalDevice,

    // --- Type proof: confirm int/bool fields keep their runtime type ---
    'demo.ohos.type.majorVersion': info.majorVersion.runtimeType.toString(),
    'demo.ohos.type.isPhysicalDevice':
        info.isPhysicalDevice.runtimeType.toString(),
  };

  // --- toJson round-trip ---
  final json = info.toJson();
  final rt = OhosDeviceInfo.fromMap(json);
  // BaseDeviceInfo has no value equality, so compare representative fields
  // across string / int / bool types rather than using ==.
  final roundTripOk = rt.productModel == info.productModel &&
      rt.sdkApiVersion == info.sdkApiVersion &&
      rt.isPhysicalDevice == info.isPhysicalDevice &&
      rt.osFullName == info.osFullName;
  out['demo.ohos.toJson.roundTripOk'] = roundTripOk;
  out['demo.ohos.toJson.keyCount'] = json.length; // expect 34

  return out;
}

/// Exercises [OhosAccessUDIDInfo.fromMap], `.serial`, `.udid`, and `.toJson()`.
Map<String, dynamic> _demoOhosAccessUDIDInfoFromMap() {
  final sample = <String, dynamic>{
    'serial': 'DEMO-SERIAL',
    'udid': 'DEMO-UDID',
  };

  final info = OhosAccessUDIDInfo.fromMap(sample);
  final json = info.toJson();

  return <String, dynamic>{
    'demo.udid.fromMap.serial': info.serial,
    'demo.udid.fromMap.udid': info.udid,
    'demo.udid.toJson.serial': json['serial'],
    'demo.udid.toJson.udid': json['udid'],
  };
}

/// Exercises the real [DeviceInfoPlugin.ohosAccessUDIDInfo] getter.
///
/// This getter requires the system-app-only permission
/// `ohos.permission.sec.ACCESS_UDID`, which the example app does NOT request,
/// so it is expected to throw on a real Ohos device (and on all non-Ohos
/// platforms). The error is captured as a row value.
Future<void> _demoOhosAccessUDIDInfoGetter(Map<String, dynamic> results) async {
  try {
    final real = await DeviceInfoPlugin().ohosAccessUDIDInfo;
    results['demo.udid.getter.serial'] = real.serial;
    results['demo.udid.getter.udid'] = real.udid;
  } catch (e) {
    results['demo.udid.getter.error'] = e.toString();
  }
}
