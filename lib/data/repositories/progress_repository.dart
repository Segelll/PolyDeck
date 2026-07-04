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
  Future<Map<String, int>> fetchDateCounts(String language,
      {String? dateStart}) async {
    try {
      String sql = 'SELECT date, COUNT(*) as count FROM words '
          'WHERE language_code = ? AND date IS NOT NULL AND date != "0"';
      final vars = <Variable>[Variable.withString(language)];
      if (dateStart != null) {
        sql += ' AND date >= ?';
        vars.add(Variable.withString(dateStart));
      }
      sql += ' GROUP BY date ORDER BY date ASC';

      final rows = await PerfTrace.timeAsync('progress.weekly',
          () => _db.customSelect(sql, variables: vars).get());
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
  /// Uses a single SQL query with month-range bucketing instead of 4 separate
  /// queries.
  Future<List<int>> fetchMonthlyCounts(DateTime startDate, String language) async {
    try {
      final counts = <int>[0, 0, 0, 0];
      await PerfTrace.timeAsync('progress.monthly', () async {
        // Build month-bucket ranges and UNION them into one round trip.
        final parts = <String>[];
        final vars = <Variable>[];
        for (int i = 0; i < 4; i++) {
          final cur = DateTime(startDate.year, startDate.month + i);
          final next = DateTime(cur.year, cur.month + 1);
          final mStart =
              '${cur.year}-${cur.month.toString().padLeft(2, '0')}-01';
          final mEnd =
              '${next.year}-${next.month.toString().padLeft(2, '0')}-01';
          parts.add(
            'SELECT ? as m, COUNT(*) as cnt FROM words '
            'WHERE language_code = ? AND date >= ? AND date < ?',
          );
          vars
            ..add(Variable.withInt(i))
            ..add(Variable.withString(language))
            ..add(Variable.withString(mStart))
            ..add(Variable.withString(mEnd));
        }
        final rows = await _db.customSelect(
          parts.join(' UNION ALL '),
          variables: vars,
        ).get();
        for (final row in rows) {
          final m = row.read<int>('m');
          final cnt = row.read<int>('cnt');
          counts[m] = cnt;
        }
      }); // end progress.monthly trace
      return counts;
    } catch (e) {
      if (kDebugMode) print('ProgressRepository.fetchMonthlyCounts error: $e');
      return [0, 0, 0, 0];
    }
  }

  Future<void> resetAllData() => _db.resetAllProgress();
}
