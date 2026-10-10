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
import SharePlusOhosPlugin from '../../../main/ets/dev/fluttercommunity/plus/share/SharePlusOhosPlugin';
import { FlutterPluginBinding } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import UIAbility from '@ohos.app.ability.UIAbility';
import { MockBinaryMessenger, MockFlutterPluginBinding, MockAbilityPluginBinding, AbilityStub }
  from './TestMocks';

const CHANNEL_NAME = 'dev.fluttercommunity.plus/share';

/** A plugin already attached to a mock engine binding (channel handler registered). */
class AttachedPlugin {
  plugin: SharePlusOhosPlugin;
  messenger: MockBinaryMessenger;
  binding: FlutterPluginBinding;

  constructor() {
    this.plugin = new SharePlusOhosPlugin();
    this.messenger = new MockBinaryMessenger();
    this.binding = new MockFlutterPluginBinding(this.messenger) as ESObject as FlutterPluginBinding;
    this.plugin.onAttachedToEngine(this.binding);
  }
}

export default function sharePlusOhosPluginTest() {
  describe('SharePlusOhosPluginPureLogicTest', () => {
    // Plugin state that never depends on engine attachment. Deterministic on
    // any device.

    it('getUniqueClassName_returnsPluginTag', 0, () => {
      const plugin: SharePlusOhosPlugin = new SharePlusOhosPlugin();
      expect(plugin.getUniqueClassName()).assertEqual('SharePlusOhosPlugin');
    });

    it('onDetachedFromEngine_withoutAttach_isSafe', 0, () => {
      // Both the channel and Share are still null; the guards must skip, not throw.
      const plugin: SharePlusOhosPlugin = new SharePlusOhosPlugin();
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

    it('onDetachedFromAbility_withoutAttach_isSafe', 0, () => {
      const plugin: SharePlusOhosPlugin = new SharePlusOhosPlugin();
      let thrown: boolean = false;
      try {
        plugin.onDetachedFromAbility();
      } catch (e) {
        thrown = true;
      }
      expect(thrown).assertFalse();
    });
  });

  describe('SharePlusOhosPluginLifecycleTest', () => {
    // Engine/ability attachment via mock bindings: exercises onAttachedToEngine /
    // onDetachedFromEngine handler registration and the ability hand-off.

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

    it('onAttachedToAbility_beforeEngine_isSafe', 0, () => {
      // Share is not created yet; the optional-chain guard must skip setAbility.
      const plugin: SharePlusOhosPlugin = new SharePlusOhosPlugin();
      let thrown: boolean = false;
      try {
        plugin.onAttachedToAbility(new MockAbilityPluginBinding(null));
      } catch (e) {
        thrown = true;
      }
      expect(thrown).assertFalse();
    });

    it('onAttachedToAbility_afterEngine_doesNotThrow', 0, () => {
      const attached: AttachedPlugin = new AttachedPlugin();
      let thrown: boolean = false;
      try {
        attached.plugin.onAttachedToAbility(
          new MockAbilityPluginBinding(new AbilityStub() as ESObject as UIAbility));
        attached.plugin.onDetachedFromAbility();
      } catch (e) {
        thrown = true;
      }
      expect(thrown).assertFalse();
    });

    it('fullLifecycle_attach_ability_detach_engine_handlerCleared', 0, () => {
      const attached: AttachedPlugin = new AttachedPlugin();
      attached.plugin.onAttachedToAbility(
        new MockAbilityPluginBinding(new AbilityStub() as ESObject as UIAbility));
      attached.plugin.onDetachedFromAbility();
      attached.plugin.onDetachedFromEngine(attached.binding);
      expect(attached.messenger.handlerRegistered).assertFalse();
    });
  });
}
