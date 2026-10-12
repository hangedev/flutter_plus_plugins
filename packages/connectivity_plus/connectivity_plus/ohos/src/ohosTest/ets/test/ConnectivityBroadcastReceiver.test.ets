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
import { ConnectivityBroadcastReceiver }
  from '../../../main/ets/dev/fluttercommunity/plus/connectivity/ConnectivityBroadcastReceiver';
import { Connectivity } from '../../../main/ets/dev/fluttercommunity/plus/connectivity/Connectivity';
import { EventSink } from '@ohos/flutter_ohos/src/main/ets/plugin/common/EventChannel';
import connection from '@ohos.net.connection';
import { ArrayList } from '@kit.ArkTS';
import { FakeNetConnection, MockEventSink, waitMs } from './TestMocks';

/** Builds a receiver wired to a fake NetConnection plus a recording EventSink. */
class ReceiverFixture {
  receiver: ConnectivityBroadcastReceiver;
  fakeNet: FakeNetConnection;
  sink: MockEventSink;

  constructor() {
    this.fakeNet = new FakeNetConnection();
    const connectivity: Connectivity = new Connectivity();
    connectivity.netConnection = this.fakeNet as ESObject as connection.NetConnection;
    this.sink = new MockEventSink();
    this.receiver = new ConnectivityBroadcastReceiver(undefined as ESObject as Context, connectivity);
  }

  listen(): void {
    this.receiver.onListen(undefined as ESObject as Object, this.sink as ESObject as EventSink);
  }
}

/** Returns the single element of an event pushed as a [none] list. */
function noneElement(event: ESObject): string {
  const types: ArrayList<String> = event as ArrayList<String>;
  expect(types.length).assertEqual(1);
  return types[0] as string;
}

export default function connectivityBroadcastReceiverTest() {
  describe('ConnectivityBroadcastReceiverTest', () => {
    // Subscription lifecycle and event push behavior, exercised against a
    // fake NetConnection so no real network state is required.
    it('onListen_subscribesRegisterAndAllNetworkEvents', 0, () => {
      const fixture: ReceiverFixture = new ReceiverFixture();
      fixture.listen();
      expect(fixture.fakeNet.registerCount).assertEqual(1);
      expect(fixture.fakeNet.subscribedTypes.length).assertEqual(5);
      expect(fixture.fakeNet.subscribedTypes.includes('netAvailable')).assertTrue();
      expect(fixture.fakeNet.subscribedTypes.includes('netCapabilitiesChange')).assertTrue();
      expect(fixture.fakeNet.subscribedTypes.includes('netConnectionPropertiesChange')).assertTrue();
      expect(fixture.fakeNet.subscribedTypes.includes('netLost')).assertTrue();
      expect(fixture.fakeNet.subscribedTypes.includes('netUnavailable')).assertTrue();
      fixture.receiver.onCancel();
    });

    it('onListen_registerSuccess_pushesCurrentTypesToSink', 0, async () => {
      const fixture: ReceiverFixture = new ReceiverFixture();
      fixture.listen();
      fixture.fakeNet.completeRegister();
      await waitMs(500);
      // The initial state must reach the stream exactly through success().
      expect(fixture.sink.successValues.length > 0).assertTrue();
      expect(fixture.sink.errorCount).assertEqual(0);
      fixture.receiver.onCancel();
    });

    it('onListen_registerFailure_fallsBackToNone', 0, async () => {
      const fixture: ReceiverFixture = new ReceiverFixture();
      fixture.listen();
      fixture.fakeNet.failRegister();
      await waitMs(100);
      // Registration failure must still deliver an initial state: [none].
      expect(fixture.sink.successValues.length).assertEqual(1);
      expect(noneElement(fixture.sink.successValues[0])).assertEqual('none');
      fixture.receiver.onCancel();
    });

    it('netLost_and_netUnavailable_pushNone', 0, () => {
      const fixture: ReceiverFixture = new ReceiverFixture();
      fixture.listen();
      fixture.fakeNet.emit('netLost', null);
      fixture.fakeNet.emit('netUnavailable', null);
      expect(fixture.sink.successValues.length).assertEqual(2);
      expect(noneElement(fixture.sink.successValues[0])).assertEqual('none');
      expect(noneElement(fixture.sink.successValues[1])).assertEqual('none');
      fixture.receiver.onCancel();
    });

    it('netCapabilitiesChange_triggersRefreshPush', 0, async () => {
      const fixture: ReceiverFixture = new ReceiverFixture();
      fixture.listen();
      fixture.fakeNet.emit('netCapabilitiesChange', null);
      await waitMs(500);
      // A capabilities change must re-query and push the current types.
      expect(fixture.sink.successValues.length > 0).assertTrue();
      fixture.receiver.onCancel();
    });

    it('onCancel_unregistersAndBlocksFurtherEvents', 0, async () => {
      const fixture: ReceiverFixture = new ReceiverFixture();
      fixture.listen();
      fixture.receiver.onCancel();
      expect(fixture.fakeNet.unregisterCount).assertEqual(1);
      // Events and in-flight async callbacks after cancel must not reach the sink.
      const eventsBefore: number = fixture.sink.successValues.length;
      fixture.fakeNet.emit('netLost', null);
      fixture.fakeNet.completeRegister();
      await waitMs(200);
      expect(fixture.sink.successValues.length).assertEqual(eventsBefore);
    });

    it('onCancel_withoutListen_isSafe', 0, () => {
      const fixture: ReceiverFixture = new ReceiverFixture();
      let thrown: boolean = false;
      try {
        fixture.receiver.onCancel();
      } catch (e) {
        thrown = true;
      }
      expect(thrown).assertFalse();
      expect(fixture.fakeNet.unregisterCount).assertEqual(0);
    });

    it('second_onListen_reRegistersCleanly', 0, () => {
      const fixture: ReceiverFixture = new ReceiverFixture();
      fixture.listen();
      fixture.listen();
      // The re-listen must clean up the previous subscription first...
      expect(fixture.fakeNet.unregisterCount).assertEqual(1);
      // ...then subscribe again, without duplicating event handlers.
      expect(fixture.fakeNet.registerCount).assertEqual(2);
      expect(fixture.fakeNet.subscribedTypes.length).assertEqual(5);
      fixture.receiver.onCancel();
      expect(fixture.fakeNet.unregisterCount).assertEqual(2);
    });

    it('eventsBeforeCancel_stillReachSink', 0, () => {
      // Cancellation only blocks pushes issued after onCancel; pushes already
      // delivered remain visible to the stream consumer.
      const fixture: ReceiverFixture = new ReceiverFixture();
      fixture.listen();
      fixture.fakeNet.emit('netUnavailable', null);
      expect(fixture.sink.successValues.length).assertEqual(1);
      fixture.receiver.onCancel();
      expect(fixture.sink.successValues.length).assertEqual(1);
    });
  });
}
