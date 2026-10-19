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

import { MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import { EventSink } from '@ohos/flutter_ohos/src/main/ets/plugin/common/EventChannel';
import { BinaryMessenger, BinaryMessageHandler, BinaryReply, TaskQueue, TaskQueueOptions }
  from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import SendableBinaryMessageHandler from '@ohos/flutter_ohos/src/main/ets/plugin/common/SendableBinaryMessageHandler';

/**
 * Test double for the Flutter-side MethodResult: records every callback the
 * plugin makes so tests can assert what was reported back to Flutter.
 */
export class MockMethodResult implements MethodResult {
  isSuccessCalled: boolean = false;
  successValue: ESObject = null;
  isErrorCalled: boolean = false;
  errorCode: string = '';
  errorMessage: string = '';
  isNotImplementedCalled: boolean = false;
  callCount: number = 0;

  success(result: ESObject): void {
    this.callCount++;
    this.isSuccessCalled = true;
    this.successValue = result;
  }

  error(errorCode: string, errorMessage: string, errorDetails: ESObject): void {
    this.callCount++;
    this.isErrorCalled = true;
    this.errorCode = errorCode;
    this.errorMessage = errorMessage;
  }

  notImplemented(): void {
    this.callCount++;
    this.isNotImplementedCalled = true;
  }
}

/**
 * Test double for the Flutter-side EventSink: records every event the plugin
 * pushes on the charging-state stream so tests can assert the stream contract
 * (immediate first event, deduplication, error reporting, teardown).
 */
export class MockEventSink implements EventSink {
  successCount: number = 0;
  successValues: string[] = [];
  errorCount: number = 0;
  errorCode: string = '';
  errorMessage: string = '';
  endOfStreamCount: number = 0;

  success(event: ESObject): void {
    this.successCount++;
    this.successValues.push(event as ESObject as string);
  }

  error(errorCode: string, errorMessage: string, errorDetails: ESObject): void {
    this.errorCount++;
    this.errorCode = errorCode;
    this.errorMessage = errorMessage;
  }

  endOfStream(): void {
    this.endOfStreamCount++;
  }
}

/**
 * No-op BinaryMessenger that records handler registration per channel, so
 * lifecycle tests can assert both the method channel and the event channel
 * were registered on attach and cleared on detach.
 */
export class MockBinaryMessenger implements BinaryMessenger {
  registeredChannels: Map<string, boolean> = new Map<string, boolean>();

  makeBackgroundTaskQueue(options?: TaskQueueOptions): TaskQueue {
    return undefined as ESObject as TaskQueue;
  }

  send(channel: String, message: ArrayBuffer | null, callback?: BinaryReply | null): void {
  }

  setMessageHandler(channel: String, handler: BinaryMessageHandler | SendableBinaryMessageHandler | null,
    taskQueue?: TaskQueue): void {
    this.registeredChannels.set(channel as ESObject as string, handler != null);
  }

  isRegistered(name: string): boolean {
    const state: boolean | undefined = this.registeredChannels.get(name);
    return state === true;
  }
}

/**
 * Structural stand-in for FlutterPluginBinding: the plugin only uses
 * getBinaryMessenger, so only that surface is provided.
 */
export class MockFlutterPluginBinding {
  private messenger: BinaryMessenger;

  constructor(messenger: BinaryMessenger) {
    this.messenger = messenger;
  }

  getBinaryMessenger(): BinaryMessenger {
    return this.messenger;
  }
}
