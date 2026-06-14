import 'package:flutter/foundation.dart';
import 'package:poly2/services/database_helper.dart';
import 'package:poly2/core/constants/language_codes.dart';

/// Repository for user preferences (language choices, first-time flag).
class UserRepository {
  final DBHelper _dbHelper;

  UserRepository([DBHelper? dbHelper]) : _dbHelper = dbHelper ?? DBHelper.instance;

  /// Loads the user's language choices, converting legacy table names
  /// to proper display codes.
  Future<Map<String, String>?> getUserChoices() async {
    try {
      final raw = await _dbHelper.getUserChoices('user');
      if (raw == null) return null;

      return {
        'mainLanguage': LanguageCodes.displayCodeFor(raw['mainLanguage'] ?? 'en'),
        'targetLanguage': LanguageCodes.displayCodeFor(
            raw['targetLanguage'] ?? 'tr'),
        'firstTime': raw['firstTime'] ?? 'true',
      };
    } catch (e) {
      if (kDebugMode) print('UserRepository.getUserChoices error: $e');
      return null;
    }
  }

  /// Saves the user's language choices, converting display codes
  /// to database table names.
  Future<void> saveUserChoices(String mainLanguage, String targetLanguage) async {
    await _dbHelper.saveUserChoices(
      'user',
      LanguageCodes.tableNameFor(mainLanguage),
      LanguageCodes.tableNameFor(targetLanguage),
    );
  }
}
