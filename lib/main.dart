import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scramble_word_game/data/word_repository.dart';
import 'package:scramble_word_game/state/game_bloc.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const ScrambleGameApp());
}

class ScrambleGameApp extends StatelessWidget {
  const ScrambleGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => GameBloc(WordRepositoryImpl())..add(LoadWordEvent()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Scramble Word Game',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const GameScreen(),
      ),
    );
  }
}