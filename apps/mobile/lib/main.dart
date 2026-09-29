import 'package:flutter/material.dart';

void main() {
  runApp(const HafidzApp());
}

class HafidzApp extends StatelessWidget {
  const HafidzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hafidz App',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: const Scaffold(
        body: Center(child: Text('Hafidz App project scaffold')),
      ),
    );
  }
}
