/*
 * Copyright (C) 2024 Huawei Device Co., Ltd.
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

import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import { wifiManager } from '@kit.ConnectivityKit';
import { connection } from '@kit.NetworkKit';

/** NetworkInfoPlusOhosPlugin **/
export default class NetworkInfoPlusOhosPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;
  private wifiMessage: string | number | null = null;
  constructor() {
  }

  getUniqueClassName(): string {
    return "NetworkInfoPlusOhosPlugin";
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "dev.fluttercommunity.plus/network_info");
    this.channel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null);
    }
  }

  async getWifiName() {
    let dataSource: string | number = 0;
    let wifiMessage = await wifiManager.getLinkedInfo().then(data => {
      dataSource = data.ssid;
      return dataSource;
    }).catch((error: number) => {
      console.info("get linked info error");
    });
    return wifiMessage;
  }

  async getWifiBSSID() {
    let dataSource: string | number = 0;
    let wifiMessage = await wifiManager.getLinkedInfo().then(data => {
      dataSource = data.bssid;
      return dataSource;
    }).catch((error: number) => {
      console.info("get linked info error");
    });
    return wifiMessage;
  }

  getWifiIPAddress() {
    const bytes = [wifiManager.getIpInfo().ipAddress >>> 24, (wifiManager.getIpInfo().ipAddress >>> 16) & 0xFF,
      (wifiManager.getIpInfo().ipAddress >>> 8) & 0xFF, wifiManager.getIpInfo().ipAddress & 0xFF];
    let ipv4 = wifiManager.getIpInfo().ipAddress;
    if (ipv4 === 0) {
      return 'null';
    }
    let dataSource = bytes.map(byte => byte.toString()).join('.');
    return dataSource;
  }

  ipToInt(ip: string): number {
    let parts = ip.split('.'); 
    let num = 0;
    for (let i = 0; i < parts.length; i++) {
      num |= parseInt(parts[i], 10) << (24 - 8 * i); 
    }
    return num;
  }

  intToIp(num: number): string {
    let parts:number[] = [];
    for (let i = 0; i < 4; i++) {
      parts.push((num >> (24 - 8 * i)) & 0xFF);
    }
    return parts.join('.');
  }

  getBroadcastIP() {
    const ipInt:number = this.ipToInt(this.getWifiIPAddress() as string);
    const subnetMaskInt = this.ipToInt(this.getWifiSubnetMask() as string);
    const broadcastInt = (ipInt & subnetMaskInt) | (~subnetMaskInt);
    if (broadcastInt === 0) {
      return null;
    }
    return this.intToIp(broadcastInt);
  }

  getWifiSubnetMask() {
    try {
      const binaryStr = wifiManager.getIpInfo().netmask.toString(2);
      const info:number[] = [];
      for (let i = 0; i < 4; i++) {
        const octet = parseInt(binaryStr.slice(i * 8, (i + 1) * 8), 2);
        info.push(octet);
      }
      if (wifiManager.getIpInfo().netmask ===0) {
        return '';
      }
      return info.join('.');
    }catch(error){
      console.error("failed:" + JSON.stringify(error));
    }
    return null;
  }

  getGatewayIPAddress() {
    try {
      const parts = [
        (wifiManager.getIpInfo().gateway >> 24) & 0xFF,
        (wifiManager.getIpInfo().gateway >> 16) & 0xFF,
        (wifiManager.getIpInfo().gateway >> 8) & 0xFF,
        wifiManager.getIpInfo().gateway & 0xFF
      ];
      if (wifiManager.getIpInfo().gateway === 0) {
        return null;
      }
      return parts.map(part => part.toString()).join('.');
    }catch(error){
      console.error("failed:" + JSON.stringify(error));
    }
    return null;
  }

  getIpV6() {
    try {
      let info = wifiManager.getIpv6Info().linkIpv6Address;
      if (info === '') {
        return null;
      }
      return info;
    }catch(error){
      console.error("failed:" + JSON.stringify(error));
    }
    return null;
  }

  //需要权限 ohos.permission.GET_WIFI_INFO
  onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case "wifiName":
        this.getWifiName().then(data =>{
          if (!data) {
            result.success(null);
            return;
          }
          result.success(data);
        })
        break;
      case "wifiBSSID":
        this.getWifiBSSID().then(data =>{
          if (!data) {
            result.success('02:00:00:00:00:00');
            return;
          }
          result.success(data);
        })
        break;
      case "wifiIPAddress":
        result.success(this.getWifiIPAddress());
        break;
      case "wifiBroadcast":
        result.success(this.getBroadcastIP());
        break;
      case "wifiSubmask":
        result.success(this.getWifiSubnetMask());
        break;
      case "wifiGatewayAddress":
        result.success(this.getGatewayIPAddress());
        break;
      case "wifiIPv6Address":
        result.success(this.getIpV6());
        break;
      default:
        result.notImplemented();
        break;
    }
  }
}