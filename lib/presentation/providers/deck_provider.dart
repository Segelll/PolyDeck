import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/data/repositories/word_repository.dart';
import 'package:poly2/data/repositories/user_repository.dart';
import 'package:poly2/domain/models/card_model.dart';
import 'package:poly2/domain/models/analysis_result.dart';
import 'package:poly2/domain/models/revlog_entry.dart';
import 'package:poly2/domain/enums/rating.dart';
import 'package:poly2/domain/enums/card_state.dart';
import 'package:poly2/domain/state/deck_state.dart';
import 'package:poly2/services/fsrs_service.dart';
import 'package:poly2/presentation/providers/settings_provider.dart';
import 'package:poly2/core/constants/app_constants.dart';
import 'package:poly2/core/constants/language_codes.dart';
import 'package:poly2/core/theme/app_theme.dart';
import 'package:poly2/core/utils/date_utils.dart';

/// Provides the [WordRepository] instance.
final wordRepositoryProvider = Provider<WordRepository>((ref) {
  return WordRepository();
});

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
        // Favorites: unchanged random selection (no SRS)
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
        // Single combined query instead of two separate COUNT queries
        final todayCounts =
            await _wordRepo.getTodayCounts(targetLang, level);

        final remainingNew =
            (config.maxNewPerDay - todayCounts.newCount).clamp(0, 999);
        final remainingReviews =
            (config.maxReviewsPerDay - todayCounts.reviewCount).clamp(0, 999);

        // Fetch due cards first (reviews)
        final dueWords =
            await _wordRepo.fetchDueCards(targetLang, level, remainingReviews);

        // Fetch new cards
        final newWords =
            await _wordRepo.fetchNewCards(targetLang, level, remainingNew);

        allWords = [...dueWords, ...newWords];

        // If not enough cards, fill with random unseen words
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
        // Batch-fetch all translations in a single query
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

      // Mark all selected cards as seen in a single batch query
      if (selected.isNotEmpty) {
        await _wordRepo.markMultipleAsSeen(
            targetLang, selected.map((c) => c.id).toList(), formatDate(DateTime.now()));
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

  /// Reviews the current card with a [Rating] and persists the FSRS result.
  Future<void> reviewCard(Rating rating) async {
    if (state.isEmpty || !state.isFlipped) return;

    final card = state.currentCard;
    final tableName = state.targetLang;
    if (tableName == null) return;

    try {
      // Load the word with its current FSRS state
      final word =
          await _wordRepo.fetchWordById(tableName, card.id);
      if (word == null) return;

      // Build FSRS card from DB state
      final fsrsCard = _fsrs.cardFromDb(
        cardId: word.id,
        cardStateValue: word.cardState,
        stability: word.stability,
        difficulty: word.difficulty,
        elapsedDays: word.elapsedDays,
        lastReview: word.lastReview,
        due: word.due,
      );

      // Run FSRS review
      final result = _fsrs.review(card: fsrsCard, rating: rating);

      // Persist new FSRS state (including legacy feedback in same query)
      final legacyFeedback = rating == Rating.again
          ? 1
          : rating == Rating.hard
              ? 3
              : 2; // Good/Easy map to 2

      await _wordRepo.updateSrsState(
        tableName,
        card.id,
        cardState: result.cardState.value,
        stability: result.stability,
        difficulty: result.difficulty,
        due: result.due,
        elapsedDays: 0,
        scheduledDays: result.scheduledDays,
        reps: word.reps + 1,
        lapses: rating == Rating.again ? word.lapses + 1 : word.lapses,
        lastReview: result.lastReview,
        legacyFeedback: legacyFeedback,
      );

      // Insert revlog entry
      final revlogEntry = RevlogEntry(
        cardId: card.id,
        deckTable: tableName,
        rating: rating.value,
        state: word.cardState,
        due: word.due ?? '',
        stability: result.stability,
        difficulty: result.difficulty,
        elapsedDays: word.elapsedDays,
        lastElapsedDays: word.elapsedDays,
        scheduledDays: result.scheduledDays,
        reviewDate: result.lastReview,
      );
      await _wordRepo.insertRevlog(revlogEntry);

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
    switch (rating) {
      case Rating.again:
        return AppTheme.ratingAgain;
      case Rating.hard:
        return AppTheme.ratingHard;
      case Rating.good:
        return AppTheme.ratingGood;
      case Rating.easy:
        return AppTheme.ratingEasy;
    }
  }

  // ── Legacy flip (called by swipe gestures in UI) ──

  Future<void> flipCard(Color color) async {
    if (state.isEmpty || state.isFlipped) return;

    // Convert legacy color to Rating for FSRS
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

    // Mark as flipped first so the UI updates immediately
    final newColorTracker = List<Color>.from(state.colorTracker);
    newColorTracker[state.currentIndex] = color;

    state = state.copyWith(
      isFlipped: true,
      colorTracker: newColorTracker,
    );

    // Then run the FSRS review
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
