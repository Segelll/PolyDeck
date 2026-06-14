import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:poly2/data/database/database.dart';

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

  Future<Map<String, int>> fetchDateCounts(String language) async {
    try {
      final rows = await _db.customSelect(
        'SELECT date, COUNT(*) as count FROM words '
        'WHERE language_code = ? AND date IS NOT NULL AND date != "0" '
        'GROUP BY date ORDER BY date ASC',
        variables: [Variable.withString(language)],
      ).get();
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

  Future<List<int>> fetchMonthlyCounts(DateTime startDate, String language) async {
    try {
      final counts = <int>[];
      for (int i = 0; i < 4; i++) {
        final cur = DateTime(startDate.year, startDate.month + i);
        final next = DateTime(cur.year, cur.month + 1);
        final start = '${cur.year}-${cur.month.toString().padLeft(2, '0')}-01';
        final end = '${next.year}-${next.month.toString().padLeft(2, '0')}-01';
        final rows = await _db.customSelect(
          'SELECT COUNT(*) as count FROM words '
          'WHERE language_code = ? AND date BETWEEN ? AND ?',
          variables: [Variable.withString(language), Variable.withString(start), Variable.withString(end)],
        ).get();
        counts.add(rows.firstOrNull?.read<int>('count') ?? 0);
      }
      return counts;
    } catch (e) {
      if (kDebugMode) print('ProgressRepository.fetchMonthlyCounts error: $e');
      return [0, 0, 0, 0];
    }
  }

  Future<void> resetAllData() => _db.resetAllProgress();
}
