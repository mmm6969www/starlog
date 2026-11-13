import 'dart:io';

import 'package:starlog/src/domain/entities/observation.dart';
import 'package:starlog/src/infrastructure/repositories/json_observation_repository.dart';
import 'package:test/test.dart';

void main() {
  test('JSON-репозиторій зберігає та читає спостереження', () async {
    final dir = await Directory.systemTemp.createTemp('starlog_');
    addTearDown(() => dir.delete(recursive: true));

    final repository = JsonObservationRepository('${dir.path}/observations.json');
    await repository.save(Observation(
      id: '1',
      title: 'Юпітер',
      notes: 'Видно чотири супутники',
      category: ObservationCategory.planet,
      observedAt: DateTime(2026, 11, 13),
    ));

    expect((await repository.getAll()).length, 1);
    expect((await repository.getById('1'))?.title, 'Юпітер');
  });
}