import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:poly2/data/database/database.dart';
import 'package:poly2/core/performance/perf_trace.dart';

/// Repository for progress tracking (weekly/monthly charts).
class ProgressRepository {
  final AppDatabase _db;
  ProgressRepository(this._db);

  Future<String?> getEarliestDate(String language) async {
    try {
      return await _db.getEarliestDate(language);
    } catch (e) {
      if (kDebugMode) print('ProgressRepository.getEarliestDate error: $e');
      return null;
    }
  }

  /// Fetches daily word counts for [language], optionally restricted to a
  /// date range. When [dateStart] is provided, only dates >= that value are
  /// returned. Uses the idx_words_progress_date index.
  Future<Map<String, int>> fetchDateCounts(
    String language, {
    String? dateStart,
  }) async {
    try {
      String sql =
          'SELECT date, COUNT(*) as count FROM words '
          'WHERE language_code = ? AND date IS NOT NULL '
          'AND date != "" AND date != "0"';
      final vars = <Variable>[Variable.withString(language)];
      if (dateStart != null) {
        sql += ' AND date >= ?';
        vars.add(Variable.withString(dateStart));
      }
      sql += ' GROUP BY date ORDER BY date ASC';

      final rows = await PerfTrace.timeAsync(
        'progress.weekly',
        () => _db.customSelect(sql, variables: vars).get(),
      );
      final combined = <String, int>{};
      for (final row in rows) {
        final date = row.read<String>('date');
        final count = row.read<int>('count');
        combined[date] = (combined[date] ?? 0) + count;
      }
      return combined;
    } catch (e) {
      if (kDebugMode) print('ProgressRepository.fetchDateCounts error: $e');
      return {};
    }
  }

  /// Fetches word counts for 4 consecutive months starting at [startDate].
  /// Uses one indexed date-range scan and groups the result in Dart.
  Future<List<int>> fetchMonthlyCounts(
    DateTime startDate,
    String language,
  ) async {
    try {
      final counts = <int>[0, 0, 0, 0];
      await PerfTrace.timeAsync('progress.monthly', () async {
        final rangeStart = _monthKey(startDate);
        final rangeEnd = _monthKey(
          DateTime(startDate.year, startDate.month + 4),
        );
        final rows = await _db
            .customSelect(
              'SELECT substr(date, 1, 7) AS month_key, COUNT(*) AS count '
              'FROM words '
              'WHERE language_code = ? '
              'AND date IS NOT NULL AND date != ? AND date != ? '
              'AND date >= ? AND date < ? '
              'GROUP BY substr(date, 1, 7)',
              variables: [
                Variable.withString(language),
                Variable.withString(''),
                Variable.withString('0'),
                Variable.withString('$rangeStart-01'),
                Variable.withString('$rangeEnd-01'),
              ],
            )
            .get();
        for (final row in rows) {
          final monthKey = row.read<String>('month_key');
          if (monthKey.length < 7) continue;
          final year = int.tryParse(monthKey.substring(0, 4));
          final month = int.tryParse(monthKey.substring(5, 7));
          if (year == null || month == null) continue;
          final index = (year - startDate.year) * 12 + month - startDate.month;
          if (index >= 0 && index < counts.length) {
            counts[index] = row.read<int>('count');
          }
        }
      }); // end progress.monthly trace
      return counts;
    } catch (e) {
      if (kDebugMode) print('ProgressRepository.fetchMonthlyCounts error: $e');
      return [0, 0, 0, 0];
    }
  }

  String _monthKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  Future<void> resetAllData() => _db.resetAllProgress();
}
