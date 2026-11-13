import 'package:starlog/src/domain/entities/observation.dart';
import 'package:starlog/src/domain/interfaces/observation_repository.dart';

class VerifyObservationUseCase {
  final IObservationRepository _repository;

  VerifyObservationUseCase(this._repository);

  Future<Observation> execute(String id) async {
    final observation = await _repository.getById(id);
    if (observation == null) {
      throw StateError('Спостереження з id $id не знайдено');
    }
    final verified = observation.verify();
    await _repository.save(verified);
    return verified;
  }
}