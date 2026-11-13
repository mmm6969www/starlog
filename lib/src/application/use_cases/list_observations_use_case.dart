import 'package:starlog/src/domain/entities/observation.dart';
import 'package:starlog/src/domain/interfaces/observation_repository.dart';

class ListObservationsUseCase {
  final IObservationRepository _repository;

  ListObservationsUseCase(this._repository);

  Future<List<Observation>> execute({ObservationCategory? category}) async {
    final all = await _repository.getAll();
    final filtered = category == null
        ? all
        : all.where((o) => o.category == category).toList();
    filtered.sort((a, b) => b.observedAt.compareTo(a.observedAt));
    return filtered;
  }
}