/*
 * Copyright (C) 2025 Huawei Device Co., Ltd.
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

import { MethodCall, MethodCallHandler, MethodResult } from '@ohos/flutter_ohos';
import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';
import deviceInfo from '@ohos.deviceInfo';

const TAG = 'DeviceMethodHandler';

export class DeviceMethodHandler implements MethodCallHandler {
  constructor() {
  }

  /**
   * Handles incoming Flutter MethodChannel calls.
   *
   * Any synchronous exception (bad arguments, unexpected error) is caught and
   * {@link deviceInfoAssemble} Promise also reports rejections through a
   * `.catch()` so the Flutter side always receives a reply (success / error /
   * not-implemented) and never hangs.
   *
   * @param call   The method invocation from Flutter (method name + args).
   * @param result The callback used to reply to Flutter.
   */
  onMethodCall(call: MethodCall, result: MethodResult): void {
    Log.d(TAG, 'onMethodCall step in');
    // Wrap the whole handler so any thrown exception is converted into a
    // result.error() reply instead of leaving the Flutter MethodChannel call
    // pending (no reply) and risking an uncaught exception in the plugin.
    if (!call || !call.method) {
      result.error('INVALID_ARGUMENT', 'Method call or method name is null', null);
      return;
    }
    try {
      switch (call.method) {
        case 'getDeviceInfo':
          this.deviceInfoAssemble().then((data: Map<string, Object>) => {
            result.success(data);
          }).catch((e: Error) => {
            result.error('DEVICE_INFO_ERROR', e.message, e);
          });
          break;
        default:
          result.notImplemented();
          break;
      }
    } catch (e) {
      result.error('UNHANDLED_ERROR', String(e), e);
    }
  }

  /**
   * Assembles the OpenHarmony device information map by reading the public
   * properties of `@ohos.deviceInfo`. `serial` and `udid` are intentionally
   * omitted (no corresponding API on ohos -> null on the Dart side).
   *
   * @returns A Promise resolving to the field map consumed by the plugin's
   *          Dart model (`OhosDeviceInfo.fromMap`).
   */
  async deviceInfoAssemble(): Promise<Map<string, Object>> {
    let data: Map<string, Object> = new Map();
    data.set('deviceType', deviceInfo.deviceType);
    data.set('manufacture', deviceInfo.manufacture);
    data.set('brand', deviceInfo.brand);
    data.set('marketName', deviceInfo.marketName);
    data.set('productSeries', deviceInfo.productSeries);
    data.set('productModel', deviceInfo.productModel);
    data.set('softwareModel', deviceInfo.softwareModel);
    data.set('hardwareModel', deviceInfo.hardwareModel);
    data.set('hardwareProfile', deviceInfo.hardwareProfile);
    // serial / udid are intentionally NOT set: @ohos.deviceInfo exposes no
    // corresponding API for them on the ohos platform, so the two fields are
    // unavailable and always read null on the Dart side (String?). See the
    // "Known Issues" section of README.OpenHarmony.md.
    data.set('bootloaderVersion', deviceInfo.bootloaderVersion);
    data.set('abiList', deviceInfo.abiList);
    data.set('securityPatchTag', deviceInfo.securityPatchTag);
    data.set('displayVersion', deviceInfo.displayVersion);
    data.set('incrementalVersion', deviceInfo.incrementalVersion);
    data.set('osReleaseType', deviceInfo.osReleaseType);
    data.set('osFullName', deviceInfo.osFullName);
    data.set('majorVersion', deviceInfo.majorVersion);
    data.set('seniorVersion', deviceInfo.seniorVersion);
    data.set('featureVersion', deviceInfo.featureVersion);
    data.set('buildVersion', deviceInfo.buildVersion);
    data.set('sdkApiVersion', deviceInfo.sdkApiVersion);
    data.set('firstApiVersion', deviceInfo.firstApiVersion);
    data.set('versionId', deviceInfo.versionId);
    data.set('buildType', deviceInfo.buildType);
    data.set('buildUser', deviceInfo.buildUser);
    data.set('buildHost', deviceInfo.buildHost);
    data.set('buildTime', deviceInfo.buildTime);
    data.set('buildRootHash', deviceInfo.buildRootHash);
    data.set('distributionOSName', deviceInfo.distributionOSName);
    data.set('distributionOSVersion', deviceInfo.distributionOSVersion);
    data.set('distributionOSApiVersion', deviceInfo.distributionOSApiVersion);
    data.set('distributionOSReleaseType', deviceInfo.distributionOSReleaseType);
    data.set('ODID', deviceInfo.ODID);
    return data;
  }
}
