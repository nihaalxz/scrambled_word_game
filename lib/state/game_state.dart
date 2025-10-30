import 'package:equatable/equatable.dart';
import '../models/game_model.dart';

class GameState extends Equatable {
  final GameModel model;

  const GameState({required this.model});

  GameState copyWith({GameModel? model}) {
    return GameState(model: model ?? this.model);
  }

  @override
  List<Object?> get props => [model];
}
