/*
 * Copyright (C) 2024 Huawei Device Co., Ltd.
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

import { StreamHandler, EventSink } from '@ohos/flutter_ohos/src/main/ets/plugin/common/EventChannel';
import { Connectivity } from './Connectivity';
import { ArrayList } from '@kit.ArkTS';
import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';
import connection from '@ohos.net.connection';
import { AsyncCallback, BusinessError } from '@ohos.base';

//创建tag
const TAG = 'ConnectivityBroadcastReceiver';

// 可变的取消标志：onListen 中的闭包捕获本对象（而非 this），onCancel 通过字段引用置位，
// 用于在注销后阻止在途异步回调继续向已失效的 EventSink 下发事件。
class CancelFlag {
  cancelled: boolean = false;
}

// 构建 [CONNECTIVITY_NONE] 列表，仅引用静态常量，不捕获任何实例。
function buildNoneTypes(): ArrayList<String> {
  const types: ArrayList<String> = new ArrayList();
  types.add(Connectivity.CONNECTIVITY_NONE);
  return types;
}

//创建类
export class ConnectivityBroadcastReceiver implements StreamHandler {
  private connectivity: Connectivity;
  private context: Context;
  private events: EventSink | null = null;
  // 订阅状态标志位：防止 onListen 被多次调用导致回调累积重复注册。
  private isListening: boolean = false;
  // 取消标志字段：供 onCancel 置位。onListen 中的闭包捕获的是指向同一 CancelFlag 的局部引用，
  // 因此 onCancel 经此字段置位后，闭包内可立即读到 cancelled=true，不依赖对 this 的捕获。
  private cancelFlag: CancelFlag | null = null;

  constructor(context: Context, connectivity: Connectivity) {
    this.context = context;
    this.connectivity = connectivity;
  }

  onListen(args: Object, events: EventSink): void {
    this.events = events;

    // 防止重复订阅：EventChannel 可能多次调用 onListen，
    // 若已在监听则先清理旧订阅再重新建立，避免回调累积。
    if (this.isListening) {
      this.unregisterAll();
    }
    this.isListening = true;

    // 资源清理说明（回应 on/off 不对称评审项）：
    // NetConnection 接口（API 12，@ohos.net.connection.d.ts）只提供 on()/register()/
    // unregister()，不提供 off()（经 ets / js / 备用 SDK 三个变体核对）。on() 回调的取消
    // 统一由 onCancel 中的 unregister() 完成（注销订阅即停止全部事件触发）。

    // === 闭包循环引用修复 ===
    // 关键：以下局部变量供闭包捕获，替代对 this 的捕获，从而打破
    // "receiver -> connectivity -> netConnection -> 回调闭包 -> receiver(this)" 的循环引用链。
    // 6 个事件回调闭包仅捕获 netConn / connectivity / sink / flag 等局部引用，
    // 体内不再出现 this，receiver（持有外部强引用的重对象）被移出循环链；
    // 剩余的 connectivity/netConnection/闭包 子环在插件释放 receiver 后对 GC 不可达，可被回收。
    const netConn: connection.NetConnection = this.connectivity.netConnection;
    const connectivity: Connectivity = this.connectivity;
    const sink: EventSink = events;
    const flag: CancelFlag = new CancelFlag();
    this.cancelFlag = flag;

    // 统一下发：检查取消标志后向 sink 推送。捕获 sink / flag 局部，不捕获 this。
    const emit = (types: ArrayList<String>): void => {
      if (flag.cancelled) {
        return;
      }
      try {
        sink.success(types);
      } catch (e) {
        // sink 可能已失效（注销后），忽略避免异常逃逸。
      }
    };

    // 获取当前网络类型并下发，捕获异步异常。捕获 connectivity / emit 局部，不捕获 this。
    const sendCurrent = async (): Promise<void> => {
      try {
        const types: ArrayList<String> = await connectivity.getNetworkTypes();
        emit(types);
      } catch (e) {
        emit(buildNoneTypes());
      }
    };

    // 注册全部网络监听；register/on 可能因权限或服务异常抛错，捕获后兜底下发 none，
    // 保证 onListen 不会因注册失败而中断、Flutter 侧也能收到初始状态。
    try {
      //注册网络监听，回调携带 error 参数；注册失败时下发 none，不继续获取网络类型。
      const registerCallback: AsyncCallback<void> = async (error: BusinessError) => {
        if (error) {
          emit(buildNoneTypes());
          return;
        }
        await sendCurrent();
      };
      netConn.register(registerCallback);

      //订阅网络可用事件。
      netConn.on('netAvailable', async (data: connection.NetHandle) => {
        await sendCurrent();
      });

      //订阅网络能力变化事件。
      netConn.on('netCapabilitiesChange', async (data: connection.NetCapabilityInfo) => {
        await sendCurrent();
      });

      //订阅网络连接信息变化事件
      netConn.on('netConnectionPropertiesChange', async (data: connection.NetConnectionPropertyInfo) => {
        await sendCurrent();
      });

      //订阅网络丢失事件。
      netConn.on('netLost', (data: connection.NetHandle) => {
        emit(buildNoneTypes());
      });

      //订阅网络不可用事件。
      netConn.on('netUnavailable', () => {
        emit(buildNoneTypes());
      });
    } catch (e) {
      Log.e(TAG, `Failed to register network listener: ${e}`);
      emit(buildNoneTypes());
    }
  }

  onCancel(args?: Object): void {
    this.unregisterAll();
    // 断开 EventSink 引用，避免持有上层对象。
    this.events = null;
  }

  // 注销整个 NetConnection 订阅（unregister 后系统不再向该连接推送事件，
  // on() 注册的回调随之停止触发，等价于整体 off），并置位取消标志阻止在途异步回调下发。
  private unregisterAll(): void {
    if (!this.isListening) {
      return;
    }
    // 通知在途异步闭包停止向 sink 下发（闭包捕获 cancelFlag 局部，置位即生效，无需捕获 this）。
    if (this.cancelFlag != null) {
      this.cancelFlag.cancelled = true;
      this.cancelFlag = null;
    }
    try {
      this.connectivity.netConnection.unregister((error: BusinessError) => {
      });
    } catch (e) {
      Log.e(TAG, `Failed to unregister network listener: ${e}`);
    }
    this.isListening = false;
  }
}
