import 'package:fsrs/fsrs.dart' as fsrs;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/domain/enums/rating.dart';
import 'package:poly2/domain/enums/card_state.dart';

/// Wraps the `package:fsrs` Dart port of the FSRS algorithm (v2.0.1).
///
/// Deck config (retention, fuzz, learning steps, w-parameters) is applied
/// per review call so that SRS Settings changes take immediate effect.
class FsrsService {
  final fsrs.Scheduler _defaultScheduler;

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
  }) : _defaultScheduler = fsrs.Scheduler(
          parameters: parameters ?? fsrs.defaultParameters,
          desiredRetention: requestRetention,
          enableFuzzing: enableFuzz,
          learningSteps: learningSteps,
          relearningSteps: relearningSteps,
        );

  /// Returns a scheduler configured per the given deck-config values.
  /// Falls back to defaults when parameters are missing or invalid.
  fsrs.Scheduler _schedulerFor({
    double? requestRetention,
    bool? enableFuzz,
    String? learningStepsJson,
    String? wJson,
  }) {
    // Parse learning steps from JSON, e.g. "[1,10]" → [1m, 10m].
    List<Duration> steps = const [Duration(minutes: 1), Duration(minutes: 10)];
    if (learningStepsJson != null) {
      try {
        final list = _parseIntList(learningStepsJson);
        steps = list.map((m) => Duration(minutes: m)).toList();
      } catch (_) {}
    }

    // Parse w-parameters from JSON.  Fall back to FSRS defaults.
    List<double> w = fsrs.defaultParameters;
    if (wJson != null) {
      try {
        final list = _parseDoubleList(wJson);
        if (list.length == 19) w = list; // FSRS-5 w vector
      } catch (_) {}
    }

    return fsrs.Scheduler(
      parameters: w,
      desiredRetention: requestRetention ?? 0.9,
      enableFuzzing: enableFuzz ?? true,
      learningSteps: steps,
      relearningSteps: const [Duration(minutes: 10)],
    );
  }

  List<int> _parseIntList(String json) =>
      (RegExp(r'\d+').allMatches(json).map((m) => int.parse(m.group(0)!)))
          .toList();

  List<double> _parseDoubleList(String json) =>
      (RegExp(r'[\d.]+').allMatches(json).map((m) => double.parse(m.group(0)!)))
          .toList();

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

  /// Reviews a card with default FSRS parameters.
  FsrsReviewResult review({
    required fsrs.Card card,
    required Rating rating,
    DateTime? now,
  }) {
    return _review(_defaultScheduler, card, rating, now);
  }

  /// Reviews a card using per-call deck-config parameters so SRS Settings
  /// changes (retention, fuzz, learning steps, w) take immediate effect.
  FsrsReviewResult reviewWithConfig({
    required fsrs.Card card,
    required Rating rating,
    DateTime? now,
    double? requestRetention,
    bool? enableFuzz,
    String? learningStepsJson,
    String? wJson,
  }) {
    final scheduler = _schedulerFor(
      requestRetention: requestRetention,
      enableFuzz: enableFuzz,
      learningStepsJson: learningStepsJson,
      wJson: wJson,
    );
    return _review(scheduler, card, rating, now);
  }

  FsrsReviewResult _review(
    fsrs.Scheduler scheduler,
    fsrs.Card card,
    Rating rating,
    DateTime? now,
  ) {
    final nowDt = (now ?? DateTime.now()).toUtc();
    final result = scheduler.reviewCard(card, _toFsrsRating(rating),
        reviewDateTime: nowDt);

    final newCard = result.card;

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
          ? scheduler.getCardRetrievability(card, currentDateTime: nowDt)
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
