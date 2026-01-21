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
  BinaryMessenger,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodChannel,
  MethodResult,
  EventChannel,
} from '@ohos/flutter_ohos';
import { sensor } from '@kit.SensorServiceKit';
import { StreamHandlerImpl } from './StreamHandlerImpl';


/** SensorsPlusOhosPlugin **/
export default class SensorsPlusOhosPlugin implements FlutterPlugin {
  private channel: MethodChannel | null = null;
  private ACCELEROMETER_CHANNEL_NAME: string = "dev.fluttercommunity.plus/sensors/accelerometer";
  private GYROSCOPE_CHANNEL_NAME: string = "dev.fluttercommunity.plus/sensors/gyroscope";
  private MAGNETOMETER_CHANNEL_NAME: string = "dev.fluttercommunity.plus/sensors/magnetometer";
  private USER_ACCELEROMETER_CHANNEL_NAME: string = "dev.fluttercommunity.plus/sensors/user_accel";
  private METHOD_CHANNEL_NAME: string = "dev.fluttercommunity.plus/sensors/method"
  private userAccelerometerChannel?: EventChannel;
  private gyroscopeChannel?: EventChannel;
  private accelerometerChannel?: EventChannel;
  private magnetometerChannel?: EventChannel;
  private userAccelerationStreamHandler?: StreamHandlerImpl;
  private gyroScopeStreamHandler?: StreamHandlerImpl;
  private accelerationStreamHandler?: StreamHandlerImpl;
  private magnetometerStreamHandler?: StreamHandlerImpl;

  constructor() {
  }

  getUniqueClassName(): string {
    return "SensorsPlusOhosPlugin";
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.setupMethodChannel(binding.getBinaryMessenger());
    this.setupEventChannels(binding.getBinaryMessenger());
  }


  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.teardownMethodChannel()
    this.teardownEventChannels()

  }

  setupMethodChannel(messenger: BinaryMessenger) {
    this.channel = new MethodChannel(messenger, this.METHOD_CHANNEL_NAME);
    this.channel.setMethodCallHandler({
      onMethodCall: (call: MethodCall, result: MethodResult) => {
        let streamHandler: StreamHandlerImpl | null = null;
        switch (call.method) {
          case "setAccelerationSamplingPeriod":
            streamHandler = this.accelerationStreamHandler;
            break;
          case "setUserAccelerometerSamplingPeriod":
            streamHandler = this.userAccelerationStreamHandler;
            break;
          case "setGyroscopeSamplingPeriod":
            streamHandler = this.gyroScopeStreamHandler
            break;
          case "setMagnetometerSamplingPeriod":
            streamHandler = this.magnetometerStreamHandler
            break;
          default :
            result.notImplemented()
        }
        streamHandler?.setSamplingPeriod(call.args);
        if (streamHandler) {
          result.success(null)
        } else {
          result.notImplemented()
        }
      }
    });
  }

  setupEventChannels(messenger: BinaryMessenger) {
    // user加速度计
    this.userAccelerometerChannel = new EventChannel(messenger, this.USER_ACCELEROMETER_CHANNEL_NAME);
    this.userAccelerationStreamHandler = new StreamHandlerImpl(sensor.SensorId.LINEAR_ACCELEROMETER);
    this.userAccelerometerChannel.setStreamHandler(this.userAccelerationStreamHandler);

    // 陀螺仪
    this.gyroscopeChannel = new EventChannel(messenger, this.GYROSCOPE_CHANNEL_NAME);
    this.gyroScopeStreamHandler = new StreamHandlerImpl(sensor.SensorId.GYROSCOPE);
    this.gyroscopeChannel.setStreamHandler(this.gyroScopeStreamHandler);

    // 加速度计
    this.accelerometerChannel = new EventChannel(messenger, this.ACCELEROMETER_CHANNEL_NAME);
    this.accelerationStreamHandler = new StreamHandlerImpl(sensor.SensorId.ACCELEROMETER);
    this.accelerometerChannel.setStreamHandler(this.accelerationStreamHandler);

    // 磁力计
    this.magnetometerChannel = new EventChannel(messenger, this.MAGNETOMETER_CHANNEL_NAME);
    this.magnetometerStreamHandler = new StreamHandlerImpl(sensor.SensorId.MAGNETIC_FIELD);
    this.magnetometerChannel.setStreamHandler(this.magnetometerStreamHandler);
  }

  teardownMethodChannel() {
    this.channel?.setMethodCallHandler(null);
  }

  teardownEventChannels() {
    this.accelerometerChannel?.setStreamHandler(null)
    this.userAccelerometerChannel?.setStreamHandler(null)
    this.gyroscopeChannel?.setStreamHandler(null)
    this.magnetometerChannel?.setStreamHandler(null)

    this.userAccelerationStreamHandler?.onCancel(null)
    this.gyroScopeStreamHandler?.onCancel(null)
    this.accelerationStreamHandler?.onCancel(null)
    this.magnetometerStreamHandler?.onCancel(null)
  }
}