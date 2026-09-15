import 'package:sensors_plus_platform_interface/sensors_plus_platform_interface.dart';

import 'src/sensors_ohos.dart';

export 'package:sensors_plus_platform_interface/sensors_plus_platform_interface.dart';

export 'src/sensors_ohos.dart' if (dart.library.html) 'src/sensors_plus_web_ohos.dart';

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
