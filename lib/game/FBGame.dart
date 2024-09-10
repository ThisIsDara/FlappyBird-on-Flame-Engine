// ignore_for_file: unnecessary_type_check

import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/rendering.dart';
import 'package:flame/sprite.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_setup/components/pipe.dart';
import 'assets.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_setup/components/background.dart';
import 'package:flame_setup/components/bird.dart';
import 'package:flame/effects.dart';
import 'package:flame_setup/components/ground.dart';
import 'package:flame_setup/components/pipe_group.dart';
import 'package:flame_setup/game/configuration.dart';
import 'package:flame/timer.dart' as timer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flame_setup/BLoC/BLoC.dart';
import 'package:flame_setup/BLoC/events.dart';
import 'package:flame_setup/BLoC/states.dart';

class FlappyBirdGame extends FlameGame with TapDetector, HasCollisionDetection {
  late Bird bird;
  late TextComponent score;
  late List<SpriteAnimationComponent> hearts;
  List<PipeGroup> pipeList = []; // All the pipes
  timer.Timer interval = timer.Timer(Config.pipeInterval, repeat: true);
  bool damaged = false;
  final GameBloc gameBloc = GameBloc();
  late final ScoreBloc scoreBloc = ScoreBloc(gameBloc);

  bool audioStarted = false;

  @override
  Future<void> onLoad() async {
    // heart spriteSheet
    final spriteSheet = await images.load(Assets.heart);
    final spriteSize = Vector2(16, 16);
    final heartFrames = SpriteAnimationData.sequenced(
        amount: 5, stepTime: 0.1, textureSize: spriteSize);

    hearts = List.generate(Config.hp, (i) {
      return SpriteAnimationComponent.fromFrameData(spriteSheet, heartFrames)
        ..size = Vector2(64, 64)
        ..position = Vector2(10 + i * 50, size.y - 74);
    });

    // Add all components to the game
    addAll([
      Background(),
      Ground(),
      bird = Bird(scoreBloc, gameBloc),
      score = buildScore(),
      ...hearts,
      camera,
    ]);
    camera.follow(bird);

    // Timer for pipe generation
    interval.onTick = () {
      final pipeGroup = PipeGroup(scoreBloc);
      add(pipeGroup);
      pipeList.add(pipeGroup);
    };

    scoreBloc.stream.listen((state) {
      if (state is ScoreState) {
        score.text = 'Score: ${state.score}';
      }
    });

    gameBloc.stream.listen((state) {
      if (state is GameOver) {
        _handleGameOver(state.finalScore);
      }
    });
  }

  void _handleGameOver(int finalScore) {
    overlays.add('gameOver');
    pauseEngine();
    debugPrint('Game Over! Final Score: $finalScore');
  }

  void resetBird() {
    bird.resetBird();
  }

  void resetPipes() {
    children.whereType<PipeGroup>().forEach((pipe) => pipe.removeFromParent());
    pipeList.clear();
  }

  void resetGameState() {
    overlays.remove('gameOver');
    overlays.remove('win');
    resumeEngine();
    gameBloc.add(StartGame());
    damaged = false;
  }

  void restartGame() {
    bird.resetAudioPlayer();
    resetBird();
    resetPipes();
    scoreBloc.add(ResetScore());
    resetGameState();
  }

  void removeHeart(Pipe? pipeG) {
    if (hearts.isNotEmpty) {
      final heartsToRemove = hearts.removeLast();
      heartsToRemove.removeFromParent();
      pipeG?.parent?.removeFromParent();
    }
  }

  Future<void> resetHearts() async {
    hearts.forEach((heart) => heart.removeFromParent());
    hearts.clear();

    final spriteSheet = await images.load(Assets.heart);
    final spriteSize = Vector2(16, 16);
    final heartFrames = SpriteAnimationData.sequenced(
        amount: 5, stepTime: 0.1, textureSize: spriteSize);

    // Add new hearts
    hearts = List.generate(Config.hp, (i) {
      return SpriteAnimationComponent.fromFrameData(spriteSheet, heartFrames)
        ..size = Vector2(64, 64)
        ..position = Vector2(10 + i * 50, size.y - 74);
    });

    addAll(hearts);
  }

  TextComponent buildScore() {
    return TextComponent(
      text: 'Score: 0',
      position: Vector2(size.x / 2, size.y / 2 * 0.2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          fontFamily: 'Game',
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  void onTap() {
    super.onTap();
    bird.fly();
    if (!audioStarted) {
      FlameAudio.bgm.play(Assets.bgmusic, volume: Config.bgVolume);
      audioStarted = true;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    interval.update(dt);
  }

  @override
  void onRemove() {
    super.onRemove();
    scoreBloc.close();
  }
}
