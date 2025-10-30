import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scramble_word_game/models/game_model.dart';
import 'package:scramble_word_game/data/word_repository.dart';
import 'package:scramble_word_game/domain/game_usecase.dart';

part 'game_event.dart';

class GameBloc extends Bloc<GameEvent, GameModel> {
  final GameUseCase _gameUseCase;

  GameBloc(WordRepository wordRepo)
      : _gameUseCase = GameUseCase(wordRepo),
        super(GameModel.initial()) {
        
    on<LoadWordEvent>((event, emit) {
      emit(_gameUseCase.loadNewWord(state));
    });

    on<SelectLetterEvent>((event, emit) {
      final newState = _gameUseCase.selectLetter(state, event.index);
      emit(newState);
      
      // Auto-check if word is complete
      if (newState.selectedWord.length == newState.currentWord.length) {
        // Use a short delay to show the completed word before processing
        Future.delayed(const Duration(milliseconds: 300), () {
          if (newState.selectedWord == newState.currentWord) {
            add(SubmitAnswerEvent());
          } else {
            // Wrong answer - just clear selection with delay
            add(WrongAnswerEvent());
          }
        });
      }
    });

    on<UndoLetterEvent>((event, emit) {
      emit(_gameUseCase.undoLastLetter(state));
    });

    on<ClearSelectionEvent>((event, emit) {
      emit(_gameUseCase.clearSelection(state));
    });

    on<ToggleHintEvent>((event, emit) {
      emit(_gameUseCase.toggleHint(state));
    });

    on<SubmitAnswerEvent>((event, emit) {
      if (state.selectedWord == state.currentWord) {
        // Correct answer
        var newState = _gameUseCase.handleCorrectAnswer(state);
        emit(newState);
        
        // Load new word after a brief delay
        Future.delayed(const Duration(milliseconds: 500), () {
          add(LoadWordEvent());
        });
      }
    });

    on<WrongAnswerEvent>((event, emit) {
      // Handle wrong answer - reset streak and clear selection
      final newState = _gameUseCase.handleWrongAnswer(state);
      emit(newState);
    });
  }
}