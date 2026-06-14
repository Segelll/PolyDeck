/// Application-wide constants.
class AppConstants {
  AppConstants._();

  /// Number of cards in a single deck session.
  static const int cardsPerDeck = 10;

  /// Number of questions in an exam.
  static const int questionsPerLevel = 4;

  /// Number of distractor options per exam question.
  static const int distractorsPerQuestion = 3;

  /// Total number of exam levels.
  static const int examLevelCount = 5;

  /// Minimum word ID in the database.
  static const int minWordId = 1;

  /// Maximum word ID in the database.
  static const int maxWordId = 4799;

  /// Level-to-ID-range mapping for exam question generation.
  static const Map<String, List<int>> levelIdRanges = {
    'A1': [1, 702],
    'A2': [704, 1425],
    'B1': [1428, 2163],
    'B2': [2166, 3539],
    'C1': [3543, 4790],
  };

  /// All language database table names for progress queries.
  static const List<String> languageTables = [
    'en',
    'tr',
    'de',
    'fr',
    'it',
    'pr',
    'esp',
  ];
}
