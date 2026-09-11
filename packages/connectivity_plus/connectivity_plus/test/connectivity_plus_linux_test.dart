// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:connectivity_plus/src/connectivity_plus_linux.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nm/nm.dart';

import 'connectivity_plus_linux_test.mocks.dart';

@GenerateMocks([NetworkManagerClient])
void main() {
  group('ConnectivityPlusLinuxPlugin registration', () {
    tearDown(() {
      // 恢复全局平台实例，避免测试间状态泄漏。
      ConnectivityPlatform.instance = ConnectivityPlusLinuxPlugin();
    });

    test(
      'should register itself as the platform implementation when '
      'registerWith is called',
      () {
      ConnectivityPlusLinuxPlugin.registerWith();
      expect(
        ConnectivityPlatform.instance,
        isA<ConnectivityPlusLinuxPlugin>(),
      );
    });
  });

  group('ConnectivityPlusLinuxPlugin.checkConnectivity', () {
    late ConnectivityPlusLinuxPlugin linux;

    setUp(() {
      linux = ConnectivityPlusLinuxPlugin();
    });

    tearDown(() {
      linux.createClient = () => NetworkManagerClient();
    });

    test(
      'should return [bluetooth] when the primary connection is bluetooth',
      () async {
      linux.createClient = () {
        final client = MockNetworkManagerClient();
        when(client.connectivity)
            .thenReturn(NetworkManagerConnectivityState.full);
        when(client.primaryConnectionType).thenReturn('bluetooth');
        return client;
      };
      expect(
        linux.checkConnectivity(),
        completion(equals([ConnectivityResult.bluetooth])),
      );
    });

    test(
      'should return [ethernet] when the primary connection is ethernet',
      () async {
      linux.createClient = () {
        final client = MockNetworkManagerClient();
        when(client.connectivity)
            .thenReturn(NetworkManagerConnectivityState.full);
        when(client.primaryConnectionType).thenReturn('ethernet');
        return client;
      };
      expect(
        linux.checkConnectivity(),
        completion(equals([ConnectivityResult.ethernet])),
      );
    });

    test('should return [wifi] when the primary connection is wireless', () async {
      linux.createClient = () {
        final client = MockNetworkManagerClient();
        when(client.connectivity)
            .thenReturn(NetworkManagerConnectivityState.full);
        when(client.primaryConnectionType).thenReturn('wireless');
        return client;
      };
      expect(
        linux.checkConnectivity(),
        completion(equals([ConnectivityResult.wifi])),
      );
    });

    test('should return [vpn] when the primary connection is vpn', () async {
      linux.createClient = () {
        final client = MockNetworkManagerClient();
        when(client.connectivity)
            .thenReturn(NetworkManagerConnectivityState.full);
        when(client.primaryConnectionType).thenReturn('vpn');
        return client;
      };
      expect(
        linux.checkConnectivity(),
        completion(equals([ConnectivityResult.vpn])),
      );
    });

    test('should return [mobile] when the primary connection is mobile', () async {
      linux.createClient = () {
        final client = MockNetworkManagerClient();
        when(client.connectivity)
            .thenReturn(NetworkManagerConnectivityState.full);
        when(client.primaryConnectionType).thenReturn('mobile');
        return client;
      };
      expect(
        linux.checkConnectivity(),
        completion(equals([ConnectivityResult.mobile])),
      );
    });

    test(
      'should return multiple types when the connection is composite '
      'wireless+vpn',
      () async {
        linux.createClient = () {
          final client = MockNetworkManagerClient();
          when(client.connectivity)
              .thenReturn(NetworkManagerConnectivityState.full);
          when(client.primaryConnectionType).thenReturn('wireless,vpn');
          return client;
        };
        expect(
          linux.checkConnectivity(),
          completion(
            equals([ConnectivityResult.wifi, ConnectivityResult.vpn]),
          ),
        );
      },
    );

    test(
      'should return [other] when the primary connection type is unrecognized',
      () async {
        linux.createClient = () {
          final client = MockNetworkManagerClient();
          when(client.connectivity)
              .thenReturn(NetworkManagerConnectivityState.full);
          when(client.primaryConnectionType).thenReturn('carrier-pigeon');
          return client;
        };
        expect(
          linux.checkConnectivity(),
          completion(equals([ConnectivityResult.other])),
        );
      },
    );

    test('should return [none] when NetworkManager reports no connectivity', () async {
      linux.createClient = () {
        final client = MockNetworkManagerClient();
        when(client.connectivity)
            .thenReturn(NetworkManagerConnectivityState.none);
        return client;
      };
      expect(
        linux.checkConnectivity(),
        completion(equals([ConnectivityResult.none])),
      );
    });

    test(
      'should open and close the client once when checkConnectivity is called',
      () async {
        final client = MockNetworkManagerClient();
        when(client.connectivity)
            .thenReturn(NetworkManagerConnectivityState.full);
        when(client.primaryConnectionType).thenReturn('wireless');
        linux.createClient = () => client;

        await linux.checkConnectivity();

        verify(client.connect()).called(1);
        verify(client.close()).called(1);
      },
    );

    test(
      'should propagate errors thrown when connecting to NetworkManager fails',
      () async {
      linux.createClient = () {
        final client = MockNetworkManagerClient();
        when(client.connect())
            .thenThrow(Exception('NetworkManager unavailable'));
        return client;
      };
      await expectLater(
        linux.checkConnectivity(),
        throwsA(isA<Exception>()),
      );
    });

    test('should use the default client factory when none is injected', () {
      // 直接调用 lib 内默认的 createClient 工厂闭包：构造真实
      // NetworkManagerClient（纯对象构造，无 I/O），覆盖默认工厂初始化路径。
      // 真正的 connect 依赖 NetworkManager/dbus，仅存在于 Linux 桌面，
      // 因此不在此处发起连接。
      final client = linux.createClient();
      expect(client, isA<NetworkManagerClient>());
    });
  });

  group('ConnectivityPlusLinuxPlugin.onConnectivityChanged', () {
    late ConnectivityPlusLinuxPlugin linux;

    setUp(() {
      linux = ConnectivityPlusLinuxPlugin();
    });

    tearDown(() {
      linux.createClient = () => NetworkManagerClient();
    });

    test(
      'should emit connectivity transitions when the Connectivity property '
      'changes',
      () {
        linux.createClient = () {
          final client = MockNetworkManagerClient();
          when(client.connectivity)
              .thenReturn(NetworkManagerConnectivityState.full);
          when(client.primaryConnectionType).thenReturn('wireless');
          when(client.propertiesChanged).thenAnswer((_) {
            when(client.connectivity)
                .thenReturn(NetworkManagerConnectivityState.none);
            return Stream.value(['Connectivity']);
          });
          return client;
        };
        expect(
          linux.onConnectivityChanged,
          emitsInOrder([
            [ConnectivityResult.wifi],
            [ConnectivityResult.none],
          ]),
        );
      },
    );

    test(
      'should ignore property changes when they are unrelated to Connectivity',
      () async {
      final emitted = <List<ConnectivityResult>>[];
      linux.createClient = () {
        final client = MockNetworkManagerClient();
        when(client.connectivity)
            .thenReturn(NetworkManagerConnectivityState.full);
        when(client.primaryConnectionType).thenReturn('wireless');
        when(client.propertiesChanged).thenAnswer((_) {
          // 非 Connectivity 属性变化，不应触发新的连接状态事件。
          return Stream.value(['SomeOtherProperty']);
        });
        return client;
      };

      final subscription = linux.onConnectivityChanged.listen(emitted.add);
      // 等待 onListen 异步初始化完成后再断言。
      await pumpEventQueue(times: 50);
      await subscription.cancel();

      // 仅应收到初始事件，不收到 SomeOtherProperty 触发的事件。
      expect(emitted, [
        [ConnectivityResult.wifi],
      ]);
    });
  });
}
