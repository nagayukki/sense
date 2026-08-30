import 'package:flutter/material.dart';

import 'features/home/home_screen.dart';

void main() {
  runApp(const SenseApp());
}

class SenseApp extends StatelessWidget {
  const SenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'sense',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4B54C8)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4B54C8),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
