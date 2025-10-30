import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/game_model.dart';
import '../state/game_bloc.dart';
import '../widgets/scrambled_grid.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _celebrationController;
  late Animation<double> _shakeAnimation;
  bool _showLevelUp = false;
  int _previousLevel = 1;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void _onWrongAnswer() {
    _shakeController.forward(from: 0);
  }

  void _showLevelUpDialog(int newLevel) {
    setState(() => _showLevelUp = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade300, Colors.pink.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
              const SizedBox(height: 16),
              const Text(
                'Level Up!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You reached Level $newLevel',
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _showLevelUp = false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Continue', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.purple.shade100],
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<GameBloc, GameModel>(
            listener: (context, state) {
              // Check for level up
              if (state.currentLevel > _previousLevel && !_showLevelUp) {
                _previousLevel = state.currentLevel;
                _showLevelUpDialog(state.currentLevel);
              }
              _previousLevel = state.currentLevel;
            },
            builder: (context, state) {
              if (state.currentWord.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildHeader(state),
                    const SizedBox(height: 30),
                    _buildProgressBar(state),
                    const SizedBox(height: 30),
                    _buildSelectedWordDisplay(state),
                    const SizedBox(height: 40),
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnimation.value, 0),
                          child: child,
                        );
                      },
                      child: ScrambledGrid(
                        letters: state.scrambledLetters,
                        selectedIndices: state.selectedIndices,
                        onLetterSelected: (index, letter) {
                          context.read<GameBloc>().add(SelectLetterEvent(index));
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildControlButtons(context, state),
                    if (state.showHint) ...[
                      const SizedBox(height: 20),
                      _buildHint(state),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(GameModel state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard('Level', '${state.currentLevel}', Icons.stairs, Colors.blue),
        _buildStatCard('Score', '${state.score}', Icons.star, Colors.amber),
        _buildStatCard('Streak', '${state.streak}🔥', Icons.local_fire_department, Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(GameModel state) {
    final progress = state.wordsCompletedInLevel / state.wordsRequiredForNextLevel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress to Level ${state.currentLevel + 1}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade400),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${state.wordsCompletedInLevel}/${state.wordsRequiredForNextLevel} words',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildSelectedWordDisplay(GameModel state) {
    final isComplete = state.selectedWord.length == state.currentWord.length;
    final isCorrect = state.selectedWord == state.currentWord;
    
    Color backgroundColor = Colors.white;
    Color textColor = Colors.grey.shade800;
    
    if (isComplete) {
      if (isCorrect) {
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
      } else {
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isComplete
              ? (isCorrect ? Colors.green : Colors.red)
              : Colors.grey.shade300,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            state.selectedWord.isEmpty ? 'Tap letters to spell' : state.selectedWord.toUpperCase(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${state.selectedWord.length}/${state.currentWord.length} letters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(BuildContext context, GameModel state) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        _buildButton(
          label: 'Undo',
          icon: Icons.undo,
          color: Colors.orange,
          onPressed: state.selectedIndices.isNotEmpty
              ? () => context.read<GameBloc>().add(UndoLetterEvent())
              : null,
        ),
        _buildButton(
          label: 'Clear',
          icon: Icons.clear,
          color: Colors.red,
          onPressed: state.selectedIndices.isNotEmpty
              ? () => context.read<GameBloc>().add(ClearSelectionEvent())
              : null,
        ),
        _buildButton(
          label: state.showHint ? 'Hide Hint' : 'Hint (-1 🔥)',
          icon: Icons.lightbulb,
          color: Colors.amber,
          onPressed: () => context.read<GameBloc>().add(ToggleHintEvent()),
        ),
        _buildButton(
          label: 'Skip',
          icon: Icons.skip_next,
          color: Colors.blue,
          onPressed: () => context.read<GameBloc>().add(LoadWordEvent()),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: onPressed != null ? color : Colors.grey.shade300,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: onPressed != null ? 4 : 0,
      ),
    );
  }

  Widget _buildHint(GameModel state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade300, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb, color: Colors.amber.shade800),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'The word is: ${state.currentWord.toUpperCase()}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.amber.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}