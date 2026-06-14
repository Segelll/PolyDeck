import 'package:fsrs/fsrs.dart' as fsrs;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/domain/enums/rating.dart';
import 'package:poly2/domain/enums/card_state.dart';

/// Wraps the `package:fsrs` Dart port of the FSRS algorithm.
///
/// Provides typed conversion between our domain enums and the
/// underlying FSRS library's enums.
class FsrsService {
  final fsrs.FSRS _fsrs;

  FsrsService({
    List<double>? parameters,
    bool enableFuzz = true,
    double requestRetention = 0.9,
  }) : _fsrs = fsrs.FSRS(
          parameters: parameters != null
              ? fsrs.FSRSDefaults(w: parameters, enableFuzz: enableFuzz)
              : fsrs.FSRSDefaults(
                  enableFuzz: enableFuzz,
                  requestedRetention: requestRetention,
                ),
        );

  /// Creates a default FSRS card for a brand-new word.
  fsrs.Card createDefaultCard() => fsrs.Card();

  /// Builds an [fsrs.Card] from database fields.
  fsrs.Card cardFromDb({
    required int cardState,
    required double stability,
    required double difficulty,
    required int elapsedDays,
    required int scheduledDays,
    required int reps,
    required int lapses,
    required String? lastReview,
    required String? due,
  }) {
    return fsrs.Card(
      due: due != null ? DateTime.parse(due) : DateTime.now(),
      stability: stability,
      difficulty: difficulty,
      elapsedDays: elapsedDays,
      scheduledDays: scheduledDays,
      reps: reps,
      lapses: lapses,
      state: _toFsrsState(CardState.fromValue(cardState)),
      lastReview:
          lastReview != null ? DateTime.parse(lastReview) : DateTime.now(),
    );
  }

  /// Reviews a card with the given [rating] and returns the scheduling result.
  FsrsReviewResult review({
    required fsrs.Card card,
    required Rating rating,
    DateTime? now,
  }) {
    final nowDt = now ?? DateTime.now();
    final scheduling =
        _fsrs.review(card: card, now: nowDt, rating: _toFsrsRating(rating));

    final newCard = scheduling.card;
    final log = scheduling.reviewLog;

    return FsrsReviewResult(
      cardState: CardState.fromValue(newCard.state.index),
      stability: newCard.stability,
      difficulty: newCard.difficulty,
      due: newCard.due != null
          ? '${newCard.due!.year}-${newCard.due!.month.toString().padLeft(2, '0')}-${newCard.due!.day.toString().padLeft(2, '0')}'
          : null,
      elapsedDays: newCard.elapsedDays,
      scheduledDays: newCard.scheduledDays,
      reps: newCard.reps,
      lapses: newCard.lapses,
      lastReview: nowDt.toIso8601String(),
      retrievability: scheduling.retrievability,
    );
  }

  // ── Private helpers ──

  fsrs.Rating _toFsrsRating(Rating rating) {
    switch (rating) {
      case Rating.again:
        return fsrs.Rating.again;
      case Rating.hard:
        return fsrs.Rating.hard;
      case Rating.good:
        return fsrs.Rating.good;
      case Rating.easy:
        return fsrs.Rating.easy;
    }
  }

  fsrs.State _toFsrsState(CardState state) {
    switch (state) {
      case CardState.new_:
        return fsrs.State.new_;
      case CardState.learning:
        return fsrs.State.learning;
      case CardState.review:
        return fsrs.State.review;
      case CardState.relearning:
        return fsrs.State.relearning;
    }
  }
}

/// Result of an FSRS review, containing everything needed to update the DB.
class FsrsReviewResult {
  final CardState cardState;
  final double stability;
  final double difficulty;
  final String? due;
  final int elapsedDays;
  final int scheduledDays;
  final int reps;
  final int lapses;
  final String lastReview;
  final double retrievability;

  const FsrsReviewResult({
    required this.cardState,
    required this.stability,
    required this.difficulty,
    this.due,
    required this.elapsedDays,
    required this.scheduledDays,
    required this.reps,
    required this.lapses,
    required this.lastReview,
    this.retrievability = 0.0,
  });
}

/// Riverpod provider for the FSRS service.
final fsrsServiceProvider = Provider<FsrsService>((ref) {
  return FsrsService();
});
