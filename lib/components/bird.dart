// ignore_for_file: non_constant_identifier_names, depend_on_referenced_packages

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flame/camera.dart';
import 'dart:ui';
import 'package:flame_audio/flame_audio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flame_setup/components/ground.dart';
import 'package:flame_setup/components/pipe.dart';
import 'package:flame_setup/components/pipe_group.dart';
import 'package:flame_setup/game/bird_states.dart';
import 'package:flame_setup/game/FBGame.dart';
import 'package:flame_setup/game/assets.dart';
import 'package:flame_setup/game/configuration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flame_noise/flame_noise.dart';
import 'package:flame/events.dart';
import 'package:flame_setup/BLoC/events.dart';
import 'package:flame_setup/BLoC/states.dart';
import 'package:flame_setup/BLoC/BLoC.dart';

class Bird extends SpriteGroupComponent<BirdMovement>
    with HasGameRef<FlappyBirdGame>, CollisionCallbacks {
  late AudioPlayer AudioP;
  final ScoreBloc scoreBloc;
  final GameBloc gameBloc;

  int hp = Config.hp;
  bool isRed = false;

  Bird(this.scoreBloc, this.gameBloc);

  @override
  Future<void> onLoad() async {
    AudioCache.instance = AudioCache(prefix: 'assets/audio/');
    AudioP = AudioPlayer();
    await AudioP.setReleaseMode(ReleaseMode.release);

    // Load sprites
    final birdMidFlap = await gameRef.loadSprite(Assets.birdMidFlap);
    final birdUpFlap = await gameRef.loadSprite(Assets.birdUpFlap);
    final birdDownFlap = await gameRef.loadSprite(Assets.birdDownFlap);
    sprites = {
      BirdMovement.middle: birdMidFlap,
      BirdMovement.up: birdUpFlap,
      BirdMovement.down: birdDownFlap,
    };
    size = Vector2(50, 40);
    position = Vector2(50, gameRef.size.y / 2 - size.y / 2);
    current = BirdMovement.middle;

    add(CircleHitbox());
  }

  void fly() {
    add(MoveByEffect(Vector2(0, Config.flapForce),
        EffectController(duration: 0.2, curve: Curves.decelerate),
        onComplete: () => current = BirdMovement.down));
    current = BirdMovement.up;
    playSound(Assets.sfx_flying, 0.08);

    _emitFlyingParticles();
  }

  void playSound(sound, volume) async {
    try {
      await AudioP.play(AssetSource(sound), volume: volume);
    } catch (error) {
      await resetAudioPlayer();
      await AudioP.play(AssetSource(sound), volume: volume);
    }
  }

  void _emitFlyingParticles() {
    final particleComponent = ParticleSystemComponent(
      particle: Particle.generate(
        count: 30,
        lifespan: 0.2,
        generator: (i) {
          final double spread = 150;
          final double direction = (i / 30) * spread - (spread / 2);

          return AcceleratedParticle(
            acceleration: Vector2(0, -100),
            speed: Vector2(direction, 150),
            position: position.clone()
              ..x += 28
              ..y -= -20,
            child: CircleParticle(
              radius: 4,
              paint: Paint()
                ..color = const Color.fromARGB(255, 255, 217, 0).withOpacity(1),
            ),
          );
        },
      ),
    );
    gameRef.add(particleComponent);
  }

  void passObstacle() {
    scoreBloc.add(IncrementScore());
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    debugPrint('Collision detected, Game Over');
    if (other is Ground) {
      gameOver();
    } else if (other is Pipe) {
      reduceHP(other);
    }
  }

  void reduceHP(Pipe pipeG) {
    if (hp > 0) {
      hp--;
      gameRef.removeHeart(pipeG);
      if (hp == 0) {
        gameOver();
      } else {
        playSound(Assets.sfx_collision, 0.08);
        _applyRedEffect();
      }
    }
  }

  void _applyRedEffect() {
    isRed = true;
    Future.delayed(Duration(milliseconds: 500), () {
      isRed = false;
    });
  }

  void resetBird() {
    position = Vector2(50, gameRef.size.y / 2 - size.y / 2);
    current = BirdMovement.middle;
    hp = Config.hp;
    gameRef.resetHearts();
    scoreBloc.add(ResetScore());
  }

  void gameOver() {
    playSound(Assets.sfx_collision, 0.08);
    final currentScore = (scoreBloc.state).score;
    Future.delayed(Duration(milliseconds: 5), () {
      gameRef.removeHeart(null); // Removing the Last Heart before pausing.
      gameBloc.add(EndGame(currentScore));
      gameRef.overlays.add('gameOver');
      gameRef.pauseEngine();
      gameRef.damaged = true;
    });
  }

  void checkWin() {
    if (scoreBloc.state.score >= Config.win_score) {
      gameRef.overlays.add('win');
      gameRef.pauseEngine();
    }
  }

  Future<void> resetAudioPlayer() async {
    AudioP.dispose();
    AudioP = AudioPlayer();
    await AudioP.setReleaseMode(ReleaseMode.release);
  }

  @override
  void render(Canvas canvas) {
    if (isRed) {
      canvas.saveLayer(
          size.toRect(),
          Paint()
            ..colorFilter =
                ColorFilter.mode(Colors.red.withOpacity(0.4), BlendMode.color));
    }
    super.render(canvas);
    if (isRed) {
      canvas.restore();
    }
  }

  void updateScore() {
    FlameAudio.play(Assets.sfx_point, volume: 0.15);
    scoreBloc.add(IncrementScore());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += Config.gravity * dt;
    if (position.y < 1) {
      gameOver();
      gameRef.resetHearts();
    }
    checkWin();
  }
}
