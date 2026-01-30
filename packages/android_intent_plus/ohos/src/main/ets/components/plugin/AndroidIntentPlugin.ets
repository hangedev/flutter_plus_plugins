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

import {
  FlutterPlugin,
  FlutterPluginBinding,
} from '@ohos/flutter_ohos';
import { MethodCallHandlerImpl } from './MethodCallHandlerImpl';
import { WantSender } from './WantSender';
import { common } from '@kit.AbilityKit';

let globalCtx: common.UIAbilityContext | null = null;

/** AndroidIntentPlugin **/
export default class AndroidIntentPlugin implements FlutterPlugin {
  private sender: WantSender | null = null;
  private impl: MethodCallHandlerImpl | null = null;

  getUniqueClassName(): string {
    return 'AndroidIntentPlugin'
  }

  // 使用 UIAbility 的context
  setContext(context: common.UIAbilityContext): void {
    globalCtx = context;
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    if (globalCtx) {
      this.sender = new WantSender(globalCtx);
      this.impl = new MethodCallHandlerImpl(this.sender);
      this.impl.startListening(binding.getBinaryMessenger());
    }
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.impl?.stopListening();
    this.sender = null;
    this.impl = null;
    globalCtx = null;
  }
}
