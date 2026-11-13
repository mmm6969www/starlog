import 'package:starlog/src/domain/entities/observation.dart';
import 'package:starlog/src/domain/interfaces/observation_repository.dart';

class InMemoryObservationRepository implements IObservationRepository {
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