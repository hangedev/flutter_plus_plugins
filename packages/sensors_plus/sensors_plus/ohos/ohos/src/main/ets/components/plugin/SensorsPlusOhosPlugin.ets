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
  EventChannel,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import { EventSink, StreamHandler } from '@ohos/flutter_ohos/src/main/ets/plugin/common/EventChannel';
import { systemDateTime } from '@kit.BasicServicesKit';
import { sensor } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';

const defaultSamplingPeriodMicros = 200000;
const epochMicros = systemDateTime.getTime() * 1000;

function normalizeNumber(value: number): number {
  return Number.isInteger(value) ? value + 0.00000000001 : value;
}

function normalizeTimestamp(sensorTimestampNanos: number): number {
  return normalizeNumber(epochMicros + sensorTimestampNanos / 1000);
}

function transformThreeAxisData(
  x: number,
  y: number,
  z: number,
  timestamp: number,
): Array<number> {
  return [
    normalizeNumber(x),
    normalizeNumber(y),
    normalizeNumber(z),
    normalizeTimestamp(timestamp),
  ];
}

class SensorStreamHandlerImpl implements StreamHandler {
  private events: EventSink | null = null;
  private samplingPeriodMicros: number = defaultSamplingPeriodMicros;
  private sensorId: number;
  private transformer: (response: sensor.Response) => Array<number>;

  constructor(
    sensorId: number,
    transformer: (response: sensor.Response) => Array<number>,
  ) {
    this.sensorId = sensorId;
    this.transformer = transformer;
  }

  setSamplingPeriod(value: number): void {
    this.samplingPeriodMicros = value;
    if (this.events !== null) {
      this.resubscribe();
    }
  }

  onListen(args: ESObject, events: EventSink): void {
    this.events = events;
    this.subscribe();
  }

  onCancel(args: ESObject): void {
    this.unsubscribe();
    this.events = null;
  }

  private get samplingPeriodNanos(): number {
    return this.samplingPeriodMicros * 1000;
  }

  private callback = (response: sensor.Response): void => {
    if (this.events === null) {
      return;
    }
    this.events.success(this.transformer(response));
  };

  private subscribe(): void {
    try {
      sensor.on(this.sensorId, this.callback, { interval: this.samplingPeriodNanos });
    } catch (error) {
      const e = error as BusinessError;
      console.error(`Failed to invoke on. Code: ${e.code}, message: ${e.message}`);
    }
  }

  private unsubscribe(): void {
    try {
      sensor.off(this.sensorId, this.callback);
    } catch (error) {
      const e = error as BusinessError;
      console.error(`Failed to invoke off. Code: ${e.code}, message: ${e.message}`);
    }
  }

  private resubscribe(): void {
    this.unsubscribe();
    this.subscribe();
  }
}

/** SensorsPlusOhosPlugin **/
export default class SensorsPlusOhosPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;
  private ACCELEROMETER_CHANNEL_NAME: string = 'dev.fluttercommunity.plus/sensors/accelerometer';
  private GYROSCOPE_CHANNEL_NAME: string = 'dev.fluttercommunity.plus/sensors/gyroscope';
  private MAGNETOMETER_CHANNEL_NAME: string = 'dev.fluttercommunity.plus/sensors/magnetometer';
  private USER_ACCELEROMETER_CHANNEL_NAME: string = 'dev.fluttercommunity.plus/sensors/user_accel';
  private BAROMETER_CHANNEL_NAME: string = 'dev.fluttercommunity.plus/sensors/barometer';
  private accelerometerChannel: EventChannel | null = null;
  private gyroscopeChannel: EventChannel | null = null;
  private magnetometerChannel: EventChannel | null = null;
  private userAccelerometerChannel: EventChannel | null = null;
  private barometerChannel: EventChannel | null = null;
  private accelerometerStreamHandler: SensorStreamHandlerImpl | null = null;
  private gyroscopeStreamHandler: SensorStreamHandlerImpl | null = null;
  private magnetometerStreamHandler: SensorStreamHandlerImpl | null = null;
  private userAccelerometerStreamHandler: SensorStreamHandlerImpl | null = null;
  private barometerStreamHandler: SensorStreamHandlerImpl | null = null;

  constructor() {
  }

  getUniqueClassName(): string {
    return 'SensorsPlusOhosPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), 'dev.fluttercommunity.plus/sensors/method');
    this.channel.setMethodCallHandler(this);
    this.setupEventChannels(binding.getBinaryMessenger());
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null);
    }
    this.accelerometerChannel?.setStreamHandler(null);
    this.gyroscopeChannel?.setStreamHandler(null);
    this.magnetometerChannel?.setStreamHandler(null);
    this.userAccelerometerChannel?.setStreamHandler(null);
    this.barometerChannel?.setStreamHandler(null);
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    let streamHandler: SensorStreamHandlerImpl | null = null;

    switch (call.method) {
      case 'getPlatformVersion':
        result.success('OpenHarmony ^ ^ ');
        return;
      case 'setAccelerationSamplingPeriod':
        streamHandler = this.accelerometerStreamHandler;
        break;
      case 'setUserAccelerometerSamplingPeriod':
        streamHandler = this.userAccelerometerStreamHandler;
        break;
      case 'setGyroscopeSamplingPeriod':
        streamHandler = this.gyroscopeStreamHandler;
        break;
      case 'setMagnetometerSamplingPeriod':
        streamHandler = this.magnetometerStreamHandler;
        break;
      case 'setBarometerSamplingPeriod':
        streamHandler = this.barometerStreamHandler;
        break;
      default:
        result.notImplemented();
        return;
    }

    if (streamHandler === null) {
      result.notImplemented();
      return;
    }

    streamHandler.setSamplingPeriod(call.args as number);
    result.success(null);
  }

  private setupEventChannels(messenger: BinaryMessenger): void {
    this.userAccelerometerChannel = new EventChannel(messenger, this.USER_ACCELEROMETER_CHANNEL_NAME);
    this.userAccelerometerStreamHandler = new SensorStreamHandlerImpl(
      sensor.SensorId.LINEAR_ACCELEROMETER,
      (response: sensor.Response) => {
        const data = response as sensor.LinearAccelerometerResponse;
        return transformThreeAxisData(data.x, data.y, data.z, data.timestamp);
      },
    );
    this.userAccelerometerChannel.setStreamHandler(this.userAccelerometerStreamHandler);

    this.gyroscopeChannel = new EventChannel(messenger, this.GYROSCOPE_CHANNEL_NAME);
    this.gyroscopeStreamHandler = new SensorStreamHandlerImpl(
      sensor.SensorId.GYROSCOPE,
      (response: sensor.Response) => {
        const data = response as sensor.GyroscopeResponse;
        return transformThreeAxisData(data.x, data.y, data.z, data.timestamp);
      },
    );
    this.gyroscopeChannel.setStreamHandler(this.gyroscopeStreamHandler);

    this.accelerometerChannel = new EventChannel(messenger, this.ACCELEROMETER_CHANNEL_NAME);
    this.accelerometerStreamHandler = new SensorStreamHandlerImpl(
      sensor.SensorId.ACCELEROMETER,
      (response: sensor.Response) => {
        const data = response as sensor.AccelerometerResponse;
        return transformThreeAxisData(data.x, data.y, data.z, data.timestamp);
      },
    );
    this.accelerometerChannel.setStreamHandler(this.accelerometerStreamHandler);

    this.magnetometerChannel = new EventChannel(messenger, this.MAGNETOMETER_CHANNEL_NAME);
    this.magnetometerStreamHandler = new SensorStreamHandlerImpl(
      sensor.SensorId.MAGNETIC_FIELD,
      (response: sensor.Response) => {
        const data = response as sensor.MagneticFieldResponse;
        return transformThreeAxisData(data.x, data.y, data.z, data.timestamp);
      },
    );
    this.magnetometerChannel.setStreamHandler(this.magnetometerStreamHandler);

    this.barometerChannel = new EventChannel(messenger, this.BAROMETER_CHANNEL_NAME);
    this.barometerStreamHandler = new SensorStreamHandlerImpl(
      sensor.SensorId.BAROMETER,
      (response: sensor.Response) => {
        const data = response as sensor.BarometerResponse;
        return [normalizeNumber(data.pressure), normalizeTimestamp(data.timestamp)];
      },
    );
    this.barometerChannel.setStreamHandler(this.barometerStreamHandler);
  }
}
