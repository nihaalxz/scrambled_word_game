import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';

import '../state/game_bloc.dart';
import '../models/game_model.dart';
import '../widgets/scrambled_grid.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final player = AudioPlayer();
  late ConfettiController _confettiController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _levelUpController;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _levelUpController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    context.read<GameBloc>().add(LoadWordEvent());
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _shakeController.dispose();
    _levelUpController.dispose();
    player.dispose();
    super.dispose();
  }

  void _showLevelUp(GameModel state) async {
    _levelUpController.forward(from: 0);
    _confettiController.play();
    await player.play(AssetSource('sounds/success.mp3'));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events, size: 80, color: Colors.yellow.shade300),
              const SizedBox(height: 16),
              const Text(
                "LEVEL UP!",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Level ${state.currentLevel}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Complete ${state.wordsRequiredForNextLevel} words to reach next level!",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<GameBloc>().add(LoadWordEvent());
                }, // This line needs to be fixed.
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.purple.shade700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameModel>(
      listener: (context, state) async {
        if (state.selectedWord == state.currentWord &&
            state.selectedWord.isNotEmpty) {
          _confettiController.play();
          await player.play(AssetSource('sounds/success.mp3'));
        }

        if (state.streak == 0 && state.selectedWord.isNotEmpty) {
          // Assuming streak resets on wrong answer
          _shakeController.forward(from: 0);
          await player.play(AssetSource('sounds/click.mp3'));
        }

        // Check if level has changed to trigger level up animation and dialog
        // This logic needs to be handled in the BLoC and passed as a separate event/state property.
        // For now, we'll assume a level up if wordsCompletedInLevel is 0 and currentLevel > 1 after a correct answer.
        if (state.wordsCompletedInLevel == 0 &&
            state.currentLevel > 1 &&
            state.selectedWord == state.currentWord) {
          _showLevelUp(state);
        }
      },

      builder: (context, state) {
        final progress =
            state.wordsCompletedInLevel / state.wordsRequiredForNextLevel;

        return Scaffold(
          backgroundColor: Colors.orange.shade100,

          appBar: AppBar(
            backgroundColor: Colors.yellow.shade600,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Word Scramble 🐥",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Level ${state.currentLevel}",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            actions: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // This column needs to be fixed.
                  Text(
                    "Score: ${state.score}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (state.streak > 0) Text("🔥 ${state.streak}"),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context.read<GameBloc>().add(LoadWordEvent()),
              ),
            ],
          ),

          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Progress bar
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 5),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Progress to Level ${state.currentLevel + 1}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 12,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.green.shade400,
                                  ),
                                ),
                              ),
                              Text(
                                "${state.wordsCompletedInLevel}/${state.wordsRequiredForNextLevel}",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.purple.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Crossword boxes with shake animation
                        AnimatedBuilder(
                          animation: _shakeAnimation,
                          builder: (_, __) => Transform.translate(
                            offset: Offset(
                              _shakeAnimation.value *
                                  sin(_shakeController.value * pi * 4),
                              0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                state.currentWord.length,
                                (i) {
                                  final isFilled =
                                      i < state.selectedWord.length;
                                  final letter = isFilled
                                      ? state.selectedWord[i].toUpperCase()
                                      : "";

                                  return Container(
                                    width: 50,
                                    height: 60,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isFilled
                                          ? Colors.orange.shade200
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isFilled
                                            ? Colors.orange.shade400
                                            : Colors.grey.shade300,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        letter,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple.shade700,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextButton.icon(
                          onPressed: () =>
                              context.read<GameBloc>().add(ToggleHintEvent()),
                          icon: Icon(
                            state.showHint
                                ? Icons.visibility_off
                                : Icons.lightbulb_outline,
                            size: 18,
                          ),
                          label: Text(
                            state.showHint ? "Hide Hint" : "Show Hint",
                          ),
                        ),

                        if (state.showHint)
                          Text(
                            "Hint: ${state.currentWord[0]}${'*' * (state.currentWord.length - 2)}${state.currentWord[state.currentWord.length - 1]}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Scrambled grid
                        // In the GameScreen's build method:
                        ScrambledGrid(
                          letters: state.scrambledLetters,
                          onLetterSelected: (index, letter) {
                            if (!state.selectedIndices.contains(index)) {
                              context.read<GameBloc>().add(
                                SelectLetterEvent(index),
                              );
                            }
                          },
                        ),

                        const SizedBox(height: 20),

                        Wrap(
                          spacing: 8,
                          children: [
                            ElevatedButton.icon(
                              onPressed: state.selectedIndices.isEmpty
                                  ? null
                                  : () => context.read<GameBloc>().add(
                                      UndoLetterEvent(),
                                    ),
                              icon: const Icon(Icons.undo),
                              label: const Text("Undo"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade400,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: state.selectedIndices.isEmpty
                                  ? null
                                  : () => context.read<GameBloc>().add(
                                      ClearSelectionEvent(),
                                    ),
                              icon: const Icon(Icons.clear),
                              label: const Text("Clear"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade400,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed:
                                  state.selectedWord.length ==
                                      state.currentWord.length
                                  ? () => context.read<GameBloc>().add(
                                      SubmitAnswerEvent(),
                                    )
                                  : null,
                              icon: const Icon(Icons.check),
                              label: const Text("Check"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirection: pi / 2,
                    numberOfParticles: 30,
                    gravity: 0.3,
                    colors: const [
                      Colors.red,
                      Colors.blue,
                      Colors.green,
                      Colors.yellow,
                      Colors.pink,
                      Colors.purple,
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
