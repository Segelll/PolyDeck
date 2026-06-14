import 'package:flutter/foundation.dart';
import 'package:poly2/data/database/database.dart';
import 'package:poly2/core/utils/date_utils.dart';

/// Repository for word-related data operations using Drift.
class WordRepository {
  final AppDatabase _db;

  WordRepository(this._db);

  Future<Word?> fetchWordById(int id) => _db.fetchWordById(id);

  Future<List<Word>> fetchWordsByIds(String language, List<int> ids) =>
      _db.fetchWordsByIds(language, ids);

  Future<List<Word>> fetchWordsByFeedback(
          String language, String? level, int feedback, int limit) =>
      _db.fetchWordsByFeedback(language, level, feedback, limit);

  Future<List<Word>> fetchWordsByIsSeen(
          String language, String? level, int isSeen, int limit) =>
      _db.fetchWordsByIsSeen(language, level, isSeen, limit);

  Future<void> markAsSeen(int id) async {
    try {
      await _db.markAsSeen(id, formatDate(DateTime.now()));
    } catch (e) {
      if (kDebugMode) print('WordRepository.markAsSeen error: $e');
    }
  }

  Future<void> markMultipleAsSeen(List<int> ids, String date) =>
      _db.markMultipleAsSeen(ids, date);

  Future<List<Word>> fetchExamWords(String language, int id) =>
      _db.fetchExamWords(language, id);

  Future<List<Word>> fetchExamOptions(String language, List<int> randomIds) =>
      _db.fetchExamOptions(language, randomIds);

  // ── Favorites ──

  Future<void> addToFavorites({
    required String word,
    required String sentence,
    required String level,
    String? backWord,
    String? backSentence,
  }) => _db.addToFav(
        word: word,
        sentence: sentence,
        level: level,
        backWord: backWord,
        backSentence: backSentence,
      );

  Future<void> removeFromFavorites(String word) => _db.removeFromFav(word);

  Future<bool> isFavorite(String word) => _db.isFavorite(word);

  Future<List<Word>> fetchAllFavorites() => _db.fetchAllFavorites();

  // ── FSRS ──

  Future<List<Word>> fetchDueCards(
          String language, String? level, int limit) async =>
      _db.fetchDueCards(language, level, formatDate(DateTime.now()), limit);

  Future<List<Word>> fetchNewCards(String language, String? level, int limit) =>
      _db.fetchNewCards(language, level, limit);

  Future<void> updateSrsState(int id,
          {required int cardState,
          required double stability,
          required double difficulty,
          String? due,
          required int elapsedDays,
          required int scheduledDays,
          required int reps,
          required int lapses,
          String? lastReview,
          int? legacyFeedback}) =>
      _db.updateSrsState(id,
          cardState: cardState,
          stability: stability,
          difficulty: difficulty,
          due: due,
          elapsedDays: elapsedDays,
          scheduledDays: scheduledDays,
          reps: reps,
          lapses: lapses,
          lastReview: lastReview,
          legacyFeedback: legacyFeedback);

  Future<void> insertRevlog({
    required int cardId,
    required String deckTable,
    required int rating,
    required int state,
    required String due,
    required double stability,
    required double difficulty,
    required int elapsedDays,
    required int lastElapsedDays,
    required int scheduledDays,
    required String reviewDate,
  }) => _db.insertRevlogEntry(
        cardId: cardId,
        deckTable: deckTable,
        rating: rating,
        state: state,
        due: due,
        stability: stability,
        difficulty: difficulty,
        elapsedDays: elapsedDays,
        lastElapsedDays: lastElapsedDays,
        scheduledDays: scheduledDays,
        reviewDate: reviewDate,
      );

  Future<({int newCount, int reviewCount})> getTodayCounts(
          String language, String? level) =>
      _db.getTodayCounts(language, level);

  Future<int> getTodayReviewCount(String language, String? level) async {
    final c = await _db.getTodayCounts(language, level);
    return c.reviewCount;
  }

  Future<int> getTodayNewCardCount(String language, String? level) async {
    final c = await _db.getTodayCounts(language, level);
    return c.newCount;
  }

  Future<Map<String, dynamic>> getDeckConfig(String level) async {
    final c = await _db.getDeckConfig(level);
    return c != null
        ? {
            'level': c.level,
            'maxNewPerDay': c.maxNewPerDay,
            'maxReviewsPerDay': c.maxReviewsPerDay,
            'learningSteps': c.learningSteps,
            'enableFuzz': c.enableFuzz == 1,
            'requestRetention': c.requestRetention,
            'w': c.w,
          }
        : {
            'level': level,
            'maxNewPerDay': 10,
            'maxReviewsPerDay': 20,
            'learningSteps': '[1,10]',
            'enableFuzz': true,
            'requestRetention': 0.9,
          };
  }

  Future<void> saveDeckConfig({
    required String level,
    required int maxNewPerDay,
    required int maxReviewsPerDay,
    required String learningSteps,
    required bool enableFuzz,
    required double requestRetention,
    String? w,
  }) => _db.saveDeckConfigEntry(
        level: level,
        maxNewPerDay: maxNewPerDay,
        maxReviewsPerDay: maxReviewsPerDay,
        learningSteps: learningSteps,
        enableFuzz: enableFuzz,
        requestRetention: requestRetention,
        w: w,
      );

  Future<void> resetSrsState(String language) => _db.resetSrsState(language);
}
