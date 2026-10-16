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
 * No-op BinaryMessenger that records handler registration so lifecycle tests
 * can assert the plugin registered/cleared its MethodChannel handler.
 */
export class MockBinaryMessenger implements BinaryMessenger {
  handlerChannel: string | null = null;
  handlerRegistered: boolean = false;

  makeBackgroundTaskQueue(options?: TaskQueueOptions): TaskQueue {
    return undefined as ESObject as TaskQueue;
  }

  send(channel: String, message: ArrayBuffer | null, callback?: BinaryReply | null): void {
  }

  setMessageHandler(channel: String, handler: BinaryMessageHandler | SendableBinaryMessageHandler | null,
    taskQueue?: TaskQueue): void {
    this.handlerChannel = channel as ESObject as string;
    this.handlerRegistered = handler != null;
  }
}

/**
 * resourceManager stand-in: getStringSync always answers with the app label the
 * mock was constructed with, so the appName mapping can be asserted without
 * depending on the real resource table of the test bundle.
 */
export class MockResourceManager {
  private appName: string;

  constructor(appName: string) {
    this.appName = appName;
  }

  getStringSync(resId: number): string {
    return this.appName;
  }
}

/** Structural stand-in for a Context: only resourceManager is used by the plugin. */
export class MockContext {
  resourceManager: MockResourceManager;

  constructor(appName: string) {
    this.resourceManager = new MockResourceManager(appName);
  }
}

/**
 * Structural stand-in for FlutterPluginBinding: the plugin only uses
 * getBinaryMessenger and getApplicationContext. Pass null as the context to
 * simulate "attached to engine, but no application context available".
 */
export class MockFlutterPluginBinding {
  private messenger: BinaryMessenger;
  private context: Context | null;

  constructor(messenger: BinaryMessenger, context: Context | null) {
    this.messenger = messenger;
    this.context = context;
  }

  getBinaryMessenger(): BinaryMessenger {
    return this.messenger;
  }

  getApplicationContext(): Context {
    return this.context as ESObject as Context;
  }
}
