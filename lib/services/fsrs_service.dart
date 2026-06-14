import 'package:fsrs/fsrs.dart' as fsrs;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/domain/enums/rating.dart';
import 'package:poly2/domain/enums/card_state.dart';

/// Wraps the `package:fsrs` Dart port of the FSRS algorithm (v2.0.1).
class FsrsService {
  final fsrs.Scheduler _scheduler;

  FsrsService({
    List<double>? parameters,
    bool enableFuzz = true,
    double requestRetention = 0.9,
    List<Duration> learningSteps = const [
      Duration(minutes: 1),
      Duration(minutes: 10),
    ],
    List<Duration> relearningSteps = const [
      Duration(minutes: 10),
    ],
  }) : _scheduler = fsrs.Scheduler(
          parameters: parameters ?? fsrs.defaultParameters,
          desiredRetention: requestRetention,
          enableFuzzing: enableFuzz,
          learningSteps: learningSteps,
          relearningSteps: relearningSteps,
        );

  /// Creates a default FSRS card for a brand-new word.
  fsrs.Card createDefaultCard(int cardId) {
    return fsrs.Card(
      cardId: cardId,
      state: fsrs.State.learning,
    );
  }

  /// Builds an [fsrs.Card] from database fields.
  fsrs.Card cardFromDb({
    required int cardId,
    required int cardStateValue,
    required double stability,
    required double difficulty,
    required int elapsedDays,
    required String? lastReview,
    required String? due,
  }) {
    final now = DateTime.now().toUtc();
    return fsrs.Card(
      cardId: cardId,
      state: _toFsrsState(CardState.fromValue(cardStateValue)),
      stability: stability > 0 ? stability : null,
      difficulty: difficulty > 0 ? difficulty : null,
      due: due != null ? DateTime.parse(due) : now,
      lastReview: lastReview != null ? DateTime.parse(lastReview) : null,
    );
  }

  /// Reviews a card with the given [rating] and returns the scheduling result.
  FsrsReviewResult review({
    required fsrs.Card card,
    required Rating rating,
    DateTime? now,
  }) {
    final nowDt = (now ?? DateTime.now()).toUtc();
    final result = _scheduler.reviewCard(card, _toFsrsRating(rating),
        reviewDateTime: nowDt);

    final newCard = result.card;
    final log = result.reviewLog;

    return FsrsReviewResult(
      cardState: _fromFsrsState(newCard.state),
      stability: newCard.stability ?? 0.0,
      difficulty: newCard.difficulty ?? 0.0,
      due: newCard.due != null
          ? '${newCard.due!.year}-${newCard.due!.month.toString().padLeft(2, '0')}-${newCard.due!.day.toString().padLeft(2, '0')}'
          : null,
      scheduledDays: newCard.due != null
          ? newCard.due!.difference(nowDt).inDays.clamp(0, 36500)
          : 0,
      lastReview: nowDt.toIso8601String(),
      retrievability: card.lastReview != null
          ? _scheduler.getCardRetrievability(card, currentDateTime: nowDt)
          : 0.0,
    );
  }

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

  fsrs.State _toFsrsState(CardState st) {
    switch (st) {
      case CardState.new_:
      case CardState.learning:
        return fsrs.State.learning;
      case CardState.review:
        return fsrs.State.review;
      case CardState.relearning:
        return fsrs.State.relearning;
    }
  }

  CardState _fromFsrsState(fsrs.State st) {
    switch (st) {
      case fsrs.State.learning:
        return CardState.learning;
      case fsrs.State.review:
        return CardState.review;
      case fsrs.State.relearning:
        return CardState.relearning;
    }
  }
}

/// Result of an FSRS review, containing everything needed to update the DB.
class FsrsReviewResult {
  final CardState cardState;
  final double stability;
  final double difficulty;
  final String? due;
  final int scheduledDays;
  final String lastReview;
  final double retrievability;

  const FsrsReviewResult({
    required this.cardState,
    required this.stability,
    required this.difficulty,
    this.due,
    required this.scheduledDays,
    required this.lastReview,
    this.retrievability = 0.0,
  });
}

/// Riverpod provider for the FSRS service.
final fsrsServiceProvider = Provider<FsrsService>((ref) {
  return FsrsService();
});
