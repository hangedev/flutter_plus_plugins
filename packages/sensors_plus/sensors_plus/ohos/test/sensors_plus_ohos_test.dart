import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart'
    show TestDefaultBinaryMessengerBinding, TestWidgetsFlutterBinding;
import 'package:sensors_plus_ohos/sensors_plus_ohos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final MethodChannel methodChannel =
      MethodChannel('dev.fluttercommunity.plus/sensors/method');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    methodChannel,
    (message) => null,
  );

  test('$accelerometerEvents are streamed', () async {
    const channelName = 'dev.fluttercommunity.plus/sensors/accelerometer';
    const sensorData = <double>[1.0, 2.0, 3.0, 1700000000000000.0];
    _initializeFakeSensorChannel(channelName, sensorData);
    final event = await accelerometerEvents.first;
    expect(event.x, sensorData[0]);
    expect(event.y, sensorData[1]);
    expect(event.z, sensorData[2]);
  });

  test('$gyroscopeEvents are streamed', () async {
    const channelName = 'dev.fluttercommunity.plus/sensors/gyroscope';
    const sensorData = <double>[3.0, 4.0, 5.0, 1700000000000000.0];
    _initializeFakeSensorChannel(channelName, sensorData);
    final event = await gyroscopeEvents.first;
    expect(event.x, sensorData[0]);
    expect(event.y, sensorData[1]);
    expect(event.z, sensorData[2]);
  });

  test('$magnetometerEvents are streamed', () async {
    const channelName = 'dev.fluttercommunity.plus/sensors/magnetometer';
    const sensorData = <double>[8.0, 9.0, 10.0, 1700000000000000.0];
    _initializeFakeSensorChannel(channelName, sensorData);
    final event = await magnetometerEvents.first;
    expect(event.x, sensorData[0]);
    expect(event.y, sensorData[1]);
    expect(event.z, sensorData[2]);
  });

  test('barometerEventStream is streamed', () async {
    const channelName = 'dev.fluttercommunity.plus/sensors/barometer';
    const sensorData = <double>[1013.25, 1700000000000000.0];
    _initializeFakeSensorChannel(channelName, sensorData);
    final event = await barometerEventStream().first;
    expect(event.pressure, sensorData[0]);
    expect(
      event.timestamp,
      DateTime.fromMicrosecondsSinceEpoch(sensorData[1].toInt()),
    );
  });
}

void _initializeFakeSensorChannel(String channelName, List<double> sensorData) {
  const standardMethod = StandardMethodCodec();
  void emitEvent(ByteData? event) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
      channelName,
      event,
      (ByteData? reply) {},
    );
  }

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler(channelName, (ByteData? message) async {
    final methodCall = standardMethod.decodeMethodCall(message);
    if (methodCall.method == 'listen') {
      emitEvent(standardMethod.encodeSuccessEnvelope(sensorData));
      emitEvent(null);
      return standardMethod.encodeSuccessEnvelope(null);
    } else if (methodCall.method == 'cancel') {
      return standardMethod.encodeSuccessEnvelope(null);
    } else {
      fail('Expected listen or cancel');
    }
  });
}
