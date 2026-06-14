import 'package:flutter/foundation.dart';
import 'package:poly2/services/database_helper.dart';
import 'package:poly2/domain/models/word.dart';
import 'package:poly2/domain/models/revlog_entry.dart';
import 'package:poly2/domain/models/deck_config.dart';
import 'package:poly2/core/utils/date_utils.dart';

/// Repository for word-related data operations including FSRS scheduling.
class WordRepository {
  final DBHelper _dbHelper;

  WordRepository([DBHelper? dbHelper])
      : _dbHelper = dbHelper ?? DBHelper.instance;

  // ── Basic word queries ──

  Future<Word?> fetchWordById(String tableName, int id) async {
    return _dbHelper.fetchWordById(tableName, id);
  }

  Future<List<Map<String, dynamic>>> fetchWordsByFeedback(
    String tableName,
    String? level,
    int feedback,
    int limit,
  ) async {
    return _dbHelper.fetchWordsByFeedback(tableName, level, feedback, limit);
  }

  Future<List<Map<String, dynamic>>> fetchWordsByIsSeen(
    String tableName,
    String? level,
    int isSeen,
    int limit,
  ) async {
    return _dbHelper.fetchWordsByIsSeen(tableName, level, isSeen, limit);
  }

  Future<void> updateFeedback(String tableName, int id, int feedback) async {
    try {
      await _dbHelper.updateFeedback(tableName, id, feedback);
    } catch (e) {
      if (kDebugMode) print('WordRepository.updateFeedback error: $e');
    }
  }

  Future<void> markAsSeen(String tableName, int id) async {
    try {
      await _dbHelper.updateIsSeenDate(tableName, id);
    } catch (e) {
      if (kDebugMode) print('WordRepository.markAsSeen error: $e');
    }
  }

  // ── Exam queries ──

  Future<List<Map<String, dynamic>>> fetchExamWords(
    String tableName,
    int id,
  ) async {
    return _dbHelper.fetchExamWords(tableName, id);
  }

  Future<List<Map<String, dynamic>>> fetchExamOptions(
      String tableName) async {
    return _dbHelper.fetchExamOptions(tableName);
  }

  // ── Favorites ──

  Future<void> addToFavorites({
    required String word,
    required String sentence,
    required String level,
    String? backWord,
    String? backSentence,
  }) async {
    await _dbHelper.addToFavorites(
        word, sentence, level, backWord, backSentence);
  }

  Future<void> removeFromFavorites(String word) async {
    await _dbHelper.removeFromFavorites(word);
  }

  Future<bool> isFavorite(String word) async {
    return _dbHelper.isFavorite(word);
  }

  Future<List<Map<String, dynamic>>> fetchAllFavorites() async {
    return _dbHelper.fetchAllFavWords();
  }

  // ── FSRS scheduling methods ──

  /// Fetches cards due for review today (or earlier) for a given level.
  Future<List<Map<String, dynamic>>> fetchDueCards(
    String tableName,
    String? level,
    int limit,
  ) async {
    final today = formatDate(DateTime.now());
    return _dbHelper.fetchDueCards(tableName, level, today, limit);
  }

  /// Fetches new (never-reviewed) cards for a given level.
  Future<List<Map<String, dynamic>>> fetchNewCards(
    String tableName,
    String? level,
    int limit,
  ) async {
    return _dbHelper.fetchNewCards(tableName, level, limit);
  }

  /// Updates the full FSRS scheduling state for a card after review.
  Future<void> updateSrsState(
    String tableName,
    int id, {
    required int cardState,
    required double stability,
    required double difficulty,
    String? due,
    required int elapsedDays,
    required int scheduledDays,
    required int reps,
    required int lapses,
    String? lastReview,
  }) async {
    await _dbHelper.updateSrsState(
      tableName,
      id,
      cardState: cardState,
      stability: stability,
      difficulty: difficulty,
      due: due,
      elapsedDays: elapsedDays,
      scheduledDays: scheduledDays,
      reps: reps,
      lapses: lapses,
      lastReview: lastReview,
    );
  }

  /// Records a review in the revlog table.
  Future<void> insertRevlog(RevlogEntry entry) async {
    await _dbHelper.insertRevlog(entry);
  }

  /// Returns today's review count for a level.
  Future<int> getTodayReviewCount(String tableName, String? level) async {
    return _dbHelper.getTodayReviewCount(tableName, level);
  }

  /// Returns today's new card count for a level.
  Future<int> getTodayNewCardCount(String tableName, String? level) async {
    return _dbHelper.getTodayNewCardCount(tableName, level);
  }

  /// Loads deck configuration from the database.
  Future<DeckConfig> getDeckConfig(String level) async {
    final config = await _dbHelper.getDeckConfig(level);
    return config ?? DeckConfig.defaults().copyWithLevel(level);
  }

  /// Saves deck configuration to the database.
  Future<void> saveDeckConfig(DeckConfig config) async {
    await _dbHelper.saveDeckConfig(config);
  }

  /// Resets FSRS scheduling state for a given table (all cards become New).
  Future<void> resetSrsState(String tableName) async {
    await _dbHelper.resetSrsState(tableName);
  }
}
