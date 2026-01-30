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
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Want, wantConstant } from '@kit.AbilityKit';
import { commonEventManager } from '@kit.BasicServicesKit';
import { MethodResult } from '@ohos/flutter_ohos';

const TAG = 'WantSender';

export class WantSender {
  public context: common.UIAbilityContext;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  // 构建Want对象
  buildWant(
    action: string | null,
    flags: number | null,
    category: string | null,
    data: string | null,
    parameters: Record<string, Object>,
    packageName: string | null,
    componentName: string | null,
    type: string | null,
  ): Want | null {
    if (!this.context) {
      hilog.error(0x0000, TAG, 'Context not initialized');
      return null;
    }

    let want: Want = {};
    if (action) {
      want.action = action;
    }
    if (data) {
      want.uri = data;
    }
    if (packageName) {
      want.bundleName = packageName;
    }
    if (componentName) {
      want.abilityName = componentName;
    }
    if (category) {
      want.moduleName = category;
    }
    if (parameters && Object.keys(parameters).length !== 0) {
      want.parameters = parameters;
    }
    if (type) {
      want.type = type;
    }
    // 处理flags
    if (flags) {
      // HarmonyOS Want flags映射
      if (flags & 0x10000000) {
        want.flags = wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION;
      }
      want.flags = flags;
    }

    return want;
  }

  // 启动Ability
  async send(want: Want): Promise<void> {
    if (!this.context) {
      hilog.error(0x0000, TAG, 'Context not initialized');
      return;
    }
    try {
      await this.context.startAbility(want);
    } catch (error) {
      hilog.error(0x0000, TAG, `Failed to start ability: ${error.message}`);
    }
  }

  // 发送广播
  sendBroadcast(want: Want, result: MethodResult): void {
    if (!this.context) {
      hilog.error(0x0000, TAG, 'Context not initialized');
      return;
    }

    // 准备公共事件发布的数据

    let options: commonEventManager.CommonEventPublishData = {};
    let event: string = '';
    if (want.bundleName) {
      options.bundleName = want.bundleName;
    }
    if (want.action) {
      event = want.action;
    }
    if (want.parameters && want.parameters.code) {
      options.code = want.parameters.code as number;
    }
    if (want.parameters && want.parameters.data) {
      options.data = want.parameters.data as string;
    }
    if (want.parameters && want.parameters.subscriberPermissions) {
      options.subscriberPermissions = want.parameters.subscriberPermissions as string[];
    }
    if (want.parameters && want.parameters.isOrdered) {
      options.isOrdered = want.parameters.isOrdered as boolean;
    }
    if (want.parameters && want.parameters.isSticky) {
      // 仅系统应用或系统服务允许发送粘性事件,默认为false,需要申请权限ohos.permission.COMMONEVENT_STICKY
      options.isSticky = want.parameters.isSticky as boolean;
    }
    if (want.parameters && want.parameters.parameters) {
      options.parameters = want.parameters.parameters as ESObject;
    }

    try {
      // 发布公共事件,使用Want对象中的action作为事件名称
      commonEventManager.publish(event, options, (err) => {
        if (err) {
          hilog.error(0x0000, TAG, "PublishCallBack err=" + JSON.stringify(err))
        } else {
          result.success(null);
        }
      })
    } catch (error) {
      hilog.error(0x0000, TAG, `Failed to publish common event: ${error.message}`);
    }
  }

  // 启动选择器
  async launchChooser(want: Want, title: string): Promise<void> {
    if (!this.context) {
      hilog.error(0x0000, TAG, 'Context not initialized');
      return;
    }

    try {
      await this.context.startAbility(want);
    } catch (error) {
      hilog.error(0x0000, TAG, `Failed to launch chooser: ${error.message}`);
    }
  }

  // 解析json字符串为Want对象
  parse(jsonStr: string): Want {
    try {
      // 尝试解析JSON字符串
      const jsonObj: Record<string, Object> = JSON.parse(jsonStr);

      // 创建Want对象
      const want: Want = {};

      // 映射JSON对象的所有属性到Want对象
      if (jsonObj.action) {
        want.action = jsonObj.action as string;
      }

      if (jsonObj.uri) {
        want.uri = jsonObj.uri as string;
      }

      if (jsonObj.bundleName) {
        want.bundleName = jsonObj.bundleName as string;
      }

      if (jsonObj.abilityName) {
        want.abilityName = jsonObj.abilityName as string;
      }

      if (jsonObj.deviceId) {
        want.deviceId = jsonObj.deviceId as string;
      }

      if (jsonObj.type) {
        want.type = jsonObj.type as string;
      }

      if (jsonObj.flags !== undefined && jsonObj.flags !== null) {
        want.flags = jsonObj.flags as number;
      }

      if (jsonObj.parameters) {
        want.parameters = jsonObj.parameters as Record<string, Object>;
      }

      if (jsonObj.entities) {
        want.entities = jsonObj.entities as Array<string>;
      }

      if (jsonObj.moduleName) {
        want.moduleName = jsonObj.moduleName as string;
      }

      return want;
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to parse JSON string: ' + (error as Error).message);
      // 如果JSON解析失败，返回一个空的Want对象
      return {};
    }
  }
}
