import 'dart:math';

import '../models/telemetry_reading.dart';

class TelemetryService {
  final _random = Random();

  /// Future + async/await: імітація довгої операції через Future.delayed.
  Future<String> calibrate() async {
    await Future.delayed(const Duration(seconds: 3));
    return 'Калібрування завершено: фокус 1200 мм';
  }

  /// Stream через генератор async*: нове значення кожні 2 секунди.
  Stream<TelemetryReading> readings() async* {
    var frame = 0;
    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      frame++;
      yield TelemetryReading(
        frame: frame,
        sensorTempC: -20 + _random.nextDouble() * 4,
      );
    }
  }

  /// Те саме простіше — Stream.periodic (для порівняння в README).
  Stream<int> frameCounter() =>
      Stream.periodic(const Duration(seconds: 2), (i) => i + 1);
}