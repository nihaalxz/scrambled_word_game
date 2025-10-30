import 'dart:math';

import 'package:scramble_word_game/data/word_repository.dart';
import 'package:scramble_word_game/models/Levelup.dart';
import 'package:scramble_word_game/models/game_model.dart';


class GameUseCase {
  final WordRepository wordRepository;

  GameUseCase(this.wordRepository);

  GameModel loadNewWord(GameModel currentState) {
    final currentWord = wordRepository.getRandomWordForLevel(currentState.currentLevel);
    List<String> scrambledLetters = currentWord.split('')..shuffle();
    
    // Ensure the word is actually scrambled
    while (scrambledLetters.join() == currentWord && currentWord.length > 1) {
      scrambledLetters.shuffle();
    }

    return currentState.copyWith(
      currentWord: currentWord,
      scrambledLetters: scrambledLetters,
      selectedIndices: [],
      selectedWord: '',
      showHint: false,
    );
  }

  GameModel selectLetter(GameModel currentState, int index) {
    if (currentState.selectedIndices.contains(index)) {
      return currentState;
    }

    final newSelectedIndices = [...currentState.selectedIndices, index];
    final newSelectedWord = newSelectedIndices
        .map((i) => currentState.scrambledLetters[i])
        .join();

    // Check if we have a complete word and if it's correct
    if (newSelectedWord.length == currentState.currentWord.length) {
      if (newSelectedWord == currentState.currentWord) {
        // Correct answer - automatically handle it
        return handleCorrectAnswer(currentState.copyWith(
          selectedIndices: newSelectedIndices,
          selectedWord: newSelectedWord,
        ));
      } else {
        // Wrong answer - just update the selection
        return currentState.copyWith(
          selectedIndices: newSelectedIndices,
          selectedWord: newSelectedWord,
        );
      }
    }

    // Normal case - just update selection
    return currentState.copyWith(
      selectedIndices: newSelectedIndices,
      selectedWord: newSelectedWord,
    );
  }

  GameModel clearSelection(GameModel currentState) {
    return currentState.copyWith(
      selectedIndices: [],
      selectedWord: '',
    );
  }

  GameModel undoLastLetter(GameModel currentState) {
    if (currentState.selectedIndices.isEmpty) return currentState;

    final newSelectedIndices = currentState.selectedIndices.sublist(0, currentState.selectedIndices.length - 1);
    final newSelectedWord = newSelectedIndices
        .map((i) => currentState.scrambledLetters[i])
        .join();

    return currentState.copyWith(
      selectedIndices: newSelectedIndices,
      selectedWord: newSelectedWord,
    );
  }

  GameModel toggleHint(GameModel currentState) {
    final newShowHint = !currentState.showHint;
    final newStreak = newShowHint ? max(0, currentState.streak - 1) : currentState.streak;

    return currentState.copyWith(
      showHint: newShowHint,
      streak: newStreak,
    );
  }

  /// Calculate points for current answer
  int calculatePoints(GameModel currentState) {
    final levelBonus = currentState.currentLevel * 5;
    final streakBonus = currentState.streak * 5;
    return 10 + levelBonus + streakBonus;
  }

  /// Check if player should level up
  bool shouldLevelUp(GameModel currentState) {
    final nextWordsCompleted = currentState.wordsCompletedInLevel + 1;
    return nextWordsCompleted >= currentState.wordsRequiredForNextLevel;
  }

  /// Get the new level data after leveling up
  LevelUpData calculateLevelUp(GameModel currentState) {
    final newLevel = currentState.currentLevel + 1;
    final newWordsRequired = 3 + (newLevel ~/ 3);
    
    return LevelUpData(
      newLevel: newLevel,
      wordsRequiredForNextLevel: newWordsRequired,
    );
  }

  GameModel handleCorrectAnswer(GameModel currentState) {
    final pointsEarned = calculatePoints(currentState);
    final newStreak = currentState.streak + 1;
    final totalWords = currentState.totalWordsCompleted + 1;
    final wordsCompleted = currentState.wordsCompletedInLevel + 1;

    // Check if level should increase
    if (wordsCompleted >= currentState.wordsRequiredForNextLevel) {
      final levelUp = calculateLevelUp(currentState);

      return currentState.copyWith(
        score: currentState.score + pointsEarned,
        streak: newStreak,
        totalWordsCompleted: totalWords,
        currentLevel: levelUp.newLevel,
        wordsCompletedInLevel: 0, // reset for new level
        wordsRequiredForNextLevel: levelUp.wordsRequiredForNextLevel,
        selectedIndices: [],
        selectedWord: '',
        showHint: false,
      );
    }

    // Normal correct answer (no level up)
    return currentState.copyWith(
      score: currentState.score + pointsEarned,
      streak: newStreak,
      totalWordsCompleted: totalWords,
      wordsCompletedInLevel: wordsCompleted,
      selectedIndices: [],
      selectedWord: '',
      showHint: false,
    );
  }

  GameModel handleWrongAnswer(GameModel currentState) {
    return currentState.copyWith(
      streak: 0,
    );
  }
}