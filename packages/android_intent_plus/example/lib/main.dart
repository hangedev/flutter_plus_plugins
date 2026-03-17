// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:platform/platform.dart';

void main() {
  runApp(const MyApp());
}

/// A sample app for launching intents.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0x9f4376f8),
      ),
      home: const MyHomePage(),
      routes: <String, WidgetBuilder>{
        ExplicitIntentsWidget.routeName: (BuildContext context) =>
            const ExplicitIntentsWidget()
      },
    );
  }
}

/// Holds the different intent widgets.
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  void _createAlarm() {
    if (const LocalPlatform().operatingSystem == 'ohos') {
      const intent = AndroidIntent(
          action: 'ohos.want.action.setAlarm', // 设置闹钟暂不支持
          arguments: <String, dynamic>{
            'hour': 21,
            'minute': 30,
            'daysOfWeek': [2, 3, 4, 5, 6],
            'title': 'Create a Flutter app',
            'content': 'Create a Flutter app',
          },
        );
        intent.launch();
        return;
    }
    const intent = AndroidIntent(
      action: 'android.intent.action.SET_ALARM',
      arguments: <String, dynamic>{
        'android.intent.extra.alarm.DAYS': <int>[2, 3, 4, 5, 6],
        'android.intent.extra.alarm.HOUR': 21,
        'android.intent.extra.alarm.MINUTES': 30,
        'android.intent.extra.alarm.SKIP_UI': true,
        'android.intent.extra.alarm.MESSAGE': 'Create a Flutter app',
      },
    );
    intent.launch();
  }

  void _openExplicitIntentsView(BuildContext context) {
    Navigator.of(context).pushNamed(ExplicitIntentsWidget.routeName);
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (const LocalPlatform().isAndroid || const LocalPlatform().operatingSystem == 'ohos') {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ElevatedButton(
              onPressed: _createAlarm,
              child: const Text(
                  'Tap here to set an alarm\non weekdays at 9:30pm.'),
            ),
            ElevatedButton(
              onPressed: _parseAndLaunch,
              child: const Text('Tap here to set an alarm\n based on URI'),
            ),
            ElevatedButton(
              onPressed: _openChooser,
              child: const Text('Tap here to launch Intent with Chooser'),
            ),
            ElevatedButton(
              onPressed: _sendBroadcast,
              child: const Text('Tap here to send Intent as broadcast'),
            ),
            ElevatedButton(
              onPressed: () => _openExplicitIntentsView(context),
              child: const Text('Tap here to test explicit intents.'),
            ),
          ],
        ),
      );
    } else {
      body = const Text('This plugin only works with Android');
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Android intent plus example app'),
        elevation: 4,
      ),
      body: Center(child: body),
    );
  }

  void _openChooser() {
    if (const LocalPlatform().operatingSystem == 'ohos') {
      const intent = AndroidIntent(
        action: 'ohos.want.action.viewData',
      );
      intent.launchChooser('Chose an app');
      return;
    }
    const intent = AndroidIntent(
      action: 'android.intent.action.SEND',
      type: 'plain/text',
      data: 'text example',
    );
    intent.launchChooser('Chose an app');
  }

  void _sendBroadcast() {
    if (const LocalPlatform().operatingSystem == 'ohos') {
      const intent = AndroidIntent(
        action: 'com.example.broadcast',
        arguments: <String, dynamic>{
          'code': 0,
        },
      );
      intent.sendBroadcast();
      return;
    }
    const intent = AndroidIntent(
      action: 'com.example.broadcast',
    );
    intent.sendBroadcast();
  }

  void _parseAndLaunch() {
    if (const LocalPlatform().operatingSystem == 'ohos') {
      // 使用JSON字符串格式
      const intent = '{"action":"ohos.want.action.setAlarm","parameters":{"ohos.alarm.time":"2130","ohos.alarm.repeat.days":127,"ohos.alarm.label":"Create a Flutter app"}}';
      AndroidIntent.parseAndLaunch(intent);
      return;
    }
    const intent = 'intent:#Intent;'
        'action=android.intent.action.SET_ALARM;'
        'B.android.intent.extra.alarm.SKIP_UI=true;'
        'S.android.intent.extra.alarm.MESSAGE=Create%20a%20Flutter%20app;'
        'i.android.intent.extra.alarm.MINUTES=30;'
        'i.android.intent.extra.alarm.HOUR=21;'
        'end';

    AndroidIntent.parseAndLaunch(intent);
  }
}

/// Launches intents to specific Android activities.
class ExplicitIntentsWidget extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const ExplicitIntentsWidget(); // ignore: public_member_api_docs

  // ignore: public_member_api_docs
  static const String routeName = '/explicitIntents';

  void _openGoogleMapsStreetView() {
    if (LocalPlatform().operatingSystem == 'ohos') {
      const intent = AndroidIntent(
        action: 'ohos.want.action.viewData',
        data: 'baidumap://map/streetview?location=39.915156,116.403694' // 地图api 暂不支持此服务
      );
      intent.launch();
      return;
    }
    final intent = AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull('google.streetview:cbll=46.414382,10.013988'),
        package: 'com.google.android.apps.maps');
    intent.launch();
  }

  void _displayMapInGoogleMaps({int zoomLevel = 12}) {
    if (LocalPlatform().operatingSystem == 'ohos') {
      const intent = AndroidIntent(
        action: 'ohos.want.action.viewData',
        data: 'baidumap://map/geocoder?address=加利福尼亚州旧金山市政中心&location=37.7749,-122.4194'
      );
      intent.launch();
      return;
    }
    final intent = AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull('geo:37.7749,-122.4194?z=$zoomLevel'),
        package: 'com.google.android.apps.maps');
    intent.launch();
  }

  void _launchTurnByTurnNavigationInGoogleMaps() {
    if (LocalPlatform().operatingSystem == 'ohos') {
      const intent = AndroidIntent(
        action: 'ohos.want.action.viewData',
        data: 'baidumap://map/direction?destination=name:天安门|latlng:39.915156,116.403694'
      );
      intent.launch();
      return;
    }
    final intent = AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull(
            'google.navigation:q=Taronga+Zoo,+Sydney+Australia&avoid=tf'),
        package: 'com.google.android.apps.maps');
    intent.launch();
  }

  void _openLinkInGoogleChrome() {
    if (const LocalPlatform().operatingSystem == 'ohos') {
      final intent = AndroidIntent(
        action: 'ohos.want.action.viewData',
        data: Uri.encodeFull('https://flutter.dev'),
        package: 'com.huawei.hmos.browser',
      );
      intent.launch();
      return;
    }
    final intent = AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull('https://flutter.dev'),
        package: 'com.android.chrome');
    intent.launch();
  }

  void _startActivityInNewTask() {
    if (const LocalPlatform().operatingSystem == 'ohos') {
      final intent = AndroidIntent(
        action: 'ohos.want.action.viewData',
        data: Uri.encodeFull('https://flutter.dev'),
      );
      intent.launch();
      return;
    }
    final intent = AndroidIntent(
      action: 'action_view',
      data: Uri.encodeFull('https://flutter.dev'),
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    intent.launch();
  }

  void _testExplicitIntentFallback() {
    if (const LocalPlatform().operatingSystem == 'ohos') {
      final intent = AndroidIntent(
        action: 'ohos.want.action.viewData',
        data: Uri.encodeFull('https://flutter.dev'),
        package: 'com.huawei.hmos.browser.test', // 该方法用于测试显式 Intent 降级为隐式 Intent 的容错机制,目前ohos 传入包名则优先使用包名匹配，如果匹配不到则返回无可打开应用
      );
      intent.launch();
      return;
    }
    final intent = AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull('https://flutter.dev'),
        package: 'com.android.chrome.implicit.fallback');
    intent.launch();
  }

  void _openLocationSettingsConfiguration() {
    if (const LocalPlatform().operatingSystem == 'ohos') {
      const intent = AndroidIntent(
        action: '', // action 是必传项
        data: 'location_manager_settings',
      );
      intent.launch();
      return;
    }
    const AndroidIntent intent = AndroidIntent(
      action: 'action_location_source_settings',
    );
    intent.launch();
  }

  void _openApplicationDetails() {
    if (const LocalPlatform().operatingSystem == 'ohos') {
      const intent = AndroidIntent(
        action: '', // action 是必传项
        data: 'application_info_entry',
        arguments: <String, dynamic>{
            'pushParams': 'com.example.android_intent_plus_example',
          }
      );
      intent.launch();
      return;
    }
    const intent = AndroidIntent(
      action: 'action_application_details_settings',
      data: 'package:io.flutter.plugins.androidintentexample',
    );
    intent.launch();
  }

  void _getResolvedActivity(BuildContext context) async {
    final intent = AndroidIntent(
      action: 'action_view',
      data: Uri.encodeFull('http://'),
    );

    final details = await intent.getResolvedActivity();
    if (details != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${details.appName} - ${details.packageName}")),
      );
    }
  }

  void _openGmail() {
    if (LocalPlatform().operatingSystem == 'ohos') {
      const intent = AndroidIntent(
        action: 'ohos.want.action.sendToData',
        data: 'mailto:eidac@me.com,overbom@mac.com?cc=john@app.com,user@app.com&bcc=liam@me.abc,abel@me.com&subject=I am the subject'
      );
      intent.launch();
      return;
    }
    const intent = AndroidIntent(
      action: 'android.intent.action.SEND',
      arguments: {'android.intent.extra.SUBJECT': 'I am the subject'},
      arrayArguments: {
        'android.intent.extra.EMAIL': ['eidac@me.com', 'overbom@mac.com'],
        'android.intent.extra.CC': ['john@app.com', 'user@app.com'],
        'android.intent.extra.BCC': ['liam@me.abc', 'abel@me.com'],
      },
      package: 'com.google.android.gm',
      type: 'message/rfc822',
    );
    intent.launch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test explicit intents'),
        elevation: 4,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: _openGoogleMapsStreetView,
                child: const Text(
                    'Tap here to display panorama\nimagery in Google Street View.'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _displayMapInGoogleMaps,
                child: const Text('Tap here to display\na map in Google Maps.'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _launchTurnByTurnNavigationInGoogleMaps,
                child: const Text(
                    'Tap here to launch turn-by-turn\nnavigation in Google Maps.'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _openLinkInGoogleChrome,
                child: const Text('Tap here to open link in Google Chrome.'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _startActivityInNewTask,
                child: const Text('Tap here to start activity in new task.'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _testExplicitIntentFallback,
                child: const Text(
                    'Tap here to test explicit intent fallback to implicit.'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _openLocationSettingsConfiguration,
                child: const Text(
                  'Tap here to open Location Settings Configuration',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _openApplicationDetails,
                child: const Text(
                  'Tap here to open Application Details',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _getResolvedActivity(context),
                child: const Text(
                  'Tap here to get default resolved activity',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _openGmail,
                child: const Text(
                  'Tap here to open gmail app with details',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
