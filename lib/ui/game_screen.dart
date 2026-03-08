import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game/big_brother_game.dart';
import 'intro_screen.dart';

/// The main screen where the game is rendered.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final BigBrotherGame _game;

  @override
  void initState() {
    super.initState();
    // Initialize the Flame game instance
    _game = BigBrotherGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // The Flame game widget
          Positioned.fill(child: GameWidget(game: _game)),

          // Placeholder for overlay UI
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              tooltip: 'Back to Menu',
              onPressed: () {
                // Return to the intro screen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const IntroScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
