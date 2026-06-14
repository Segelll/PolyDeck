import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/data/repositories/word_repository.dart';
import 'package:poly2/data/repositories/user_repository.dart';
import 'package:poly2/domain/models/card_model.dart';
import 'package:poly2/domain/models/analysis_result.dart';
import 'package:poly2/domain/enums/feedback_type.dart';
import 'package:poly2/domain/state/deck_state.dart';
import 'package:poly2/core/constants/app_constants.dart';
import 'package:poly2/core/constants/language_codes.dart';
import 'package:poly2/core/theme/app_theme.dart';

/// Provides the [WordRepository] instance.
final wordRepositoryProvider = Provider<WordRepository>((ref) {
  return WordRepository();
});

/// Manages the deck-based flashcard session.
class DeckNotifier extends StateNotifier<DeckState> {
  final WordRepository _wordRepo;
  final UserRepository _userRepo;

  DeckNotifier(this._wordRepo, this._userRepo) : super(const DeckState());

  Future<void> loadDeck(String level) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Load user language preferences
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
        final hardWords = await _wordRepo.fetchWordsByFeedback(
          targetLang, level, FeedbackType.hard.value, 4,
        );
        final easyWords = await _wordRepo.fetchWordsByFeedback(
          targetLang, level, FeedbackType.easy.value, 1,
        );
        allWords = [...hardWords, ...easyWords];

        final missingCards = AppConstants.cardsPerDeck - allWords.length;
        if (missingCards > 0) {
          final additionalWords = await _wordRepo.fetchWordsByIsSeen(
            targetLang, level, 0, missingCards,
          );
          allWords.addAll(additionalWords);
        }
      }

      // Build CardModel list with translations
      final List<CardModel> allCards = [];
      for (final word in allWords) {
        final wordId = word['id'] as int;
        final translation = await _wordRepo.fetchWordById(motherLang, wordId);

        if (translation != null) {
          allCards.add(CardModel(
            word['id'] as int,
            word['word'] as String,
            word['sentence'] as String,
            word['level'] == 'fav'
                ? (word['backword'] as String? ?? '')
                : translation.word,
            word['level'] == 'fav'
                ? (word['backsentence'] as String? ?? '')
                : translation.sentence,
            word['level'] as String,
          ));
        }
      }

      allCards.shuffle(Random());
      final selected = allCards.take(AppConstants.cardsPerDeck).toList();

      // Mark all selected cards as seen
      for (final card in selected) {
        await _wordRepo.markAsSeen(targetLang, card.id);
      }

      state = state.copyWith(
        cards: selected,
        currentIndex: 0,
        isFlipped: false,
        isLoading: false,
        colorTracker: List.generate(selected.length, (_) => AppTheme.cardDefault),
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

  Future<void> flipCard(Color color) async {
    if (state.isEmpty || state.isFlipped) return;

    final currentCard = state.currentCard;

    // Map color to feedback value using the FeedbackType enum
    final int feedback;
    if (color == AppTheme.cardRed || color == Colors.red.shade200) {
      feedback = FeedbackType.hard.value;
    } else if (color == AppTheme.cardGreen || color == Colors.green.shade200) {
      feedback = FeedbackType.easy.value;
    } else {
      feedback = FeedbackType.medium.value;
    }

    // Persist feedback
    if (state.targetLang != null) {
      await _wordRepo.updateFeedback(state.targetLang!, currentCard.id, feedback);
    }

    final newColorTracker = List<Color>.from(state.colorTracker);
    newColorTracker[state.currentIndex] = color;

    final newAnalysis = List<AnalysisResult>.from(state.analysisResults)
      ..add(AnalysisResult(
        word: currentCard.frontText,
        meaning: currentCard.backText,
        color: color,
      ));

    state = state.copyWith(
      isFlipped: true,
      colorTracker: newColorTracker,
      analysisResults: newAnalysis,
    );
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
    );

    // Check if the new card is a favorite
    final fav = await _wordRepo.isFavorite(state.currentCard.frontText);
    state = state.copyWith(isFavorite: fav);
  }

  void startNewDeck() {
    state = DeckState(
      isLoading: true,
      deckIndex: state.deckIndex + 1,
      colorTracker: List.generate(AppConstants.cardsPerDeck, (_) => AppTheme.cardDefault),
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
  return DeckNotifier(wordRepo, userRepo);
});
