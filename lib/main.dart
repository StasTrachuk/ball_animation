import 'package:ball_animation/event_screen.dart';
import 'package:ball_animation/simulation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: EventScreen(),
    );
  }
}
