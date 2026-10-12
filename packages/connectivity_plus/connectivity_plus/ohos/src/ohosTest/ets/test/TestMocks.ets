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
import { AsyncCallback, BusinessError } from '@ohos.base';

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
 * No-op BinaryMessenger that records handler registration per channel so
 * lifecycle tests can assert the plugin registered/cleared both its
 * MethodChannel and EventChannel handlers.
 */
export class MockBinaryMessenger implements BinaryMessenger {
  handlerChannel: string | null = null;
  handlerRegistered: boolean = false;
  private channels: Map<string, boolean> = new Map<string, boolean>();

  makeBackgroundTaskQueue(options?: TaskQueueOptions): TaskQueue {
    return undefined as ESObject as TaskQueue;
  }

  send(channel: String, message: ArrayBuffer | null, callback?: BinaryReply | null): void {
  }

  setMessageHandler(channel: String, handler: BinaryMessageHandler | SendableBinaryMessageHandler | null,
    taskQueue?: TaskQueue): void {
    this.handlerChannel = channel as ESObject as string;
    this.handlerRegistered = handler != null;
    this.channels.set(this.handlerChannel, this.handlerRegistered);
  }

  isRegistered(name: string): boolean {
    const state: boolean | undefined = this.channels.get(name);
    return state === true;
  }
}

/**
 * Structural stand-in for FlutterPluginBinding: only getBinaryMessenger and
 * getApplicationContext are used by the plugin (the context is stored, never read).
 */
export class MockFlutterPluginBinding {
  private messenger: BinaryMessenger;

  constructor(messenger: BinaryMessenger) {
    this.messenger = messenger;
  }

  getBinaryMessenger(): BinaryMessenger {
    return this.messenger;
  }

  getApplicationContext(): Context {
    return undefined as ESObject as Context;
  }
}

/**
 * Test double for the Flutter-side EventSink: records every event the receiver
 * pushes so tests can assert what the stream delivered (and when it stopped).
 */
export class MockEventSink implements EventSink {
  successValues: Array<ESObject> = [];
  errorCount: number = 0;
  endOfStreamCount: number = 0;

  success(event: ESObject): void {
    this.successValues.push(event);
  }

  error(errorCode: string, errorMessage: string, errorDetails: ESObject): void {
    this.errorCount++;
  }

  endOfStream(): void {
    this.endOfStreamCount++;
  }
}

/**
 * In-memory NetConnection double: records register()/unregister()/on() calls
 * and lets tests fire network events manually, so ConnectivityBroadcastReceiver
 * logic is exercised without depending on the real network stack. Injected via
 * the public Connectivity.netConnection field (cast, not `implements`, because
 * NetConnection.on is a set of typed overloads).
 */
export class FakeNetConnection {
  registerCount: number = 0;
  unregisterCount: number = 0;
  subscribedTypes: Array<string> = [];
  private registerCallback: AsyncCallback<void> | null = null;
  private handlers: Map<string, (data: ESObject) => void> = new Map<string, (data: ESObject) => void>();

  register(callback: AsyncCallback<void>): void {
    this.registerCount++;
    this.registerCallback = callback;
  }

  unregister(callback: AsyncCallback<void>): void {
    this.unregisterCount++;
  }

  on(type: string, callback: (data: ESObject) => void): void {
    this.handlers.set(type, callback);
    if (this.subscribedTypes.indexOf(type) < 0) {
      this.subscribedTypes.push(type);
    }
  }

  /** Simulates a successful register() completion; drives the initial state push. */
  completeRegister(): void {
    if (this.registerCallback != null) {
      this.registerCallback(undefined as ESObject as BusinessError, undefined);
    }
  }

  /** Simulates a failed register(); drives the "none" fallback push. */
  failRegister(): void {
    if (this.registerCallback != null) {
      const err: BusinessError<void> = { code: 201, message: 'permission denied', name: 'BusinessError' };
      this.registerCallback(err, undefined);
    }
  }

  /** Fires a subscribed network event, e.g. emit('netLost', null). */
  emit(type: string, data: ESObject): void {
    const handler: ((data: ESObject) => void) | undefined = this.handlers.get(type);
    if (handler != null) {
      handler(data);
    }
  }
}

/** Resolves after ms milliseconds; used to let fire-and-forget async paths settle. */
export function waitMs(ms: number): Promise<void> {
  return new Promise<void>((resolve: () => void) => {
    setTimeout(resolve, ms);
  });
}

/** Polls condition every 50ms until true or the timeout; returns whether it held. */
export async function waitUntil(condition: () => boolean, timeoutMs: number): Promise<boolean> {
  const deadline: number = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    if (condition()) {
      return true;
    }
    await waitMs(50);
  }
  return condition();
}
