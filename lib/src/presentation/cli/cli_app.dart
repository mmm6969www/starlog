import 'dart:io';

import 'package:starlog/src/application/use_cases/add_observation_use_case.dart';
import 'package:starlog/src/application/use_cases/list_observations_use_case.dart';
import 'package:starlog/src/application/use_cases/verify_observation_use_case.dart';
import 'package:starlog/src/domain/entities/observation.dart';

class CliApp {
  final String title;
  final AddObservationUseCase addObservation;
  final ListObservationsUseCase listObservations;
  final VerifyObservationUseCase verifyObservation;

  CliApp({
    required this.title,
    required this.addObservation,
    required this.listObservations,
    required this.verifyObservation,
  });

  Future<void> run() async {
    print('=== $title ===');
    while (true) {
      print('');
      print('1) Додати спостереження');
      print('2) Показати журнал');
      print('3) Підтвердити спостереження');
      print('0) Вихід');
      stdout.write('> ');
      final choice = stdin.readLineSync()?.trim();
      if (choice == null) return;

      try {
        switch (choice) {
          case '1':
            await _add();
          case '2':
            await _list();
          case '3':
            await _verify();
          case '0':
            print('Чистого неба!');
            return;
          default:
            print('Невідома команда');
        }
      } on ArgumentError catch (e) {
        print('Помилка: ${e.message}');
      } on StateError catch (e) {
        print('Помилка: ${e.message}');
      }
    }
  }

  Future<void> _add() async {
    stdout.write('Назва об’єкта: ');
    final title = stdin.readLineSync() ?? '';
    stdout.write('Нотатки: ');
    final notes = stdin.readLineSync() ?? '';
    print('Категорія:');
    for (final c in ObservationCategory.values) {
      print('  ${c.index + 1}) ${c.name}');
    }
    stdout.write('> ');
    final index = int.tryParse(stdin.readLineSync() ?? '');
    if (index == null || index < 1 || index > ObservationCategory.values.length) {
      print('Невірна категорія');
      return;
    }
    final added = await addObservation.execute(
      title: title,
      notes: notes,
      category: ObservationCategory.values[index - 1],
    );
    print('Додано: ${added.title} (id ${added.id})');
  }

  Future<void> _list() async {
    final items = await listObservations.execute();
    if (items.isEmpty) {
      print('Журнал порожній');
      return;
    }
    for (final o in items) {
      final mark = o.isVerified ? '[+]' : '[ ]';
      print('$mark #${o.id} ${o.title} (${o.category.name}) - ${o.notes}');
    }
  }

  Future<void> _verify() async {
    stdout.write('id спостереження: ');
    final id = (stdin.readLineSync() ?? '').trim();
    final verified = await verifyObservation.execute(id);
    print('Підтверджено: ${verified.title}');
  }
}