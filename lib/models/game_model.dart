class GameModel {
  final String currentWord;
  final List<String> scrambledLetters;
  final List<int> selectedIndices;
  final String selectedWord;
  final int score;
  final int streak;
  final bool showHint;
  final int currentLevel;
  final int wordsCompletedInLevel;
  final int wordsRequiredForNextLevel;
  final int totalWordsCompleted;

  const GameModel({
    required this.currentWord,
    required this.scrambledLetters,
    required this.selectedIndices,
    required this.selectedWord,
    required this.score,
    required this.streak,
    required this.showHint,
    required this.currentLevel,
    required this.wordsCompletedInLevel,
    required this.wordsRequiredForNextLevel,
    required this.totalWordsCompleted,
  });

  GameModel copyWith({
    String? currentWord,
    List<String>? scrambledLetters,
    List<int>? selectedIndices,
    String? selectedWord,
    int? score,
    int? streak,
    bool? showHint,
    int? currentLevel,
    int? wordsCompletedInLevel,
    int? wordsRequiredForNextLevel,
    int? totalWordsCompleted,
  }) {
    return GameModel(
      currentWord: currentWord ?? this.currentWord,
      scrambledLetters: scrambledLetters ?? this.scrambledLetters,
      selectedIndices: selectedIndices ?? this.selectedIndices,
      selectedWord: selectedWord ?? this.selectedWord,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      showHint: showHint ?? this.showHint,
      currentLevel: currentLevel ?? this.currentLevel,
      wordsCompletedInLevel: wordsCompletedInLevel ?? this.wordsCompletedInLevel,
      wordsRequiredForNextLevel: wordsRequiredForNextLevel ?? this.wordsRequiredForNextLevel,
      totalWordsCompleted: totalWordsCompleted ?? this.totalWordsCompleted,
    );
  }

  static GameModel initial() {
    return GameModel(
      currentWord: '',
      scrambledLetters: [],
      selectedIndices: [],
      selectedWord: '',
      score: 0,
      streak: 0,
      showHint: false,
      currentLevel: 1,
      wordsCompletedInLevel: 0,
      wordsRequiredForNextLevel: 3,
      totalWordsCompleted: 0,
    );
  }
}