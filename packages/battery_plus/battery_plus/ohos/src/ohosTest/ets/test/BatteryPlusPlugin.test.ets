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
import BatteryPlusPlugin from '../../../main/ets/components/plugin/BatteryPlusPlugin';
import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
import { MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import { FlutterPluginBinding } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import { MockMethodResult, MockEventSink, MockBinaryMessenger, MockFlutterPluginBinding } from './TestMocks';

const METHOD_CHANNEL_NAME = 'dev.fluttercommunity.plus/battery';
const EVENT_CHANNEL_NAME = 'dev.fluttercommunity.plus/charging';

/** Charging states the Dart side's parseBatteryState accepts. */
const KNOWN_CHARGING_STATUSES: string[] = ['unknown', 'charging', 'discharging', 'full'];

function isKnownChargingStatus(value: string): boolean {
  return KNOWN_CHARGING_STATUSES.indexOf(value) !== -1;
}

/** A plugin already attached to a mock engine binding (channel handlers registered). */
class AttachedPlugin {
  plugin: BatteryPlusPlugin;
  messenger: MockBinaryMessenger;
  binding: FlutterPluginBinding;

  constructor() {
    this.plugin = new BatteryPlusPlugin();
    this.messenger = new MockBinaryMessenger();
    this.binding = new MockFlutterPluginBinding(this.messenger) as ESObject as FlutterPluginBinding;
    this.plugin.onAttachedToEngine(this.binding);
  }
}

/**
 * Plugin double with a scriptable charging status and an injectable read
 * failure, to drive status transitions and the catch paths of the polling
 * callback and the method-channel reads. Note: ArkTS only allows throwing
 * Error values (arkts-limited-throw), so the non-Error branch of the
 * plugin's `e instanceof Error ? ... : String(e)` guards is unreachable
 * from tests and covered defensively only.
 */
class ScriptedStatusPlugin extends BatteryPlusPlugin {
  scriptedStatus: string = 'charging';
  failure: Error | null = null;

  getChargingStatus(): string {
    if (this.failure !== null) {
      throw this.failure;
    }
    return this.scriptedStatus;
  }
}

/**
 * Plugin double whose power-mode read always fails, to exercise the catch
 * branch of onMethodCall through the 'isInBatterySaveMode' case.
 */
class FailingPowerModePlugin extends BatteryPlusPlugin {
  getBatteryMode(result: MethodResult): void {
    throw new Error('mock power mode failure');
  }
}

/** Invokes `method` on the plugin and returns the recorded result. */
function callMethod(plugin: BatteryPlusPlugin, method: string): MockMethodResult {
  const mockResult: MockMethodResult = new MockMethodResult();
  plugin.onMethodCall(new MethodCall(method, null), mockResult);
  return mockResult;
}

export default function batteryPlusPluginTest() {
  describe('BatteryPlusPluginPureLogicTest', () => {
    // Pure plugin logic that never depends on engine attachment or a live
    // battery: method routing, state mapping and the result contract with
    // Flutter. Deterministic on any device.

    let plugin: BatteryPlusPlugin = new BatteryPlusPlugin();

    beforeAll(() => {
      plugin = new BatteryPlusPlugin();
    });

    it('getUniqueClassName_returnsPluginClassName', 0, () => {
      expect(plugin.getUniqueClassName()).assertEqual('BatteryPlusPlugin');
    });

    it('onMethodCall_unknownMethod_reportsNotImplemented', 0, () => {
      const mockResult: MockMethodResult = callMethod(plugin, 'noSuchMethod');
      expect(mockResult.isNotImplementedCalled).assertTrue();
      expect(mockResult.callCount).assertEqual(1);
      expect(mockResult.isSuccessCalled).assertFalse();
      expect(mockResult.isErrorCalled).assertFalse();
    });

    it('onMethodCall_methodMatchIsCaseSensitive', 0, () => {
      // A case-variant of a known name must not be routed to the real method.
      const mockResult: MockMethodResult = callMethod(plugin, 'GetBatteryLevel');
      expect(mockResult.isNotImplementedCalled).assertTrue();
      expect(mockResult.callCount).assertEqual(1);
      expect(mockResult.isSuccessCalled).assertFalse();
      expect(mockResult.isErrorCalled).assertFalse();
    });

    it('getChargingStatus_returnsKnownDartState', 0, () => {
      // Whatever the hardware reports, the value must be one the Dart side's
      // parseBatteryState can parse; 'connected_not_charging' is unreachable
      // on OHOS and must never appear.
      const status: string = plugin.getChargingStatus();
      expect(isKnownChargingStatus(status)).assertTrue();
      expect(status === 'connected_not_charging').assertFalse();
    });

    it('chargeModeCallback_withoutListener_isSafeNoOp', 0, () => {
      // No stream has ever been listened to; the callback must return early
      // instead of dereferencing a null sink.
      let thrown: boolean = false;
      try {
        plugin.chargeModeCallback();
      } catch (e) {
        thrown = true;
      }
      expect(thrown).assertFalse();
    });

    it('onCancel_withoutListener_isSafeNoOp', 0, () => {
      // disposeStream runs with no active timer (timerId === -1) and no sink;
      // it must skip clearInterval instead of throwing.
      let thrown: boolean = false;
      try {
        plugin.onCancel(null);
      } catch (e) {
        thrown = true;
      }
      expect(thrown).assertFalse();
    });
  });

  describe('BatteryPlusPluginDeviceTest', () => {
    // The three method-channel reads hit the real batteryInfo/power services.
    // The values themselves vary per device; the tests pin down the plugin's
    // contract with Flutter: exactly one well-formed terminal result, or the
    // 'UNAVAILABLE' error the Dart layer knows.

    let plugin: BatteryPlusPlugin = new BatteryPlusPlugin();

    beforeAll(() => {
      plugin = new BatteryPlusPlugin();
    });

    it('getBatteryLevel_deliversExactlyOneTerminalResult', 0, () => {
      const mockResult: MockMethodResult = callMethod(plugin, 'getBatteryLevel');
      expect(mockResult.callCount).assertEqual(1);
      expect(mockResult.isSuccessCalled !== mockResult.isErrorCalled).assertTrue();
      expect(mockResult.isNotImplementedCalled).assertFalse();
    });

    it('getBatteryLevel_success_valueWithinValidRange', 0, () => {
      const mockResult: MockMethodResult = callMethod(plugin, 'getBatteryLevel');
      if (mockResult.isSuccessCalled) {
        const level: number = mockResult.successValue as number;
        expect(level >= 0).assertTrue();
        expect(level <= 100).assertTrue();
      } else {
        expect(mockResult.errorCode).assertEqual('UNAVAILABLE');
      }
    });

    it('getBatteryState_deliversKnownChargingStatus', 0, () => {
      const mockResult: MockMethodResult = callMethod(plugin, 'getBatteryState');
      if (mockResult.isSuccessCalled) {
        expect(isKnownChargingStatus(mockResult.successValue as string)).assertTrue();
      } else {
        expect(mockResult.errorCode).assertEqual('UNAVAILABLE');
      }
    });

    it('isInBatterySaveMode_deliversBooleanExactlyOnce', 0, () => {
      const mockResult: MockMethodResult = callMethod(plugin, 'isInBatterySaveMode');
      expect(mockResult.callCount).assertEqual(1);
      expect(mockResult.isNotImplementedCalled).assertFalse();
      if (mockResult.isSuccessCalled) {
        expect(mockResult.successValue === true || mockResult.successValue === false).assertTrue();
      } else {
        expect(mockResult.errorCode).assertEqual('UNAVAILABLE');
      }
    });
  });

  describe('BatteryPlusPluginStreamTest', () => {
    // EventChannel stream behaviour: immediate first event, deduplication of
    // unchanged status, teardown on cancel, sink switching on re-listen, and
    // the error path of the polling callback.

    let plugin: BatteryPlusPlugin = new BatteryPlusPlugin();

    beforeAll(() => {
      plugin = new BatteryPlusPlugin();
    });

    it('onListen_emitsCurrentStatusImmediately', 0, () => {
      const sink: MockEventSink = new MockEventSink();
      plugin.onListen(null, sink);
      expect(sink.successCount).assertEqual(1);
      expect(isKnownChargingStatus(sink.successValues[0])).assertTrue();
      plugin.onCancel(null);
    });

    it('onListen_deduplicatesUnchangedChargingStatus', 0, () => {
      // A poll that observes the same status as the last pushed one must not
      // emit a duplicate event.
      const sink: MockEventSink = new MockEventSink();
      plugin.onListen(null, sink);
      expect(sink.successCount).assertEqual(1);
      plugin.chargeModeCallback();
      expect(sink.successCount).assertEqual(1);
      plugin.onCancel(null);
    });

    it('onCancel_stopsDeliveryToSink', 0, () => {
      const sink: MockEventSink = new MockEventSink();
      plugin.onListen(null, sink);
      const emittedAtListen: number = sink.successCount;
      plugin.onCancel(null);
      plugin.chargeModeCallback();
      expect(sink.successCount).assertEqual(emittedAtListen);
      expect(sink.errorCount).assertEqual(0);
    });

    it('repeatedOnListen_switchesDeliveryToNewSink', 0, () => {
      // A second listen must replace the first sink (and not leak its timer):
      // only the new sink receives events afterwards.
      const firstSink: MockEventSink = new MockEventSink();
      const secondSink: MockEventSink = new MockEventSink();
      plugin.onListen(null, firstSink);
      plugin.onListen(null, secondSink);
      expect(firstSink.successCount).assertEqual(1);
      expect(secondSink.successCount).assertEqual(1);
      plugin.chargeModeCallback();
      expect(firstSink.successCount).assertEqual(1);
      plugin.onCancel(null);
    });

    it('chargeModeCallback_whenStatusReadFails_reportsErrorAndDisposes', 0, () => {
      const scriptedPlugin: ScriptedStatusPlugin = new ScriptedStatusPlugin();
      const sink: MockEventSink = new MockEventSink();
      scriptedPlugin.onListen(null, sink);
      expect(sink.successCount).assertEqual(1);
      scriptedPlugin.failure = new Error('mock battery read failure');
      scriptedPlugin.chargeModeCallback();
      expect(sink.errorCount).assertEqual(1);
      expect(sink.errorCode).assertEqual('UNAVAILABLE');
      // The stream is disposed: further polls are no-ops, not more errors.
      scriptedPlugin.chargeModeCallback();
      expect(sink.errorCount).assertEqual(1);
      expect(sink.successCount).assertEqual(1);
    });
  });

  describe('BatteryPlusPluginScriptedStatusTest', () => {
    // Branch coverage with a scriptable status double: status transitions on
    // the stream, the empty-status guard rails, and the catch paths of the
    // method channel and the polling callback.

    it('onListen_emptyStatus_skipsImmediateEvent_thenEmitsOnChange', 0, () => {
      const scriptedPlugin: ScriptedStatusPlugin = new ScriptedStatusPlugin();
      scriptedPlugin.scriptedStatus = '';
      const sink: MockEventSink = new MockEventSink();
      scriptedPlugin.onListen(null, sink);
      expect(sink.successCount).assertEqual(0);
      // Once a real status appears, the next poll must push it.
      scriptedPlugin.scriptedStatus = 'charging';
      scriptedPlugin.chargeModeCallback();
      expect(sink.successCount).assertEqual(1);
      expect(sink.successValues[0]).assertEqual('charging');
      scriptedPlugin.onCancel(null);
    });

    it('chargeModeCallback_emitsWhenStatusChanges', 0, () => {
      const scriptedPlugin: ScriptedStatusPlugin = new ScriptedStatusPlugin();
      const sink: MockEventSink = new MockEventSink();
      scriptedPlugin.onListen(null, sink);
      expect(sink.successCount).assertEqual(1);
      scriptedPlugin.scriptedStatus = 'discharging';
      scriptedPlugin.chargeModeCallback();
      expect(sink.successCount).assertEqual(2);
      expect(sink.successValues[0]).assertEqual('charging');
      expect(sink.successValues[1]).assertEqual('discharging');
      scriptedPlugin.onCancel(null);
    });

    it('onMethodCall_getBatteryState_emptyStatus_reportsUnavailable', 0, () => {
      const scriptedPlugin: ScriptedStatusPlugin = new ScriptedStatusPlugin();
      scriptedPlugin.scriptedStatus = '';
      const mockResult: MockMethodResult = callMethod(scriptedPlugin, 'getBatteryState');
      expect(mockResult.isErrorCalled).assertTrue();
      expect(mockResult.errorCode).assertEqual('UNAVAILABLE');
      expect(mockResult.callCount).assertEqual(1);
    });

    it('onMethodCall_statusReadFailure_reportsUnavailableWithReason', 0, () => {
      const scriptedPlugin: ScriptedStatusPlugin = new ScriptedStatusPlugin();
      scriptedPlugin.failure = new Error('mock status read failure');
      const mockResult: MockMethodResult = callMethod(scriptedPlugin, 'getBatteryState');
      expect(mockResult.isErrorCalled).assertTrue();
      expect(mockResult.errorCode).assertEqual('UNAVAILABLE');
      expect(mockResult.errorMessage.indexOf('mock status read failure') !== -1).assertTrue();
    });

    it('onMethodCall_isInBatterySaveMode_powerModeFailure_reportsUnavailable', 0, () => {
      const failingModePlugin: FailingPowerModePlugin = new FailingPowerModePlugin();
      const mockResult: MockMethodResult = callMethod(failingModePlugin, 'isInBatterySaveMode');
      expect(mockResult.isErrorCalled).assertTrue();
      expect(mockResult.errorCode).assertEqual('UNAVAILABLE');
      expect(mockResult.errorMessage.indexOf('mock power mode failure') !== -1).assertTrue();
    });
  });

  describe('BatteryPlusPluginLifecycleTest', () => {
    // Engine attachment via mock bindings: exercises onAttachedToEngine /
    // onDetachedFromEngine handler registration for both channels and stream
    // teardown on detach.

    it('onAttachedToEngine_registersHandlersOnBothChannels', 0, () => {
      const attached: AttachedPlugin = new AttachedPlugin();
      expect(attached.messenger.isRegistered(METHOD_CHANNEL_NAME)).assertTrue();
      expect(attached.messenger.isRegistered(EVENT_CHANNEL_NAME)).assertTrue();
    });

    it('onDetachedFromEngine_clearsHandlersOnBothChannels', 0, () => {
      const attached: AttachedPlugin = new AttachedPlugin();
      attached.plugin.onDetachedFromEngine(attached.binding);
      expect(attached.messenger.isRegistered(METHOD_CHANNEL_NAME)).assertFalse();
      expect(attached.messenger.isRegistered(EVENT_CHANNEL_NAME)).assertFalse();
    });

    it('onDetachedFromEngine_withoutAttach_isSafe', 0, () => {
      // The channels are still null; the optional chaining must skip clearing
      // instead of throwing.
      const plugin: BatteryPlusPlugin = new BatteryPlusPlugin();
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
      expect(attached.messenger.isRegistered(METHOD_CHANNEL_NAME)).assertFalse();
      expect(attached.messenger.isRegistered(EVENT_CHANNEL_NAME)).assertFalse();
    });

    it('reattach_afterDetach_registersHandlersAgain', 0, () => {
      const attached: AttachedPlugin = new AttachedPlugin();
      attached.plugin.onDetachedFromEngine(attached.binding);
      expect(attached.messenger.isRegistered(METHOD_CHANNEL_NAME)).assertFalse();
      attached.plugin.onAttachedToEngine(attached.binding);
      expect(attached.messenger.isRegistered(METHOD_CHANNEL_NAME)).assertTrue();
      expect(attached.messenger.isRegistered(EVENT_CHANNEL_NAME)).assertTrue();
    });

    it('onDetachedFromEngine_disposesActiveStream', 0, () => {
      const attached: AttachedPlugin = new AttachedPlugin();
      const sink: MockEventSink = new MockEventSink();
      attached.plugin.onListen(null, sink);
      expect(sink.successCount).assertEqual(1);
      attached.plugin.onDetachedFromEngine(attached.binding);
      attached.plugin.chargeModeCallback();
      expect(sink.successCount).assertEqual(1);
      expect(sink.errorCount).assertEqual(0);
    });

    it('fullFlow_attach_call_listen_detach', 0, () => {
      const attached: AttachedPlugin = new AttachedPlugin();
      const levelResult: MockMethodResult = callMethod(attached.plugin, 'getBatteryLevel');
      expect(levelResult.callCount).assertEqual(1);
      const sink: MockEventSink = new MockEventSink();
      attached.plugin.onListen(null, sink);
      expect(sink.successCount).assertEqual(1);
      attached.plugin.onDetachedFromEngine(attached.binding);
      expect(attached.messenger.isRegistered(METHOD_CHANNEL_NAME)).assertFalse();
      expect(attached.messenger.isRegistered(EVENT_CHANNEL_NAME)).assertFalse();
    });
  });
}
