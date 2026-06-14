import 'package:flutter/foundation.dart';
import 'package:poly2/data/database/database.dart';
import 'package:poly2/core/constants/language_codes.dart';

/// Repository for user preferences (language choices, first-time flag).
class UserRepository {
  final AppDatabase _db;

  UserRepository(this._db);

  Future<Map<String, String>?> getUserChoices() async {
    try {
      final raw = await _db.getUserChoices();
      if (raw == null) return null;
      return {
        'mainLanguage': LanguageCodes.displayCodeFor(raw['mainLanguage'] ?? 'en'),
        'targetLanguage':
            LanguageCodes.displayCodeFor(raw['targetLanguage'] ?? 'tr'),
        'firstTime': raw['firstTime'] ?? 'true',
      };
    } catch (e) {
      if (kDebugMode) print('UserRepository.getUserChoices error: $e');
      return null;
    }
  }

  Future<void> saveUserChoices(
      String mainLanguage, String targetLanguage) async {
    await _db.saveUserChoices(
      LanguageCodes.tableNameFor(mainLanguage),
      LanguageCodes.tableNameFor(targetLanguage),
    );
  }
}
