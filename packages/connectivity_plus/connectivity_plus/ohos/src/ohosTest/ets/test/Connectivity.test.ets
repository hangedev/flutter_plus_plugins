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
import { Connectivity } from '../../../main/ets/dev/fluttercommunity/plus/connectivity/Connectivity';
import connection from '@ohos.net.connection';

const KNOWN_TYPES: Array<string> = ['none', 'wifi', 'mobile', 'ethernet', 'bluetooth', 'vpn', 'other'];

export default function connectivityTest() {
  describe('ConnectivityConstantsTest', () => {
    // The Dart side maps these strings to its ConnectivityResult enum;
    // renaming any of them silently breaks the platform contract.
    it('constants_exposeDartSideTypeNames', 0, () => {
      expect(Connectivity.CONNECTIVITY_NONE).assertEqual('none');
      expect(Connectivity.CONNECTIVITY_WIFI).assertEqual('wifi');
      expect(Connectivity.CONNECTIVITY_MOBILE).assertEqual('mobile');
      expect(Connectivity.CONNECTIVITY_ETHERNET).assertEqual('ethernet');
      expect(Connectivity.CONNECTIVITY_BLUETOOTH).assertEqual('bluetooth');
      expect(Connectivity.CONNECTIVITY_VPN).assertEqual('vpn');
      expect(Connectivity.CONNECTIVITY_OTHER).assertEqual('other');
    });
  });

  describe('ConnectivityHasTransportTest', () => {
    // Pure mapping from OHOS bearer types to Flutter-side names; every
    // branch is covered deterministically without touching the system.
    let connectivity: Connectivity = new Connectivity();

    beforeAll(() => {
      connectivity = new Connectivity();
    });

    it('emptyBearerTypes_reportsNone', 0, () => {
      const types = connectivity.hasTransport([]);
      expect(types.length).assertEqual(1);
      expect(types[0]).assertEqual('none');
    });

    it('wifiBearer_reportsWifi', 0, () => {
      const types = connectivity.hasTransport([connection.NetBearType.BEARER_WIFI]);
      expect(types.length).assertEqual(1);
      expect(types[0]).assertEqual('wifi');
    });

    it('cellularBearer_reportsMobile', 0, () => {
      const types = connectivity.hasTransport([connection.NetBearType.BEARER_CELLULAR]);
      expect(types.length).assertEqual(1);
      expect(types[0]).assertEqual('mobile');
    });

    it('ethernetBearer_reportsEthernet', 0, () => {
      const types = connectivity.hasTransport([connection.NetBearType.BEARER_ETHERNET]);
      expect(types.length).assertEqual(1);
      expect(types[0]).assertEqual('ethernet');
    });

    it('bluetoothBearer_reportsBluetooth', 0, () => {
      const types = connectivity.hasTransport([connection.NetBearType.BEARER_BLUETOOTH]);
      expect(types.length).assertEqual(1);
      expect(types[0]).assertEqual('bluetooth');
    });

    it('vpnBearer_reportsVpn', 0, () => {
      const types = connectivity.hasTransport([connection.NetBearType.BEARER_VPN]);
      expect(types.length).assertEqual(1);
      expect(types[0]).assertEqual('vpn');
    });

    it('multipleBearers_reportAllMatchesInFixedOrder', 0, () => {
      // All matching transports are collected (like Android getCapabilitiesList),
      // ordered wifi -> ethernet -> vpn -> mobile -> bluetooth.
      const types = connectivity.hasTransport(
        [connection.NetBearType.BEARER_WIFI, connection.NetBearType.BEARER_VPN]);
      expect(types.length).assertEqual(2);
      expect(types[0]).assertEqual('wifi');
      expect(types[1]).assertEqual('vpn');

      const mixed = connectivity.hasTransport(
        [connection.NetBearType.BEARER_CELLULAR, connection.NetBearType.BEARER_WIFI]);
      expect(mixed.length).assertEqual(2);
      expect(mixed[0]).assertEqual('wifi');
      expect(mixed[1]).assertEqual('mobile');
    });

    it('unknownBearer_fallsBackToOther', 0, () => {
      // Connected, but no known bearer type: must be "other", not "none".
      const types = connectivity.hasTransport([99]);
      expect(types.length).assertEqual(1);
      expect(types[0]).assertEqual('other');
    });

    it('unknownBearer_alongsideKnownBearer_isIgnored', 0, () => {
      const types = connectivity.hasTransport([99, connection.NetBearType.BEARER_WIFI]);
      expect(types.length).assertEqual(1);
      expect(types[0]).assertEqual('wifi');
    });
  });

  describe('ConnectivityDeviceTest', () => {
    // getNetworkTypes touches the real network stack; the plugin's contract
    // is that it never throws and always returns a non-empty list of known
    // type names (falling back to [none] when the network can't be queried).
    it('getNetworkTypes_neverThrows_returnsNonEmptyKnownTypes', 0, async () => {
      const types = await new Connectivity().getNetworkTypes();
      expect(types != null).assertTrue();
      expect(types.length > 0).assertTrue();
      for (let i = 0; i < types.length; i++) {
        expect(KNOWN_TYPES.includes(types[i] as string)).assertTrue();
      }
    });

    it('netConnection_isPerInstance_notSharedStatically', 0, () => {
      // Each plugin instance must own its NetConnection so detaching one
      // instance never unregisters another's callbacks.
      const first: Connectivity = new Connectivity();
      const second: Connectivity = new Connectivity();
      expect(first.netConnection != null).assertTrue();
      expect(second.netConnection != null).assertTrue();
      expect(first.netConnection === second.netConnection).assertFalse();
    });
  });
}
