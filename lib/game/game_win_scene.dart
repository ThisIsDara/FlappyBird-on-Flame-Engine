import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_setup/game/FBGame.dart';
import 'package:flame_setup/game/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class WinScreen extends StatelessWidget {
  final FlappyBirdGame game;

  const WinScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black38,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You Win!',
              style: TextStyle(color: Colors.white, fontSize: 40),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => game.restartGame(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text(
                'Restart',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
