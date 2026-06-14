import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/data/repositories/word_repository.dart';
import 'package:poly2/data/repositories/user_repository.dart';
import 'package:poly2/domain/models/card_model.dart';
import 'package:poly2/domain/models/analysis_result.dart';
import 'package:poly2/domain/enums/rating.dart';
import 'package:poly2/domain/state/deck_state.dart';
import 'package:poly2/services/fsrs_service.dart';
import 'package:poly2/presentation/providers/database_provider.dart';
import 'package:poly2/presentation/providers/settings_provider.dart';
import 'package:poly2/core/constants/app_constants.dart';
import 'package:poly2/core/constants/language_codes.dart';
import 'package:poly2/core/theme/app_theme.dart';
import 'package:poly2/core/utils/date_utils.dart';

/// Manages a FSRS-driven flashcard session.
class DeckNotifier extends StateNotifier<DeckState> {
  final WordRepository _wordRepo;
  final UserRepository _userRepo;
  final FsrsService _fsrs;

  DeckNotifier(this._wordRepo, this._userRepo, this._fsrs)
      : super(const DeckState());

  // ── Deck loading (FSRS algorithm) ──

  Future<void> loadDeck(String level) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final userSettings = await _userRepo.getUserChoices();
      final targetLang =
          LanguageCodes.tableNameFor(userSettings?['targetLanguage'] ?? 'tr');
      final motherLang =
          LanguageCodes.tableNameFor(userSettings?['mainLanguage'] ?? 'en');

      List<Map<String, dynamic>> allWords = [];

      if (level == 'fav') {
        final favWords = await _wordRepo.fetchAllFavorites();
        final random = Random();
        final randomIndices = <int>{};
        while (randomIndices.length < AppConstants.cardsPerDeck &&
            randomIndices.length < favWords.length) {
          randomIndices.add(random.nextInt(favWords.length));
        }
        for (final index in randomIndices) {
          allWords.add(favWords[index]);
        }
      } else {
        // FSRS-driven selection
        final config = await _wordRepo.getDeckConfig(level);
        final todayCounts =
            await _wordRepo.getTodayCounts(targetLang, level);

        final remainingNew =
            ((config['maxNewPerDay'] as int) - todayCounts.newCount).clamp(0, 999);
        final remainingReviews =
            ((config['maxReviewsPerDay'] as int) - todayCounts.reviewCount).clamp(0, 999);

        final dueWords =
            await _wordRepo.fetchDueCards(targetLang, level, remainingReviews);
        final newWords =
            await _wordRepo.fetchNewCards(targetLang, level, remainingNew);

        allWords = [...dueWords, ...newWords];

        final missing = AppConstants.cardsPerDeck - allWords.length;
        if (missing > 0) {
          final fillers = await _wordRepo.fetchWordsByIsSeen(
              targetLang, level, 0, missing);
          allWords.addAll(fillers);
        }
      }

      // Build CardModel list with translations (batch query)
      final List<CardModel> allCards = [];
      if (allWords.isNotEmpty) {
        final wordIds = allWords.map((w) => w['id'] as int).toList();
        final translations =
            await _wordRepo.fetchWordsByIds(motherLang, wordIds);
        final translationMap = <int, Map<String, dynamic>>{};
        for (final t in translations) {
          translationMap[t['id'] as int] = t;
        }

        for (final word in allWords) {
          final wordId = word['id'] as int;
          final translation = translationMap[wordId];

          allCards.add(CardModel(
            word['id'] as int,
            word['word'] as String,
            word['sentence'] as String,
            word['level'] == 'fav'
                ? (word['backword'] as String? ?? '')
                : (translation?['word'] as String? ?? ''),
            word['level'] == 'fav'
                ? (word['backsentence'] as String? ?? '')
                : (translation?['sentence'] as String? ?? ''),
            word['level'] as String,
          ));
        }
      }

      allCards.shuffle(Random());
      final selected = allCards.take(AppConstants.cardsPerDeck).toList();

      if (selected.isNotEmpty) {
        await _wordRepo.markMultipleAsSeen(
            targetLang, selected.map((c) => c.id).toList(),
            formatDate(DateTime.now()));
      }

      state = state.copyWith(
        cards: selected,
        currentIndex: 0,
        isFlipped: false,
        isLoading: false,
        colorTracker:
            List.generate(selected.length, (_) => AppTheme.cardDefault),
        analysisResults: [],
        targetLang: targetLang,
        motherLang: motherLang,
        isFavorite: false,
      );
    } catch (e) {
      if (kDebugMode) print('DeckNotifier.loadDeck error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load deck: $e',
      );
    }
  }

  // ── Card review (FSRS) ──

  Future<void> reviewCard(Rating rating) async {
    if (state.isEmpty || !state.isFlipped) return;

    final card = state.currentCard;
    final tableName = state.targetLang;
    if (tableName == null) return;

    try {
      final word = await _wordRepo.fetchWordById(tableName, card.id);
      if (word == null) return;

      final fsrsCard = _fsrs.cardFromDb(
        cardId: word['id'] as int,
        cardStateValue: word['card_state'] as int? ?? 0,
        stability: (word['stability'] as num?)?.toDouble() ?? 0.0,
        difficulty: (word['difficulty'] as num?)?.toDouble() ?? 0.0,
        elapsedDays: word['elapsed_days'] as int? ?? 0,
        lastReview: word['last_review'] as String?,
        due: word['due'] as String?,
      );

      final result = _fsrs.review(card: fsrsCard, rating: rating);

      final legacyFeedback = rating == Rating.again
          ? 1
          : rating == Rating.hard
              ? 3
              : 2;

      await _wordRepo.updateSrsState(
        tableName, card.id,
        cardState: result.cardState.value,
        stability: result.stability,
        difficulty: result.difficulty,
        due: result.due,
        elapsedDays: 0,
        scheduledDays: result.scheduledDays,
        reps: (word['reps'] as int? ?? 0) + 1,
        lapses: rating == Rating.again
            ? (word['lapses'] as int? ?? 0) + 1
            : (word['lapses'] as int? ?? 0),
        lastReview: result.lastReview,
        legacyFeedback: legacyFeedback,
      );

      await _wordRepo.insertRevlog(
        cardId: card.id,
        deckTable: tableName,
        rating: rating.value,
        state: word['card_state'] as int? ?? 0,
        due: word['due'] as String? ?? '',
        stability: result.stability,
        difficulty: result.difficulty,
        elapsedDays: word['elapsed_days'] as int? ?? 0,
        lastElapsedDays: word['elapsed_days'] as int? ?? 0,
        scheduledDays: result.scheduledDays,
        reviewDate: result.lastReview,
      );

      // Update color tracker
      final color = _colorForRating(rating);
      final newColorTracker = List<Color>.from(state.colorTracker);
      newColorTracker[state.currentIndex] = color;

      final newAnalysis = List<AnalysisResult>.from(state.analysisResults)
        ..add(AnalysisResult(
          word: card.frontText,
          meaning: card.backText,
          color: color,
        ));

      state = state.copyWith(
        colorTracker: newColorTracker,
        analysisResults: newAnalysis,
        lastRating: rating,
      );
    } catch (e) {
      if (kDebugMode) print('DeckNotifier.reviewCard error: $e');
      state = state.copyWith(errorMessage: 'Failed to record review');
    }
  }

  Color _colorForRating(Rating rating) {
    return switch (rating) {
      Rating.again => AppTheme.ratingAgain,
      Rating.hard => AppTheme.ratingHard,
      Rating.good => AppTheme.ratingGood,
      Rating.easy => AppTheme.ratingEasy,
    };
  }

  // ── Legacy flip ──

  Future<void> flipCard(Color color) async {
    if (state.isEmpty || state.isFlipped) return;

    Rating rating;
    if (color == AppTheme.cardRed || color == Colors.red.shade200) {
      rating = Rating.again;
    } else if (color == AppTheme.cardGreen || color == Colors.green.shade200) {
      rating = Rating.good;
    } else if (color == AppTheme.cardYellow) {
      rating = Rating.hard;
    } else {
      rating = Rating.good;
    }

    final newColorTracker = List<Color>.from(state.colorTracker);
    newColorTracker[state.currentIndex] = color;

    state = state.copyWith(
      isFlipped: true,
      colorTracker: newColorTracker,
    );

    await reviewCard(rating);
  }

  void reflipCard() {
    if (!state.isFlipped) return;
    final newColorTracker = List<Color>.from(state.colorTracker);
    newColorTracker[state.currentIndex] = AppTheme.cardDefault;
    state = state.copyWith(
      isFlipped: false,
      colorTracker: newColorTracker,
      analysisResults: state.analysisResults
          .where((r) => r.word != state.currentCard.frontText)
          .toList(),
    );
  }

  Future<void> nextCard() async {
    if (state.isLastCard) return;
    final newIndex = state.currentIndex + 1;
    state = state.copyWith(
      currentIndex: newIndex,
      isFlipped: false,
      isFavorite: false,
      lastRating: null,
    );
    final fav = await _wordRepo.isFavorite(state.currentCard.frontText);
    state = state.copyWith(isFavorite: fav);
  }

  void startNewDeck() {
    state = DeckState(
      isLoading: true,
      deckIndex: state.deckIndex + 1,
      colorTracker:
          List.generate(AppConstants.cardsPerDeck, (_) => AppTheme.cardDefault),
    );
  }

  Future<void> toggleFavorite() async {
    final card = state.currentCard;
    try {
      if (state.isFavorite) {
        await _wordRepo.removeFromFavorites(card.frontText);
        state = state.copyWith(isFavorite: false);
      } else {
        await _wordRepo.addToFavorites(
          word: card.frontText,
          sentence: card.frontSentence,
          level: card.level,
          backWord: card.backText,
          backSentence: card.backSentence,
        );
        state = state.copyWith(isFavorite: true);
      }
    } catch (e) {
      if (kDebugMode) print('DeckNotifier.toggleFavorite error: $e');
      state = state.copyWith(errorMessage: 'Error updating favorite');
    }
  }
}

/// Provider for the deck session state.
final deckProvider =
    StateNotifierProvider.autoDispose<DeckNotifier, DeckState>((ref) {
  final wordRepo = ref.read(wordRepositoryProvider);
  final userRepo = ref.read(userRepositoryProvider);
  final fsrs = ref.read(fsrsServiceProvider);
  return DeckNotifier(wordRepo, userRepo, fsrs);
});
