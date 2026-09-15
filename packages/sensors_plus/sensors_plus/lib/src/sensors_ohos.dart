import 'package:sensors_plus_platform_interface/sensors_plus_platform_interface.dart';

/// The Sensors implementation.
class Sensors extends SensorsPlatform {
  /// Constructs a singleton instance of [Sensors].
  ///
  /// [Sensors] is designed to work as a singleton.
  factory Sensors() => _singleton ??= Sensors._();

  Sensors._();

  static Sensors? _singleton;

  static SensorsPlatform get _platform => SensorsPlatform.instance;

  /// A broadcast stream of events from the device accelerometer.
  @override
  Stream<AccelerometerEvent> accelerometerEventStream({
    Duration samplingPeriod = SensorInterval.normalInterval,
  }) {
    return _platform.accelerometerEventStream(samplingPeriod: samplingPeriod);
  }

  /// A broadcast stream of events from the device gyroscope.
  @override
  Stream<GyroscopeEvent> gyroscopeEventStream({
    Duration samplingPeriod = SensorInterval.normalInterval,
  }) {
    return _platform.gyroscopeEventStream(samplingPeriod: samplingPeriod);
  }

  /// Events from the device accelerometer with gravity removed.
  @override
  Stream<UserAccelerometerEvent> userAccelerometerEventStream({
    Duration samplingPeriod = SensorInterval.normalInterval,
  }) {
    return _platform.userAccelerometerEventStream(
        samplingPeriod: samplingPeriod);
  }

  /// A broadcast stream of events from the device magnetometer.
  @override
  Stream<MagnetometerEvent> magnetometerEventStream({
    Duration samplingPeriod = SensorInterval.normalInterval,
  }) {
    return _platform.magnetometerEventStream(samplingPeriod: samplingPeriod);
  }

}
