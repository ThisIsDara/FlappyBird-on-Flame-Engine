// ignore_for_file: unused_import, unused_field, prefer_const_constructors

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_setup/components/pipe.dart';
import 'package:flame_setup/game/assets.dart';
import 'package:flame_setup/game/configuration.dart';
import 'package:flame_setup/game/FBGame.dart';
import 'package:flame_setup/game/pipe_position.dart';
import 'package:flutter/foundation.dart';
import 'package:flame_setup/BLoC/BLoC.dart';
import 'package:flame_setup/BLoC/events.dart';
import 'package:flame_setup/BLoC/states.dart';

class PipeGroup extends PositionComponent with HasGameRef<FlappyBirdGame> {
  final ScoreBloc scoreBloc;
  bool passedBird = false;

  PipeGroup(this.scoreBloc);

  final _random = Random();

  @override
  Future<void> onLoad() async {
    position.x = gameRef.size.x;

    final heightMinusGround = gameRef.size.y - Config.groundHeight;
    final spacing = 100 + _random.nextDouble() * (heightMinusGround / 4);
    final centerY =
        spacing + _random.nextDouble() * (heightMinusGround - spacing);

    addAll([
      Pipe(pipePosition: PipePosition.top, height: centerY - spacing / 1.5),
      Pipe(
          pipePosition: PipePosition.bottom,
          height: heightMinusGround - (centerY + spacing / 1.5)),
    ]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= Config.gameSpeed * dt;

    if (!passedBird && position.x + size.x / 2 < gameRef.bird.position.x) {
      passedBird = true;
      gameRef.bird.updateScore();
    }

    if (position.x < Config.PipeRemoveDistance) {
      removeFromParent();
      debugPrint('removed');
    }
    if (gameRef.damaged) {
      removeFromParent();
      gameRef.damaged = false;
    }
  }
}
