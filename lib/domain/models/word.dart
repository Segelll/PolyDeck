/// Unified word model used across the application.
///
/// This replaces the two previously separate [WordModel] classes
/// in [models/word_model.dart] and [services/database_helper.dart].
class Word {
  final int id;
  final String word;
  final String sentence;
  final String level;
  final int isSeen;
  final int feedback;
  final String? date;

  /// Back-side word (translation in the mother language).
  final String? backWord;

  /// Back-side sentence (translated sentence).
  final String? backSentence;

  const Word({
    required this.id,
    required this.word,
    required this.sentence,
    required this.level,
    this.isSeen = 0,
    this.feedback = 0,
    this.date,
    this.backWord,
    this.backSentence,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'sentence': sentence,
      'level': level,
      'isSeen': isSeen,
      'feedback': feedback,
      'date': date,
    };
  }

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'] as int,
      word: map['word'] as String? ?? '',
      sentence: map['sentence'] as String? ?? '',
      level: map['level'] as String? ?? '',
      isSeen: map['isSeen'] as int? ?? 0,
      feedback: map['feedback'] as int? ?? 0,
      date: map['date'] as String?,
      backWord: map['backword'] as String?,
      backSentence: map['backsentence'] as String?,
    );
  }

  Word copyWith({
    int? id,
    String? word,
    String? sentence,
    String? level,
    int? isSeen,
    int? feedback,
    String? date,
    String? backWord,
    String? backSentence,
  }) {
    return Word(
      id: id ?? this.id,
      word: word ?? this.word,
      sentence: sentence ?? this.sentence,
      level: level ?? this.level,
      isSeen: isSeen ?? this.isSeen,
      feedback: feedback ?? this.feedback,
      date: date ?? this.date,
      backWord: backWord ?? this.backWord,
      backSentence: backSentence ?? this.backSentence,
    );
  }
}
