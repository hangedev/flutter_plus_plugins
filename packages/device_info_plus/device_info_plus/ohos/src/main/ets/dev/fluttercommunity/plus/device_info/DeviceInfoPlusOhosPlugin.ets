/*
* Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
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

import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';
import {
  FlutterPlugin,
  FlutterPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import MethodChannel from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import { DeviceMethodHandler } from './DeviceMethodHandler'

const TAG = 'DeviceInfoPlusOhosPlugin';
const CHANNEL_NAME = 'dev.fluttercommunity.plus/device_info';

/**
 * OpenHarmony (ohos) implementation of the `device_info_plus` plugin.
 *
 * Registers a [MethodChannel] with a [DeviceMethodHandler] when the Flutter
 * engine attaches, and cleans it up on detach.
 */
export default class DeviceInfoPlusOhosPlugin implements FlutterPlugin {
  private channel: MethodChannel | null = null;

  /**
   * Returns the unique class name used by the Flutter-OHOS plugin registry
   * to identify this plugin instance.
   *
   * @returns The plugin's unique identifier string.
   */
  getUniqueClassName(): string {
    return TAG;
  }

  /**
   * Called when the Flutter engine attaches this plugin. Creates the
   * `device_info` [MethodChannel] and binds a [DeviceMethodHandler] to it.
   *
   * @param binding The Flutter plugin binding providing the binary messenger
   *                and other engine services.
   */
  onAttachedToEngine(binding: FlutterPluginBinding): void {
    Log.d(TAG, 'onAttachedToEngine local auth')
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    const deviceMethodHandler: DeviceMethodHandler = new DeviceMethodHandler();
    this.channel.setMethodCallHandler(deviceMethodHandler);
  }

  /**
   * Called when the Flutter engine detaches this plugin. Releases the
   * [MethodChannel] handler and clears the channel reference.
   *
   * @param binding The Flutter plugin binding (unused beyond lifecycle signalling).
   */
  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null);
      this.channel = null;
    }
  }
}
