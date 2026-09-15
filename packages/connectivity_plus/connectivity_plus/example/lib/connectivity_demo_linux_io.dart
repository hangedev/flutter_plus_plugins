// Copyright 2024 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Linux 平台内部接口演示（真实实现，仅在非 web 构建下编译）。
//
// ConnectivityPlusLinuxPlugin 经 connectivity_plus.dart 的条件导出
// （export 'src/connectivity_plus_linux.dart'）在所有非 web 平台可见。
// 本函数由 ConnectivityDemo.start 在 Linux 桌面（defaultTargetPlatform ==
// TargetPlatform.linux）时调用，其余平台不会被调用。
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';

/// 演示 [ConnectivityPlusLinuxPlugin] 的全部公开接口：
/// registerWith / checkConnectivity / onConnectivityChanged / createClient。
Future<void> runLinuxPlatformDemo() async {
  // 1) registerWith()：将 Linux 实现注册为全局平台实现
  //    （Flutter 桌面自动注册的最终入口也是它）。
  ConnectivityPlusLinuxPlugin.registerWith();

  final linux = ConnectivityPlusLinuxPlugin();

  // 2) checkConnectivity()：Linux 实现的一次性查询（经 NetworkManager）。
  await linux.checkConnectivity();

  // 3) onConnectivityChanged：Linux 实现的变化流。订阅后立即取消，
  //    演示其生命周期（onListen 建立 NetworkManager 订阅、onCancel 关闭）。
  final subscription = linux.onConnectivityChanged.listen((_) {});
  await subscription.cancel();

  // 4) createClient 字段：内置的 NetworkManager 客户端工厂，标注
  //    @visibleForTesting 供测试注入替换。调用默认工厂是纯对象构造、
  //    无 I/O，此处仅演示默认工厂的形态，不发起真实连接。
  // ignore: invalid_use_of_visible_for_testing_member
  final client = linux.createClient();
  developer.log('default createClient() -> ${client.runtimeType}');
}
