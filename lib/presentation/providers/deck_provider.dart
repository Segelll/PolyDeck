import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/data/database/database.dart';
import 'package:poly2/data/repositories/word_repository.dart';
import 'package:poly2/data/repositories/user_repository.dart';
import 'package:poly2/domain/models/card_model.dart';
import 'package:poly2/domain/models/analysis_result.dart';
import 'package:poly2/domain/enums/rating.dart';
import 'package:poly2/domain/state/deck_state.dart';
import 'package:poly2/services/fsrs_service.dart';
import 'package:poly2/presentation/providers/database_provider.dart';
import 'package:poly2/core/constants/app_constants.dart';
import 'package:poly2/core/constants/language_codes.dart';
import 'package:poly2/core/theme/app_theme.dart';
import 'package:poly2/core/utils/date_utils.dart';

// ignore_for_file: lines_longer_than_80_chars

class DeckNotifier extends StateNotifier<DeckState> {
  final WordRepository _wordRepo;
  final UserRepository _userRepo;
  final FsrsService _fsrs;

  DeckNotifier(this._wordRepo, this._userRepo, this._fsrs)
      : super(const DeckState());

  Future<void> loadDeck(String level) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final userSettings = await _userRepo.getUserChoices();
      final targetLang =
          LanguageCodes.tableNameFor(userSettings?['targetLanguage'] ?? 'tr');
      final motherLang =
          LanguageCodes.tableNameFor(userSettings?['mainLanguage'] ?? 'en');

      List<Word> allWords;

      if (level == 'fav') {
        allWords = await _wordRepo.fetchAllFavorites();
        final random = Random();
        final picked = <Word>[];
        final indices = <int>{};
        while (indices.length < AppConstants.cardsPerDeck &&
            indices.length < allWords.length) {
          indices.add(random.nextInt(allWords.length));
        }
        picked.addAll(indices.map((i) => allWords[i]));
        allWords = picked;
      } else {
        final config = await _wordRepo.getDeckConfig(level);
        final todayCounts = await _wordRepo.getTodayCounts(targetLang, level);

        final remainingNew =
            ((config['maxNewPerDay'] as int) - todayCounts.newCount).clamp(0, 999);
        final remainingReviews =
            ((config['maxReviewsPerDay'] as int) - todayCounts.reviewCount)
                .clamp(0, 999);

        final dueWords =
            await _wordRepo.fetchDueCards(targetLang, level, remainingReviews);
        final newWords =
            await _wordRepo.fetchNewCards(targetLang, level, remainingNew);

        allWords = [...dueWords, ...newWords];

        final missing = AppConstants.cardsPerDeck - allWords.length;
        if (missing > 0) {
          final fillers =
              await _wordRepo.fetchWordsByIsSeen(targetLang, level, 0, missing);
          allWords.addAll(fillers);
        }
      }

      // Build CardModel list with mother-language translations (batch)
      final motherWordIds = allWords.map((Word w) => w.id).toList();
      final motherWords = await _wordRepo.fetchWordsByIds(motherLang, motherWordIds);
      final motherMap = <int, String>{};
      for (final mw in motherWords) {
        motherMap[mw.id] = mw.word;
      }

      final allCards = allWords.map((Word w) => CardModel(
            w.id, w.word, w.sentence,
            w.languageCode == 'fav' ? (w.backword ?? '') : (motherMap[w.id] ?? ''),
            w.languageCode == 'fav' ? (w.backsentence ?? '') : '',
            w.level,
          )).toList();

      allCards.shuffle(Random());
      final selected = allCards.take(AppConstants.cardsPerDeck).toList();

      if (selected.isNotEmpty) {
        await _wordRepo.markMultipleAsSeen(
            selected.map((c) => c.id).toList(), formatDate(DateTime.now()));
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
  }

  Future<void> reviewCard(Rating rating) async {
    if (state.isEmpty || !state.isFlipped) return;
    final card = state.currentCard;
    final language = state.targetLang;
    if (language == null) return;

    try {
      final word = await _wordRepo.fetchWordById(card.id);
      if (word == null) return;

      final fsrsCard = _fsrs.cardFromDb(
        cardId: word.id,
        cardStateValue: word.cardState,
        stability: word.stability,
        difficulty: word.difficulty,
        elapsedDays: word.elapsedDays,
        lastReview: word.lastReview,
        due: word.due,
      );

      final result = _fsrs.review(card: fsrsCard, rating: rating);

      final legacyFeedback =
          rating == Rating.again ? 1 : rating == Rating.hard ? 3 : 2;

      await _wordRepo.updateSrsState(card.id,
          cardState: result.cardState.value,
          stability: result.stability,
          difficulty: result.difficulty,
          due: result.due,
          elapsedDays: 0,
          scheduledDays: result.scheduledDays,
          reps: word.reps + 1,
          lapses: rating == Rating.again ? word.lapses + 1 : word.lapses,
          lastReview: result.lastReview,
          legacyFeedback: legacyFeedback);

      await _wordRepo.insertRevlog(
        cardId: card.id,
        deckTable: language,
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

      final color = _colorForRating(rating);
      final newColors = List<Color>.from(state.colorTracker)
        ..[state.currentIndex] = color;
      final newAnalysis = List<AnalysisResult>.from(state.analysisResults)
        ..add(AnalysisResult(
            word: card.frontText, meaning: card.backText, color: color));

      state = state.copyWith(
          colorTracker: newColors, analysisResults: newAnalysis, lastRating: rating);
    } catch (e) {
      if (kDebugMode) print('DeckNotifier.reviewCard error: $e');
    }
  }

  Color _colorForRating(Rating rating) => switch (rating) {
        Rating.again => AppTheme.ratingAgain,
        Rating.hard => AppTheme.ratingHard,
        Rating.good => AppTheme.ratingGood,
        Rating.easy => AppTheme.ratingEasy,
      };

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
    final newColors = List<Color>.from(state.colorTracker)
      ..[state.currentIndex] = color;
    state = state.copyWith(isFlipped: true, colorTracker: newColors);
    await reviewCard(rating);
  }

  void reflipCard() {
    if (!state.isFlipped) return;
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
    if (state.isLastCard) return;
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
  final fsrs = ref.read(fsrsServiceProvider);
  return DeckNotifier(wordRepo, userRepo, fsrs);
});
