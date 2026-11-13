import 'dart:convert';
import 'dart:io';

import 'package:starlog/src/domain/entities/observation.dart';
import 'package:starlog/src/domain/interfaces/observation_repository.dart';

class JsonObservationRepository implements IObservationRepository {
  final File _file;

  JsonObservationRepository(String path) : _file = File(path);

  @override
  Future<List<Observation>> getAll() async {
    if (!await _file.exists()) return [];
    final content = await _file.readAsString();
    if (content.trim().isEmpty) return [];
    final List<dynamic> data = jsonDecode(content);
    return data.map((e) => _fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Observation?> getById(String id) async {
    for (final observation in await getAll()) {
      if (observation.id == id) return observation;
    }
    return null;
  }

  @override
  Future<void> save(Observation observation) async {
    final all = await getAll();
    final index = all.indexWhere((o) => o.id == observation.id);
    if (index >= 0) {
      all[index] = observation;
    } else {
      all.add(observation);
    }
    const encoder = JsonEncoder.withIndent('  ');
    await _file.writeAsString(encoder.convert(all.map(_toJson).toList()));
  }

  // Перетворення JSON <-> сутність живе в Infrastructure:
  // Domain нічого не знає про формат зберігання.
  static Map<String, dynamic> _toJson(Observation o) => {
        'id': o.id,
        'title': o.title,
        'notes': o.notes,
        'category': o.category.name,
        'observedAt': o.observedAt.toIso8601String(),
        'isVerified': o.isVerified,
      };

  static Observation _fromJson(Map<String, dynamic> json) => Observation(
        id: json['id'] as String,
        title: json['title'] as String,
        notes: json['notes'] as String,
        category: ObservationCategory.values.byName(json['category'] as String),
        observedAt: DateTime.parse(json['observedAt'] as String),
        isVerified: json['isVerified'] as bool,
      );
}