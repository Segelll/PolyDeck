import 'package:flutter/foundation.dart';
import 'package:poly2/data/database/database.dart';
import 'package:poly2/core/utils/date_utils.dart';

/// Repository for word-related data operations using Drift.
class WordRepository {
  final AppDatabase _db;

  WordRepository(this._db);

  // ── Word queries ──

  Future<Map<String, dynamic>?> fetchWordById(
      String tableName, int id) async {
    return _db.fetchWordById(tableName, id);
  }

  Future<List<Map<String, dynamic>>> fetchWordsByIds(
      String tableName, List<int> ids) async {
    return _db.fetchWordsByIds(tableName, ids);
  }

  Future<List<Map<String, dynamic>>> fetchWordsByFeedback(
    String tableName, String? level, int feedback, int limit,
  ) async {
    return _db.fetchWordsByFeedback(tableName, level, feedback, limit);
  }

  Future<List<Map<String, dynamic>>> fetchWordsByIsSeen(
    String tableName, String? level, int isSeen, int limit,
  ) async {
    return _db.fetchWordsByIsSeen(tableName, level, isSeen, limit);
  }

  Future<void> markAsSeen(String tableName, int id) async {
    try {
      await _db.markAsSeen(tableName, id, formatDate(DateTime.now()));
    } catch (e) {
      if (kDebugMode) print('WordRepository.markAsSeen error: $e');
    }
  }

  Future<void> markMultipleAsSeen(
      String tableName, List<int> ids, String date) async {
    await _db.markMultipleAsSeen(tableName, ids, date);
  }

  // ── Exam queries ──

  Future<List<Map<String, dynamic>>> fetchExamWords(
      String tableName, int id) async {
    return _db.fetchExamWords(tableName, id);
  }

  Future<List<Map<String, dynamic>>> fetchExamOptions(
      String tableName, List<int> randomIds) async {
    return _db.fetchExamOptions(tableName, randomIds);
  }

  // ── Favorites ──

  Future<void> addToFavorites({
    required String word,
    required String sentence,
    required String level,
    String? backWord,
    String? backSentence,
  }) async {
    await _db.addToFav(
      word: word,
      sentence: sentence,
      level: level,
      backWord: backWord,
      backSentence: backSentence,
    );
  }

  Future<void> removeFromFavorites(String word) async {
    await _db.removeFromFav(word);
  }

  Future<bool> isFavorite(String word) async {
    return _db.isFavorite(word);
  }

  Future<List<Map<String, dynamic>>> fetchAllFavorites() async {
    final data = await _db.fetchAllFavorites();
    return data.map((f) => <String, dynamic>{
          'id': f.id,
          'word': f.word,
          'sentence': f.sentence,
          'level': f.level,
          'isSeen': f.isSeen,
          'feedback': f.feedback,
          'date': f.date,
          'backword': f.backword,
          'backsentence': f.backsentence,
          'card_state': f.cardState,
          'stability': f.stability,
          'difficulty': f.difficulty,
          'due': f.due,
          'elapsed_days': f.elapsedDays,
          'scheduled_days': f.scheduledDays,
          'reps': f.reps,
          'lapses': f.lapses,
          'last_review': f.lastReview,
        }).toList();
  }

  // ── FSRS methods ──

  Future<List<Map<String, dynamic>>> fetchDueCards(
    String tableName, String? level, int limit,
  ) async {
    final today = formatDate(DateTime.now());
    return _db.fetchDueCards(tableName, level, today, limit);
  }

  Future<List<Map<String, dynamic>>> fetchNewCards(
    String tableName, String? level, int limit,
  ) async {
    return _db.fetchNewCards(tableName, level, limit);
  }

  Future<void> updateSrsState(
    String tableName, int id, {
    required int cardState,
    required double stability,
    required double difficulty,
    String? due,
    required int elapsedDays,
    required int scheduledDays,
    required int reps,
    required int lapses,
    String? lastReview,
    int? legacyFeedback,
  }) async {
    await _db.updateSrsState(
      tableName, id,
      cardState: cardState, stability: stability, difficulty: difficulty,
      due: due, elapsedDays: elapsedDays, scheduledDays: scheduledDays,
      reps: reps, lapses: lapses, lastReview: lastReview,
      legacyFeedback: legacyFeedback,
    );
  }

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
  }) async {
    await _db.insertRevlogEntry(
      cardId: cardId, deckTable: deckTable, rating: rating, state: state,
      due: due, stability: stability, difficulty: difficulty,
      elapsedDays: elapsedDays, lastElapsedDays: lastElapsedDays,
      scheduledDays: scheduledDays, reviewDate: reviewDate,
    );
  }

  Future<({int newCount, int reviewCount})> getTodayCounts(
      String tableName, String? level) async {
    return _db.getTodayCounts(tableName, level);
  }

  Future<int> getTodayReviewCount(String tableName, String? level) async {
    final c = await _db.getTodayCounts(tableName, level);
    return c.reviewCount;
  }

  Future<int> getTodayNewCardCount(String tableName, String? level) async {
    final c = await _db.getTodayCounts(tableName, level);
    return c.newCount;
  }

  Future<Map<String, dynamic>> getDeckConfig(String level) async {
    final config = await _db.getDeckConfig(level);
    if (config != null) {
      return {
        'level': config.level, 'maxNewPerDay': config.maxNewPerDay,
        'maxReviewsPerDay': config.maxReviewsPerDay, 'learningSteps': config.learningSteps,
        'enableFuzz': config.enableFuzz == 1, 'requestRetention': config.requestRetention,
        'w': config.w,
      };
    }
    return {
      'level': level, 'maxNewPerDay': 10, 'maxReviewsPerDay': 20,
      'learningSteps': '[1,10]', 'enableFuzz': true, 'requestRetention': 0.9, 'w': null,
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
  }) async {
    await _db.saveDeckConfigEntry(
      level: level, maxNewPerDay: maxNewPerDay,
      maxReviewsPerDay: maxReviewsPerDay, learningSteps: learningSteps,
      enableFuzz: enableFuzz, requestRetention: requestRetention, w: w,
    );
  }

  Future<void> resetSrsState(String tableName) async {
    await _db.resetSrsState(tableName);
  }
}
