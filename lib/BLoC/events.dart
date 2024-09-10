import 'package:equatable/equatable.dart';
import 'package:flame/game.dart';

// Score Event

abstract class ScoreEvent extends Equatable {
  const ScoreEvent();

  @override
  List<Object?> get props => [];
}

class IncrementScore extends ScoreEvent {
  const IncrementScore();
}

class ResetScore extends ScoreEvent {
  const ResetScore();
}

// Game Event

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class StartGame extends GameEvent {
  const StartGame();
}

class EndGame extends GameEvent {
  final int finalScore;

  const EndGame(this.finalScore);

  @override
  List<Object?> get props => [finalScore];
}

// Reset Event

class RestartGame extends GameEvent {
  const RestartGame();

  @override
  List<Object?> get props => [];
}

// Win Event

class WinGame extends GameEvent {
  const WinGame();

  @override
  List<Object?> get props => [];
}
