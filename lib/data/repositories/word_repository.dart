import 'package:flutter/foundation.dart';
import 'package:poly2/services/database_helper.dart';
import 'package:poly2/domain/models/word.dart';
import 'package:poly2/models/card_model.dart';

/// Repository for word-related data operations.
///
/// Wraps [DBHelper] to provide a clean API for the presentation layer.
class WordRepository {
  final DBHelper _dbHelper;

  WordRepository([DBHelper? dbHelper]) : _dbHelper = dbHelper ?? DBHelper.instance;

  /// Fetches a word by its ID from the given language table.
  Future<Word?> fetchWordById(String tableName, int id) async {
    return _dbHelper.fetchWordById(tableName, id);
  }

  /// Fetches words matching a specific feedback value.
  Future<List<Map<String, dynamic>>> fetchWordsByFeedback(
    String tableName,
    String? level,
    int feedback,
    int limit,
  ) async {
    return _dbHelper.fetchWordsByFeedback(tableName, level, feedback, limit);
  }

  /// Fetches unseen words.
  Future<List<Map<String, dynamic>>> fetchWordsByIsSeen(
    String tableName,
    String? level,
    int isSeen,
    int limit,
  ) async {
    return _dbHelper.fetchWordsByIsSeen(tableName, level, isSeen, limit);
  }

  /// Updates the feedback for a word.
  Future<void> updateFeedback(String tableName, int id, int feedback) async {
    try {
      await _dbHelper.updateFeedback(tableName, id, feedback);
    } catch (e) {
      if (kDebugMode) print('WordRepository.updateFeedback error: $e');
    }
  }

  /// Marks a word as seen with today's date.
  Future<void> markAsSeen(String tableName, int id) async {
    try {
      await _dbHelper.updateIsSeenDate(tableName, id);
    } catch (e) {
      if (kDebugMode) print('WordRepository.markAsSeen error: $e');
    }
  }

  /// Fetches exam words for a given language and ID.
  Future<List<Map<String, dynamic>>> fetchExamWords(
    String tableName,
    int id,
  ) async {
    return _dbHelper.fetchExamWords(tableName, id);
  }

  /// Fetches random distractor options for exam questions.
  Future<List<Map<String, dynamic>>> fetchExamOptions(String tableName) async {
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
    await _dbHelper.addToFavorites(word, sentence, level, backWord, backSentence);
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
}
