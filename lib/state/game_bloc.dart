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
      emit(_gameUseCase.selectLetter(state, event.index));
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

        // Load new word ✅
        newState = _gameUseCase.loadNewWord(newState);

        emit(newState);
      } else {
        // Wrong answer
        emit(_gameUseCase.handleWrongAnswer(state));
      }
    });
  }
}
