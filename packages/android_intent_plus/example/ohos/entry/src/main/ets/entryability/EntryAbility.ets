
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

import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
// 导入AndroidIntentPlugin
import AndroidIntentPlugin from 'android_intent_plus';

import { commonEventManager } from '@kit.BasicServicesKit';
import { promptAction, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { notificationManager } from '@kit.NotificationKit';

interface Info {
  events: string[]
}

//订阅者信息
let subscribeInfo: Info = {
  events: ["com.example.broadcast"],
}

const TAG = 'AndroidIntentPlugin'

export default class EntryAbility extends FlutterAbility {
  //用于保存创建成功的订阅者对象，后续使用其完成订阅及退订的动作
  private subscriber: commonEventManager.CommonEventSubscriber | null = null;

  async configureFlutterEngine(flutterEngine: FlutterEngine) {
    // 获取插件实例并设置上下文
    try {
      // 通过反射或直接导入的方式来设置上下文
      // 由于我们无法直接访问已注册的实例，我们直接调用插件的静态方法来设置全局上下文
      const pluginInstance: AndroidIntentPlugin = new AndroidIntentPlugin();
      if (pluginInstance && typeof pluginInstance.setContext === 'function') {
        pluginInstance.setContext(this.context);
        hilog.info(0x0000, TAG, "global context set successfully");
      }

      //创建订阅者回调
      this.subscriber = await commonEventManager.createSubscriber(subscribeInfo)
      hilog.info(0x0000, TAG, "CreateSubscriber");

      if (!this.subscriber) {
        return;
      }
      commonEventManager.subscribe(this.subscriber, async (err: BusinessError, data: commonEventManager.CommonEventData) => {
        try {
          if (err) {
            hilog.error(0x0000, TAG,`Failed to subscribe. Code is ${err.code}, message is ${err.message}`);
            return;
          }
          hilog.info(0x0000, TAG, `Succeeded in subscribing, data is ${JSON.stringify(data)}`);
          await promptAction.openToast({ message: 'Broadcast Received!' });
        } catch (error) {
          hilog.error(0x0000, TAG,"commonEventManager subscribe Failed:", error);
        }
      });
    } catch (error) {
      hilog.error(0x0000, TAG,"Failed to set context for AndroidIntentPlugin:", error);
    }
    super.configureFlutterEngine(flutterEngine);
    GeneratedPluginRegistrant.registerWith(flutterEngine);
  }

  onDestroy(): void {
    try {
      if (!this.subscriber) {
        return;
      }
      commonEventManager.unsubscribe(this.subscriber, (err: BusinessError) => {
        if (err) {
          console.error(`Failed to unsubscribe. Code is ${err.code}, message is ${err.message}`);
          return;
        }
        // subscriber不再使用时需要将其置为null，避免内存泄露
        this.subscriber = null;
        hilog.info(0x0000, TAG, `Succeeded in unsubscribing.`);
      });
    } catch (error) {
      hilog.error(0x0000, TAG,"commonEventManager unsubscribe Failed:", error);
    }
  }
}
