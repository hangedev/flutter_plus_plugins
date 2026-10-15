/*
 * Copyright (C) 2026 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { describe, it, expect } from '@ohos/hypium';
import DeviceInfoPlusPlugin from '../../../main/ets/components/plugin/DeviceInfoPlusPlugin';
import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
import { FlutterPluginBinding } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import HashMap from '@ohos.util.HashMap';
import { MockMethodResult, MockBinaryMessenger, MockFlutterPluginBinding } from './TestMocks';

const CHANNEL_NAME = 'dev.fluttercommunity.plus/device_info';

/** Every key the Dart side expects in the getDeviceInfo map (see buildDeviceInfoMap). */
const DEVICE_INFO_KEYS: string[] = [
  'deviceType', 'manufacture', 'brand', 'marketName', 'productSeries', 'productModel',
  'softwareModel', 'hardwareModel', 'bootloaderVersion', 'abiList', 'securityPatchTag',
  'displayVersion', 'incrementalVersion', 'osReleaseType', 'osFullName', 'majorVersion',
  'seniorVersion', 'featureVersion', 'buildVersion', 'sdkApiVersion', 'firstApiVersion',
  'versionId', 'buildType', 'buildUser', 'buildHost', 'buildTime', 'buildRootHash', 'ODID',
  'distributionOSName', 'distributionOSVersion', 'distributionOSApiVersion',
  'distributionOSReleaseType', 'isPhysicalDevice'
];

/** A plugin already attached to a mock engine binding (channel handler registered). */
class AttachedPlugin {
  plugin: DeviceInfoPlusPlugin;
  messenger: MockBinaryMessenger;
  binding: FlutterPluginBinding;

  constructor() {
    this.plugin = new DeviceInfoPlusPlugin();
    this.messenger = new MockBinaryMessenger();
    this.binding = new MockFlutterPluginBinding(this.messenger) as ESObject as FlutterPluginBinding;
    this.plugin.onAttachedToEngine(this.binding);
  }
}

/** Calls getDeviceInfo through onMethodCall and returns the recorded result. */
function callGetDeviceInfo(plugin: DeviceInfoPlusPlugin): MockMethodResult {
  const mockResult: MockMethodResult = new MockMethodResult();
  plugin.onMethodCall(new MethodCall('getDeviceInfo', null), mockResult);
  return mockResult;
}

export default function deviceInfoPlusPluginTest() {
  describe('DeviceInfoPlusPluginPureLogicTest', () => {
    // Plugin logic that never reaches a system API: routing, guards and
    // lifecycle bookkeeping. Deterministic on any device.

    it('getUniqueClassName_returnsPluginClassName', 0, () => {
      const plugin: DeviceInfoPlusPlugin = new DeviceInfoPlusPlugin();
      expect(plugin.getUniqueClassName()).assertEqual('DeviceInfoPlusPlugin');
    });

    it('onMethodCall_unknownMethod_reportsNotImplemented', 0, () => {
      const plugin: DeviceInfoPlusPlugin = new DeviceInfoPlusPlugin();
      const mockResult: MockMethodResult = new MockMethodResult();
      plugin.onMethodCall(new MethodCall('noSuchMethod', null), mockResult);
      expect(mockResult.isNotImplementedCalled).assertTrue();
      expect(mockResult.isSuccessCalled).assertFalse();
      expect(mockResult.isErrorCalled).assertFalse();
      expect(mockResult.callCount).assertEqual(1);
    });

    it('onDetachedFromEngine_withoutAttach_isSafe', 0, () => {
      // The channel is still null; the null guard must skip, not throw.
      const plugin: DeviceInfoPlusPlugin = new DeviceInfoPlusPlugin();
      const binding: FlutterPluginBinding =
        new MockFlutterPluginBinding(new MockBinaryMessenger()) as ESObject as FlutterPluginBinding;
      let thrown: boolean = false;
      try {
        plugin.onDetachedFromEngine(binding);
      } catch (e) {
        thrown = true;
      }
      expect(thrown).assertFalse();
    });
  });

  describe('DeviceInfoPlusPluginLifecycleTest', () => {
    // Engine attachment via a mock binding: exercises onAttachedToEngine /
    // onDetachedFromEngine handler registration on the shared channel.

    it('onAttachedToEngine_registersChannelHandler', 0, () => {
      const attached: AttachedPlugin = new AttachedPlugin();
      expect(attached.messenger.handlerRegistered).assertTrue();
      expect(attached.messenger.handlerChannel).assertEqual(CHANNEL_NAME);
    });

    it('onDetachedFromEngine_clearsChannelHandler', 0, () => {
      const attached: AttachedPlugin = new AttachedPlugin();
      attached.plugin.onDetachedFromEngine(attached.binding);
      expect(attached.messenger.handlerRegistered).assertFalse();
      expect(attached.messenger.handlerChannel).assertEqual(CHANNEL_NAME);
    });

    it('onDetachedFromEngine_twice_isIdempotent', 0, () => {
      const attached: AttachedPlugin = new AttachedPlugin();
      let thrown: boolean = false;
      try {
        attached.plugin.onDetachedFromEngine(attached.binding);
        attached.plugin.onDetachedFromEngine(attached.binding);
      } catch (e) {
        thrown = true;
      }
      expect(thrown).assertFalse();
      expect(attached.messenger.handlerRegistered).assertFalse();
    });

    it('reattach_afterDetach_registersHandlerAgain', 0, () => {
      const attached: AttachedPlugin = new AttachedPlugin();
      attached.plugin.onDetachedFromEngine(attached.binding);
      expect(attached.messenger.handlerRegistered).assertFalse();
      attached.plugin.onAttachedToEngine(attached.binding);
      expect(attached.messenger.handlerRegistered).assertTrue();
      expect(attached.messenger.handlerChannel).assertEqual(CHANNEL_NAME);
    });
  });

  describe('DeviceInfoPlusPluginDeviceTest', () => {
    // These wrap @ohos.deviceInfo, whose values vary per device and per
    // permission grant. The plugin's contract with Flutter is what is
    // asserted: exactly one well-formed result per call, never a crash.

    it('getDeviceInfo_deliversMapWithAllExpectedKeys', 0, () => {
      const plugin: DeviceInfoPlusPlugin = new DeviceInfoPlusPlugin();
      const mockResult: MockMethodResult = callGetDeviceInfo(plugin);
      expect(mockResult.callCount).assertEqual(1);
      if (mockResult.isSuccessCalled) {
        const infoMap: HashMap<string, Object> =
          mockResult.successValue as ESObject as HashMap<string, Object>;
        for (let i = 0; i < DEVICE_INFO_KEYS.length; i++) {
          expect(infoMap.hasKey(DEVICE_INFO_KEYS[i])).assertTrue();
        }
        expect(typeof infoMap.get('isPhysicalDevice') === 'boolean').assertTrue();
      } else {
        expect(mockResult.isErrorCalled).assertTrue();
        expect(mockResult.errorCode).assertEqual('DEVICE_INFO_ERROR');
      }
    });

    it('getDeviceInfo_isPhysicalDevice_negationOfIsEmulator', 0, () => {
      const plugin: DeviceInfoPlusPlugin = new DeviceInfoPlusPlugin();
      const mockResult: MockMethodResult = callGetDeviceInfo(plugin);
      expect(mockResult.callCount).assertEqual(1);
      if (mockResult.isSuccessCalled) {
        const infoMap: HashMap<string, Object> =
          mockResult.successValue as ESObject as HashMap<string, Object>;
        expect(infoMap.get('isPhysicalDevice')).assertEqual(!plugin.isEmulator(infoMap));
      }
    });

    it('getAccessUDIDInfo_deliversSerialAndUdidOrReportsError', 0, () => {
      // deviceInfo.serial/udid need the system permission
      // ohos.permission.sec.ACCESS_UDID. On a normal app they throw and the
      // plugin must report a DEVICE_INFO_ERROR; on a privileged build the
      // serial/udid map is delivered. Both outcomes are valid.
      const plugin: DeviceInfoPlusPlugin = new DeviceInfoPlusPlugin();
      const mockResult: MockMethodResult = new MockMethodResult();
      plugin.onMethodCall(new MethodCall('getAccessUDIDInfo', null), mockResult);
      expect(mockResult.callCount).assertEqual(1);
      if (mockResult.isSuccessCalled) {
        const infoMap: HashMap<string, Object> =
          mockResult.successValue as ESObject as HashMap<string, Object>;
        expect(infoMap.hasKey('serial')).assertTrue();
        expect(infoMap.hasKey('udid')).assertTrue();
        expect(typeof infoMap.get('serial') === 'string').assertTrue();
        expect(typeof infoMap.get('udid') === 'string').assertTrue();
      } else {
        expect(mockResult.isErrorCalled).assertTrue();
        expect(mockResult.errorCode).assertEqual('DEVICE_INFO_ERROR');
        expect(mockResult.errorMessage.includes('getAccessUDIDInfo failed:')).assertTrue();
      }
    });
  });

  describe('DeviceInfoPlusPluginIsEmulatorTest', () => {
    // isEmulator mixes an injectable input (the map) with real deviceInfo
    // fields; the tagged-map case is fully deterministic because the
    // hasValue short-circuit wins before any system field is read.

    it('isEmulator_mapTaggedWithEmulator_returnsTrue', 0, () => {
      const plugin: DeviceInfoPlusPlugin = new DeviceInfoPlusPlugin();
      const taggedMap: HashMap<string, Object> = new HashMap<string, Object>();
      taggedMap.set('softwareModel', 'emulator');
      expect(plugin.isEmulator(taggedMap)).assertTrue();
    });

    it('isEmulator_untaggedMap_returnsConsistentBoolean', 0, () => {
      // Without the tag the verdict comes from versionId/displayVersion:
      // true on an emulator runtime, false on a physical device. Only the
      // type and the call-to-call consistency are device-independent.
      const plugin: DeviceInfoPlusPlugin = new DeviceInfoPlusPlugin();
      const plainMap: HashMap<string, Object> = new HashMap<string, Object>();
      plainMap.set('softwareModel', 'typicalModel');
      const first: boolean = plugin.isEmulator(plainMap);
      const second: boolean = plugin.isEmulator(plainMap);
      expect(typeof first === 'boolean').assertTrue();
      expect(second).assertEqual(first);
    });
  });
}
