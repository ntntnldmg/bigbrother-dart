import 'package:flutter/material.dart';
import 'ui/intro_screen.dart';

void main() {
  runApp(const BigBrotherApp());
}

/// The root application widget.
class BigBrotherApp extends StatelessWidget {
  const BigBrotherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Big Brother Game',
      theme: ThemeData.dark(),
      home: const IntroScreen(),
    );
  }
}
