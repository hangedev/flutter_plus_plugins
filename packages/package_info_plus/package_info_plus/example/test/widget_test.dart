// Widget test for the package_info_plus example app.
//
// The home page loads its data through PackageInfo.fromPlatform in
// initState, so mock values are seeded before pumping the widget —
// no platform channel is involved.

import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:package_info_plus_example/main.dart';

void main() {
  testWidgets('renders every package info tile with the platform values',
      (WidgetTester tester) async {
    PackageInfo.setMockInitialValues(
      appName: 'mock_package_info_example',
      packageName: 'io.flutter.plugins.mockpackageinfoexample',
      version: '1.2.3',
      buildNumber: '4',
      buildSignature: 'a1b2c3d4e5f6a7b8',
      installerStore: 'com.example.store',
    );

    await tester.pumpWidget(const MyApp());

    expect(find.text('PackageInfoPlus example'), findsOneWidget);

    // Let the initState platform lookup complete and rebuild the tiles.
    await tester.pumpAndSettle();

    expect(find.text('App name'), findsOneWidget);
    expect(find.text('mock_package_info_example'), findsOneWidget);
    expect(find.text('Package name'), findsOneWidget);
    expect(find.text('io.flutter.plugins.mockpackageinfoexample'), findsOneWidget);
    expect(find.text('App version'), findsOneWidget);
    expect(find.text('1.2.3'), findsOneWidget);
    expect(find.text('Build number'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Build signature'), findsOneWidget);
    expect(find.text('a1b2c3d4e5f6a7b8'), findsOneWidget);
    expect(find.text('Installer store'), findsOneWidget);
    expect(find.text('com.example.store'), findsOneWidget);
  });

  testWidgets('falls back to placeholders until the platform answers',
      (WidgetTester tester) async {
    PackageInfo.setMockInitialValues(
      appName: 'Unknown',
      packageName: 'Unknown',
      version: 'Unknown',
      buildNumber: 'Unknown',
      buildSignature: 'Unknown',
      installerStore: null,
    );

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Empty/unset fields are rendered as 'Unknown'/'not available' rather
    // than blank tiles.
    expect(find.text('Unknown'), findsNWidgets(5));
    expect(find.text('not available'), findsOneWidget);
  });
}
