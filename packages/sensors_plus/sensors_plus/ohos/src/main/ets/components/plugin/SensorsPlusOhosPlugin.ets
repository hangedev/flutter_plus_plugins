/**
 MIT License

 Copyright (c) 2024 zmtzawqlp

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import {
  FlutterPlugin,
  FlutterPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import MethodChannel, {
  MethodCallHandler,
  MethodResult
} from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
import EventChannel from '@ohos/flutter_ohos/src/main/ets/plugin/common/EventChannel';
import {
  AccelerometerStreamHandlerPlus,
  GyroscopeStreamHandlerPlus,
  MagnetometerStreamHandlerPlus,
  PressureStreamHandlerPlus,
  SensorStreamHandlerImpl,
  UserAccelerometerStreamHandlerPlus
} from './StreamHandlerPlus';

/** SensorsPlusOhosPlugin **/
export default class SensorsPlusOhosPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;
  private METHOD_CHANNEL_NAME = "dev.fluttercommunity.plus/sensors/method";
  private ACCELEROMETER_CHANNEL_NAME = 'dev.fluttercommunity.plus/sensors/accelerometer';
  private USER_ACCELEROMETER_CHANNEL_NAME = 'dev.fluttercommunity.plus/sensors/user_accel';
  private GYROSCOPE_CHANNEL_NAME = 'dev.fluttercommunity.plus/sensors/gyroscope';
  private MAGNETOMETER_CHANNEL_NAME = 'dev.fluttercommunity.plus/sensors/magnetometer';
  private BAROMETER_CHANNEL_NAME = 'dev.fluttercommunity.plus/sensors/barometer';
  private accelerometerChannel: EventChannel | null = null;
  private gyroscopeChannel: EventChannel | null = null;
  private magnetometerChannel: EventChannel | null = null;
  private userAccelerometerChannel: EventChannel | null = null;
  private barometerChannel: EventChannel | null = null;
  private accelerometerStreamHandler: SensorStreamHandlerImpl | undefined
  private userAccelerometerStreamHandler: SensorStreamHandlerImpl | undefined
  private gyroscopeStreamHandler: SensorStreamHandlerImpl | undefined
  private magnetometerStreamHandler: SensorStreamHandlerImpl | undefined
  private barometerStreamHandler: SensorStreamHandlerImpl | undefined

  getUniqueClassName(): string {
    return "SensorsPlusOhosPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), this.METHOD_CHANNEL_NAME);
    this.channel.setMethodCallHandler(this)
    this.setupEventChannels(binding);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
    // 传感器通道释放
    this.accelerometerChannel?.setStreamHandler(null);
    this.userAccelerometerChannel?.setStreamHandler(null);
    this.gyroscopeChannel?.setStreamHandler(null);
    this.magnetometerChannel?.setStreamHandler(null);
    this.barometerChannel?.setStreamHandler(null);
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    let streamHandler: SensorStreamHandlerImpl | undefined;
    switch (call.method) {
      case "setAccelerationSamplingPeriod":
        streamHandler = this.accelerometerStreamHandler;
        break;
      case "setUserAccelerometerSamplingPeriod":
        streamHandler = this.userAccelerometerStreamHandler;
        break;
      case "setGyroscopeSamplingPeriod":
        streamHandler = this.gyroscopeStreamHandler;
        break;
      case "setMagnetometerSamplingPeriod":
        streamHandler = this.magnetometerStreamHandler;
        break;
      case "setBarometerSamplingPeriod":
        streamHandler = this.barometerStreamHandler;
        break;
      default:
        streamHandler = undefined;
    }

    if (streamHandler) {
      streamHandler.samplingPeriod = call.args as number;
      result.success(null);
    } else {
      result.notImplemented();
    }
  }

  setupEventChannels(binding: FlutterPluginBinding): void {
    this.accelerometerChannel = new EventChannel(binding.getBinaryMessenger(), this.ACCELEROMETER_CHANNEL_NAME);
    this.accelerometerStreamHandler = AccelerometerStreamHandlerPlus();
    this.accelerometerChannel.setStreamHandler(this.accelerometerStreamHandler);

    this.userAccelerometerChannel =
      new EventChannel(binding.getBinaryMessenger(), this.USER_ACCELEROMETER_CHANNEL_NAME);
    this.userAccelerometerStreamHandler = UserAccelerometerStreamHandlerPlus();
    this.userAccelerometerChannel.setStreamHandler(this.userAccelerometerStreamHandler);

    this.gyroscopeChannel = new EventChannel(binding.getBinaryMessenger(), this.GYROSCOPE_CHANNEL_NAME);
    this.gyroscopeStreamHandler = GyroscopeStreamHandlerPlus();
    this.gyroscopeChannel.setStreamHandler(this.gyroscopeStreamHandler);

    this.magnetometerChannel = new EventChannel(binding.getBinaryMessenger(), this.MAGNETOMETER_CHANNEL_NAME);
    this.magnetometerStreamHandler = MagnetometerStreamHandlerPlus();
    this.magnetometerChannel.setStreamHandler(this.magnetometerStreamHandler);

    this.barometerChannel = new EventChannel(binding.getBinaryMessenger(), this.BAROMETER_CHANNEL_NAME);
    this.barometerStreamHandler = PressureStreamHandlerPlus();
    this.barometerChannel.setStreamHandler(this.barometerStreamHandler);
  }
}
