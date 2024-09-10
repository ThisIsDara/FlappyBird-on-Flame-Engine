import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_setup/game/FBGame.dart';
import 'package:flame_setup/game/game_win_scene.dart';
import 'package:flutter/material.dart';
import 'package:flame_setup/game/game_over_scene.dart';

void main() {
  final game = FlappyBirdGame();

  runApp(GameWidget(game: game, overlayBuilderMap: {
    'gameOver': (context, _) => GameOverScreen(
          game: game,
        ),
    'win': (context, _) => WinScreen(game: game), // Win Screen
  }));
}
