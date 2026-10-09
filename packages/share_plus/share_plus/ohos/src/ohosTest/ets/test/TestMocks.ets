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

import common from '@ohos.app.ability.common';
import UIAbility from '@ohos.app.ability.UIAbility';
import { MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import { BinaryMessenger, BinaryMessageHandler, BinaryReply, TaskQueue, TaskQueueOptions }
  from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import SendableBinaryMessageHandler from '@ohos/flutter_ohos/src/main/ets/plugin/common/SendableBinaryMessageHandler';
import { AbilityPluginBinding, NewWantListener, WindowFocusChangedListener, OnSaveStateListener }
  from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/ability/AbilityPluginBinding';
import Share from '../../../main/ets/dev/fluttercommunity/plus/share/Share';

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
 * Structural stand-in for FlutterPluginBinding: only getBinaryMessenger and
 * getApplicationContext are used by the plugin (the context feeds Share).
 */
export class MockFlutterPluginBinding {
  private messenger: BinaryMessenger;
  private context: common.Context | null;

  constructor(messenger: BinaryMessenger, context: common.Context | null = null) {
    this.messenger = messenger;
    this.context = context;
  }

  getBinaryMessenger(): BinaryMessenger {
    return this.messenger;
  }

  getApplicationContext(): common.Context {
    return this.context as ESObject as common.Context;
  }
}

/** Empty stand-in for a UIAbility: only non-nullness matters to the plugin's guards. */
export class AbilityStub {
}

/**
 * No-op AbilityPluginBinding. Pass null to simulate "binding attached but no
 * ability yet", or an AbilityStub cast to simulate a foreground ability.
 */
export class MockAbilityPluginBinding implements AbilityPluginBinding {
  private ability: UIAbility | null;

  constructor(ability: UIAbility | null) {
    this.ability = ability;
  }

  getAbility(): UIAbility {
    return this.ability as ESObject as UIAbility;
  }

  addOnNewWantListener(listener: NewWantListener): void {
  }

  removeOnNewWantListener(listener: NewWantListener): void {
  }

  addOnWindowFocusChangedListener(listener: WindowFocusChangedListener): void {
  }

  removeOnWindowFocusChangedListener(listener: WindowFocusChangedListener): void {
  }

  addOnSaveStateListener(listener: OnSaveStateListener): void {
  }

  removeOnSaveStateListener(listener: OnSaveStateListener): void {
  }
}

/**
 * Share test double that records every delegation from the method-channel
 * handler instead of touching the share sheet or the filesystem, so routing
 * tests stay deterministic on any device.
 */
export class RecordingShare extends Share {
  public shareCallCount: number = 0;
  public shareFilesCallCount: number = 0;
  public lastText: string | null = null;
  public lastSubject: string | null = null;
  public lastTitle: string | null = null;
  public lastWithResult: boolean = false;
  public lastPaths: string[] | null = null;
  public lastMimeTypes: string[] | null = null;

  constructor() {
    // A null context is safe here: every overridden path below avoids the
    // filesystem and the share sheet entirely.
    super(null as ESObject as common.Context);
  }

  public async share(text: string, subject: string | null, title: string | null,
    withResult: boolean, result: MethodResult): Promise<void> {
    this.shareCallCount++;
    this.lastText = text;
    this.lastSubject = subject;
    this.lastTitle = title;
    this.lastWithResult = withResult;
  }

  public async shareFiles(paths: string[], mimeTypes: string[] | null, text: string | null,
    subject: string | null, title: string | null, withResult: boolean,
    result: MethodResult): Promise<void> {
    this.shareFilesCallCount++;
    this.lastPaths = paths;
    this.lastMimeTypes = mimeTypes;
    this.lastText = text;
    this.lastSubject = subject;
    this.lastTitle = title;
    this.lastWithResult = withResult;
  }
}
