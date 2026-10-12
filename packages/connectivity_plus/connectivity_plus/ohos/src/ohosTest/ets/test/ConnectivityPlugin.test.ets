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
import ConnectivityPlugin from '../../../main/ets/dev/fluttercommunity/plus/connectivity/ConnectivityPlugin';
import { FlutterPluginBinding } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import { MockBinaryMessenger, MockFlutterPluginBinding } from './TestMocks';

const METHOD_CHANNEL_NAME = 'dev.fluttercommunity.plus/connectivity';
const EVENT_CHANNEL_NAME = 'dev.fluttercommunity.plus/connectivity_status';

/** A plugin already attached to a mock engine binding (both channels registered). */
class AttachedPlugin {
  plugin: ConnectivityPlugin;
  messenger: MockBinaryMessenger;
  binding: FlutterPluginBinding;

  constructor() {
    this.plugin = new ConnectivityPlugin();
    this.messenger = new MockBinaryMessenger();
    this.binding = new MockFlutterPluginBinding(this.messenger) as ESObject as FlutterPluginBinding;
    this.plugin.onAttachedToEngine(this.binding);
  }
}

export default function connectivityPluginTest() {
  describe('ConnectivityPluginTest', () => {
    // Engine attachment via mock bindings: exercises onAttachedToEngine /
    // onDetachedFromEngine and the registration of both channels.
    let plugin: ConnectivityPlugin = new ConnectivityPlugin();

    beforeAll(() => {
      plugin = new ConnectivityPlugin();
    });

    it('getUniqueClassName_returnsPluginClassName', 0, () => {
      expect(plugin.getUniqueClassName()).assertEqual('ConnectivityPlugin');
    });

    it('onAttachedToEngine_registersMethodAndEventChannelHandlers', 0, () => {
      const attached: AttachedPlugin = new AttachedPlugin();
      expect(attached.messenger.isRegistered(METHOD_CHANNEL_NAME)).assertTrue();
      expect(attached.messenger.isRegistered(EVENT_CHANNEL_NAME)).assertTrue();
      attached.plugin.onDetachedFromEngine(attached.binding);
    });

    it('onDetachedFromEngine_clearsBothChannelHandlers', 0, () => {
      const attached: AttachedPlugin = new AttachedPlugin();
      attached.plugin.onDetachedFromEngine(attached.binding);
      expect(attached.messenger.isRegistered(METHOD_CHANNEL_NAME)).assertFalse();
      expect(attached.messenger.isRegistered(EVENT_CHANNEL_NAME)).assertFalse();
    });

    it('onDetachedFromEngine_withoutAttach_isSafe', 0, () => {
      // Channels and receiver are still null; the ?. guards must skip
      // clearing instead of throwing.
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

    it('onDetachedFromEngine_twice_isSafe', 0, () => {
      // The second detach must stay harmless (everything already cleared).
      const attached: AttachedPlugin = new AttachedPlugin();
      attached.plugin.onDetachedFromEngine(attached.binding);
      let thrown: boolean = false;
      try {
        attached.plugin.onDetachedFromEngine(attached.binding);
      } catch (e) {
        thrown = true;
      }
      expect(thrown).assertFalse();
      expect(attached.messenger.isRegistered(METHOD_CHANNEL_NAME)).assertFalse();
      expect(attached.messenger.isRegistered(EVENT_CHANNEL_NAME)).assertFalse();
    });

    it('attach_afterDetach_registersChannelsAgain', 0, () => {
      const attached: AttachedPlugin = new AttachedPlugin();
      attached.plugin.onDetachedFromEngine(attached.binding);
      attached.plugin.onAttachedToEngine(attached.binding);
      expect(attached.messenger.isRegistered(METHOD_CHANNEL_NAME)).assertTrue();
      expect(attached.messenger.isRegistered(EVENT_CHANNEL_NAME)).assertTrue();
      attached.plugin.onDetachedFromEngine(attached.binding);
    });
  });
}
