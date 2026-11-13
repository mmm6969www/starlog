import 'package:starlog/src/domain/entities/observation.dart';
import 'package:starlog/src/domain/interfaces/observation_repository.dart';

class AddObservationUseCase {
  final IObservationRepository _repository;

  AddObservationUseCase(this._repository);

  Future<Observation> execute({
    required String title,
    required String notes,
    required ObservationCategory category,
    DateTime? observedAt,
  }) async {
    final existing = await _repository.getAll();
    final nextId = existing.fold<int>(0, (max, o) {
      final n = int.tryParse(o.id) ?? 0;
      return n > max ? n : max;
    }) + 1;

    final observation = Observation(
      id: '$nextId',
      title: title,
      notes: notes,
      category: category,
      observedAt: observedAt ?? DateTime.now(),
    );
    await _repository.save(observation);
    return observation;
  }
}