import 'package:equatable/equatable.dart';
import 'package:flutter/rendering.dart';

// Score State

class ScoreState extends Equatable {
  final int score;

  const ScoreState({required this.score});

  @override
  List<Object?> get props => [score];
}

// Game State

abstract class GameState extends Equatable {
  const GameState();

  @override
  List<Object?> get props => [];
}

class GameInitial extends GameState {
  const GameInitial();
}

class GameInProgress extends GameState {
  const GameInProgress();
}

class GameOver extends GameState {
  final int finalScore;

  const GameOver({required this.finalScore});

  @override
  List<Object?> get props => [finalScore];
}

class GameWon extends GameState {
  @override
  List<Object?> get props => [];
}
