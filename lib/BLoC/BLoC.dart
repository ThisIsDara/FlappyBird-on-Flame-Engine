// ignore_for_file: prefer_const_constructors

import 'package:flutter_bloc/flutter_bloc.dart';
import 'events.dart';
import 'states.dart';

// Score Bloc
class ScoreBloc extends Bloc<ScoreEvent, ScoreState> {
  final GameBloc gameBloc;

  ScoreBloc(this.gameBloc) : super(const ScoreState(score: 0)) {
    on<IncrementScore>((event, emit) {
      final newScore = state.score + 1;
      emit(ScoreState(score: newScore));

      if (newScore >= 50) {
        gameBloc.add(WinGame());
      }
    });

    on<ResetScore>((event, emit) {
      emit(const ScoreState(score: 0));
    });
  }
}

// Game Bloc
class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc() : super(GameInitial()) {
    on<StartGame>((event, emit) => emit(GameInProgress()));

    on<EndGame>((event, emit) {
      emit(GameOver(finalScore: event.finalScore));
    });

    // RestartGame handler
    on<RestartGame>((event, emit) {
      emit(GameInitial());
    });

    on<WinGame>((event, emit) {
      emit(GameWon());
    });
  }
}
