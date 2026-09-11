// Copyright 2024 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

// 平台内部实现接口的条件导入：
// - Linux 平台插件（ConnectivityPlusLinuxPlugin）经 connectivity_plus.dart
//   的条件导出仅在非 web 构建下可见；
// - Web 平台插件（ConnectivityPlusWebPlugin / DartHtmlConnectivityPlugin）
//   仅在 web 构建下可见。
// 两侧各提供一对 real/stub 文件，保证任意目标平台都能编译。
import 'connectivity_demo_linux_io.dart'
    if (dart.library.js_interop) 'connectivity_demo_linux_web.dart';
import 'connectivity_demo_web_io.dart'
    if (dart.library.js_interop) 'connectivity_demo_web_web.dart';

/// 演示 connectivity_plus 对外导出的全部接口：
///   1. [Connectivity] —— 单例构造
///   2. [Connectivity.checkConnectivity] —— 一次性查询当前连接状态
///   3. [Connectivity.onConnectivityChanged] —— 监听连接状态变化流（含 distinct 去重）
///   4. [ConnectivityResult] 全部 7 个枚举值（见 [describe]）
///   5. 平台内部实现接口（Linux / Web，按运行平台条件演示，见 [start]）
///
/// 在 [MyHomePageState.initState] 中通过 [ConnectivityDemo.start] 启动，
/// 在 [MyHomePageState.dispose] 中通过 [ConnectivityDemo.dispose] 释放。
/// 本 demo 仅在后台记录日志，不在 UI 上展示数据。
class ConnectivityDemo {
  ConnectivityDemo();

  /// 1. Connectivity() —— 单例：多次构造返回同一实例。
  ///    通过工厂构造函数保证全进程只有一个 [Connectivity]，避免重复创建
  ///    覆盖已有 EventChannel 订阅。
  final Connectivity _connectivity = Connectivity();

  /// 3. onConnectivityChanged 的订阅句柄，dispose 时需取消。
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// 最近一次状态（仅后台记录，不接入 UI）。
  ValueNotifier<List<ConnectivityResult>> lastStatus =
      ValueNotifier<List<ConnectivityResult>>(const [ConnectivityResult.none]);

  /// 历史变化记录，便于观察 distinct 去重与网络切换序列。
  final ValueNotifier<List<List<ConnectivityResult>>> history =
      ValueNotifier<List<List<ConnectivityResult>>>(const []);

  /// 启动 demo：一次性查询 + 平台内部接口演示 + 订阅变化流。
  ///
  /// 在 [MyHomePageState.initState] 末尾调用。
  Future<void> start() async {
    // 2. checkConnectivity() —— 一次性查询当前连接状态。
    //    平台调用可能失败（权限不足、系统异常），需用 try/catch 捕获。
    await _checkConnectivityOnce();

    // 平台内部实现接口演示：按当前运行平台条件执行。
    // - 浏览器（web）：ConnectivityPlusWebPlugin.registerWith +
    //   DartHtmlConnectivityPlugin 的 checkConnectivity / onConnectivityChanged；
    // - Linux 桌面：ConnectivityPlusLinuxPlugin 的 registerWith /
    //   checkConnectivity / onConnectivityChanged；
    // - 其余平台（OHOS/Android/iOS 等）：平台内部接口由引擎自动注册，
    //   无需应用侧调用，此处不执行。
    if (kIsWeb) {
      await runWebPlatformDemo();
    } else if (defaultTargetPlatform == TargetPlatform.linux) {
      await runLinuxPlatformDemo();
    }

    // 3. onConnectivityChanged —— 监听连接状态变化流。
    //    stream 内部已应用 Stream.distinct，连续相同状态不会重复发射，
    //    因此 onEvent 收到的都是真实的状态切换。
    _subscription = _connectivity.onConnectivityChanged.listen(
      _onChanged,
      onError: (Object error, StackTrace stackTrace) {
        developer.log('onConnectivityChanged stream error',
            error: error, stackTrace: stackTrace);
      },
    );
  }

  /// 释放订阅，避免插件卸载后回调仍被触发。
  ///
  /// 在 [MyHomePageState.dispose] 中调用。
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  /// 演示 [Connectivity.checkConnectivity] 的独立调用入口。
  ///
  /// 返回当前连接类型列表（永不为空，无连接时为 `[ConnectivityResult.none]`）。
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return _checkConnectivityOnce();
  }

  Future<List<ConnectivityResult>> _checkConnectivityOnce() async {
    List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } on Exception catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      result = const [ConnectivityResult.none];
    }
    _onChanged(result);
    return result;
  }

  void _onChanged(List<ConnectivityResult> result) {
    lastStatus.value = result;
    // 追加到历史记录（保留最近 20 条，避免无限增长）。
    final updated = List<List<ConnectivityResult>>.from(history.value);
    updated.add(result);
    if (updated.length > 20) {
      updated.removeAt(0);
    }
    history.value = updated;
    developer.log('ConnectivityDemo: ${describe(result)}');
  }

  /// 4. 显式引用 [ConnectivityResult] 的全部 7 个枚举值，
  ///    将连接类型列表转换为可读描述（仅用于日志，不接入 UI）。
  String describe(List<ConnectivityResult> results) {
    // 无连接时列表仅含单个 none 元素。
    if (results.contains(ConnectivityResult.none)) {
      return '无连接 (none)';
    }
    final parts = <String>[];
    if (results.contains(ConnectivityResult.wifi)) {
      parts.add('Wi-Fi (wifi)');
    }
    if (results.contains(ConnectivityResult.ethernet)) {
      parts.add('以太网 (ethernet)');
    }
    if (results.contains(ConnectivityResult.mobile)) {
      parts.add('移动网络 (mobile)');
    }
    if (results.contains(ConnectivityResult.bluetooth)) {
      parts.add('蓝牙 (bluetooth)');
    }
    if (results.contains(ConnectivityResult.vpn)) {
      parts.add('VPN (vpn)');
    }
    if (results.contains(ConnectivityResult.other)) {
      parts.add('其他网络 (other)');
    }
    return parts.isEmpty ? '未知类型' : parts.join(' + ');
  }

  /// 便于日志展示的格式化方法。
  String format(List<ConnectivityResult> results) {
    return results.map((e) => e.toString().split('.').last).join(', ');
  }
}
