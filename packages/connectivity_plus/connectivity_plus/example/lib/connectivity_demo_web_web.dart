// Copyright 2024 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Web 平台内部接口演示（真实实现，仅在 web 构建下编译、kIsWeb 时调用）。
//
// 说明：ConnectivityPlusWebPlugin 在主库中经条件导出
// （if (dart.library.js_interop) 'src/connectivity_plus_web.dart'）仅在
// web 构建下可见；为了让 VM 分析器也能解析本文件，这里直接引入 src
// 实现（与平台条件导出指向的是同一文件）。本文件只在 web 构建下参与
// 编译链接，不会把 web 依赖引入非 web 构建。
//
// 本函数由 ConnectivityDemo.start 在浏览器（kIsWeb == true）时调用。

import 'dart:developer' as developer;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show NetworkInformation;

// ignore: implementation_imports
import 'package:connectivity_plus/src/connectivity_plus_web.dart';
// ignore: implementation_imports
import 'package:connectivity_plus/src/web/dart_html_connectivity_plugin.dart';
// ignore: implementation_imports
import 'package:connectivity_plus/src/web/utils/connectivity_result.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/flutter_web_plugins.dart' show Registrar;

/// 演示 Web 平台全部公开接口：
/// - [ConnectivityPlusWebPlugin.registerWith]
/// - [DartHtmlConnectivityPlugin] 的 checkConnectivity / onConnectivityChanged
/// - [networkInformationToConnectivityResult] 工具函数（全部映射分支）
Future<void> runWebPlatformDemo() async {
  // 1) ConnectivityPlusWebPlugin.registerWith(Registrar)：注册 Web 平台实现。
  //    参数 registrar 在实现中未被使用（仅做平台实例替换），
  //    传入空实现即可。
  ConnectivityPlusWebPlugin.registerWith(_DemoRegistrar());

  final webPlugin = DartHtmlConnectivityPlugin();

  // 2) checkConnectivity()：浏览器在线返回 [wifi]，离线返回 [none]。
  await webPlugin.checkConnectivity();

  // 3) onConnectivityChanged：浏览器 online/offline 事件流。
  //    订阅后立即取消，演示其生命周期。
  final subscription = webPlugin.onConnectivityChanged.listen((_) {});
  await subscription.cancel();

  // 4) networkInformationToConnectivityResult()：NetworkInformation →
  //    ConnectivityResult 的 Web 工具函数。用一组代表性输入驱动其
  //    全部映射分支（type / effectiveType / 零带宽 / 双空回退），
  //    仅日志输出。
  _demoNetworkInformationMapping();
}

/// 用代表性的 [html.NetworkInformation] 输入演示
/// [networkInformationToConnectivityResult] 的映射逻辑。
void _demoNetworkInformationMapping() {
  void logMapping(String label, html.NetworkInformation info) {
    developer.log(
      'networkInformationToConnectivityResult($label) -> '
      '${networkInformationToConnectivityResult(info)}',
    );
  }

  // type 映射分支。
  logMapping(
    'type: wifi',
    _DemoNetworkInformation()
      ..downlink = 10
      ..rtt = 100
      ..type = 'wifi',
  );
  logMapping(
    'type: ethernet',
    _DemoNetworkInformation()
      ..downlink = 10
      ..rtt = 100
      ..type = 'ethernet',
  );
  logMapping(
    'type: bluetooth',
    _DemoNetworkInformation()
      ..downlink = 10
      ..rtt = 100
      ..type = 'bluetooth',
  );
  logMapping(
    'type: cellular',
    _DemoNetworkInformation()
      ..downlink = 10
      ..rtt = 100
      ..type = 'cellular',
  );
  logMapping(
    'type: carrier-pigeon (未识别)',
    _DemoNetworkInformation()
      ..downlink = 10
      ..rtt = 100
      ..type = 'carrier-pigeon',
  );
  // effectiveType 回退分支（type 为 null 时）。
  logMapping(
    'effectiveType: 4g',
    _DemoNetworkInformation()
      ..downlink = 10
      ..rtt = 100
      ..type = null
      ..effectiveType = '4g',
  );
  // 零带宽分支：downlink 与 rtt 均为 0 → [none]。
  logMapping(
    'downlink/rtt: 0/0',
    _DemoNetworkInformation()
      ..downlink = 0
      ..rtt = 0
      ..type = 'wifi',
  );
  // 双空回退分支：type 与 effectiveType 均为 null → [none]。
  logMapping(
    'type/effectiveType: null',
    _DemoNetworkInformation()
      ..downlink = 10
      ..rtt = 100
      ..type = null
      ..effectiveType = null,
  );
}

/// 仅用于演示 [networkInformationToConnectivityResult] 的可控
/// NetworkInformation 实现（浏览器 Network Information API 并非所有
/// 环境可用，这里以确定性输入驱动映射逻辑）。
class _DemoNetworkInformation implements html.NetworkInformation {
  num? _downlink = 0;
  int? _rtt = 0;
  String? _type;
  String? _effectiveType;

  @override
  num? get downlink => _downlink;
  set downlink(num? v) => _downlink = v;

  @override
  int? get rtt => _rtt;
  set rtt(int? v) => _rtt = v;

  @override
  String? get type => _type;
  set type(String? v) => _type = v;

  @override
  String? get effectiveType => _effectiveType;
  set effectiveType(String? v) => _effectiveType = v;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 仅用于演示 registerWith 的空 Registrar（其参数在实现中未被使用）。
class _DemoRegistrar implements Registrar {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
