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
  AbilityAware,
  AbilityPluginBinding,
  BinaryMessenger,
  FlutterPlugin,
  FlutterPluginBinding,
} from '@ohos/flutter_ohos';
import { MethodCallHandlerImpl } from './MethodCallHandlerImpl';
import { WantSender } from './WantSender';
import { common } from '@kit.AbilityKit';

/** AndroidIntentPlugin **/
export default class AndroidIntentPlugin implements FlutterPlugin, AbilityAware {
  private sender: WantSender | null = null;
  private impl: MethodCallHandlerImpl | null = null;
  private context: common.UIAbilityContext | null = null;
  private binaryMessenger: BinaryMessenger | null = null;

  private tryStartListening(): void {
    if (!this.context || !this.binaryMessenger) {
      return;
    }
    if (!this.sender) {
      this.sender = new WantSender();
    }
    this.sender.setContext(this.context);
    if (!this.impl) {
      this.impl = new MethodCallHandlerImpl(this.sender);
    }
    this.impl.startListening(this.binaryMessenger);
  }

  getUniqueClassName(): string {
    return 'AndroidIntentPlugin'
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.binaryMessenger = binding.getBinaryMessenger();
    this.tryStartListening();
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.context = binding.getAbility().context as common.UIAbilityContext;
    this.tryStartListening();
  }

  onDetachedFromAbility(): void {
    this.impl?.stopListening();
    this.impl = null;
    this.sender?.setContext(null);
    this.context = null;
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.impl?.stopListening();
    this.sender = null;
    this.impl = null;
    this.binaryMessenger = null;
    this.context = null;
  }
}
