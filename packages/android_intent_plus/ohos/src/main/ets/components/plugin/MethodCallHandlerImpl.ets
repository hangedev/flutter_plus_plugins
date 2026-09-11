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

import { MethodChannel, MethodCall, MethodResult, BinaryMessenger, MethodCallHandler, Log } from '@ohos/flutter_ohos';
import { WantSender } from './WantSender';
import { Want } from '@kit.AbilityKit';

const TAG = 'MethodCallHandlerImpl';
const CHANNEL_NAME = 'dev.fluttercommunity.plus/android_intent';

export class MethodCallHandlerImpl implements MethodCallHandler {
  private sender: WantSender;
  private methodChannel: MethodChannel | null = null;

  constructor(sender: WantSender) {
    this.sender = sender;
  }

  startListening(messenger: BinaryMessenger): void {
    if (this.methodChannel != null) {
      Log.i(TAG, "Setting a method call handler before the last was disposed.");
      this.stopListening();
    }
    this.methodChannel = new MethodChannel(messenger, CHANNEL_NAME);
    this.methodChannel.setMethodCallHandler(this);
  }

  stopListening(): void {
    if (this.methodChannel == null) {
      Log.i(TAG, "Tried to stop listening when no methodChannel had been initialized.");
      return;
    }
    this.methodChannel.setMethodCallHandler(null);
    this.methodChannel = null;
  }

  private getErrorMessage(error: Object): string {
    if (error instanceof Error) {
      return error.message;
    }
    return String(error);
  }

  async onMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    let want = this.getCallArguments(call);
    try {
      switch (call.method) {
        case 'launch':
          await this.launch(want);
          result.success(null);
          break;

        case 'sendBroadcast':
          this.sender.sendBroadcast(want, result);
          break;

        case 'launchChooser':
          const title = call.argument('chooserTitle') as string;
          await this.sender.launchChooser(want, title);
          result.success(null);
          break;

        case 'parseAndLaunch':
          const uri = call.argument('uri') as string;
          try {
            want = this.sender.parse(uri);
          } catch (error) {
            // 解析失败使用parse_error错误码，与Android端保持一致
            const parseMessage = this.getErrorMessage(error);
            Log.e(TAG, `Failed to parse URI: ${parseMessage}`);
            result.error('parse_error', 'Failed to parse URI', parseMessage);
            break;
          }
          await this.sender.send(want);
          result.success(null);
          break;

        case 'sendService':
          // 此功能仅2in1设备且企业应用支持
          result.notImplemented();
          break;

        case 'canResolveActivity':
          // 此功能仅系统应用支持
          result.notImplemented();
          break;

        case 'getResolvedActivity':
          // 此功能仅系统应用支持
          result.notImplemented();
          break;

        default:
          result.notImplemented();
      }
    } catch (error) {
      const message = this.getErrorMessage(error);
      Log.e(TAG, `Error handling method call: ${message}`);
      result.error('error', message, null);
    }
  }

  private getCallArguments(call: MethodCall): Want {
    const action = call.argument('action') as string;
    const flags = call.argument('flags') as number | null;
    const category = call.argument('category') as string | null;
    const data = call.argument('data') as string | null;

    const rawArgsMap: ESObject = call.argument("arguments");
    let args: Record<string, Object> = {};

    if (rawArgsMap && typeof rawArgsMap.forEach === 'function') {
      rawArgsMap.forEach((value: ESObject, key: string) => {
        Log.i(TAG, `Map Key: ${key}, Value: ${value}, Type: ${typeof value}`);
        args[key] = this.recursivelyConvertMap(value);
      });
    }

    const rawArrayArguments = call.argument('arrayArguments') as Record<string, Object[]>;
    const packageName = call.argument('package') as string | null;
    const componentName = call.argument('componentName') as string | null;
    const type = call.argument('type') as string | null;

    let mergedArguments: Record<string, Object> = {};

    // 转换args
    this.getMergeArgs(args, mergedArguments, rawArrayArguments);

    let want: Want | null = this.sender.buildWant(
      action,
      flags,
      category,
      data,
      mergedArguments,
      packageName,
      componentName,
      type,
    );

    if (!want) {
      throw new Error('Failed to build Want object: context not initialized');
    }
    return want;
  }

  private recursivelyConvertMap(obj: ESObject): Object {
    if (obj === null || typeof obj !== 'object') {
      return obj;
    }

    // 先检查是否是数组（数组也有 forEach 方法，必须先判断）
    if (Array.isArray(obj)) {
      const result: Object[] = [];
      for (let i = 0; i < obj.length; i++) {
        result.push(this.recursivelyConvertMap(obj[i]));
      }
      return result;
    }

    // 检查是否是 Map 对象（有 forEach 方法但不是数组）
    if (typeof (obj as ESObject).forEach === 'function') {
      const converted: Record<string, Object> = {};
      (obj as ESObject).forEach((value: ESObject, key: string) => {
        converted[key] = this.recursivelyConvertMap(value);
      });
      return converted;
    }

    // 如果是普通对象
    const converted: Record<string, Object> = {};
    const keys = Object.keys(obj);
    for (let i = 0; i < keys.length; i++) {
      const key = keys[i];
      converted[key] = this.recursivelyConvertMap(obj[key]);
    }
    return converted;
  }

  private getMergeArgs(args: Record<string, Object> | null, mergedArguments: Record<string, Object>,
    arrayArguments: Record<string, Object[]> | null) {
    if (args && typeof args === 'object' && !Array.isArray(args)) {
      const argKeys = Object.keys(args);
      for (let i = 0; i < argKeys.length; i++) {
        const key = argKeys[i];
        mergedArguments[key] = args[key];
      }
    }

    // 合并 arrayArguments
    if (arrayArguments && typeof arrayArguments === 'object' && !Array.isArray(arrayArguments)) {
      const arrayKeys = Object.keys(arrayArguments);
      for (let i = 0; i < arrayKeys.length; i++) {
        const key = arrayKeys[i];
        // 对数组参数也进行递归转换
        mergedArguments[key] = this.recursivelyConvertMap(arrayArguments[key]);
      }
    }
  }

  private async launch(want: Want): Promise<void> {
    // 兼容部分场景 data 可能被编码成 geo%3A...
    if (want.uri && want.uri.startsWith('geo%3A')) {
      want.uri = decodeURIComponent(want.uri);
    }

    await this.sender.send(want);
  }
}
