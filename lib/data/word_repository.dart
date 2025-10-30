import 'dart:math';
import 'package:scramble_word_game/data/word_list.dart';

abstract class WordRepository {
  List<String> getWordsForLevel(int level);
  String getRandomWordForLevel(int level);
}

class WordRepositoryImpl implements WordRepository {
  @override
  List<String> getWordsForLevel(int level) {
    if (level <= 3) {
      // Levels 1-3: Easy words (3-4 letters)
      return kidsWords.where((w) => w.length <= 4).toList();
    } else if (level <= 6) {
      // Levels 4-6: Medium words (5-6 letters)
      return kidsWords.where((w) => w.length >= 5 && w.length <= 6).toList();
    } else if (level <= 9) {
      // Levels 7-9: Challenging words (7-8 letters)
      return kidsWords.where((w) => w.length >= 7 && w.length <= 8).toList();
    } else {
      // Level 10+: Advanced words (9+ letters)
      return kidsWords.where((w) => w.length >= 9).toList();
    }
  }

  @override
  String getRandomWordForLevel(int level) {
    final availableWords = getWordsForLevel(level);
    if (availableWords.isEmpty) {
      // Fallback to any word if no words found for level
      final random = Random();
      return kidsWords[random.nextInt(kidsWords.length)];
    }
    
    final random = Random();
    return availableWords[random.nextInt(availableWords.length)];
  }
}


