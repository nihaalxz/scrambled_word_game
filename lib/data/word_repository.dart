import 'dart:math';

import 'package:scramble_word_game/data/word_list.dart';

abstract class WordRepository {
  List<String> getWordsForLevel(int level);
  String getRandomWordForLevel(int level);
}

class WordRepositoryImpl implements WordRepository {
  @override
  List<String> getWordsForLevel(int level) {
    if (level <= 2) {
      return kidsWords.where((w) => w.length <= 4).toList();
    } else if (level <= 5) {
      return kidsWords.where((w) => w.length <= 6).toList();
    } else if (level <= 8) {
      return kidsWords.where((w) => w.length <= 8).toList();
    } else {
      return kidsWords;
    }
  }

  @override
  String getRandomWordForLevel(int level) {
    final availableWords = getWordsForLevel(level);
    if (availableWords.isEmpty) return kidsWords.first;
    
    final random = Random();
    return availableWords[random.nextInt(availableWords.length)];
  }
}