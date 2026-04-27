import 'package:sensors_plus_platform_interface/sensors_plus_platform_interface.dart';

import 'src/sensors_ohos.dart';

export 'package:sensors_plus_platform_interface/sensors_plus_platform_interface.dart';

export 'src/sensors_ohos.dart'
    if (dart.library.js_interop) 'src/sensors_plus_web.dart';

final _sensors = Sensors();

/// A broadcast stream of events from the device accelerometer.
Stream<AccelerometerEvent> get accelerometerEvents {
  return _sensors.accelerometerEventStream();
}

/// A broadcast stream of events from the device gyroscope.
Stream<GyroscopeEvent> get gyroscopeEvents {
  return _sensors.gyroscopeEventStream();
}

/// Events from the device accelerometer with gravity removed.
Stream<UserAccelerometerEvent> get userAccelerometerEvents {
  return _sensors.userAccelerometerEventStream();
}

/// A broadcast stream of events from the device magnetometer.
Stream<MagnetometerEvent> get magnetometerEvents {
  return _sensors.magnetometerEventStream();
}

/// A broadcast stream of events from the device barometer.
Stream<BarometerEvent> get barometerEvents {
  return _sensors.barometerEventStream();
}

/// Returns a broadcast stream of events from the device accelerometer at the
/// given sampling frequency.
Stream<AccelerometerEvent> accelerometerEventStream({
  Duration samplingPeriod = SensorInterval.normalInterval,
}) {
  return _sensors.accelerometerEventStream(samplingPeriod: samplingPeriod);
}

/// Returns a broadcast stream of events from the device gyroscope at the given
/// sampling frequency.
Stream<GyroscopeEvent> gyroscopeEventStream({
  Duration samplingPeriod = SensorInterval.normalInterval,
}) {
  return _sensors.gyroscopeEventStream(samplingPeriod: samplingPeriod);
}

/// Returns a broadcast stream of events from the device accelerometer with
/// gravity removed at the given sampling frequency.
Stream<UserAccelerometerEvent> userAccelerometerEventStream({
  Duration samplingPeriod = SensorInterval.normalInterval,
}) {
  return _sensors.userAccelerometerEventStream(samplingPeriod: samplingPeriod);
}

/// Returns a broadcast stream of events from the device magnetometer at the
/// given sampling frequency.
Stream<MagnetometerEvent> magnetometerEventStream({
  Duration samplingPeriod = SensorInterval.normalInterval,
}) {
  return _sensors.magnetometerEventStream(samplingPeriod: samplingPeriod);
}

/// Returns a broadcast stream of events from the device barometer at the given
/// sampling frequency.
Stream<BarometerEvent> barometerEventStream({
  Duration samplingPeriod = SensorInterval.normalInterval,
}) {
  return _sensors.barometerEventStream(samplingPeriod: samplingPeriod);
}
