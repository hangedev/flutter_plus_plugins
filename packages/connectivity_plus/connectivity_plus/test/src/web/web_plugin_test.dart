// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('browser')
library;

// Web 平台插件测试：仅在 web 测试运行器（chrome）下编译执行。
// VM 运行器（`flutter test` 默认平台）会在编译前依据 @TestOn 跳过本文件，
// 因此这里可以直接依赖 package:web / dart:js，全量 `flutter test` 不受影响。
//
// 运行方式（使本文件真正执行并计入覆盖率）：
//   flutter test --platform chrome test/src/web/
import 'dart:js' as js;

import 'package:connectivity_plus/src/connectivity_plus_web.dart';
import 'package:connectivity_plus/src/web/dart_html_connectivity_plugin.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:connectivity_plus_platform_interface/method_channel_connectivity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart' show Registrar;
import 'package:web/web.dart';

/// 用 defineProperty 在 navigator 实例上遮蔽原型链的 onLine getter，
/// 使 window.navigator.onLine 返回注入值（configurable 便于测试后恢复）。
void _setNavigatorOnLine(bool value) {
  js.context.callMethod('eval', [
    "Object.defineProperty(window.navigator, 'onLine', "
        "{value: ${value ? 'true' : 'false'}, configurable: true});"
  ]);
}

/// 删除实例上的遮蔽属性，恢复浏览器原生 onLine。
void _resetNavigatorOnLine() {
  js.context.callMethod('eval', ['delete window.navigator.onLine;']);
}

void main() {
  tearDown(() {
    // registerWith 会替换全局平台实例，恢复默认实现避免污染其他测试。
    ConnectivityPlatform.instance = MethodChannelConnectivity();
    _resetNavigatorOnLine();
  });

  group('ConnectivityPlusWebPlugin', () {
    test(
      'should set ConnectivityPlatform.instance to DartHtmlConnectivityPlugin '
      'when registerWith is called',
      () {
        ConnectivityPlusWebPlugin.registerWith(_NullRegistrar());
        expect(ConnectivityPlatform.instance, isA<DartHtmlConnectivityPlugin>());
      },
    );
  });

  group('DartHtmlConnectivityPlugin.checkConnectivity', () {
    test('should return [wifi] when the navigator reports online', () async {
      // navigator.onLine 在测试 web 运行器下默认为 true，显式断言前置条件。
      expect(window.navigator.onLine, isTrue);
      final plugin = DartHtmlConnectivityPlugin();
      expect(await plugin.checkConnectivity(), [ConnectivityResult.wifi]);
    });

    test('should return [none] when the navigator reports offline', () async {
      _setNavigatorOnLine(false);
      expect(window.navigator.onLine, isFalse); // 确认遮蔽生效
      final plugin = DartHtmlConnectivityPlugin();
      expect(await plugin.checkConnectivity(), [ConnectivityResult.none]);
    });
  });

  group('DartHtmlConnectivityPlugin.onConnectivityChanged', () {
    test(
      'should emit [wifi] when the window fires online and [none] when it '
      'fires offline',
      () async {
        final plugin = DartHtmlConnectivityPlugin();
        final emitted = <List<ConnectivityResult>>[];
        final subscription = plugin.onConnectivityChanged.listen(emitted.add);

        window.dispatchEvent(Event('online'));
        window.dispatchEvent(Event('offline'));

        await pumpEventQueue(times: 50);
        await subscription.cancel();

        expect(emitted, [
          [ConnectivityResult.wifi],
          [ConnectivityResult.none],
        ]);
      },
    );

    test(
      'should create the broadcast stream lazily and reuse it when accessed '
      'repeatedly',
      () {
        final plugin = DartHtmlConnectivityPlugin();
        // 第一次访问：走懒初始化分支（创建 controller 并注册 online/offline 监听）。
        final first = plugin.onConnectivityChanged;
        // 第二次访问：走缓存分支，直接返回已有 stream。
        final second = plugin.onConnectivityChanged;
        expect(identical(first, second), isTrue);
        expect(first, isA<Stream<List<ConnectivityResult>>>());
      },
    );

    test(
      'should support multiple concurrent subscribers when several listeners '
      'attach to the broadcast stream',
      () async {
        final plugin = DartHtmlConnectivityPlugin();
        final firstEvents = <List<ConnectivityResult>>[];
        final secondEvents = <List<ConnectivityResult>>[];
        final firstSubscription =
            plugin.onConnectivityChanged.listen(firstEvents.add);
        final secondSubscription =
            plugin.onConnectivityChanged.listen(secondEvents.add);

        window.dispatchEvent(Event('offline'));

        await pumpEventQueue(times: 50);
        await firstSubscription.cancel();
        await secondSubscription.cancel();

        expect(firstEvents, [
          [ConnectivityResult.none],
        ]);
        expect(secondEvents, [
          [ConnectivityResult.none],
        ]);
      },
    );
  });
}

/// Registrar 的空实现，仅用于 registerWith 单元测试。
class _NullRegistrar implements Registrar {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
