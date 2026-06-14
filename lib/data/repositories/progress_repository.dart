import 'package:flutter/foundation.dart';
import 'package:poly2/services/database_helper.dart';
import 'package:poly2/core/constants/app_constants.dart';

/// Repository for progress tracking data (weekly/monthly charts).
class ProgressRepository {
  final DBHelper _dbHelper;

  ProgressRepository([DBHelper? dbHelper]) : _dbHelper = dbHelper ?? DBHelper.instance;

  final List<String> languageTables = AppConstants.languageTables;

  /// Gets the earliest seen date across all language tables.
  Future<String?> getEarliestDate() async {
    try {
      String? earliestDate;
      for (final table in languageTables) {
        final tableEarliestDate = await _dbHelper.getEarliestDate(table);
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

  /// Fetches daily word counts grouped by date across all language tables.
  Future<Map<String, int>> fetchDateCounts() async {
    try {
      final db = await _dbHelper.database;
      final Map<String, int> combinedCounts = {};

      for (final table in languageTables) {
        final result = await db.rawQuery(
          'SELECT date, COUNT(*) as count FROM $table '
          'WHERE date IS NOT NULL AND date != "0" '
          'GROUP BY date ORDER BY date ASC',
        );
        for (final row in result) {
          final date = row['date'] as String;
          final count = row['count'] as int;
          combinedCounts[date] = (combinedCounts[date] ?? 0) + count;
        }
      }

      return combinedCounts;
    } catch (e) {
      if (kDebugMode) print('ProgressRepository.fetchDateCounts error: $e');
      return {};
    }
  }

  /// Fetches monthly word counts for the next 4 months from [startDate].
  Future<List<int>> fetchMonthlyCounts(DateTime startDate) async {
    try {
      final db = await _dbHelper.database;
      final List<int> monthlyCounts = [];

      for (int i = 0; i < 4; i++) {
        final currentDate = DateTime(startDate.year, startDate.month + i);
        final nextMonth = DateTime(currentDate.year, currentDate.month + 1);

        int totalCount = 0;
        for (final table in languageTables) {
          final result = await db.rawQuery(
            'SELECT COUNT(*) as count FROM $table WHERE date BETWEEN ? AND ?',
            [
              '${currentDate.year}-${currentDate.month.toString().padLeft(2, "0")}-01',
              '${nextMonth.year}-${nextMonth.month.toString().padLeft(2, "0")}-01',
            ],
          );
          totalCount += result.first['count'] as int;
        }
        monthlyCounts.add(totalCount);
      }

      return monthlyCounts;
    } catch (e) {
      if (kDebugMode) print('ProgressRepository.fetchMonthlyCounts error: $e');
      return [0, 0, 0, 0];
    }
  }

  /// Resets all progress data across all language tables.
  Future<void> resetAllData() async {
    final db = await _dbHelper.database;
    for (final lang in languageTables) {
      await db.update(lang, {'isSeen': 0, 'date': '', 'feedback': 0});
    }
    await db.delete('fav');
  }
}
