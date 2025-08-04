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
 
import {
  Any,
  EventChannel,
  EventSink,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
  StreamHandler,
} from '@ohos/flutter_ohos';
import batteryInfo from '@ohos.batteryInfo';
import power from '@ohos.power';
import { Callback } from '@kit.BasicServicesKit';

const UPDATE_INTERVAL = 200; // 监听手机充电状态时间间隔 ms

/** BatteryPlusPlugin **/
export default class BatteryPlusPlugin implements FlutterPlugin, MethodCallHandler, StreamHandler {
  private METHOD_CHANNEL: string = "dev.fluttercommunity.plus/battery";
  private EVENT_CHANNEL: string = "dev.fluttercommunity.plus/charging";
  private methodChannel: MethodChannel | null = null;
  private eventChannel: EventChannel | null = null;
  private timerId: number = -1;
  private chargeMode: string = "";
  private battery_events: EventSink | null = null;

  constructor() {
  }

  getUniqueClassName(): string {
    return "BatteryPlusPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.methodChannel = new MethodChannel(binding.getBinaryMessenger(), this.METHOD_CHANNEL);
    this.eventChannel = new EventChannel(binding.getBinaryMessenger(), this.EVENT_CHANNEL);
    this.methodChannel.setMethodCallHandler(this)
    this.eventChannel.setStreamHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.methodChannel != null) {
      this.methodChannel.setMethodCallHandler(null)
    }
    if (this.eventChannel != null) {
      this.methodChannel?.setMethodCallHandler(null)
    }
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    const callMethod = call.method;
    switch (callMethod) {
      case "getBatteryLevel":
        result.success(batteryInfo.batterySOC);
        break;
      case "getBatteryState":
        result.success(this.getChargingStatus());
        break;
      case "isInBatterySaveMode":
        // 是否是节能模式
        this.getBatteryMode(result);
        break;
      default:
        result.notImplemented();
    }
  }

  getChargingStatus(): string {
    const battertChargeState: batteryInfo.BatteryChargeState = batteryInfo.chargingStatus;
    let chargingStatusRet: string = '';
    switch (battertChargeState) {
      case batteryInfo.BatteryChargeState.NONE:
        chargingStatusRet = "unknown"
        break;
      case batteryInfo.BatteryChargeState.ENABLE:
        chargingStatusRet = "charging"
        break;
      case batteryInfo.BatteryChargeState.DISABLE:
        chargingStatusRet = "discharging"
        break;
      case batteryInfo.BatteryChargeState.FULL:
        chargingStatusRet = "full"
        break;
      default:
        chargingStatusRet = ""
        break;
    }
    return chargingStatusRet;
  }

  getBatteryMode(result: MethodResult): void {
    const powerMode = power.getPowerMode();
    if (powerMode == power.DevicePowerMode.MODE_POWER_SAVE ||
      powerMode == power.DevicePowerMode.MODE_EXTREME_POWER_SAVE) {
      result.success(true);
    } else {
      result.success(false);
    }
  }

  chargeModeCallback: Callback<EventSink> = () => {
    const battertChargeState: string = this.getChargingStatus();
    if (battertChargeState != this.chargeMode && this.battery_events) {
      this.chargeMode = battertChargeState;
      this.battery_events.success(this.chargeMode);
    }
  }

  onListen(args: Any, events: EventSink): void {
    this.battery_events = events;
    this.timerId = setInterval(this.chargeModeCallback, UPDATE_INTERVAL);
  }

  onCancel(args: Any): void {
    if (this.timerId != -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }
}
