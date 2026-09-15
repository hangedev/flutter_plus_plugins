// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:platform/platform.dart';

void main() {
  AndroidIntent androidIntent;
  late MockMethodChannel mockChannel;
  setUp(() {
    mockChannel = MockMethodChannel();
  });
  tearDown(() {
    reset(mockChannel);
  });

  group('AndroidIntent', () {
    test('raises error if neither an action nor a component is provided', () {
      try {
        androidIntent = AndroidIntent(data: 'https://flutter.dev');
        fail('should raise an AssertionError');
      } on AssertionError catch (e) {
        expect(e.message, 'action or component (or both) must be specified');
      } catch (e) {
        fail('should raise an AssertionError');
      }
    });

    group('launch', () {
      test('pass right params', () async {
        androidIntent = AndroidIntent.private(
            action: 'action_view',
            data: Uri.encodeFull('https://flutter.dev'),
            flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
            channel: mockChannel,
            platform: FakePlatform(operatingSystem: 'android'),
            type: 'video/*');
        await androidIntent.launch();
        verify(mockChannel.invokeMethod<void>('launch', <String, Object>{
          'action': 'action_view',
          'data': Uri.encodeFull('https://flutter.dev'),
          'flags':
              androidIntent.convertFlags(<int>[Flag.FLAG_ACTIVITY_NEW_TASK]),
          'type': 'video/*',
        }));
      });

      test('can send Intent with an action and no component', () async {
        androidIntent = AndroidIntent.private(
          action: 'action_view',
          channel: mockChannel,
          platform: FakePlatform(operatingSystem: 'android'),
        );
        await androidIntent.launch();
        verify(mockChannel.invokeMethod<void>('launch', <String, Object>{
          'action': 'action_view',
        }));
      });

      test('should pass category param when it is provided', () async {
        androidIntent = AndroidIntent.private(
          action: 'action_view',
          category: 'android.intent.category.DEFAULT',
          channel: mockChannel,
          platform: FakePlatform(operatingSystem: 'android'),
        );
        expect(androidIntent.category, 'android.intent.category.DEFAULT');
        await androidIntent.launch();
        verify(mockChannel.invokeMethod<void>('launch', <String, Object>{
          'action': 'action_view',
          'category': 'android.intent.category.DEFAULT',
        }));
      });

      test('should omit category key from arguments when category is null',
          () async {
        androidIntent = AndroidIntent.private(
          action: 'action_view',
          category: null,
          channel: mockChannel,
          platform: FakePlatform(operatingSystem: 'android'),
        );
        expect(androidIntent.category, isNull);
        await androidIntent.launch();
        verify(mockChannel.invokeMethod<void>('launch', <String, Object>{
          'action': 'action_view',
        }));
      });

      test('should pass arguments and arrayArguments when they are provided',
          () async {
        androidIntent = AndroidIntent.private(
          action: 'action_view',
          arguments: <String, dynamic>{'key': 'value'},
          arrayArguments: <String, List<dynamic>>{
            'days': <int>[1, 2, 3],
          },
          channel: mockChannel,
          platform: FakePlatform(operatingSystem: 'android'),
        );
        await androidIntent.launch();
        verify(mockChannel.invokeMethod<void>('launch', <String, Object>{
          'action': 'action_view',
          'arguments': <String, dynamic>{'key': 'value'},
          'arrayArguments': <String, List<dynamic>>{
            'days': <int>[1, 2, 3],
          },
        }));
      });

      test('can send Intent with a component and no action', () async {
        androidIntent = AndroidIntent.private(
          package: 'packageName',
          componentName: 'componentName',
          channel: mockChannel,
          platform: FakePlatform(operatingSystem: 'android'),
        );
        await androidIntent.launch();
        verify(mockChannel.invokeMethod<void>('launch', <String, Object>{
          'package': 'packageName',
          'componentName': 'componentName',
        }));
      });

      test('call in ios platform', () async {
        androidIntent = AndroidIntent.private(
            action: 'action_view',
            channel: mockChannel,
            platform: FakePlatform(operatingSystem: 'ios'));
        await androidIntent.launch();
        verifyZeroInteractions(mockChannel);
      });
    });

    group('canResolveActivity', () {
      test('pass right params', () async {
        androidIntent = AndroidIntent.private(
            action: 'action_view',
            data: Uri.encodeFull('https://flutter.dev'),
            flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
            channel: mockChannel,
            platform: FakePlatform(operatingSystem: 'android'),
            type: 'video/*');
        await androidIntent.canResolveActivity();
        verify(mockChannel
            .invokeMethod<void>('canResolveActivity', <String, Object>{
          'action': 'action_view',
          'data': Uri.encodeFull('https://flutter.dev'),
          'flags':
              androidIntent.convertFlags(<int>[Flag.FLAG_ACTIVITY_NEW_TASK]),
          'type': 'video/*',
        }));
      });

      test('can send Intent with an action and no component', () async {
        androidIntent = AndroidIntent.private(
          action: 'action_view',
          channel: mockChannel,
          platform: FakePlatform(operatingSystem: 'android'),
        );
        await androidIntent.canResolveActivity();
        verify(mockChannel
            .invokeMethod<void>('canResolveActivity', <String, Object>{
          'action': 'action_view',
        }));
      });

      test('can send Intent with a component and no action', () async {
        androidIntent = AndroidIntent.private(
          package: 'packageName',
          componentName: 'componentName',
          channel: mockChannel,
          platform: FakePlatform(operatingSystem: 'android'),
        );
        await androidIntent.canResolveActivity();
        verify(mockChannel
            .invokeMethod<void>('canResolveActivity', <String, Object>{
          'package': 'packageName',
          'componentName': 'componentName',
        }));
      });

      test('call in ios platform', () async {
        androidIntent = AndroidIntent.private(
            action: 'action_view',
            channel: mockChannel,
            platform: FakePlatform(operatingSystem: 'ios'));
        await androidIntent.canResolveActivity();
        verifyZeroInteractions(mockChannel);
      });
    });

    group('getResolvedActivity', () {
      test('pass right params', () async {
        androidIntent = AndroidIntent.private(
            action: 'action_view',
            data: Uri.encodeFull('https://flutter.dev'),
            flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
            channel: mockChannel,
            platform: FakePlatform(operatingSystem: 'android'),
            type: 'video/*');
        await androidIntent.getResolvedActivity();
        verify(mockChannel
            .invokeMethod<void>('getResolvedActivity', <String, Object>{
          'action': 'action_view',
          'data': Uri.encodeFull('https://flutter.dev'),
          'flags':
              androidIntent.convertFlags(<int>[Flag.FLAG_ACTIVITY_NEW_TASK]),
          'type': 'video/*',
        }));
      });

      test('returns a ResolvedActivity', () async {
        androidIntent = AndroidIntent.private(
          action: 'action_view',
          data: Uri.encodeFull('https://flutter.dev'),
          channel: mockChannel,
          platform: FakePlatform(operatingSystem: 'android'),
        );

        when(mockChannel.invokeMethod("getResolvedActivity", any))
            .thenAnswer((_) async => <String, dynamic>{
                  "activityName": "activity name",
                  "appName": "App Name",
                  "packageName": "com.packagename",
                });

        final result = await androidIntent.getResolvedActivity();

        expect(result?.activityName, equals("activity name"));
        expect(result?.appName, equals("App Name"));
        expect(result?.packageName, equals("com.packagename"));
      });

      test('can send Intent with an action and no component', () async {
        androidIntent = AndroidIntent.private(
          action: 'action_view',
          channel: mockChannel,
          platform: FakePlatform(operatingSystem: 'android'),
        );
        await androidIntent.getResolvedActivity();
        verify(mockChannel
            .invokeMethod<void>('getResolvedActivity', <String, Object>{
          'action': 'action_view',
        }));
      });

      test('can send Intent with a component and no action', () async {
        androidIntent = AndroidIntent.private(
          package: 'packageName',
          componentName: 'componentName',
          channel: mockChannel,
          platform: FakePlatform(operatingSystem: 'android'),
        );
        await androidIntent.getResolvedActivity();
        verify(mockChannel
            .invokeMethod<void>('getResolvedActivity', <String, Object>{
          'package': 'packageName',
          'componentName': 'componentName',
        }));
      });

      test('call in ios platform', () async {
        androidIntent = AndroidIntent.private(
            action: 'action_view',
            channel: mockChannel,
            platform: FakePlatform(operatingSystem: 'ios'));
        await androidIntent.getResolvedActivity();
        verifyZeroInteractions(mockChannel);
      });
    });

    group('launchChooser', () {
      test('pass title', () async {
        androidIntent = AndroidIntent.private(
          action: 'action_view',
          channel: mockChannel,
          platform: FakePlatform(operatingSystem: 'android'),
        );
        await androidIntent.launchChooser('title');
        verify(mockChannel.invokeMethod<void>('launchChooser', <String, Object>{
          'action': 'action_view',
          'chooserTitle': 'title',
        }));
      });
    });

    group('sendService', () {
      test('start a service', () async {
        androidIntent = AndroidIntent.private(
          action: 'com.example.service',
          channel: mockChannel,
          platform: FakePlatform(operatingSystem: 'android'),
        );
        await androidIntent.sendService();
        verify(mockChannel.invokeMethod<void>('sendService', <String, Object>{
          'action': 'com.example.service',
        }));
      });
    });

    group('sendBroadcast', () {
      test('send a broadcast', () async {
        androidIntent = AndroidIntent.private(
          action: 'com.example.broadcast',
          channel: mockChannel,
          platform: FakePlatform(operatingSystem: 'android'),
        );
        await androidIntent.sendBroadcast();
        verify(mockChannel.invokeMethod<void>('sendBroadcast', <String, Object>{
          'action': 'com.example.broadcast',
        }));
      });
    });

    group('parseAndLaunch', () {
      test('should return without invoking the channel when called on an '
          'unsupported platform', () async {
        TestWidgetsFlutterBinding.ensureInitialized();
        var invoked = false;
        const channel = MethodChannel('dev.fluttercommunity.plus/android_intent');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall call) async {
          invoked = true;
          return null;
        });
        // 宿主机(Windows/macOS/Linux)上平台守卫直接返回, 不触发通道调用
        await AndroidIntent.parseAndLaunch('intent://scan/#Intent;end');
        expect(invoked, isFalse);
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      });
    });

    group('timeout handling', () {
      test('should throw TimeoutException when launch never completes',
          () async {
        androidIntent = AndroidIntent.private(
          action: 'action_view',
          channel: mockChannel,
          platform: FakePlatform(operatingSystem: 'android'),
        );
        when(mockChannel.invokeMethod<void>('launch', any))
            .thenAnswer((_) => Completer<void>().future);
        await expectLater(
          androidIntent.launch().timeout(const Duration(milliseconds: 50)),
          throwsA(isA<TimeoutException>()),
        );
      });

      test('should throw TimeoutException when getResolvedActivity never '
          'completes', () async {
        androidIntent = AndroidIntent.private(
          action: 'action_view',
          channel: mockChannel,
          platform: FakePlatform(operatingSystem: 'android'),
        );
        when(mockChannel.invokeMethod<Map<Object?, Object?>>(
                'getResolvedActivity', any))
            .thenAnswer(
                (_) => Completer<Map<Object?, Object?>>().future);
        await expectLater(
          androidIntent
              .getResolvedActivity()
              .timeout(const Duration(milliseconds: 50)),
          throwsA(isA<TimeoutException>()),
        );
      });
    });

    group('concurrent calls', () {
      test('should handle concurrent launch calls of multiple intents',
          () async {
        final intents = <AndroidIntent>[
          AndroidIntent.private(
            action: 'action_one',
            channel: mockChannel,
            platform: FakePlatform(operatingSystem: 'android'),
          ),
          AndroidIntent.private(
            action: 'action_two',
            channel: mockChannel,
            platform: FakePlatform(operatingSystem: 'android'),
          ),
          AndroidIntent.private(
            action: 'action_three',
            channel: mockChannel,
            platform: FakePlatform(operatingSystem: 'android'),
          ),
        ];
        await Future.wait(intents.map((intent) => intent.launch()));
        verify(mockChannel.invokeMethod<void>('launch',
            <String, Object>{'action': 'action_one'}));
        verify(mockChannel.invokeMethod<void>('launch',
            <String, Object>{'action': 'action_two'}));
        verify(mockChannel.invokeMethod<void>('launch',
            <String, Object>{'action': 'action_three'}));
      });

      test('should handle concurrent mixed method calls', () async {
        final launchIntent = AndroidIntent.private(
          action: 'action_launch',
          channel: mockChannel,
          platform: FakePlatform(operatingSystem: 'android'),
        );
        final broadcastIntent = AndroidIntent.private(
          action: 'action_broadcast',
          channel: mockChannel,
          platform: FakePlatform(operatingSystem: 'android'),
        );
        final serviceIntent = AndroidIntent.private(
          action: 'action_service',
          channel: mockChannel,
          platform: FakePlatform(operatingSystem: 'android'),
        );
        final chooserIntent = AndroidIntent.private(
          action: 'action_chooser',
          channel: mockChannel,
          platform: FakePlatform(operatingSystem: 'android'),
        );
        await Future.wait(<Future<void>>[
          launchIntent.launch(),
          broadcastIntent.sendBroadcast(),
          serviceIntent.sendService(),
          chooserIntent.launchChooser('title'),
        ]);
        verify(mockChannel.invokeMethod<void>(
            'launch', <String, Object>{'action': 'action_launch'}));
        verify(mockChannel.invokeMethod<void>(
            'sendBroadcast', <String, Object>{'action': 'action_broadcast'}));
        verify(mockChannel.invokeMethod<void>(
            'sendService', <String, Object>{'action': 'action_service'}));
        verify(mockChannel.invokeMethod<void>('launchChooser', <String, Object>{
          'action': 'action_chooser',
          'chooserTitle': 'title',
        }));
      });
    });
  });

  // === 鸿蒙平台测试 ===
  group('Ohos AndroidIntent', () {
    test('should send launch on ohos platform', () async {
      androidIntent = AndroidIntent.private(
        action: 'action_view',
        channel: mockChannel,
        platform: FakePlatform(operatingSystem: 'ohos'),
      );
      await androidIntent.launch();
      verify(mockChannel.invokeMethod<void>('launch', <String, Object>{
        'action': 'action_view',
      }));
    });

    test('should send broadcast on ohos platform', () async {
      androidIntent = AndroidIntent.private(
        action: 'com.example.broadcast',
        channel: mockChannel,
        platform: FakePlatform(operatingSystem: 'ohos'),
      );
      await androidIntent.sendBroadcast();
      verify(mockChannel.invokeMethod<void>('sendBroadcast', <String, Object>{
        'action': 'com.example.broadcast',
      }));
    });

    test('should launch chooser on ohos platform', () async {
      androidIntent = AndroidIntent.private(
        action: 'action_view',
        channel: mockChannel,
        platform: FakePlatform(operatingSystem: 'ohos'),
      );
      await androidIntent.launchChooser('title');
      verify(mockChannel.invokeMethod<void>('launchChooser', <String, Object>{
        'action': 'action_view',
        'chooserTitle': 'title',
      }));
    });

    test('should return channel result from canResolveActivity on ohos '
        'platform', () async {
      androidIntent = AndroidIntent.private(
        action: 'action_view',
        channel: mockChannel,
        platform: FakePlatform(operatingSystem: 'ohos'),
      );
      when(mockChannel.invokeMethod<bool>('canResolveActivity', any))
          .thenAnswer((_) async => true);
      final result = await androidIntent.canResolveActivity();
      expect(result, isTrue);
    });
  });

  group('ResolvedActivity', () {
    test('should compare equal when all fields match', () {
      final a = ResolvedActivity(
        appName: 'App Name',
        activityName: 'activity name',
        packageName: 'com.packagename',
      );
      final b = ResolvedActivity(
        appName: 'App Name',
        activityName: 'activity name',
        packageName: 'com.packagename',
      );
      expect(a, equals(b));
      expect(a == a, isTrue);
      expect(a.hashCode, b.hashCode);
    });

    test('should not compare equal when any field differs', () {
      final a = ResolvedActivity(
        appName: 'App Name',
        activityName: 'activity name',
        packageName: 'com.packagename',
      );
      final b = ResolvedActivity(
        appName: 'Other App',
        activityName: 'activity name',
        packageName: 'com.packagename',
      );
      final c = ResolvedActivity(
        appName: 'App Name',
        activityName: 'other activity',
        packageName: 'com.packagename',
      );
      final d = ResolvedActivity(
        appName: 'App Name',
        activityName: 'activity name',
        packageName: 'com.other',
      );
      expect(a == b, isFalse);
      expect(a == c, isFalse);
      expect(a == d, isFalse);
    });

    test('should include all fields in toString', () {
      final a = ResolvedActivity(
        appName: 'App Name',
        activityName: 'activity name',
        packageName: 'com.packagename',
      );
      expect(a.toString(), contains('appName: App Name'));
      expect(a.toString(), contains('activityName: activity name'));
      expect(a.toString(), contains('packageName: com.packagename'));
    });
  });

  group('convertFlags ', () {
    androidIntent = const AndroidIntent(
      action: 'action_view',
    );
    test('add filled flag list', () async {
      final flags = <int>[];
      flags.add(Flag.FLAG_ACTIVITY_NEW_TASK);
      flags.add(Flag.FLAG_ACTIVITY_NEW_DOCUMENT);
      expect(
        androidIntent.convertFlags(flags),
        268959744,
      );
    });
    test('add flags whose values are not power of 2', () async {
      final flags = <int>[];
      flags.add(100);
      flags.add(10);
      expect(
        () => androidIntent.convertFlags(flags),
        throwsArgumentError,
      );
    });
    test('add empty flag list', () async {
      final flags = <int>[];
      expect(
        androidIntent.convertFlags(flags),
        0,
      );
    });
    test('should handle the smallest flag value', () async {
      expect(
        androidIntent.convertFlags(<int>[1]),
        1,
      );
    });
    test('should handle large flag values', () async {
      expect(
        androidIntent.convertFlags(<int>[0x40000000, 0x80000000]),
        0xC0000000,
      );
    });
  });
}

// https://github.com/dart-lang/mockito/issues/316
class MockMethodChannel extends Mock implements MethodChannel {
  @override
  Future<T?> invokeMethod<T>(String method, [dynamic arguments]) async {
    return super
            .noSuchMethod(Invocation.method(#invokeMethod, [method, arguments]))
        as dynamic;
  }
}
