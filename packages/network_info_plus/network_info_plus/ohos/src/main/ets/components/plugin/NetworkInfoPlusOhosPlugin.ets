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
// 统一通道错误码：native 通过 result.error() 抛出后，Flutter 端会收到对应的 PlatformException
const NETWORK_INFO_ERROR_CODE = 'network_info_error';

/** NetworkInfoPlusOhosPlugin **/
export default class NetworkInfoPlusOhosPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;
  constructor() {
  }

  getUniqueClassName(): string {
    return 'NetworkInfoPlusOhosPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    // 通道名必须与 Dart 端 MethodChannel('dev.fluttercommunity.plus/network_info') 完全一致
    this.channel = new MethodChannel(binding.getBinaryMessenger(), 'dev.fluttercommunity.plus/network_info');
    this.channel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel !== null) {
      this.channel.setMethodCallHandler(null);
      // 释放 MethodChannel 引用，避免分离后残留引用继续回调导致崩溃
      this.channel = null;
    }
  }

  async getWifiName(): Promise<string> {
    // getLinkedInfo() 在权限未授予或系统异常时会 reject；这里不再吞掉异常，
    // 直接抛出，由 onMethodCall 统一转为 PlatformException 回传 Flutter
    const data = await wifiManager.getLinkedInfo();
    return data.ssid;
  }

  async getWifiBSSID(): Promise<string> {
    const data = await wifiManager.getLinkedInfo();
    return data.bssid;
  }

  getWifiIPAddress(): string | null {
    // 获取Wi-Fi的IPv4地址（32位整数格式）；权限未授予等异常会抛出，
    // 由 onMethodCall 统一捕获并转为 PlatformException，避免直接崩溃
    const ipv4 = wifiManager.getIpInfo().ipAddress;

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
    return bytes.map(byte => byte.toString()).join('.');
  }

  ipToInt(ip: string): number {
    // 校验输入：非空字符串，避免 ipToInt('') 产生 NaN
    if (!ip) {
      throw new Error('Invalid IP address: empty input');
    }
    // 将IP地址字符串按点号分割成4个部分
    const parts = ip.split('.');
    // 校验必须为4段
    if (parts.length !== IP_BYTES_COUNT) {
      throw new Error('Invalid IP address: expected 4 octets, got ' + parts.length);
    }
    let num = 0;
    // 遍历4个字节，将每个字节左移到对应位置并合并
    for (let i = 0; i < IP_BYTES_COUNT; i++) {
      // 将字符串转换为十进制数
      const octet = parseInt(parts[i], RADIX_DECIMAL);
      // 校验每段为有效整数且在 0–255 范围内，避免 parseInt 返回 NaN 导致位运算结果不可预测
      if (Number.isNaN(octet) || octet < 0 || octet > BYTE_MASK) {
        throw new Error('Invalid IP address: octet "' + parts[i] + '" out of range');
      }
      // 左移到对应位置：
      // i=0: 左移24位（最高字节）
      // i=1: 左移16位（第二字节）
      // i=2: 左移8位（第三字节）
      // i=3: 左移0位（最低字节）
      num |= octet << (SHIFT_24_BITS - SHIFT_8_BITS * i);
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

  getBroadcastIP(): string | null {
    // 获取本机 IP；可能抛出异常（由 onMethodCall 统一处理）
    const ip = this.getWifiIPAddress();
    if (ip === null) {
      return null;
    }
    // 获取子网掩码；返回空串表示无有效子网掩码（如未连接 Wi-Fi），此时无法计算广播地址
    const subnetMask = this.getWifiSubnetMask();
    if (subnetMask === '') {
      return null;
    }
    const ipInt = this.ipToInt(ip);
    const subnetMaskInt = this.ipToInt(subnetMask);
    const broadcastInt = (ipInt & subnetMaskInt) | (~subnetMaskInt);
    return this.intToIp(broadcastInt);
  }

  getWifiSubnetMask(): string {
    // 直接读取子网掩码；权限未授予等异常会抛出，由 onMethodCall 统一处理
    const netmask = wifiManager.getIpInfo().netmask;
    // netmask 为 0 表示无有效子网掩码（如未连接 Wi-Fi），返回空串
    if (netmask === 0) {
      return '';
    }
    const binaryStr = netmask.toString(2);
    const info: number[] = [];
    for (let i = 0; i < IP_BYTES_COUNT; i++) {
      const octet = parseInt(binaryStr.slice(i * 8, (i + 1) * 8), 2);
      info.push(octet);
    }
    return info.join('.');
  }

  getGatewayIPAddress(): string | null {
    // 获取网关IP地址（32位整数格式）；权限未授予等异常会抛出，由 onMethodCall 统一处理
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
  }

  getIpV6(): string | null {
    // 获取IPv6地址；权限未授予等异常会抛出，由 onMethodCall 统一处理
    const info = wifiManager.getIpv6Info().linkIpv6Address;
    if (info === '') {
      return null;
    }
    return info;
  }

  // 将异常转为 PlatformException 回传 Flutter，并输出日志便于定位
  private replyError(result: MethodResult, method: string, detail: string): void {
    console.error(method + ' failed: ' + detail);
    result.error(NETWORK_INFO_ERROR_CODE, 'Failed to get ' + method, detail);
  }

  // 同步获取网络信息并回传；异常转为 PlatformException，避免 native 崩溃
  private replyWith(result: MethodResult, method: string, producer: () => string | null): void {
    // 引擎已分离时不再操作 result，避免在分离后回调导致崩溃
    if (this.channel === null) {
      return;
    }
    try {
      result.success(producer());
    } catch (e) {
      this.replyError(result, method, JSON.stringify(e));
    }
  }

  // 异步获取网络信息并回传；rejected 转为 PlatformException，避免 native 崩溃
  private replyWithAsync(result: MethodResult, method: string, future: Promise<string>): void {
    future.then((data: string) => {
      if (this.channel === null) {
        return;
      }
      // 与原逻辑保持一致：无有效值（空串等）统一回传 null
      result.success(data ? data : null);
    }).catch((e: Object) => {
      if (this.channel === null) {
        return;
      }
      this.replyError(result, method, JSON.stringify(e));
    });
  }

  //需要权限 ohos.permission.GET_WIFI_INFO
  onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case 'wifiName':
        this.replyWithAsync(result, 'wifiName', this.getWifiName());
        break;
      case 'wifiBSSID':
        this.replyWithAsync(result, 'wifiBSSID', this.getWifiBSSID());
        break;
      case 'wifiIPAddress':
        this.replyWith(result, 'wifiIPAddress', () => this.getWifiIPAddress());
        break;
      case 'wifiBroadcast':
        this.replyWith(result, 'wifiBroadcast', () => this.getBroadcastIP());
        break;
      case 'wifiSubmask':
        this.replyWith(result, 'wifiSubmask', () => this.getWifiSubnetMask());
        break;
      case 'wifiGatewayAddress':
        this.replyWith(result, 'wifiGatewayAddress', () => this.getGatewayIPAddress());
        break;
      case 'wifiIPv6Address':
        this.replyWith(result, 'wifiIPv6Address', () => this.getIpV6());
        break;
      default:
        result.notImplemented();
        break;
    }
  }
}
