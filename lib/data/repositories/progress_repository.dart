import 'package:flutter/foundation.dart';
import 'package:poly2/data/database/database.dart';
import 'package:poly2/core/constants/app_constants.dart';

/// Repository for progress tracking data (weekly/monthly charts).
class ProgressRepository {
  final AppDatabase _db;

  ProgressRepository(this._db);

  final List<String> languageTables = AppConstants.languageTables;

  Future<String?> getEarliestDate() async {
    try {
      String? earliestDate;
      for (final table in languageTables) {
        final tableEarliestDate = await _db.getEarliestDate(table);
        if (tableEarliestDate != null) {
          final trimmed = tableEarliestDate.trim();
          if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(trimmed)) {
            final date = DateTime.parse(trimmed);
            if (earliestDate == null ||
                date.isBefore(DateTime.parse(earliestDate))) {
              earliestDate = trimmed;
            }
          }
        }
      }
      return earliestDate;
    } catch (e) {
      if (kDebugMode) print('ProgressRepository.getEarliestDate error: $e');
      return null;
    }
  }

  Future<Map<String, int>> fetchDateCounts() async {
    try {
      return await _db.fetchDateCounts(languageTables);
    } catch (e) {
      if (kDebugMode) print('ProgressRepository.fetchDateCounts error: $e');
      return {};
    }
  }

  Future<List<int>> fetchMonthlyCounts(DateTime startDate) async {
    try {
      return await _db.fetchMonthlyCounts(languageTables, startDate);
    } catch (e) {
      if (kDebugMode) print('ProgressRepository.fetchMonthlyCounts error: $e');
      return [0, 0, 0, 0];
    }
  }

  Future<void> resetAllData() async {
    await _db.resetAllProgress(languageTables);
  }
}
