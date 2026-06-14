/// Unified word model with FSRS scheduling state.
///
/// Combines static vocabulary data (id, word, sentence, level) with
/// dynamic spaced-repetition fields (stability, difficulty, due, etc.).
class Word {
  // ── Static vocabulary fields ──
  final int id;
  final String word;
  final String sentence;
  final String level;
  final int isSeen;
  final String? date;

  /// Legacy 3-value feedback (1=hard, 2=easy, 3=medium).
  /// Kept for backward compatibility. New reviews use FSRS.
  final int feedback;

  /// Translation in mother language.
  final String? backWord;

  /// Translated sentence in mother language.
  final String? backSentence;

  // ── FSRS scheduling fields ──
  final int cardState;
  final double stability;
  final double difficulty;
  final String? due;
  final int elapsedDays;
  final int scheduledDays;
  final int reps;
  final int lapses;
  final String? lastReview;

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
    this.cardState = 0,
    this.stability = 0.0,
    this.difficulty = 0.0,
    this.due,
    this.elapsedDays = 0,
    this.scheduledDays = 0,
    this.reps = 0,
    this.lapses = 0,
    this.lastReview,
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
      'card_state': cardState,
      'stability': stability,
      'difficulty': difficulty,
      'due': due,
      'elapsed_days': elapsedDays,
      'scheduled_days': scheduledDays,
      'reps': reps,
      'lapses': lapses,
      'last_review': lastReview,
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
      cardState: map['card_state'] as int? ?? 0,
      stability: (map['stability'] as num?)?.toDouble() ?? 0.0,
      difficulty: (map['difficulty'] as num?)?.toDouble() ?? 0.0,
      due: map['due'] as String?,
      elapsedDays: map['elapsed_days'] as int? ?? 0,
      scheduledDays: map['scheduled_days'] as int? ?? 0,
      reps: map['reps'] as int? ?? 0,
      lapses: map['lapses'] as int? ?? 0,
      lastReview: map['last_review'] as String?,
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
    int? cardState,
    double? stability,
    double? difficulty,
    String? due,
    int? elapsedDays,
    int? scheduledDays,
    int? reps,
    int? lapses,
    String? lastReview,
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
      cardState: cardState ?? this.cardState,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      due: due ?? this.due,
      elapsedDays: elapsedDays ?? this.elapsedDays,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      lastReview: lastReview ?? this.lastReview,
    );
  }
}
