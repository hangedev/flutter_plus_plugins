/*
 * Copyright (C) 2026 Huawei Device Co., Ltd.
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
import { EventSink, StreamHandler } from '@ohos/flutter_ohos';
import { sensor } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';

// StreamHandlerImpl 实现了 StreamHandler 接口
export class StreamHandlerImpl implements StreamHandler {
  private event?: EventSink;
  private sensorId?: sensor.SensorId;
  private samplingPeriod: number = 200000;

  constructor(sensorId: sensor.SensorId) {
    this.sensorId = sensorId;
  }

  setSamplingPeriod(samplingPeriod: number){
    this.samplingPeriod = samplingPeriod;
  }

  // user加速度计传感器
  private listenLinearAccelerometer(): void {
    try {
      sensor.on(sensor.SensorId.LINEAR_ACCELEROMETER, (data: sensor.LinearAccelerometerResponse) => {
        if (this.event) {
          let arr: Array<number> = [4];
          arr[0] = data.x;
          arr[1] = data.y;
          arr[2] = data.z;
          while (Number.isInteger(data.x)) {
            arr[0] = data.x + 0.00000000001;
          }
          while (Number.isInteger(data.y)) {
            arr[1] = data.y + 0.00000000001;
          }
          while (Number.isInteger(data.z)) {
            arr[2] = data.z + 0.00000000001;
          }
          this.event.success(arr);
        }
      }, { interval: this.samplingPeriod });
    } catch (error) {
      let e: BusinessError = error as BusinessError;
      console.error(`Failed to invoke on. Code: ${e.code}, message: ${e.message}`);
    }
  }

  // 陀螺仪
  private listenGyroscope(): void {
    try {
      sensor.on(sensor.SensorId.GYROSCOPE, (data: sensor.GyroscopeResponse) => {
        if (this.event) {
          let arr: Array<number> = [3];
          arr[0] = data.x;
          arr[1] = data.y;
          arr[2] = data.z;
          while (Number.isInteger(data.x)) {
            arr[0] = data.x + 0.00000000001;
          }
          while (Number.isInteger(data.y)) {
            arr[1] = data.y + 0.00000000001;
          }
          while (Number.isInteger(data.z)) {
            arr[2] = data.z + 0.00000000001;
          }
          this.event.success(arr);
        }
      }, { interval: this.samplingPeriod });
    } catch (error) {
      let e: BusinessError = error as BusinessError;
      console.error(`Failed to invoke on. Code: ${e.code}, message: ${e.message}`);
    }
  }

  // 加速度计
  private listenAccelerometer(): void {
    try {
      sensor.on(sensor.SensorId.ACCELEROMETER, (data: sensor.AccelerometerResponse) => {
        if (this.event) {
          let arr: Array<number> = [3];
          arr[0] = data.x;
          arr[1] = data.y;
          arr[2] = data.z;
          while (Number.isInteger(data.x)) {
            arr[0] = data.x + 0.00000000001;
          }
          while (Number.isInteger(data.y)) {
            arr[1] = data.y + 0.00000000001;
          }
          while (Number.isInteger(data.z)) {
            arr[2] = data.z + 0.00000000001;
          }
          this.event.success(arr);
        }
      }, { interval: this.samplingPeriod });
    } catch (error) {
      let e: BusinessError = error as BusinessError;
      console.error(`Failed to invoke on. Code: ${e.code}, message: ${e.message}`);
    }
  }

  // 磁力计
  private listenMagnetic(): void {
    try {
      sensor.on(sensor.SensorId.MAGNETIC_FIELD, (data: sensor.MagneticFieldResponse) => {
        if (this.event) {
          let arr: Array<number> = [3];
          arr[0] = data.x;
          arr[1] = data.y;
          arr[2] = data.z;
          while (Number.isInteger(data.x)) {
            arr[0] = data.x + 0.00000000001;
          }
          while (Number.isInteger(data.y)) {
            arr[1] = data.y + 0.00000000001;
          }
          while (Number.isInteger(data.z)) {
            arr[2] = data.z + 0.00000000001;
          }
          this.event.success(arr);
        }
      }, { interval: this.samplingPeriod });
    } catch (error) {
      let e: BusinessError = error as BusinessError;
      console.error(`Failed to invoke on. Code: ${e.code}, message: ${e.message}`);
    }
  }

  onListen(args: ESObject, events: EventSink): void {
    this.event = events;
    switch (this.sensorId) {
      case sensor.SensorId.LINEAR_ACCELEROMETER:
        this.listenLinearAccelerometer();
        break;
      case sensor.SensorId.GYROSCOPE:
        this.listenGyroscope();
        break;
      case sensor.SensorId.ACCELEROMETER:
        this.listenAccelerometer();
        break;
      case sensor.SensorId.MAGNETIC_FIELD:
        this.listenMagnetic();
        break;
    }
  }

  onCancel(args: ESObject): void {
    try {
      switch (this.sensorId) {
        case sensor.SensorId.LINEAR_ACCELEROMETER:
          sensor.off(sensor.SensorId.LINEAR_ACCELEROMETER);
          break;
        case sensor.SensorId.GYROSCOPE:
          sensor.off(sensor.SensorId.GYROSCOPE);
          break;
        case sensor.SensorId.ACCELEROMETER:
          sensor.off(sensor.SensorId.ACCELEROMETER);
          break;
        case sensor.SensorId.MAGNETIC_FIELD:
          sensor.off(sensor.SensorId.MAGNETIC_FIELD);
          break;
      }
    } catch (error) {
      let e: BusinessError = error as BusinessError;
      console.error(`Failed to sensor off. Code: ${e.code}, message: ${e.message}`);
    }
  }
}
