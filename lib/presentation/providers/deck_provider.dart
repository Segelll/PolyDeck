import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/data/repositories/word_repository.dart';
import 'package:poly2/data/repositories/user_repository.dart';
import 'package:poly2/models/card_model.dart';
import 'package:poly2/models/analysis_result.dart';
import 'package:poly2/domain/models/word.dart';
import 'package:poly2/core/constants/language_codes.dart';

/// Provides the [WordRepository] instance.
final wordRepositoryProvider = Provider<WordRepository>((ref) {
  return WordRepository();
});

/// The state of a single card flip session.
class DeckState {
  final List<CardModel> cards;
  final int currentIndex;
  final bool isFlipped;
  final bool isLoading;
  final List<Color> colorTracker;
  final List<AnalysisResult> analysisResults;
  final int deckIndex;
  final String? targetLang;
  final String? motherLang;
  final bool isFavorite;
  final String? errorMessage;

  const DeckState({
    this.cards = const [],
    this.currentIndex = 0,
    this.isFlipped = false,
    this.isLoading = true,
    this.colorTracker = const [],
    this.analysisResults = const [],
    this.deckIndex = 1,
    this.targetLang,
    this.motherLang,
    this.isFavorite = false,
    this.errorMessage,
  });

  DeckState copyWith({
    List<CardModel>? cards,
    int? currentIndex,
    bool? isFlipped,
    bool? isLoading,
    List<Color>? colorTracker,
    List<AnalysisResult>? analysisResults,
    int? deckIndex,
    String? targetLang,
    String? motherLang,
    bool? isFavorite,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DeckState(
      cards: cards ?? this.cards,
      currentIndex: currentIndex ?? this.currentIndex,
      isFlipped: isFlipped ?? this.isFlipped,
      isLoading: isLoading ?? this.isLoading,
      colorTracker: colorTracker ?? this.colorTracker,
      analysisResults: analysisResults ?? this.analysisResults,
      deckIndex: deckIndex ?? this.deckIndex,
      targetLang: targetLang ?? this.targetLang,
      motherLang: motherLang ?? this.motherLang,
      isFavorite: isFavorite ?? this.isFavorite,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  CardModel get currentCard => cards[currentIndex];
  bool get isLastCard => currentIndex >= cards.length - 1;
  bool get isEmpty => cards.isEmpty;
}

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
        while (randomIndices.length < 10 && randomIndices.length < favWords.length) {
          randomIndices.add(random.nextInt(favWords.length));
        }
        for (final index in randomIndices) {
          allWords.add(favWords[index]);
        }
      } else {
        final feedback1Words = await _wordRepo.fetchWordsByFeedback(
          targetLang, level, 1, 4,
        );
        final feedback2Words = await _wordRepo.fetchWordsByFeedback(
          targetLang, level, 2, 1,
        );
        allWords = [...feedback1Words, ...feedback2Words];

        final missingCards = 10 - allWords.length;
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
      final selected = allCards.take(10).toList();

      // Mark all selected cards as seen
      for (final card in selected) {
        await _wordRepo.markAsSeen(targetLang, card.id);
      }

      state = state.copyWith(
        cards: selected,
        currentIndex: 0,
        isFlipped: false,
        isLoading: false,
        colorTracker: List.generate(selected.length, (_) => Colors.grey),
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

    // Map color to feedback value
    int feedback;
    if (color == Colors.red || color == Colors.red.shade200) {
      feedback = 1;
    } else if (color == Colors.green || color == Colors.green.shade200) {
      feedback = 2;
    } else {
      feedback = 3;
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
    newColorTracker[state.currentIndex] = Colors.grey;

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
      colorTracker: List.generate(10, (_) => Colors.grey),
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
