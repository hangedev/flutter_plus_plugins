// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package

import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_info_plus_platform_interface/device_info_plus_platform_interface.dart';
import 'package:device_info_plus_platform_interface/method_channel/method_channel_device_info.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// A real [DeviceInfoPlatform] subclass used to drive [DeviceInfoPlugin].
///
/// It must be a genuine subclass (not a mockito mock) because
/// [DeviceInfoPlatform.instance]'s setter calls `PlatformInterface.verifyToken`,
/// which rejects mocks that do not carry the platform-interface token.
class FakeDeviceInfoPlatform extends DeviceInfoPlatform {
  FakeDeviceInfoPlatform(this._result);

  final BaseDeviceInfo _result;
  int callCount = 0;
  bool throwOnce = false;

  @override
  Future<BaseDeviceInfo> deviceInfo() async {
    callCount++;
    if (throwOnce) {
      throwOnce = false;
      throw Exception('platform failure');
    }
    return _result;
  }
}

/// A [DeviceInfoPlatform] that always throws, used to verify error
/// propagation through the plugin getters.
class _ThrowingPlatform extends DeviceInfoPlatform {
  _ThrowingPlatform(this.error);
  final Object error;

  @override
  Future<BaseDeviceInfo> deviceInfo() async => throw error;
}

const _androidMap = <String, dynamic>{
  'model': 'Pixel',
  'board': 'board',
  'bootloader': 'bootloader',
  'brand': 'Google',
  'device': 'device',
  'display': 'display',
  'fingerprint': 'fingerprint',
  'hardware': 'hardware',
  'host': 'host',
  'id': 'id',
  'manufacturer': 'manufacturer',
  'product': 'product',
  'supported32BitAbis': <String>[],
  'supported64BitAbis': <String>[],
  'supportedAbis': <String>['arm64-v8a'],
  'tags': 'tags',
  'type': 'type',
  'isPhysicalDevice': true,
  'systemFeatures': <String>['FEATURE_AUDIO_OUTPUT'],
  'serialNumber': 'SERIAL',
  'version': <String, dynamic>{
    'baseOS': 'baseOS',
    'codename': 'codename',
    'incremental': 'incremental',
    'previewSdkInt': 30,
    'release': 'release',
    'sdkInt': 33,
    'securityPatch': 'securityPatch',
  },
  'displayMetrics': <String, dynamic>{
    'widthPx': 1080.0,
    'heightPx': 2220.0,
    'xDpi': 530.0,
    'yDpi': 529.0,
  },
};

const _iosMap = <String, dynamic>{
  'name': 'name',
  'model': 'model',
  'systemName': 'systemName',
  'systemVersion': 'systemVersion',
  'localizedModel': 'localizedModel',
  'identifierForVendor': 'idfv',
  'isPhysicalDevice': 'true',
  'utsname': <String, dynamic>{
    'sysname': 'sysname',
    'nodename': 'nodename',
    'release': 'release',
    'version': 'version',
    'machine': 'machine',
  },
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
  'productModel': 'ALN-AL00',
  'osFullName': 'OpenHarmony 5.0.0.120',
  'majorVersion': 5,
  'sdkApiVersion': 12,
  'ODID': 'odid-value',
};

final _linuxInfo = LinuxDeviceInfo(
  name: 'Linux',
  id: 'linux',
  prettyName: 'Linux',
  machineId: 'machineId',
);

final _windowsInfo = WindowsDeviceInfo(
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

final _webInfo = WebBrowserInfo(
  appCodeName: 'appCodeName',
  appName: 'appName',
  appVersion: 'appVersion',
  deviceMemory: 8,
  language: 'en',
  languages: ['en'],
  platform: 'platform',
  product: 'product',
  productSub: 'productSub',
  userAgent: 'Mozilla/5.0 Firefox/61.0',
  vendor: 'vendor',
  vendorSub: 'vendorSub',
  hardwareConcurrency: 4,
  maxTouchPoints: 1,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DeviceInfoPlugin plugin;

  setUp(() {
    plugin = DeviceInfoPlugin();
  });

  tearDown(() {
    // Restore the default platform so the global does not leak across files.
    DeviceInfoPlatform.instance = MethodChannelDeviceInfo();
  });

  group('DeviceInfoPlugin getters', () {
    test('androidInfo parses the platform map', () async {
      DeviceInfoPlatform.instance =
          FakeDeviceInfoPlatform(BaseDeviceInfo(_androidMap));
      final info = await plugin.androidInfo;
      expect(info, isA<AndroidDeviceInfo>());
      expect(info.model, 'Pixel');
      expect(info.version.sdkInt, 33);
      expect(info.displayMetrics.widthPx, 1080.0);
    });

    test('iosInfo parses the platform map', () async {
      DeviceInfoPlatform.instance =
          FakeDeviceInfoPlatform(BaseDeviceInfo(_iosMap));
      final info = await plugin.iosInfo;
      expect(info, isA<IosDeviceInfo>());
      expect(info.name, 'name');
      expect(info.isPhysicalDevice, isTrue);
      expect(info.utsname.machine, 'machine');
    });

    test('macOsInfo parses the platform map', () async {
      DeviceInfoPlatform.instance =
          FakeDeviceInfoPlatform(BaseDeviceInfo(_macosMap));
      final info = await plugin.macOsInfo;
      expect(info, isA<MacOsDeviceInfo>());
      expect(info.computerName, 'computerName');
      expect(info.majorVersion, 12);
      expect(info.systemGUID, 'systemGUID');
    });

    test('ohosInfo parses the platform map', () async {
      DeviceInfoPlatform.instance =
          FakeDeviceInfoPlatform(BaseDeviceInfo(_ohosMap));
      final info = await plugin.ohosInfo;
      expect(info, isA<OhosDeviceInfo>());
      expect(info.productModel, 'ALN-AL00');
      expect(info.sdkApiVersion, 12);
      expect(info.odID, 'odid-value');
    });

    test('linuxInfo returns the platform result', () async {
      DeviceInfoPlatform.instance = FakeDeviceInfoPlatform(_linuxInfo);
      final info = await plugin.linuxInfo;
      expect(info, isA<LinuxDeviceInfo>());
      expect(info.name, 'Linux');
      expect(info.machineId, 'machineId');
    });

    test('windowsInfo returns the platform result', () async {
      DeviceInfoPlatform.instance = FakeDeviceInfoPlatform(_windowsInfo);
      final info = await plugin.windowsInfo;
      expect(info, isA<WindowsDeviceInfo>());
      expect(info.computerName, 'computerName');
      expect(info.numberOfCores, 4);
    });

    test('webBrowserInfo returns the platform result', () async {
      DeviceInfoPlatform.instance = FakeDeviceInfoPlatform(_webInfo);
      final info = await plugin.webBrowserInfo;
      expect(info, isA<WebBrowserInfo>());
      expect(info.userAgent, 'Mozilla/5.0 Firefox/61.0');
      expect(info.browserName, BrowserName.firefox);
    });

    test('deviceInfo dispatches to the running platform', () async {
      // deviceInfo() routes by Platform.isX. On the Windows test host it
      // dispatches to windowsInfo, which casts the platform result.
      if (!Platform.isWindows) {
        return; // host-dependent: only asserted on Windows.
      }
      DeviceInfoPlatform.instance = FakeDeviceInfoPlatform(_windowsInfo);
      final result = await plugin.deviceInfo;
      expect(result, isA<BaseDeviceInfo>());
    });
  });

  // The model classes expose deprecated toMap() aliases of data. Cover them so
  // the deprecated members are exercised (the rest of the suite uses `data`).
  group('deprecated toMap() coverage', () {
    test('LinuxDeviceInfo.toMap equals data', () {
      expect(_linuxInfo.toMap(), equals(_linuxInfo.data));
    });

    test('WebBrowserInfo.toMap equals data', () {
      expect(_webInfo.toMap(), equals(_webInfo.data));
    });

    test('WindowsDeviceInfo.toMap equals data', () {
      expect(_windowsInfo.toMap(), equals(_windowsInfo.data));
    });

    test('BaseDeviceInfo.toMap equals data', () {
      final base = BaseDeviceInfo(_androidMap);
      expect(base.toMap(), equals(base.data));
    });
  });

  group('caching', () {
    test('repeated call returns the cached instance and calls platform once',
        () async {
      final fake = FakeDeviceInfoPlatform(BaseDeviceInfo(_androidMap));
      DeviceInfoPlatform.instance = fake;
      final first = await plugin.androidInfo;
      final second = await plugin.androidInfo;
      expect(identical(first, second), isTrue);
      expect(fake.callCount, 1);
    });

    test('concurrent reads settle and a later call is cached', () async {
      final fake = FakeDeviceInfoPlatform(BaseDeviceInfo(_androidMap));
      DeviceInfoPlatform.instance = fake;
      // Fire two reads concurrently; they may both reach the platform, but the
      // cache must end up populated so a subsequent call does not re-invoke.
      await Future.wait([plugin.androidInfo, plugin.androidInfo]);
      final callsBeforeThird = fake.callCount;
      final third = await plugin.androidInfo;
      expect(fake.callCount, callsBeforeThird);
      expect(third.model, 'Pixel');
    });

    test('a thrown result is not cached and is retried', () async {
      final fake = FakeDeviceInfoPlatform(BaseDeviceInfo(_androidMap))
        ..throwOnce = true;
      DeviceInfoPlatform.instance = fake;
      await expectLater(plugin.androidInfo, throwsA(isException));
      // Cache must still be empty -> the next call retries and succeeds.
      final info = await plugin.androidInfo;
      expect(info.model, 'Pixel');
      expect(fake.callCount, 2);
    });
  });

  group('concurrency', () {
    test('many concurrent reads to the same getter all succeed equivalently',
        () async {
      final fake = FakeDeviceInfoPlatform(BaseDeviceInfo(_androidMap));
      DeviceInfoPlatform.instance = fake;
      // Fire many reads before the cache settles. Each concurrent caller may
      // build its own instance, but they must all complete without throwing
      // and carry the same parsed data.
      final results = await Future.wait(
        List.generate(10, (_) => plugin.androidInfo),
      );
      expect(results, hasLength(10));
      expect(results.every((e) => e.model == 'Pixel'), isTrue);
      // After settling, the cache must be populated.
      final callsBeforeExtra = fake.callCount;
      await plugin.androidInfo;
      expect(fake.callCount, callsBeforeExtra);
    });

    test('a cached value survives a later platform error on another getter',
        () async {
      final fake = FakeDeviceInfoPlatform(BaseDeviceInfo(_androidMap));
      DeviceInfoPlatform.instance = fake;
      // First call succeeds and caches androidInfo (no throw armed).
      final android = await plugin.androidInfo;
      expect(android.model, 'Pixel');

      // Arm a failure on the shared platform; iosInfo has no cache yet, so it
      // reaches the platform and throws. androidInfo must NOT be affected.
      fake.throwOnce = true;
      await expectLater(plugin.iosInfo, throwsA(isException));

      // androidInfo returns from cache without touching the platform.
      final cached = await plugin.androidInfo;
      expect(identical(android, cached), isTrue);
      expect(cached.model, 'Pixel');
    });
  });

  group('exception propagation', () {
    test('PlatformException-shaped errors surface to the caller', () async {
      DeviceInfoPlatform.instance =
          _ThrowingPlatform(Exception('getDeviceInfo failed'));
      await expectLater(plugin.androidInfo, throwsA(isException));
    });

    test('repeated failures keep throwing until the platform recovers',
        () async {
      final fake = FakeDeviceInfoPlatform(BaseDeviceInfo(_androidMap));
      DeviceInfoPlatform.instance = fake;
      // Re-arm the one-shot throw before each failing attempt.
      fake.throwOnce = true;
      await expectLater(plugin.androidInfo, throwsA(isException));
      fake.throwOnce = true;
      await expectLater(plugin.androidInfo, throwsA(isException));
      // Now let the platform succeed; the cache must be populated.
      fake.throwOnce = false;
      final ok = await plugin.androidInfo;
      expect(ok.model, 'Pixel');
    });
  });

  group('MethodChannelDeviceInfo (MethodChannel mock)', () {
    const channelName = 'dev.fluttercommunity.plus/device_info';
    MethodCall? capturedCall;

    setUp(() {
      capturedCall = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel(channelName),
        (MethodCall call) async {
          capturedCall = call;
          return <String, dynamic>{'model': 'Pixel'};
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel(channelName), null);
    });

    test('invokes getDeviceInfo and wraps the map in a BaseDeviceInfo',
        () async {
      // A fresh instance uses the default channel name above.
      final result = await MethodChannelDeviceInfo().deviceInfo();

      expect(result, isA<BaseDeviceInfo>());
      expect(result.data, {'model': 'Pixel'});
      expect(capturedCall, isNotNull);
      expect(capturedCall!.method, 'getDeviceInfo');
    });
  });
}
