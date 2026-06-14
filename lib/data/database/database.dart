import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Fav, RevlogEntries, DeckConfigs, UserSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(DatabaseConnection.delayed(_connect()));

  static Future<DatabaseConnection> _connect() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(appDir.path, 'polydesk.db');

    if (!await File(dbPath).exists()) {
      try {
        final data = await rootBundle.load('assets/polydesk.db');
        final bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(dbPath).writeAsBytes(bytes, flush: true);
      } catch (_) {}
    }

    return DatabaseConnection(NativeDatabase(
      File(dbPath),
      setup: (rawDb) {
        rawDb.execute('PRAGMA journal_mode=WAL');
        rawDb.execute('PRAGMA synchronous=NORMAL');
        rawDb.execute('PRAGMA cache_size=-64000');
        rawDb.execute('PRAGMA temp_store=MEMORY');
        rawDb.execute('PRAGMA mmap_size=67108864');
        rawDb.execute('PRAGMA foreign_keys=ON');
      },
    ));
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _ensureIndices();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Handle future schema upgrades here
        },
        beforeOpen: (details) async {
          await _ensureIndices();
        },
      );

  Future<void> _ensureIndices() async {
    const langs = ['en', 'tr', 'de', 'fr', 'it', 'pr', 'esp', 'fav'];
    for (final lang in langs) {
      try {
        await customStatement(
            'CREATE INDEX IF NOT EXISTS "idx_${lang}_fsrs_due" ON "$lang" ("level", "card_state", "due")');
      } catch (_) {}
      try {
        await customStatement(
            'CREATE INDEX IF NOT EXISTS "idx_${lang}_fsrs_new" ON "$lang" ("level", "card_state", "isSeen")');
      } catch (_) {}
      try {
        await customStatement(
            'CREATE INDEX IF NOT EXISTS "idx_${lang}_level_isSeen" ON "$lang" ("level", "isSeen")');
      } catch (_) {}
      try {
        await customStatement(
            'CREATE INDEX IF NOT EXISTS "idx_${lang}_feedback" ON "$lang" ("isSeen", "feedback")');
      } catch (_) {}
    }
    try {
      await customStatement(
          'CREATE INDEX IF NOT EXISTS "idx_revlog_card" ON "revlog" ("deck_table", "card_id")');
    } catch (_) {}
    try {
      await customStatement(
          'CREATE INDEX IF NOT EXISTS "idx_revlog_date" ON "revlog" ("review_date")');
    } catch (_) {}
    try {
      await customStatement(
          'CREATE INDEX IF NOT EXISTS "idx_revlog_deck_date_state" ON "revlog" ("deck_table", "review_date", "state")');
    } catch (_) {}
  }

  // ═══════════════════════════════════════════════════════════════
  //  Language table queries (dynamic table names → raw SQL)
  // ═══════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>?> fetchWordById(String tn, int id) async {
    final rows = await customSelect(
      'SELECT * FROM "$tn" WHERE id = ?',
      variables: [Variable.withInt(id)],
    ).get();
    if (rows.isEmpty) return null;
    return _rowToMap(rows.first);
  }

  Future<List<Map<String, dynamic>>> fetchWordsByIds(
      String tn, List<int> ids) async {
    if (ids.isEmpty) return [];
    final ph = ids.map((_) => '?').join(',');
    final rows = await customSelect(
      'SELECT * FROM "$tn" WHERE id IN ($ph)',
      variables: ids.map((i) => Variable.withInt(i)).toList(),
    ).get();
    return rows.map(_rowToMap).toList();
  }

  Future<List<Map<String, dynamic>>> fetchDueCards(
      String tn, String? level, String date, int limit) async {
    final where = level != null
        ? 'level = ? AND due IS NOT NULL AND due <= ? AND card_state IN (1,2,3)'
        : 'due IS NOT NULL AND due <= ? AND card_state IN (1,2,3)';
    final vars = level != null
        ? [Variable.withString(level), Variable.withString(date)]
        : [Variable.withString(date)];

    final rows = await customSelect(
      'SELECT * FROM "$tn" WHERE $where ORDER BY due ASC LIMIT $limit',
      variables: vars,
    ).get();
    return rows.map(_rowToMap).toList();
  }

  Future<List<Map<String, dynamic>>> fetchNewCards(
      String tn, String? level, int limit) async {
    final where = level != null
        ? 'level = ? AND card_state = 0 AND isSeen = 0'
        : 'card_state = 0 AND isSeen = 0';
    final vars = level != null
        ? [Variable.withString(level)]
        : <Variable<Object>>[];

    // Get a candidate pool
    final candidates = await customSelect(
      'SELECT id FROM "$tn" WHERE $where LIMIT 100',
      variables: vars,
    ).get();
    final ids = candidates.map((r) => r.read<int>('id')).toList();

    if (ids.isEmpty) return [];
    ids.shuffle();
    final pick = ids.take(limit).toList();
    final ph = pick.map((_) => '?').join(',');
    final rows = await customSelect(
      'SELECT * FROM "$tn" WHERE id IN ($ph)',
      variables: pick.map((i) => Variable.withInt(i)).toList(),
    ).get();
    final result = rows.map(_rowToMap).toList();
    result.shuffle();
    return result;
  }

  Future<List<Map<String, dynamic>>> fetchWordsByIsSeen(
      String tn, String? level, int isSeen, int limit) async {
    final where =
        level != null ? 'level = ? AND isSeen = ?' : 'isSeen = ?';
    final vars = level != null
        ? [Variable.withString(level), Variable.withInt(isSeen)]
        : [Variable.withInt(isSeen)];
    final rows = await customSelect(
      'SELECT * FROM "$tn" WHERE $where LIMIT $limit',
      variables: vars,
    ).get();
    return rows.map(_rowToMap).toList();
  }

  Future<List<Map<String, dynamic>>> fetchWordsByFeedback(
      String tn, String? level, int feedback, int limit) async {
    final where =
        level != null ? 'level = ? AND feedback = ?' : 'feedback = ?';
    final vars = level != null
        ? [Variable.withString(level), Variable.withInt(feedback)]
        : [Variable.withInt(feedback)];
    final rows = await customSelect(
      'SELECT * FROM "$tn" WHERE $where LIMIT $limit',
      variables: vars,
    ).get();
    return rows.map(_rowToMap).toList();
  }

  Future<void> updateSrsState(
    String tn, int id, {
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
    final parts = [
      'card_state = $cardState',
      'stability = $stability',
      'difficulty = $difficulty',
      if (due != null) "due = '$due'" else 'due = NULL',
      'elapsed_days = $elapsedDays',
      'scheduled_days = $scheduledDays',
      'reps = $reps',
      'lapses = $lapses',
      if (lastReview != null) "last_review = '$lastReview'" else 'last_review = NULL',
      if (legacyFeedback != null) 'feedback = $legacyFeedback',
    ];
    await customStatement(
        'UPDATE "$tn" SET ${parts.join(', ')} WHERE id = $id');
  }

  Future<void> markAsSeen(String tn, int id, String date) async {
    await customStatement(
        'UPDATE "$tn" SET isSeen = 1, date = ? WHERE id = ?', [date, id]);
  }

  Future<void> markMultipleAsSeen(
      String tn, List<int> ids, String date) async {
    if (ids.isEmpty) return;
    final ph = ids.join(',');
    await customStatement(
        'UPDATE "$tn" SET isSeen = 1, date = ? WHERE id IN ($ph)', [date]);
  }

  Future<List<int>> fetchAllIsSeenId(String tn) async {
    final rows = await customSelect(
      'SELECT id FROM "$tn" WHERE isSeen = 1',
    ).get();
    return rows.map((r) => r.read<int>('id')).toList();
  }

  Future<String?> getEarliestDate(String tn) async {
    final rows = await customSelect(
      'SELECT MIN(date) as earliestDate FROM "$tn" WHERE date != 0',
    ).get();
    return rows.firstOrNull?.readNullable<String>('earliestDate');
  }

  Future<List<Map<String, dynamic>>> fetchExamWords(String tn, int id) async {
    final rows = await customSelect(
      'SELECT * FROM "$tn" WHERE id = ?',
      variables: [Variable.withInt(id)],
    ).get();
    return rows.map(_rowToMap).toList();
  }

  Future<List<Map<String, dynamic>>> fetchExamOptions(
      String tn, List<int> randomIds) async {
    if (randomIds.isEmpty) return [];
    final ph = randomIds.map((_) => '?').join(',');
    final rows = await customSelect(
      'SELECT * FROM "$tn" WHERE id IN ($ph)',
      variables: randomIds.map((i) => Variable.withInt(i)).toList(),
    ).get();
    return rows.map(_rowToMap).toList();
  }

  // ═══════════════════════════════════════════════════════════════
  //  Favorites (managed by Drift)
  // ═══════════════════════════════════════════════════════════════

  Future<void> addToFav({
    required String word,
    required String sentence,
    required String level,
    String? backWord,
    String? backSentence,
  }) async {
    await into(fav).insert(FavCompanion.insert(
          word: word,
          sentence: sentence,
          level: level,
          backword: Value(backWord ?? ''),
          backsentence: Value(backSentence ?? ''),
        ));
  }

  Future<void> removeFromFav(String word) async {
    await (delete(fav)..where((t) => t.word.equals(word))).go();
  }

  Future<bool> isFavorite(String word) async {
    final cnt = await (selectOnly(fav)
          ..addColumns([fav.id])
          ..where(fav.word.equals(word)))
        .map((r) => r.read(fav.id))
        .get();
    return cnt.isNotEmpty;
  }

  Future<List<FavData>> fetchAllFavorites() => select(fav).get();

  // ═══════════════════════════════════════════════════════════════
  //  User settings
  // ═══════════════════════════════════════════════════════════════

  Future<Map<String, String>?> getUserChoices() async {
    final rows = await select(userSettings).get();
    if (rows.isEmpty) return null;
    final r = rows.first;
    return {
      'mainLanguage': r.mainLanguage,
      'targetLanguage': r.targetLanguage,
      'firstTime': r.firstTime,
    };
  }

  Future<void> saveUserChoices(
      String mainLanguage, String targetLanguage) async {
    await customStatement('DELETE FROM "user"');
    await into(userSettings).insert(UserSettingsCompanion.insert(
          mainLanguage: mainLanguage,
          targetLanguage: targetLanguage,
          firstTime: 'true',
        ));
  }

  // ═══════════════════════════════════════════════════════════════
  //  Revlog
  // ═══════════════════════════════════════════════════════════════

  Future<void> insertRevlogEntry({
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
    await into(revlogEntries).insert(RevlogEntriesCompanion.insert(
          cardId: cardId,
          deckTable: deckTable,
          rating: rating,
          state: state,
          due: due,
          stability: stability,
          difficulty: difficulty,
          elapsedDays: elapsedDays,
          lastElapsedDays: Value(lastElapsedDays),
          scheduledDays: scheduledDays,
          reviewDate: reviewDate,
        ));
  }

  Future<({int newCount, int reviewCount})> getTodayCounts(
      String tableName, String? level) async {
    final today = DateTime.now();
    String ds(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final todayStr = ds(today);
    final tomorrowStr = ds(today.add(const Duration(days: 1)));

    final where = level != null
        ? 'deck_table = ? AND review_date >= ? AND review_date < ?'
        : 'review_date >= ? AND review_date < ?';
    final vars = level != null
        ? [Variable.withString(tableName), Variable.withString(todayStr), Variable.withString(tomorrowStr)]
        : [Variable.withString(todayStr), Variable.withString(tomorrowStr)];

    final rows = await customSelect(
      '''SELECT
        SUM(CASE WHEN state = 0 THEN 1 ELSE 0 END) as new_cnt,
        SUM(CASE WHEN state IN (2,3) THEN 1 ELSE 0 END) as review_cnt
      FROM revlog WHERE $where''',
      variables: vars,
    ).get();

    return (
      newCount: rows.firstOrNull?.read<int>('new_cnt') ?? 0,
      reviewCount: rows.firstOrNull?.read<int>('review_cnt') ?? 0,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  Deck config
  // ═══════════════════════════════════════════════════════════════

  Future<DeckConfig?> getDeckConfig(String level) async {
    final rows =
        await (select(deckConfigs)..where((t) => t.level.equals(level))).get();
    if (rows.isNotEmpty) return rows.first;
    final defaults = await (select(deckConfigs)
          ..where((t) => t.level.equals('default')))
        .get();
    return defaults.firstOrNull;
  }

  Future<void> saveDeckConfigEntry({
    required String level,
    required int maxNewPerDay,
    required int maxReviewsPerDay,
    required String learningSteps,
    required bool enableFuzz,
    required double requestRetention,
    String? w,
  }) async {
    await into(deckConfigs).insert(
      DeckConfigsCompanion.insert(
        level: level,
        maxNewPerDay: Value(maxNewPerDay),
        maxReviewsPerDay: Value(maxReviewsPerDay),
        learningSteps: Value(learningSteps),
        enableFuzz: Value(enableFuzz ? 1 : 0),
        requestRetention: Value(requestRetention),
        w: Value(w),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  // ── Progress queries ──

  Future<Map<String, int>> fetchDateCounts(List<String> languageTables) async {
    final combined = <String, int>{};
    for (final table in languageTables) {
      final rows = await customSelect(
        'SELECT date, COUNT(*) as count FROM "$table" '
        'WHERE date IS NOT NULL AND date != "0" '
        'GROUP BY date ORDER BY date ASC',
      ).get();
      for (final row in rows) {
        final date = row.read<String>('date');
        final count = row.read<int>('count');
        combined[date] = (combined[date] ?? 0) + count;
      }
    }
    return combined;
  }

  Future<List<int>> fetchMonthlyCounts(
      List<String> languageTables, DateTime startDate) async {
    final counts = <int>[];
    for (int i = 0; i < 4; i++) {
      final cur = DateTime(startDate.year, startDate.month + i);
      final next = DateTime(cur.year, cur.month + 1);
      final startStr =
          '${cur.year}-${cur.month.toString().padLeft(2, '0')}-01';
      final endStr =
          '${next.year}-${next.month.toString().padLeft(2, '0')}-01';
      int total = 0;
      for (final table in languageTables) {
        final rows = await customSelect(
          'SELECT COUNT(*) as count FROM "$table" WHERE date BETWEEN ? AND ?',
          variables: [
            Variable.withString(startStr),
            Variable.withString(endStr),
          ],
        ).get();
        total += rows.firstOrNull?.read<int>('count') ?? 0;
      }
      counts.add(total);
    }
    return counts;
  }

  Future<void> resetAllProgress(List<String> languageTables) async {
    for (final lang in languageTables) {
      await customStatement(
          'UPDATE "$lang" SET isSeen = 0, date = "", feedback = 0');
      await customStatement('''UPDATE "$lang" SET
        card_state = 0, stability = 0.0, difficulty = 0.0,
        due = NULL, elapsed_days = 0, scheduled_days = 0,
        reps = 0, lapses = 0, last_review = NULL''');
    }
    await customStatement('DELETE FROM "fav"');
    await customStatement('DELETE FROM "revlog"');
  }

  Future<void> resetSrsState(String tn) async {
    await customStatement('''UPDATE "$tn" SET
      card_state = 0, stability = 0.0, difficulty = 0.0,
      due = NULL, elapsed_days = 0, scheduled_days = 0,
      reps = 0, lapses = 0, last_review = NULL''');
  }

  // ── Helpers ──

  Map<String, dynamic> _rowToMap(QueryRow row) => {
        'id': row.read<int>('id'),
        'word': row.read<String>('word'),
        'sentence': row.read<String>('sentence'),
        'level': row.read<String>('level'),
        'isSeen': row.read<int>('isSeen'),
        'feedback': row.read<int>('feedback'),
        'date': row.readNullable<String>('date'),
        'backword': row.readNullable<String>('backword'),
        'backsentence': row.readNullable<String>('backsentence'),
        'card_state': row.read<int>('card_state'),
        'stability': row.read<double>('stability'),
        'difficulty': row.read<double>('difficulty'),
        'due': row.readNullable<String>('due'),
        'elapsed_days': row.read<int>('elapsed_days'),
        'scheduled_days': row.read<int>('scheduled_days'),
        'reps': row.read<int>('reps'),
        'lapses': row.read<int>('lapses'),
        'last_review': row.readNullable<String>('last_review'),
      };
}
