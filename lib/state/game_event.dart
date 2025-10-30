part of 'game_bloc.dart';

abstract class GameEvent {}

class LoadWordEvent extends GameEvent {}

class SelectLetterEvent extends GameEvent {
  final int index;
  SelectLetterEvent(this.index);
}

class SubmitAnswerEvent extends GameEvent {}

class UndoLetterEvent extends GameEvent {}

class ClearSelectionEvent extends GameEvent {}

class ToggleHintEvent extends GameEvent {}
