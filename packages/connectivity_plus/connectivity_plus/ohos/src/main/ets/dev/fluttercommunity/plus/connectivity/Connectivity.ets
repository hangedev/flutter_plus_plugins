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

import connection from '@ohos.net.connection'
import { ArrayList } from '@kit.ArkTS';

const TAG = 'Connectivity';

// 注意：OHOS 的 NetBearType 与 Android 的 NetworkCapabilities.TRANSPORT_* 语义对应：
//   BEARER_CELLULAR  -> mobile   (对应 Android TRANSPORT_CELLULAR)
//   BEARER_WIFI      -> wifi     (对应 Android TRANSPORT_WIFI)
//   BEARER_BLUETOOTH -> bluetooth(对应 Android TRANSPORT_BLUETOOTH, @since API 12)
//   BEARER_ETHERNET  -> ethernet (对应 Android TRANSPORT_ETHERNET)
//   BEARER_VPN       -> vpn      (对应 Android TRANSPORT_VPN, @since API 12)
// 当存在网络连接但 bearerTypes 不含任何已知类型时，回退为 "other"，
// 与 Android 的 CONNECTIVITY_OTHER 行为保持一致。
export class Connectivity {
  static readonly CONNECTIVITY_NONE = 'none';
  static readonly CONNECTIVITY_WIFI = 'wifi';
  static readonly CONNECTIVITY_MOBILE = 'mobile';
  static readonly CONNECTIVITY_ETHERNET = 'ethernet';
  static readonly CONNECTIVITY_BLUETOOTH = 'bluetooth';
  static readonly CONNECTIVITY_VPN = 'vpn';
  static readonly CONNECTIVITY_OTHER = 'other';
  // 改为实例字段：每个插件实例持有独立的 NetConnection，
  // 避免静态变量长期持有 on() 回调闭包导致 ConnectivityBroadcastReceiver 无法 GC。
  public netConnection: connection.NetConnection = connection.createNetConnection();

  constructor() {

  }

  async getNetworkTypes(): Promise<ArrayList<String>> {
    //通过异步方式获取网络信息
    // connection.getDefaultNet / getNetCapabilities 可能因权限不足或系统异常抛错，
    // 捕获后兜底返回 [CONNECTIVITY_NONE]，保证调用方总能拿到非空结果。
    try {
      const netHandle = await connection.getDefaultNet();
      if (netHandle.netId == 0) {
        const types: ArrayList<String> = new ArrayList();
        types.add(Connectivity.CONNECTIVITY_NONE);
        return types;
      }
      const capabilities = await connection.getNetCapabilities(netHandle);
      return this.hasTransport(capabilities.bearerTypes);
    } catch (e) {
      const types: ArrayList<String> = new ArrayList();
      types.add(Connectivity.CONNECTIVITY_NONE);
      return types;
    }
  }

  // 与 Android getCapabilitiesList 对齐：使用独立 if 遍历所有传输类型，
  // 可返回多个匹配类型（如 WiFi + VPN），而非命中首个即返回。
  hasTransport(capabilities: Array<number>): ArrayList<String> {
    const types: ArrayList<String> = new ArrayList();
    //若数组为空返回CONNECTIVITY_NONE
    if (capabilities.length == 0) {
      types.add(Connectivity.CONNECTIVITY_NONE);
      return types;
    }
    if (capabilities.includes(connection.NetBearType.BEARER_WIFI)) {
      types.add(Connectivity.CONNECTIVITY_WIFI);
    }
    if (capabilities.includes(connection.NetBearType.BEARER_ETHERNET)) {
      types.add(Connectivity.CONNECTIVITY_ETHERNET);
    }
    if (capabilities.includes(connection.NetBearType.BEARER_VPN)) {
      types.add(Connectivity.CONNECTIVITY_VPN);
    }
    if (capabilities.includes(connection.NetBearType.BEARER_CELLULAR)) {
      types.add(Connectivity.CONNECTIVITY_MOBILE);
    }
    if (capabilities.includes(connection.NetBearType.BEARER_BLUETOOTH)) {
      types.add(Connectivity.CONNECTIVITY_BLUETOOTH);
    }
    //存在网络连接但无已知 bearer 类型时，回退为 other，避免误报为 none
    if (types.length == 0) {
      types.add(Connectivity.CONNECTIVITY_OTHER);
    }
    return types;
  }
}
