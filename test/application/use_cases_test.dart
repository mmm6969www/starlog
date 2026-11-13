import 'package:starlog/src/application/use_cases/add_observation_use_case.dart';
import 'package:starlog/src/application/use_cases/list_observations_use_case.dart';
import 'package:starlog/src/application/use_cases/verify_observation_use_case.dart';
import 'package:starlog/src/domain/entities/observation.dart';
import 'package:starlog/src/domain/interfaces/observation_repository.dart';
import 'package:test/test.dart';

/// Фейкове сховище: use cases не знають, що це не справжня БД.
class FakeObservationRepository implements IObservationRepository {
  final Map<String, Observation> _store = {};

  @override
  Future<List<Observation>> getAll() async => _store.values.toList();

  @override
  Future<Observation?> getById(String id) async => _store[id];

  @override
  Future<void> save(Observation observation) async {
    _store[observation.id] = observation;
  }
}

void main() {
  late FakeObservationRepository repository;

  setUp(() => repository = FakeObservationRepository());

  test('додає спостереження до сховища', () async {
    final added = await AddObservationUseCase(repository).execute(
      title: 'Юпітер',
      notes: 'Видно чотири супутники',
      category: ObservationCategory.planet,
    );
    expect((await repository.getAll()).single.id, added.id);
  });

  test('фільтрує список за категорією', () async {
    final add = AddObservationUseCase(repository);
    await add.execute(title: 'Юпітер', notes: '', category: ObservationCategory.planet);
    await add.execute(title: 'Комета', notes: '', category: ObservationCategory.comet);

    final comets = await ListObservationsUseCase(repository)
        .execute(category: ObservationCategory.comet);
    expect(comets.single.title, 'Комета');
  });

  test('повторне підтвердження кидає StateError', () async {
    final added = await AddObservationUseCase(repository).execute(
      title: 'Сіріус',
      notes: '',
      category: ObservationCategory.star,
    );
    final verify = VerifyObservationUseCase(repository);
    await verify.execute(added.id);
    await expectLater(verify.execute(added.id), throwsStateError);
  });
}