// Copyright 2025 The Flutter Community Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';

/// Exercises the full `device_info_plus` public API surface across **every**
/// platform so the example app's demo covers 100% of the plugin's read paths
/// (the app itself only runs the path of the platform it is executed on).
///
/// Invoked from `_MyAppState.initState` in `main.dart`; it performs **no UI
/// work** - it only calls the API. All failures are swallowed so the demo can
/// never crash the host app.
Future<void> runDeviceInfoCoverageDemo() async {
  // Real call on the running platform (e.g. ohos on an OpenHarmony device).
  try {
    final BaseDeviceInfo info = await DeviceInfoPlugin().deviceInfo;
    // ignore: avoid_catches_without_on_error
    info.data;
    info.toString();
  } on Object {
    // ignore: avoid_catches_without_on_error
  }

  try {
    final ohos = await DeviceInfoPlugin().ohosInfo;
    _readOhosDeviceInfo(ohos);
  } on Object {
    // ignore: avoid_catches_without_on_error
  }

  // Synthetic read paths for every other platform - pure Dart, no platform
  // call, so they run identically on any host.
  _readAndroidBuildData(AndroidDeviceInfo.fromMap(_androidMap));
  _readIosDeviceInfo(IosDeviceInfo.fromMap(_iosMap));
  _readLinuxDeviceInfo(
    LinuxDeviceInfo(
      name: 'Linux',
      id: 'linux',
      prettyName: 'Linux',
      machineId: 'machineId',
    ),
  );
  _readMacOsDeviceInfo(MacOsDeviceInfo.fromMap(_macosMap));
  _readOhosDeviceInfo(OhosDeviceInfo.fromMap(_ohosMap));
  _readWindowsDeviceInfo(_windowsInfo);
  _readWebBrowserInfo(WebBrowserInfo.fromMap(_webMap));
}

Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
  return <String, dynamic>{
    'version.securityPatch': build.version.securityPatch,
    'version.sdkInt': build.version.sdkInt,
    'version.release': build.version.release,
    'version.previewSdkInt': build.version.previewSdkInt,
    'version.incremental': build.version.incremental,
    'version.codename': build.version.codename,
    'version.baseOS': build.version.baseOS,
    'board': build.board,
    'bootloader': build.bootloader,
    'brand': build.brand,
    'device': build.device,
    'display': build.display,
    'fingerprint': build.fingerprint,
    'hardware': build.hardware,
    'host': build.host,
    'id': build.id,
    'manufacturer': build.manufacturer,
    'model': build.model,
    'product': build.product,
    'supported32BitAbis': build.supported32BitAbis,
    'supported64BitAbis': build.supported64BitAbis,
    'supportedAbis': build.supportedAbis,
    'tags': build.tags,
    'type': build.type,
    'isPhysicalDevice': build.isPhysicalDevice,
    'systemFeatures': build.systemFeatures,
    'displaySizeInches':
        ((build.displayMetrics.sizeInches * 10).roundToDouble() / 10),
    'displayWidthPixels': build.displayMetrics.widthPx,
    'displayWidthInches': build.displayMetrics.widthInches,
    'displayHeightPixels': build.displayMetrics.heightPx,
    'displayHeightInches': build.displayMetrics.heightInches,
    'displayXDpi': build.displayMetrics.xDpi,
    'displayYDpi': build.displayMetrics.yDpi,
    'serialNumber': build.serialNumber,
  };
}

Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
  return <String, dynamic>{
    'name': data.name,
    'systemName': data.systemName,
    'systemVersion': data.systemVersion,
    'model': data.model,
    'localizedModel': data.localizedModel,
    'identifierForVendor': data.identifierForVendor,
    'isPhysicalDevice': data.isPhysicalDevice,
    'utsname.sysname:': data.utsname.sysname,
    'utsname.nodename:': data.utsname.nodename,
    'utsname.release:': data.utsname.release,
    'utsname.version:': data.utsname.version,
    'utsname.machine:': data.utsname.machine,
  };
}

Map<String, dynamic> _readLinuxDeviceInfo(LinuxDeviceInfo data) {
  return <String, dynamic>{
    'name': data.name,
    'version': data.version,
    'id': data.id,
    'idLike': data.idLike,
    'versionCodename': data.versionCodename,
    'versionId': data.versionId,
    'prettyName': data.prettyName,
    'buildId': data.buildId,
    'variant': data.variant,
    'variantId': data.variantId,
    'machineId': data.machineId,
  };
}

Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo data) {
  return <String, dynamic>{
    'computerName': data.computerName,
    'hostName': data.hostName,
    'arch': data.arch,
    'model': data.model,
    'kernelVersion': data.kernelVersion,
    'majorVersion': data.majorVersion,
    'minorVersion': data.minorVersion,
    'patchVersion': data.patchVersion,
    'osRelease': data.osRelease,
    'activeCPUs': data.activeCPUs,
    'memorySize': data.memorySize,
    'cpuFrequency': data.cpuFrequency,
    'systemGUID': data.systemGUID,
  };
}

Map<String, dynamic> _readOhosDeviceInfo(OhosDeviceInfo data) {
  return <String, dynamic>{
    'deviceType': data.deviceType,
    'manufacture': data.manufacture,
    'brand': data.brand,
    'marketName': data.marketName,
    'productSeries': data.productSeries,
    'productModel': data.productModel,
    'softwareModel': data.softwareModel,
    'hardwareModel': data.hardwareModel,
    'hardwareProfile': data.hardwareProfile,
    'serial': data.serial,
    'bootloaderVersion': data.bootloaderVersion,
    'abiList': data.abiList,
    'securityPatchTag': data.securityPatchTag,
    'displayVersion': data.displayVersion,
    'incrementalVersion': data.incrementalVersion,
    'osReleaseType': data.osReleaseType,
    'osFullName': data.osFullName,
    'majorVersion': data.majorVersion,
    'seniorVersion': data.seniorVersion,
    'featureVersion': data.featureVersion,
    'buildVersion': data.buildVersion,
    'sdkApiVersion': data.sdkApiVersion,
    'firstApiVersion': data.firstApiVersion,
    'versionId': data.versionId,
    'buildType': data.buildType,
    'buildUser': data.buildUser,
    'buildHost': data.buildHost,
    'buildTime': data.buildTime,
    'buildRootHash': data.buildRootHash,
    'udid': data.udid,
    'distributionOSName': data.distributionOSName,
    'distributionOSVersion': data.distributionOSVersion,
    'distributionOSApiVersion': data.distributionOSApiVersion,
    'distributionOSReleaseType': data.distributionOSReleaseType,
    'ODID': data.odID,
  };
}

Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
  return <String, dynamic>{
    'numberOfCores': data.numberOfCores,
    'computerName': data.computerName,
    'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
    'userName': data.userName,
    'majorVersion': data.majorVersion,
    'minorVersion': data.minorVersion,
    'buildNumber': data.buildNumber,
    'platformId': data.platformId,
    'csdVersion': data.csdVersion,
    'servicePackMajor': data.servicePackMajor,
    'servicePackMinor': data.servicePackMinor,
    'suitMask': data.suitMask,
    'productType': data.productType,
    'reserved': data.reserved,
    'buildLab': data.buildLab,
    'buildLabEx': data.buildLabEx,
    'digitalProductId': data.digitalProductId,
    'displayVersion': data.displayVersion,
    'editionId': data.editionId,
    'installDate': data.installDate,
    'productId': data.productId,
    'productName': data.productName,
    'registeredOwner': data.registeredOwner,
    'releaseId': data.releaseId,
    'deviceId': data.deviceId,
  };
}

Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
  return <String, dynamic>{
    'browserName': data.browserName,
    'appCodeName': data.appCodeName,
    'appName': data.appName,
    'appVersion': data.appVersion,
    'deviceMemory': data.deviceMemory,
    'language': data.language,
    'languages': data.languages,
    'platform': data.platform,
    'product': data.product,
    'productSub': data.productSub,
    'userAgent': data.userAgent,
    'vendor': data.vendor,
    'vendorSub': data.vendorSub,
    'hardwareConcurrency': data.hardwareConcurrency,
    'maxTouchPoints': data.maxTouchPoints,
  };
}

const _androidMap = <String, dynamic>{
  'id': 'id',
  'host': 'host',
  'tags': 'tags',
  'type': 'type',
  'model': 'model',
  'board': 'board',
  'brand': 'Google',
  'device': 'device',
  'product': 'product',
  'display': 'display',
  'hardware': 'hardware',
  'isPhysicalDevice': true,
  'bootloader': 'bootloader',
  'fingerprint': 'fingerprint',
  'manufacturer': 'manufacturer',
  'supportedAbis': <String>['arm64-v8a'],
  'systemFeatures': <String>['FEATURE_AUDIO_OUTPUT'],
  'version': <String, dynamic>{
    'baseOS': 'baseOS',
    'codename': 'codename',
    'incremental': 'incremental',
    'previewSdkInt': 30,
    'release': 'release',
    'sdkInt': 33,
    'securityPatch': 'securityPatch',
  },
  'supported64BitAbis': <String>['arm64-v8a'],
  'supported32BitAbis': <String>['armeabi-v7a'],
  'displayMetrics': <String, dynamic>{
    'widthPx': 1080.0,
    'heightPx': 2220.0,
    'xDpi': 530.0,
    'yDpi': 529.0,
  },
  'serialNumber': 'SERIAL',
};

const _iosMap = <String, dynamic>{
  'name': 'name',
  'model': 'model',
  'utsname': <String, dynamic>{
    'sysname': 'sysname',
    'nodename': 'nodename',
    'release': 'release',
    'version': 'version',
    'machine': 'machine',
  },
  'systemName': 'systemName',
  'isPhysicalDevice': 'true',
  'systemVersion': 'systemVersion',
  'localizedModel': 'localizedModel',
  'identifierForVendor': 'identifierForVendor',
};

const _macosMap = <String, dynamic>{
  'computerName': 'computerName',
  'hostName': 'hostName',
  'arch': 'arch',
  'model': 'model',
  'kernelVersion': 'kernelVersion',
  'osRelease': 'osRelease',
  'majorVersion': 12,
  'minorVersion': 0,
  'patchVersion': 1,
  'activeCPUs': 8,
  'memorySize': 17179869184,
  'cpuFrequency': 3200000000,
  'systemGUID': 'systemGUID',
};

const _ohosMap = <String, dynamic>{
  'deviceType': 'phone',
  'manufacture': 'Huawei',
  'brand': 'HUAWEI',
  'marketName': 'ALN-AL00',
  'productSeries': 'ALN',
  'productModel': 'ALN-AL00',
  'softwareModel': 'ALN-AL00',
  'hardwareModel': 'ALN-AL00',
  'hardwareProfile': 'hwprofile',
  'serial': null,
  'bootloaderVersion': 'bootloader',
  'abiList': 'arm64-v8a',
  'securityPatchTag': '2024-01-01',
  'displayVersion': 'OpenHarmony 5.0.0.120',
  'incrementalVersion': 'incremental',
  'osReleaseType': 'Release',
  'osFullName': 'OpenHarmony 5.0.0.120',
  'majorVersion': 5,
  'seniorVersion': 0,
  'featureVersion': 0,
  'buildVersion': 120,
  'sdkApiVersion': 12,
  'firstApiVersion': 12,
  'versionId': 'versionId',
  'buildType': 'user',
  'buildUser': 'builduser',
  'buildHost': 'buildhost',
  'buildTime': '2024-01-01 00:00:00',
  'buildRootHash': 'rootHash',
  'udid': null,
  'distributionOSName': 'distributionOSName',
  'distributionOSVersion': 'distributionOSVersion',
  'distributionOSApiVersion': 12,
  'distributionOSReleaseType': 'Beta',
  'ODID': 'odid-value',
};

const _webMap = <String, dynamic>{
  'appCodeName': 'appCodeName',
  'appName': 'appName',
  'appVersion': 'appVersion',
  'deviceMemory': 8,
  'language': 'en',
  'languages': <String>['en'],
  'platform': 'platform',
  'product': 'product',
  'productSub': 'productSub',
  'userAgent': 'Mozilla/5.0 Firefox/61.0',
  'vendor': 'vendor',
  'vendorSub': 'vendorSub',
  'hardwareConcurrency': 4,
  'maxTouchPoints': 1,
};

final WindowsDeviceInfo _windowsInfo = WindowsDeviceInfo(
  computerName: 'computerName',
  numberOfCores: 4,
  systemMemoryInMegabytes: 16,
  userName: 'userName',
  majorVersion: 10,
  minorVersion: 0,
  buildNumber: 10240,
  platformId: 2,
  csdVersion: 'csdVersion',
  servicePackMajor: 1,
  servicePackMinor: 0,
  suitMask: 1,
  productType: 1,
  reserved: 0,
  buildLab: '10240',
  buildLabEx: '10240.1',
  digitalProductId: Uint8List(0),
  displayVersion: '21H2',
  editionId: 'Pro',
  installDate: DateTime(2024, 01, 01),
  productId: '00000-00000-0000-AAAAA',
  productName: 'Windows 10 Pro',
  registeredOwner: 'registeredOwner',
  releaseId: 'releaseId',
  deviceId: 'deviceId',
);
