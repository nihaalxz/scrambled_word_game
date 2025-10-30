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
    int attempts = 0;
    while (scrambledLetters.join() == currentWord && currentWord.length > 1 && attempts < 10) {
      scrambledLetters.shuffle();
      attempts++;
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
    // Don't allow selecting the SAME INDEX twice (same tile)
    // But allow selecting different tiles with the same letter
    if (currentState.selectedIndices.contains(index)) {
      return currentState;
    }

    // Don't allow selecting more letters than the word length
    if (currentState.selectedIndices.length >= currentState.currentWord.length) {
      return currentState;
    }

    final newSelectedIndices = [...currentState.selectedIndices, index];
    final newSelectedWord = newSelectedIndices
        .map((i) => currentState.scrambledLetters[i])
        .join();

    // Just update the selection - don't auto-submit
    // The UI or bloc will handle submission when word is complete
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

    final newSelectedIndices = currentState.selectedIndices.sublist(
      0, 
      currentState.selectedIndices.length - 1
    );
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
    // Only reduce streak when showing hint, not when hiding it
    final newStreak = (newShowHint && !currentState.showHint) 
        ? max(0, currentState.streak - 1) 
        : currentState.streak;

    return currentState.copyWith(
      showHint: newShowHint,
      streak: newStreak,
    );
  }

  /// Calculate points for current answer
  int calculatePoints(GameModel currentState) {
    final basePoints = 10;
    final levelBonus = currentState.currentLevel * 5;
    final streakBonus = currentState.streak * 5;
    final wordLengthBonus = currentState.currentWord.length * 2;
    
    return basePoints + levelBonus + streakBonus + wordLengthBonus;
  }

  /// Check if player should level up
  bool shouldLevelUp(GameModel currentState) {
    final nextWordsCompleted = currentState.wordsCompletedInLevel + 1;
    return nextWordsCompleted >= currentState.wordsRequiredForNextLevel;
  }

  /// Get the new level data after leveling up
  LevelUpData calculateLevelUp(GameModel currentState) {
    final newLevel = currentState.currentLevel + 1;
    // Gradually increase words required: starts at 3, increases by 1 every 3 levels
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
    // Reset streak and clear selection
    return currentState.copyWith(
      streak: 0,
      selectedIndices: [],
      selectedWord: '',
    );
  }
}