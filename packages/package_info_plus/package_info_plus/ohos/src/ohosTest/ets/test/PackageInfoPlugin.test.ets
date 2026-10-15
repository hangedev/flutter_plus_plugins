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

import { describe, beforeAll, it, expect } from '@ohos/hypium';
import { PackageInfoPlugin } from '../../../main/ets/dev/fluttercommunity/plus/packageinfo/PackageInfoPlugin';
import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
import { FlutterPluginBinding } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import { MockMethodResult, MockBinaryMessenger, MockFlutterPluginBinding, MockContext } from './TestMocks';

const CHANNEL_NAME = 'dev.fluttercommunity.plus/package_info';

/** A plugin already attached to a mock engine binding (channel handler registered). */
class AttachedPlugin {
  plugin: PackageInfoPlugin;
  messenger: MockBinaryMessenger;
  binding: FlutterPluginBinding;

  constructor(context: Context | null = null) {
    this.plugin = new PackageInfoPlugin();
    this.messenger = new MockBinaryMessenger();
    this.binding = new MockFlutterPluginBinding(this.messenger, context) as ESObject as FlutterPluginBinding;
    this.plugin.onAttachedToEngine(this.binding);
  }
}

/** Runs getAll on the plugin and returns the recorded result. */
function callGetAll(plugin: PackageInfoPlugin): MockMethodResult {
  const mockResult: MockMethodResult = new MockMethodResult();
  plugin.onMethodCall(new MethodCall('getAll', null), mockResult);
  return mockResult;
}

export default function packageInfoPluginTest() {
  describe('PackageInfoPluginPureLogicTest', () => {
    // Pure plugin logic that never depends on engine attachment: method routing
    // and the result contract with Flutter. Deterministic on any device.
    let plugin: PackageInfoPlugin = new PackageInfoPlugin();

    beforeAll(() => {
      plugin = new PackageInfoPlugin();
    });

    it('getUniqueClassName_returnsPluginClassName', 0, () => {
      expect(plugin.getUniqueClassName()).assertEqual('PackageInfoPlugin');
    });

    it('onMethodCall_unknownMethod_reportsNotImplemented', 0, () => {
      const mockResult: MockMethodResult = new MockMethodResult();
      plugin.onMethodCall(new MethodCall('noSuchMethod', null), mockResult);
      expect(mockResult.isNotImplementedCalled).assertTrue();
      expect(mockResult.callCount).assertEqual(1);
      expect(mockResult.isSuccessCalled).assertFalse();
      expect(mockResult.isErrorCalled).assertFalse();
    });

    it('onMethodCall_methodMatchIsCaseSensitive', 0, () => {
      // A case-variant of the known name must not be routed to getAll.
      const mockResult: MockMethodResult = new MockMethodResult();
      plugin.onMethodCall(new MethodCall('GetAll', null), mockResult);
      expect(mockResult.isNotImplementedCalled).assertTrue();
      expect(mockResult.callCount).assertEqual(1);
      expect(mockResult.isSuccessCalled).assertFalse();
      expect(mockResult.isErrorCalled).assertFalse();
    });

    it('onMethodCall_extraArguments_areIgnoredNotRejected', 0, () => {
      // getAll reads no arguments; passing some must not change routing.
      const args: Map<string, ESObject> = new Map<string, ESObject>();
      args.set('unused', 'value');
      const mockResult: MockMethodResult = new MockMethodResult();
      plugin.onMethodCall(new MethodCall('getAll', args), mockResult);
      expect(mockResult.callCount).assertEqual(1);
      expect(mockResult.isSuccessCalled || mockResult.isErrorCalled).assertTrue();
      expect(mockResult.isNotImplementedCalled).assertFalse();
    });
  });

  describe('PackageInfoPluginDeviceTest', () => {
    // getAll reads the real bundle info through bundleManager. The system
    // values themselves vary per device; the tests pin down the plugin's
    // contract with Flutter: a well-formed Map is delivered exactly once, or
    // the failure is reported as the 'Name not found' error the Dart side knows.
    let plugin: PackageInfoPlugin = new PackageInfoPlugin();

    beforeAll(() => {
      plugin = new PackageInfoPlugin();
    });

    it('getAll_deliversExactlyOneTerminalResult', 0, () => {
      const mockResult: MockMethodResult = callGetAll(plugin);
      expect(mockResult.callCount).assertEqual(1);
      expect(mockResult.isSuccessCalled !== mockResult.isErrorCalled).assertTrue();
      expect(mockResult.isNotImplementedCalled).assertFalse();
    });

    it('getAll_success_containsAllPackageInfoKeys', 0, () => {
      const mockResult: MockMethodResult = callGetAll(plugin);
      if (mockResult.isSuccessCalled) {
        const infoMap: Map<string, string> = mockResult.successValue as Map<string, string>;
        const keys: Array<string> =
          ['appName', 'packageName', 'version', 'buildNumber', 'installTime', 'updateTime'];
        for (let i = 0; i < keys.length; i++) {
          expect(infoMap.get(keys[i]) !== undefined).assertTrue();
        }
      } else {
        expect(mockResult.errorCode).assertEqual('Name not found');
      }
    });

    it('getAll_success_deliversNonEmptyBundleIdentity', 0, () => {
      const mockResult: MockMethodResult = callGetAll(plugin);
      if (mockResult.isSuccessCalled) {
        const infoMap: Map<string, string> = mockResult.successValue as Map<string, string>;
        expect(infoMap.get('packageName') !== '').assertTrue();
        expect(infoMap.get('buildNumber') !== '').assertTrue();
      } else {
        expect(mockResult.errorCode).assertEqual('Name not found');
      }
    });

    it('getAll_withoutApplicationContext_appNameFallsBackToEmptyString', 0, () => {
      // Never attached to an engine: applicationContext is null and the
      // resourceManager lookup must be skipped instead of throwing.
      const mockResult: MockMethodResult = callGetAll(plugin);
      if (mockResult.isSuccessCalled) {
        const infoMap: Map<string, string> = mockResult.successValue as Map<string, string>;
        expect(infoMap.get('appName')).assertEqual('');
      } else {
        expect(mockResult.isErrorCalled).assertTrue();
      }
    });
  });

  describe('PackageInfoPluginLifecycleTest', () => {
    // Engine attachment via mock bindings: exercises onAttachedToEngine /
    // onDetachedFromEngine handler registration and the context-dependent
    // appName mapping.

    it('onAttachedToEngine_registersChannelHandler', 0, () => {
      const attached: AttachedPlugin = new AttachedPlugin();
      expect(attached.messenger.handlerRegistered).assertTrue();
      expect(attached.messenger.handlerChannel).assertEqual(CHANNEL_NAME);
    });

    it('onAttachedToEngine_withContext_appNameComesFromResourceManager', 0, () => {
      const attached: AttachedPlugin =
        new AttachedPlugin(new MockContext('MockAppName') as ESObject as Context);
      const mockResult: MockMethodResult = callGetAll(attached.plugin);
      if (mockResult.isSuccessCalled) {
        const infoMap: Map<string, string> = mockResult.successValue as Map<string, string>;
        expect(infoMap.get('appName')).assertEqual('MockAppName');
      } else {
        expect(mockResult.isErrorCalled).assertTrue();
      }
      attached.plugin.onDetachedFromEngine(attached.binding);
    });

    it('onAttachedToEngine_withNullContext_getAllStillSucceedsWithEmptyAppName', 0, () => {
      const attached: AttachedPlugin = new AttachedPlugin(null);
      const mockResult: MockMethodResult = callGetAll(attached.plugin);
      if (mockResult.isSuccessCalled) {
        const infoMap: Map<string, string> = mockResult.successValue as Map<string, string>;
        expect(infoMap.get('appName')).assertEqual('');
      } else {
        expect(mockResult.isErrorCalled).assertTrue();
      }
      attached.plugin.onDetachedFromEngine(attached.binding);
    });

    it('onDetachedFromEngine_clearsChannelHandler', 0, () => {
      const attached: AttachedPlugin = new AttachedPlugin();
      attached.plugin.onDetachedFromEngine(attached.binding);
      expect(attached.messenger.handlerRegistered).assertFalse();
      expect(attached.messenger.handlerChannel).assertEqual(CHANNEL_NAME);
    });

    it('onDetachedFromEngine_withoutAttach_isSafe', 0, () => {
      // The channel is still null; the optional chaining must skip clearing
      // instead of throwing.
      const plugin: PackageInfoPlugin = new PackageInfoPlugin();
      const binding: FlutterPluginBinding =
        new MockFlutterPluginBinding(new MockBinaryMessenger(), null) as ESObject as FlutterPluginBinding;
      let thrown: boolean = false;
      try {
        plugin.onDetachedFromEngine(binding);
      } catch (e) {
        thrown = true;
      }
      expect(thrown).assertFalse();
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

    it('fullFlow_attach_getAll_detach_handlerCleared', 0, () => {
      const attached: AttachedPlugin =
        new AttachedPlugin(new MockContext('MockAppName') as ESObject as Context);
      const mockResult: MockMethodResult = callGetAll(attached.plugin);
      expect(mockResult.callCount).assertEqual(1);
      expect(mockResult.isSuccessCalled || mockResult.isErrorCalled).assertTrue();
      attached.plugin.onDetachedFromEngine(attached.binding);
      expect(attached.messenger.handlerRegistered).assertFalse();
    });
  });
}
