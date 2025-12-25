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

// IP地址位运算相关常量
const BYTE_MASK = 0xFF;              // 字节掩码，用于提取8位数据
const SHIFT_24_BITS = 24;            // 右移24位，获取最高字节
const SHIFT_16_BITS = 16;            // 右移16位，获取第二字节
const SHIFT_8_BITS = 8;              // 右移8位，获取第三字节
const IP_BYTES_COUNT = 4;            // IP地址由4个字节组成
const RADIX_DECIMAL = 10;            // 十进制基数

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
    // 获取Wi-Fi的IPv4地址（32位整数格式）
    let ipv4 = wifiManager.getIpInfo().ipAddress;
    
    // 如果IP地址为0，表示未连接Wi-Fi或无有效IP，返回null
    if (ipv4 === 0) {
      return null;
    }
    
    // 将32位整数形式的IP地址转换为4个字节的数组
    // 通过位运算提取每个字节：从高位到低位依次提取
    const bytes = [
      ipv4 >>> SHIFT_24_BITS,                    // 第1个字节（最高位）
      (ipv4 >>> SHIFT_16_BITS) & BYTE_MASK,      // 第2个字节
      (ipv4 >>> SHIFT_8_BITS) & BYTE_MASK,       // 第3个字节
      ipv4 & BYTE_MASK                           // 第4个字节（最低位）
    ];
    
    // 将字节数组转换为字符串数组，然后用点号连接成标准的IP地址格式（如：192.168.1.1）
    let dataSource = bytes.map(byte => byte.toString()).join('.');
    
    // 返回格式化后的IP地址字符串
    return dataSource;
  }

  ipToInt(ip: string): number {
    // 将IP地址字符串按点号分割成4个部分
    let parts = ip.split('.');
    let num = 0;
    // 遍历4个字节，将每个字节左移到对应位置并合并
    for (let i = 0; i < parts.length; i++) {
      // 将字符串转换为十进制数，然后左移到对应位置
      // i=0: 左移24位（最高字节）
      // i=1: 左移16位（第二字节）
      // i=2: 左移8位（第三字节）
      // i=3: 左移0位（最低字节）
      num |= parseInt(parts[i], RADIX_DECIMAL) << (SHIFT_24_BITS - SHIFT_8_BITS * i);
    }
    return num;
  }

  intToIp(num: number): string {
    let parts:number[] = [];
    // 遍历4个字节，从高位到低位依次提取
    for (let i = 0; i < IP_BYTES_COUNT; i++) {
      // 右移对应位数后与字节掩码进行按位与，提取每个字节
      // i=0: 右移24位，提取最高字节
      // i=1: 右移16位，提取第二字节
      // i=2: 右移8位，提取第三字节
      // i=3: 右移0位，提取最低字节
      parts.push((num >> (SHIFT_24_BITS - SHIFT_8_BITS * i)) & BYTE_MASK);
    }
    // 将字节数组用点号连接成IP地址字符串
    return parts.join('.');
  }

  getBroadcastIP() {
    if (this.getWifiIPAddress()) {
      const ipInt:number = this.ipToInt(this.getWifiIPAddress() as string);
      const subnetMaskInt = this.ipToInt(this.getWifiSubnetMask() as string);
      const broadcastInt = (ipInt & subnetMaskInt) | (~subnetMaskInt);
      return this.intToIp(broadcastInt);
    } else {
      return null;
    }
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
      // 获取网关IP地址（32位整数格式）
      const gatewayIp = wifiManager.getIpInfo().gateway;
      
      // 如果网关地址为0，表示无有效网关，返回null
      if (gatewayIp === 0) {
        return null;
      }
      
      // 将32位整数形式的网关地址转换为4个字节的数组
      // 通过位运算提取每个字节：从高位到低位依次提取
      const parts = [
        (gatewayIp >> SHIFT_24_BITS) & BYTE_MASK,  // 第1个字节（最高位）
        (gatewayIp >> SHIFT_16_BITS) & BYTE_MASK,  // 第2个字节
        (gatewayIp >> SHIFT_8_BITS) & BYTE_MASK,   // 第3个字节
        gatewayIp & BYTE_MASK                      // 第4个字节（最低位）
      ];
      
      // 将字节数组转换为字符串数组，然后用点号连接成标准的IP地址格式
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
            result.success(null);
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
