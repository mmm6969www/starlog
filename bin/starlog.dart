import 'dart:convert';
import 'dart:io';

import 'package:starlog/src/application/use_cases/add_observation_use_case.dart';
import 'package:starlog/src/application/use_cases/list_observations_use_case.dart';
import 'package:starlog/src/application/use_cases/verify_observation_use_case.dart';
import 'package:starlog/src/domain/interfaces/observation_repository.dart';
import 'package:starlog/src/infrastructure/repositories/in_memory_observation_repository.dart';
import 'package:starlog/src/infrastructure/repositories/json_observation_repository.dart';
import 'package:starlog/src/presentation/cli/cli_app.dart';

Future<void> main() async {
  final config = jsonDecode(await File('appsettings.json').readAsString())
      as Map<String, dynamic>;
  final storage = config['storage'] as Map<String, dynamic>;

  // Composition root: єдине місце, де обирається конкретна реалізація сховища.
  final IObservationRepository repository = switch (storage['type']) {
    'memory' => InMemoryObservationRepository(),
    _ => JsonObservationRepository(storage['dataFile'] as String),
  };

  final app = CliApp(
    title: config['appName'] as String,
    addObservation: AddObservationUseCase(repository),
    listObservations: ListObservationsUseCase(repository),
    verifyObservation: VerifyObservationUseCase(repository),
  );
  await app.run();
}