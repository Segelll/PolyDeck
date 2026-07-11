import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/data/database/database.dart';
import 'package:poly2/data/repositories/word_repository.dart';
import 'package:poly2/data/repositories/user_repository.dart';
import 'package:poly2/data/repositories/deck_repository.dart';
import 'package:poly2/domain/models/card_model.dart';
import 'package:poly2/domain/models/analysis_result.dart';
import 'package:poly2/domain/enums/rating.dart';
import 'package:poly2/domain/state/deck_state.dart';
import 'package:poly2/services/fsrs_service.dart';
import 'package:poly2/presentation/providers/database_provider.dart';
import 'package:poly2/presentation/providers/deck_repository_provider.dart';
import 'package:poly2/core/constants/app_constants.dart';
import 'package:poly2/core/constants/language_codes.dart';
import 'package:poly2/core/theme/app_theme.dart';
import 'package:poly2/core/utils/date_utils.dart';
import 'package:poly2/core/performance/perf_trace.dart';

// ignore_for_file: lines_longer_than_80_chars

class DeckNotifier extends StateNotifier<DeckState> {
  final WordRepository _wordRepo;
  final UserRepository _userRepo;
  final DeckRepository _deckRepo;
  final FsrsService _fsrs;

  DeckNotifier(this._wordRepo, this._userRepo, this._deckRepo, this._fsrs)
      : super(const DeckState());

  Future<void> loadDeck(String level, {int? deckId}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    await PerfTrace.timeAsync('deck.load', () async {
      try {
        final userSettings = await _userRepo.getUserChoices();
        final targetLang =
            LanguageCodes.tableNameFor(userSettings?['targetLanguage'] ?? 'tr');
        final motherLang =
            LanguageCodes.tableNameFor(userSettings?['mainLanguage'] ?? 'en');

        final requestedDeckId = deckId ??
            (level == 'fav' ? await _deckRepo.ensureFavoritesDeck() : null);
        List<CardModel> allCards;

        if (requestedDeckId != null) {
          final entries = await _deckRepo.fetchDeckWords(
              requestedDeckId, AppConstants.cardsPerDeck);
          allCards = entries
              .map((entry) => CardModel(
                    entry.word.id,
                    entry.word.word,
                    entry.word.sentence,
                    entry.sourceWord ?? '',
                    entry.sourceSentence ?? '',
                    entry.word.level,
                    entry.targetLanguage,
                    sourceLanguageCode: entry.sourceLanguage,
                    targetLanguageCode: entry.targetLanguage,
                  ))
              .toList();
        } else {
          List<Word> allWords;
          // Parallel: config + today counts are independent.
          final results = await Future.wait([
            _wordRepo.getDeckConfig(level),
            _wordRepo.getTodayCounts(targetLang, level),
          ]);
          final config = results[0] as Map<String, dynamic>;
          final todayCounts = results[1] as ({int newCount, int reviewCount});

          final remainingNew =
              ((config['maxNewPerDay'] as int) - todayCounts.newCount)
                  .clamp(0, 999);
          final remainingReviews =
              ((config['maxReviewsPerDay'] as int) - todayCounts.reviewCount)
                  .clamp(0, 999);

          // Parallel: due + new card queries are independent.
          final cardResults = await Future.wait([
            PerfTrace.timeAsync(
                'deck.fetchDue',
                () => _wordRepo.fetchDueCards(
                    targetLang, level, remainingReviews)),
            PerfTrace.timeAsync('deck.fetchNew',
                () => _wordRepo.fetchNewCards(targetLang, level, remainingNew)),
          ]);
          final dueWords = cardResults[0]!;
          final newWords = cardResults[1]!;

          allWords = [...dueWords, ...newWords];

          final missing = AppConstants.cardsPerDeck - allWords.length;
          if (missing > 0) {
            final fillers = await _wordRepo.fetchWordsByIsSeen(
                targetLang, level, 0, missing);
            allWords.addAll(fillers);
          }
          // Build CardModel list with mother-language translations (batch)
          final motherWordIds = allWords.map((Word w) => w.id).toList();
          final motherWords = await PerfTrace.timeAsync('deck.fetchTranslations',
              () => _wordRepo.fetchWordsByIds(motherLang, motherWordIds));
          final motherMap = <int, String>{};
          for (final mw in motherWords) {
            motherMap[mw.id] = mw.word;
          }

          allCards = allWords
              .map((Word w) => CardModel(
                    w.id, w.word, w.sentence,
                    motherMap[w.id] ?? '',
                    '',
                    w.level,
                    targetLang,
                    sourceLanguageCode: motherLang,
                    targetLanguageCode: targetLang,
                  ))
              .toList();
        }

        allCards.shuffle(Random());
        final selected = allCards.take(AppConstants.cardsPerDeck).toList();

        if (selected.isNotEmpty) {
          final idsByLanguage = <String, List<int>>{};
          for (final card in selected) {
            idsByLanguage.putIfAbsent(card.targetLanguageCode, () => [])
                .add(card.id);
          }
          await Future.wait(idsByLanguage.entries.map((entry) =>
              PerfTrace.timeAsync('deck.markSeen', () =>
                  _wordRepo.markMultipleAsSeen(entry.key, entry.value,
                      formatDate(DateTime.now())))));
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
            isLoading: false, errorMessage: 'Failed to load deck: $e');
      }
    }); // end deck.load trace
  }

  Future<void> reviewCard(Rating rating) async {
    if (state.isEmpty || !state.isFlipped || state.isReviewing) return;
    state = state.copyWith(isReviewing: true);
    final card = state.currentCard;
    final reviewIndex = state.currentIndex;

    // Use the card's own languageCode so fav cards target 'fav'
    // instead of state.targetLang.
    final lang = card.languageCode;

    try {
      final word = await _wordRepo.fetchWordById(lang, card.id);
      if (word == null) {
        state = state.copyWith(isReviewing: false);
        return;
      }

      final fsrsCard = _fsrs.cardFromDb(
        cardId: word.id,
        cardStateValue: word.cardState,
        stability: word.stability,
        difficulty: word.difficulty,
        elapsedDays: word.elapsedDays,
        lastReview: word.lastReview,
        due: word.due,
      );

      // Fetch the deck config for this card's level so FSRS parameters
      // (retention, fuzz, learning steps, w) take immediate effect.
      final deckConfig = await _wordRepo.getDeckConfig(word.level);

      final result = _fsrs.reviewWithConfig(
        card: fsrsCard,
        rating: rating,
        requestRetention: (deckConfig['requestRetention'] as num?)?.toDouble(),
        enableFuzz: deckConfig['enableFuzz'] as bool?,
        learningStepsJson: deckConfig['learningSteps'] as String?,
        wJson: deckConfig['w'] as String?,
      );

      final legacyFeedback =
          rating == Rating.again ? 1 : rating == Rating.hard ? 3 : 2;

      // Use transactional review with optimistic guard against double-writes.
      // The guard checks that last_review still matches the value we read
      // before computing FSRS — if it changed, another review already landed.
      var saved = false;
      await PerfTrace.timeAsync('deck.review', () async {
        saved = await _wordRepo.reviewWord(
          wordId: card.id,
          deckTable: lang,
          rating: rating.value,
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
          reviewDate: result.lastReview,
          guardLastReview: word.lastReview,
        );
      }); // end deck.review trace

      // Guard rejected the write — another tap already landed for this card.
      if (!saved) {
        state = state.copyWith(isReviewing: false);
        return;
      }

      // Navigation must not be able to move the result to another card while
      // the database transaction is in flight. Keep this guard as a second
      // line of defense for non-UI callers.
      if (state.currentIndex != reviewIndex ||
          state.cards.length <= reviewIndex ||
          state.cards[reviewIndex].id != card.id ||
          state.cards[reviewIndex].languageCode != lang) {
        state = state.copyWith(isReviewing: false);
        return;
      }

      final color = _colorForRating(rating);
      final newColors = List<Color>.from(state.colorTracker)
        ..[reviewIndex] = color;
      final newAnalysis = List<AnalysisResult>.from(state.analysisResults)
        ..add(AnalysisResult(
            word: card.frontText, meaning: card.backText, color: color));

      state = state.copyWith(
          colorTracker: newColors,
          analysisResults: newAnalysis,
          lastRating: rating,
          isReviewing: false);
    } catch (e) {
      if (kDebugMode) print('DeckNotifier.reviewCard error: $e');
      state = state.copyWith(isReviewing: false);
    }
  }

  Color _colorForRating(Rating rating) => switch (rating) {
        Rating.again => AppTheme.ratingAgain,
        Rating.hard => AppTheme.ratingHard,
        Rating.good => AppTheme.ratingGood,
        Rating.easy => AppTheme.ratingEasy,
      };

  Future<void> flipCard(Color color) async {
    if (state.isEmpty || state.isFlipped || state.isReviewing) return;
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
    final newColors = List<Color>.from(state.colorTracker)
      ..[state.currentIndex] = color;
    state = state.copyWith(isFlipped: true, colorTracker: newColors);
    await reviewCard(rating);
  }

  void reflipCard() {
    if (!state.isFlipped || state.isReviewing) return;
    final newColors = List<Color>.from(state.colorTracker)
      ..[state.currentIndex] = AppTheme.cardDefault;
    state = state.copyWith(
        isFlipped: false,
        colorTracker: newColors,
        analysisResults: state.analysisResults
            .where((r) => r.word != state.currentCard.frontText)
            .toList());
  }

  Future<void> nextCard() async {
    if (state.isLastCard || state.isReviewing) return;
    state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        isFlipped: false,
        isFavorite: false,
        lastRating: null);
    final fav = await _wordRepo.isFavorite(state.currentCard.frontText);
    state = state.copyWith(isFavorite: fav);
  }

  void startNewDeck() => state = DeckState(
        isLoading: true,
        deckIndex: state.deckIndex + 1,
        colorTracker:
            List.generate(AppConstants.cardsPerDeck, (_) => AppTheme.cardDefault),
      );

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
    }
  }
}

final deckProvider =
    StateNotifierProvider.autoDispose<DeckNotifier, DeckState>((ref) {
  final wordRepo = ref.read(wordRepositoryProvider);
  final userRepo = ref.read(userRepositoryProvider);
  final deckRepo = ref.read(deckRepositoryProvider);
  final fsrs = ref.read(fsrsServiceProvider);
  return DeckNotifier(wordRepo, userRepo, deckRepo, fsrs);
});
