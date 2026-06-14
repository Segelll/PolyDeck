/// A single review log entry, tracking the history of card reviews.
///
/// Equivalent to Anki's `revlog` table. Stored for future FSRS
/// parameter optimization and statistics.
class RevlogEntry {
  final int? id;
  final int cardId;
  final String deckTable;
  final int rating;
  final int state;
  final String due;
  final double stability;
  final double difficulty;
  final int elapsedDays;
  final int lastElapsedDays;
  final int scheduledDays;
  final String reviewDate;

  const RevlogEntry({
    this.id,
    required this.cardId,
    required this.deckTable,
    required this.rating,
    required this.state,
    required this.due,
    required this.stability,
    required this.difficulty,
    required this.elapsedDays,
    this.lastElapsedDays = 0,
    required this.scheduledDays,
    required this.reviewDate,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'card_id': cardId,
      'deck_table': deckTable,
      'rating': rating,
      'state': state,
      'due': due,
      'stability': stability,
      'difficulty': difficulty,
      'elapsed_days': elapsedDays,
      'last_elapsed_days': lastElapsedDays,
      'scheduled_days': scheduledDays,
      'review_date': reviewDate,
    };
  }

  factory RevlogEntry.fromMap(Map<String, dynamic> map) {
    return RevlogEntry(
      id: map['id'] as int?,
      cardId: map['card_id'] as int,
      deckTable: map['deck_table'] as String,
      rating: map['rating'] as int,
      state: map['state'] as int,
      due: map['due'] as String,
      stability: (map['stability'] as num).toDouble(),
      difficulty: (map['difficulty'] as num).toDouble(),
      elapsedDays: map['elapsed_days'] as int,
      lastElapsedDays: map['last_elapsed_days'] as int? ?? 0,
      scheduledDays: map['scheduled_days'] as int,
      reviewDate: map['review_date'] as String,
    );
  }
}
