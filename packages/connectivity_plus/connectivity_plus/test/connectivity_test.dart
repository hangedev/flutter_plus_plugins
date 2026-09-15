// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:connectivity_plus_platform_interface/method_channel_connectivity.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// 一个可控的 [ConnectivityPlatform] 假实现，用于驱动 [Connectivity] 门面类的测试。
///
/// 同时支持 [checkConnectivity] 与 [onConnectivityChanged]，并允许注入
/// 异常结果以覆盖异常传播路径，或让查询永不返回以覆盖超时场景。
class FakeConnectivityPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements ConnectivityPlatform {
  FakeConnectivityPlatform({
    List<ConnectivityResult> checkResult = const [ConnectivityResult.wifi],
    StreamController<List<ConnectivityResult>>? streamController,
    Object? checkError,
  })  : _checkResult = checkResult,
        _checkError = checkError,
        _controller = streamController ??
            StreamController<List<ConnectivityResult>>.broadcast();

  List<ConnectivityResult> _checkResult;
  Object? _checkError;
  final StreamController<List<ConnectivityResult>> _controller;

  int checkCallCount = 0;

  /// 让 [checkConnectivity] 永不完成，用于模拟平台无响应（超时）场景。
  bool hangForever = false;

  set checkResult(List<ConnectivityResult> value) => _checkResult = value;

  /// 切换 [checkConnectivity] 抛出的异常，用于异常场景测试。
  set checkError(Object? error) => _checkError = error;

  StreamController<List<ConnectivityResult>> get controller => _controller;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    checkCallCount++;
    if (hangForever) {
      return Completer<List<ConnectivityResult>>().future;
    }
    if (_checkError != null) {
      throw _checkError!;
    }
    return _checkResult;
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;
}

void main() {
  group('Connectivity', () {
    late Connectivity connectivity;
    late FakeConnectivityPlatform fakePlatform;

    setUp(() {
      fakePlatform = FakeConnectivityPlatform();
      ConnectivityPlatform.instance = fakePlatform;
      connectivity = Connectivity();
    });

    tearDown(() {
      // 清理全局平台实例与流控制器，避免测试间状态泄漏。
      ConnectivityPlatform.instance = MethodChannelConnectivity();
      fakePlatform.controller.close();
    });

    group('singleton', () {
      test(
        'should return the same instance when constructed multiple times',
        () {
          final first = Connectivity();
          final second = Connectivity();
          expect(identical(first, second), isTrue);
        },
      );
    });

    group('checkConnectivity', () {
      test(
        'should delegate to the platform implementation when '
        'checkConnectivity is called',
        () async {
          final result = await connectivity.checkConnectivity();
          expect(result, equals([ConnectivityResult.wifi]));
          expect(fakePlatform.checkCallCount, 1);
        },
      );

      test(
        'should return multiple connectivity types when the platform reports '
        'several bearers',
        () async {
          fakePlatform.checkResult = [
            ConnectivityResult.wifi,
            ConnectivityResult.vpn,
          ];
          final result = await connectivity.checkConnectivity();
          expect(
            result,
            equals([ConnectivityResult.wifi, ConnectivityResult.vpn]),
          );
        },
      );

      test(
        'should return [none] when the platform reports no connectivity',
        () async {
          fakePlatform.checkResult = [ConnectivityResult.none];
          final result = await connectivity.checkConnectivity();
          expect(result, equals([ConnectivityResult.none]));
        },
      );

      test(
        'should propagate platform exceptions to the caller when the '
        'platform throws',
        () async {
          fakePlatform.checkError = PlatformException(
            code: 'UNAVAILABLE',
            message: 'Could not determine connectivity status',
          );
          await expectLater(
            connectivity.checkConnectivity(),
            throwsA(isA<PlatformException>()),
          );
        },
      );

      test(
        'should handle concurrent invocations without cross-talk when called '
        'in parallel',
        () async {
          fakePlatform.checkResult = [ConnectivityResult.mobile];
          final results = await Future.wait([
            connectivity.checkConnectivity(),
            connectivity.checkConnectivity(),
            connectivity.checkConnectivity(),
          ]);
          expect(results, everyElement(equals([ConnectivityResult.mobile])));
          expect(fakePlatform.checkCallCount, 3);
        },
      );
    });

    group('error handling', () {
      test(
        'should throw TimeoutException when the platform never responds and '
        'the caller applies a timeout',
        () async {
          // 模拟平台通道无响应：checkConnectivity 永不完成，
          // 调用方通过 Future.timeout 兜底，验证门面层不会吞掉超时。
          fakePlatform.hangForever = true;
          await expectLater(
            connectivity
                .checkConnectivity()
                .timeout(const Duration(milliseconds: 200)),
            throwsA(isA<TimeoutException>()),
          );
        },
      );

      test(
        'should propagate permission exceptions when the platform denies '
        'network access (e.g. GET_NETWORK_INFO)',
        () async {
          // 模拟权限被系统拒绝（Android GET_NETWORK_INFO / OHOS
          // ohos.permission.INTERNET 等）：平台层抛出权限错误码的
          // PlatformException，验证其原样传播、不被门面层吞掉。
          fakePlatform.checkError = PlatformException(
            code: 'PERMISSION_DENIED',
            message: 'GET_NETWORK_INFO permission is denied',
          );
          await expectLater(
            connectivity.checkConnectivity(),
            throwsA(
              isA<PlatformException>().having(
                (error) => error.code,
                'code',
                'PERMISSION_DENIED',
              ),
            ),
          );
        },
      );

      test(
        'should complete the subscription when the platform stream closes '
        'after the device disconnects',
        () async {
          // 模拟设备断开/平台流关闭：先发射最后一次 [none]，随后流 done，
          // 验证订阅者既收到末次事件也收到完成回调。
          final emitted = <List<ConnectivityResult>>[];
          var done = false;
          final subscription = connectivity.onConnectivityChanged.listen(
            emitted.add,
            onDone: () => done = true,
          );

          fakePlatform.controller.add([ConnectivityResult.none]);
          await fakePlatform.controller.close();
          await pumpEventQueue(times: 50);
          await subscription.cancel();

          expect(emitted, [
            [ConnectivityResult.none],
          ]);
          expect(done, isTrue);
        },
      );
    });

    group('onConnectivityChanged', () {
      test(
        'should emit events when the platform stream fires',
        () async {
          final emitted = <List<ConnectivityResult>>[];
          final subscription =
              connectivity.onConnectivityChanged.listen(emitted.add);

          fakePlatform.controller.add([ConnectivityResult.wifi]);
          fakePlatform.controller.add([ConnectivityResult.none]);

          await pumpEventQueue(times: 50);
          await subscription.cancel();

          expect(emitted, [
            [ConnectivityResult.wifi],
            [ConnectivityResult.none],
          ]);
        },
      );

      test(
        'should filter out consecutive duplicates when the platform '
        're-emits the same state',
        () async {
          final emitted = <List<ConnectivityResult>>[];
          final subscription =
              connectivity.onConnectivityChanged.listen(emitted.add);

          // 连续相同的 wifi 事件应被去重，仅发射一次。
          fakePlatform.controller.add([ConnectivityResult.wifi]);
          fakePlatform.controller.add([ConnectivityResult.wifi]);
          // 顺序不同的相同元素集合，仍视为相等（ListEquality 按内容比较）。
          fakePlatform.controller.add([ConnectivityResult.none]);
          fakePlatform.controller.add([ConnectivityResult.wifi]);

          await pumpEventQueue(times: 50);
          await subscription.cancel();

          expect(emitted, [
            [ConnectivityResult.wifi],
            [ConnectivityResult.none],
            [ConnectivityResult.wifi],
          ]);
        },
      );

      test(
        'should support multiple concurrent subscribers when several '
        'listeners attach',
        () async {
          final first = <List<ConnectivityResult>>[];
          final second = <List<ConnectivityResult>>[];

          final subA = connectivity.onConnectivityChanged.listen(first.add);
          final subB = connectivity.onConnectivityChanged.listen(second.add);

          fakePlatform.controller.add([ConnectivityResult.ethernet]);

          await pumpEventQueue(times: 50);
          await subA.cancel();
          await subB.cancel();

          expect(first, [
            [ConnectivityResult.ethernet]
          ]);
          expect(second, [
            [ConnectivityResult.ethernet]
          ]);
        },
      );

      test(
        'should emit network switch transitions in order when the network '
        'changes repeatedly',
        () async {
          final emitted = <List<ConnectivityResult>>[];
          final subscription =
              connectivity.onConnectivityChanged.listen(emitted.add);

          // 模拟网络切换：wifi -> mobile -> wifi+vpn -> none
          fakePlatform.controller.add([ConnectivityResult.wifi]);
          fakePlatform.controller.add([ConnectivityResult.mobile]);
          fakePlatform.controller.add([
            ConnectivityResult.wifi,
            ConnectivityResult.vpn,
          ]);
          fakePlatform.controller.add([ConnectivityResult.none]);

          await pumpEventQueue(times: 50);
          await subscription.cancel();

          expect(emitted, [
            [ConnectivityResult.wifi],
            [ConnectivityResult.mobile],
            [ConnectivityResult.wifi, ConnectivityResult.vpn],
            [ConnectivityResult.none],
          ]);
        },
      );
    });
  });
}
