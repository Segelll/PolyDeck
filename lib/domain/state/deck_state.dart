import 'package:flutter/material.dart';
import 'package:poly2/domain/models/card_model.dart';
import 'package:poly2/domain/models/analysis_result.dart';

/// Immutable state for a single card flip (deck) session.
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
  final int? lastRating;

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
    this.lastRating,
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
    int? lastRating,
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
      lastRating: lastRating ?? this.lastRating,
    );
  }

  CardModel get currentCard => cards[currentIndex];
  bool get isLastCard => currentIndex >= cards.length - 1;
  bool get isEmpty => cards.isEmpty;
}
