import '../entities/observation.dart';

abstract interface class IObservationRepository {
  Future<List<Observation>> getAll();
  Future<Observation?> getById(String id);

  /// Додає нове або оновлює наявне спостереження.
  Future<void> save(Observation observation);
}