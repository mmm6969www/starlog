enum ObservationCategory { planet, star, comet, deepSky }

class Observation {
  static const int maxNotesLength = 500;

  final String id;
  final String title;
  final String notes;
  final ObservationCategory category;
  final DateTime observedAt;
  final bool isVerified;

  Observation({
    required this.id,
    required this.title,
    required this.notes,
    required this.category,
    required this.observedAt,
    this.isVerified = false,
  }) {
    if (title.trim().isEmpty) {
      throw ArgumentError('Назва об’єкта не може бути порожньою');
    }
    if (notes.length > maxNotesLength) {
      throw ArgumentError('Нотатки довші за $maxNotesLength символів');
    }
  }
    /// Бізнес-правило: спостереження можна підтвердити лише один раз.
  Observation verify() {
    if (isVerified) {
      throw StateError('Спостереження вже підтверджено');
    }
    return Observation(
      id: id,
      title: title,
      notes: notes,
      category: category,
      observedAt: observedAt,
      isVerified: true,
    );
  }
    @override
  String toString() =>
      'Observation(#$id, $title, ${category.name}, verified: $isVerified)';
}