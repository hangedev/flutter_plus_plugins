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
import ConnectivityMethodChannelHandler
  from '../../../main/ets/dev/fluttercommunity/plus/connectivity/ConnectivityMethodChannelHandler';
import { Connectivity } from '../../../main/ets/dev/fluttercommunity/plus/connectivity/Connectivity';
import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
import { ArrayList } from '@kit.ArkTS';
import { MockMethodResult, waitUntil } from './TestMocks';

export default function connectivityMethodChannelHandlerTest() {
  describe('ConnectivityMethodChannelHandlerTest', () => {
    // Method routing is synchronous and deterministic; the 'check' branch is
    // async (OHOS network queries are promise-based) but always delivers
    // exactly one well-formed result to the Flutter side.
    let handler: ConnectivityMethodChannelHandler = new ConnectivityMethodChannelHandler(new Connectivity());

    beforeAll(() => {
      handler = new ConnectivityMethodChannelHandler(new Connectivity());
    });

    it('onMethodCall_unknownMethod_reportsNotImplemented', 0, () => {
      const mockResult: MockMethodResult = new MockMethodResult();
      handler.onMethodCall(new MethodCall('noSuchMethod', null), mockResult);
      expect(mockResult.isNotImplementedCalled).assertTrue();
      expect(mockResult.callCount).assertEqual(1);
      expect(mockResult.isSuccessCalled).assertFalse();
      expect(mockResult.isErrorCalled).assertFalse();
    });

    it('onMethodCall_methodMatchIsCaseSensitive', 0, () => {
      // A case-variant of the known name must not be routed to check.
      const mockResult: MockMethodResult = new MockMethodResult();
      handler.onMethodCall(new MethodCall('Check', null), mockResult);
      expect(mockResult.isNotImplementedCalled).assertTrue();
      expect(mockResult.isSuccessCalled).assertFalse();
    });

    it('onMethodCall_check_routesToAsyncResult', 0, async () => {
      // onMethodCall dispatches the async check without awaiting; poll until
      // the result reaches the Flutter-side MethodResult.
      const mockResult: MockMethodResult = new MockMethodResult();
      handler.onMethodCall(new MethodCall('check', null), mockResult);
      const delivered: boolean = await waitUntil((): boolean => mockResult.callCount > 0, 3000);
      expect(delivered).assertTrue();
      expect(mockResult.isSuccessCalled).assertTrue();
      expect(mockResult.isNotImplementedCalled).assertFalse();
      expect(mockResult.isErrorCalled).assertFalse();
      const types: ArrayList<String> = mockResult.successValue as ArrayList<String>;
      expect(types.length > 0).assertTrue();
    });

    it('handleCheckResult_deliversSuccessExactlyOnce', 0, async () => {
      // Deterministic direct call: getNetworkTypes resolves internally and
      // the handler reports success exactly once with a non-empty list.
      const mockResult: MockMethodResult = new MockMethodResult();
      await handler.handleCheckResult(mockResult);
      expect(mockResult.isSuccessCalled).assertTrue();
      expect(mockResult.callCount).assertEqual(1);
      expect(mockResult.isErrorCalled).assertFalse();
      expect(mockResult.isNotImplementedCalled).assertFalse();
      const types: ArrayList<String> = mockResult.successValue as ArrayList<String>;
      expect(types.length > 0).assertTrue();
    });
  });
}
