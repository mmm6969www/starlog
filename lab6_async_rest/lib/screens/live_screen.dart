import 'package:flutter/material.dart';

import '../models/telemetry_reading.dart';
import '../services/telemetry_service.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  final _service = TelemetryService();
  late Future<String> _calibration;
  late final Stream<TelemetryReading> _readings;
  int _futureBuilds = 0;
  int _streamBuilds = 0;

  @override
  void initState() {
    super.initState();
    _calibration = _service.calibrate();
    _readings = _service.readings();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Future vs Stream')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: 'FutureBuilder — одна подія',
            child: FutureBuilder<String>(
              future: _calibration,
              builder: (context, snapshot) {
                _futureBuilds++;
                final Widget content;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  content = const LinearProgressIndicator();
                } else if (snapshot.hasError) {
                  content = Text('Помилка: ${snapshot.error}');
                } else {
                  content = Text(snapshot.data ?? '');
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    content,
                    const SizedBox(height: 8),
                    Text('connectionState: ${snapshot.connectionState.name}'
                        ' · перебудов: $_futureBuilds'),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _calibration = _service.calibrate();
                        });
                      },
                      child: const Text('Перекалібрувати'),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'StreamBuilder — потік подій',
            child: StreamBuilder<TelemetryReading>(
              stream: _readings,
              builder: (context, snapshot) {
                _streamBuilds++;
                if (snapshot.hasError) {
                  return Text('Помилка: ${snapshot.error}');
                }
                if (!snapshot.hasData) {
                  return const Text('Очікування першого кадру...');
                }
                final reading = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Кадр №${reading.frame}',
                        style: textTheme.headlineMedium),
                    Text('Температура сенсора: '
                        '${reading.sensorTempC.toStringAsFixed(1)} °C'),
                    const SizedBox(height: 8),
                    Text('connectionState: ${snapshot.connectionState.name}'
                        ' · перебудов: $_streamBuilds'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }
}