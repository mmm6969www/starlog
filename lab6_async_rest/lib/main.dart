import 'package:flutter/material.dart';

import 'screens/home_shell.dart';

void main() => runApp(const StarLogApp());

class StarLogApp extends StatelessWidget {
  const StarLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StarLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: const HomeShell(),
    );
  }
}