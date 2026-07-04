import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';
import '../../core/performance/perf_trace.dart';

part 'database.g.dart';

/// Thrown when the pre-populated database fails integrity checks.
/// The app layer should catch this and surface a blocking error dialog
/// so the user knows to reinstall.
class DatabaseIntegrityException implements Exception {
  final String message;
  const DatabaseIntegrityException(this.message);
  @override
  String toString() => 'DatabaseIntegrityException: $message';
}

@DriftDatabase(tables: [Words, RevlogEntries, DeckConfigs, UserSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(DatabaseConnection.delayed(_connect()));

  static Future<DatabaseConnection> _connect() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(appDir.path, 'polydesk.db');

    if (!await File(dbPath).exists()) {
      await PerfTrace.timeAsync('db.copyAsset', () async {
        try {
          final data = await rootBundle.load('assets/polydesk.db');
          final bytes =
              data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          await File(dbPath).writeAsBytes(bytes, flush: true);
        } catch (e) {
          if (kDebugMode) print('DB copy failed: $e');
        }
      });
    }

    return PerfTrace.timeAsync('db.open', () async {
      // Open the database on a background isolate so SQLite IO never blocks
      // the UI thread. The setup callback configures WAL, cache, and PRAGMAs.
      return DatabaseConnection(
        await NativeDatabase.createInBackground(
          File(dbPath),
          setup: (rawDb) {
            rawDb.execute('PRAGMA journal_mode=WAL');
            rawDb.execute('PRAGMA synchronous=NORMAL');
            rawDb.execute('PRAGMA cache_size=-64000');
            rawDb.execute('PRAGMA temp_store=MEMORY');
            rawDb.execute('PRAGMA mmap_size=67108864');
            rawDb.execute('PRAGMA foreign_keys=ON');
          },
        ),
      );
    });
  }

  /// Schema version for the pre-populated asset DB.
  /// Must match the user_version PRAGMA stored in assets/polydesk.db.
  /// Bump when the asset DB structure changes and a migration is needed.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _ensureIndices();
        },
        onUpgrade: (Migrator m, int from, int to) async {},
        beforeOpen: (details) async {
          // If the DB was copied from assets, it already has the tables.
          // This just ensures indices are present in case they were missed.
          await _ensureIndices();
          // Verify the copied database is intact and contains the expected data.
          await _validateDatabase();
        },
      );

  /// Runs a lightweight integrity check after DB open.
  ///
  /// Verifies that:
  /// - The words table is non-empty
  /// - All expected language codes are present
  /// - All five CEFR levels (A1-C1) exist per language
  ///
  /// Throws [DatabaseIntegrityException] if any check fails, which the app
  /// layer should catch and surface as a blocking error dialog.
  Future<void> _validateDatabase() async {
    // 1) Word count — must be non-empty.
    final rowCount = await (selectOnly(words)..addColumns([words.id.count()]))
        .map((r) => r.read<int>(words.id.count()))
        .getSingle();
    if (rowCount == 0) {
      throw DatabaseIntegrityException(
          'Database is empty. Please reinstall the app.');
    }

    // 2) Expected language codes must be present.
    const expectedLangs = ['en', 'tr', 'de', 'fr', 'it', 'pt', 'es'];
    final langRows = await customSelect(
      'SELECT DISTINCT language_code FROM words',
    ).get();
    final langs = langRows.map((r) => r.read<String>('language_code')).toSet();
    for (final lang in expectedLangs) {
      if (!langs.contains(lang)) {
        throw DatabaseIntegrityException(
            'Missing language data for "$lang". Please reinstall the app.');
      }
    }

    // 3) All five CEFR levels must be present for at least one language.
    const expectedLevels = ['A1', 'A2', 'B1', 'B2', 'C1'];
    for (final level in expectedLevels) {
      final cnt = await (selectOnly(words)
            ..addColumns([words.id.count()])
            ..where(words.level.equals(level)))
          .map((r) => r.read<int>(words.id.count()))
          .getSingle();
      if (cnt == 0) {
        throw DatabaseIntegrityException(
            'Missing CEFR level "$level". Please reinstall the app.');
      }
    }
  }

  Future<void> _ensureIndices() async {
    // Index strategy (see PERFORMANCE_REFACTOR_PLAN_EN.md §1.3):
    // Column order matters — filtering columns first, then range/order columns,
    // so SQLite can use the index for both WHERE and ORDER BY / GROUP BY.

    // Drop superseded indexes from the old schema (ignore errors if missing).
    const oldIdxs = [
      'DROP INDEX IF EXISTS idx_words_lang_level_state_due',
      'DROP INDEX IF EXISTS idx_words_lang_level_state_seen',
      'DROP INDEX IF EXISTS idx_revlog_deck_date_state',
    ];
    for (final sql in oldIdxs) {
      try {
        await customStatement(sql);
      } catch (_) {}
    }

    // Current index set.
    const idxs = [
      // Due-card queue: ORDER BY due can use this index because `due` comes
      // before `card_state`, avoiding a temporary B-tree sort.
      'CREATE INDEX IF NOT EXISTS idx_words_due_queue ON words (language_code, level, due, card_state)',
      // New-card queue: covers language + level + unseen filtering; `id` at
      // the end supports deterministic offset/window selection.
      'CREATE INDEX IF NOT EXISTS idx_words_new_queue ON words (language_code, level, card_state, isSeen, id)',
      // Progress queries: optimize GROUP BY date and date-range filters.
      'CREATE INDEX IF NOT EXISTS idx_words_progress_date ON words (language_code, date)',
      // Favorites: fast word-text lookup within the fav language partition.
      'CREATE INDEX IF NOT EXISTS idx_words_fav_word ON words (language_code, word)',
      // Today's review counts.
      'CREATE INDEX IF NOT EXISTS idx_revlog_today_counts ON revlog (deck_table, review_date, state)',
      // ── Retained from the original set ──
      'CREATE INDEX IF NOT EXISTS idx_words_lang_level_isSeen ON words (language_code, level, isSeen)',
      'CREATE INDEX IF NOT EXISTS idx_words_feedback ON words (isSeen, feedback)',
      'CREATE INDEX IF NOT EXISTS idx_revlog_card ON revlog (deck_table, card_id)',
      'CREATE INDEX IF NOT EXISTS idx_revlog_date ON revlog (review_date)',
    ];
    for (final sql in idxs) {
      try {
        await customStatement(sql);
      } catch (_) {}
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  Type-safe word queries (unified words table)
  // ═══════════════════════════════════════════════════════════════

  Future<Word?> fetchWordById(int id) =>
      (select(words)..where((w) => w.id.equals(id))).getSingleOrNull();

  Future<List<Word>> fetchWordsByIds(String language, List<int> ids) {
    if (ids.isEmpty) return Future.value([]);
    return (select(words)..where((w) => w.languageCode.equals(language) & w.id.isIn(ids))).get();
  }

  Future<List<Word>> fetchDueCards(
      String language, String? level, String date, int limit) {
    var q = select(words)
      ..where((w) =>
          w.languageCode.equals(language) &
          w.due.isNotNull() &
          w.due.isSmallerOrEqualValue(date) &
          w.cardState.isIn([1, 2, 3]))
      ..orderBy([(u) => OrderingTerm.asc(u.due)])
      ..limit(limit);
    if (level != null && level != 'fav') {
      q = select(words)..where((w) => w.level.equals(level));
      q
        ..where((w) =>
            w.languageCode.equals(language) &
            w.due.isNotNull() &
            w.due.isSmallerOrEqualValue(date) &
            w.cardState.isIn([1, 2, 3]))
        ..orderBy([(u) => OrderingTerm.asc(u.due)])
        ..limit(limit);
    }
    return q.get();
  }

  Future<List<Word>> fetchNewCards(
      String language, String? level, int limit) {
    var q = select(words)
      ..where((w) =>
          w.languageCode.equals(language) &
          w.cardState.equals(0) &
          w.isSeen.equals(0))
      ..orderBy([(u) => OrderingTerm.random()])
      ..limit(limit);
    if (level != null && level != 'fav') {
      q = select(words)
        ..where((w) =>
            w.languageCode.equals(language) &
            w.level.equals(level) &
            w.cardState.equals(0) &
            w.isSeen.equals(0))
        ..orderBy([(u) => OrderingTerm.random()])
        ..limit(limit);
    }
    return q.get();
  }

  Future<List<Word>> fetchWordsByIsSeen(
      String language, String? level, int isSeen, int limit) {
    var q = select(words)
      ..where((w) =>
          w.languageCode.equals(language) & w.isSeen.equals(isSeen))
      ..limit(limit);
    if (level != null && level != 'fav') {
      q = select(words)
        ..where((w) =>
            w.languageCode.equals(language) &
            w.level.equals(level) &
            w.isSeen.equals(isSeen))
        ..limit(limit);
    }
    return q.get();
  }

  Future<List<Word>> fetchWordsByFeedback(
      String language, String? level, int feedback, int limit) {
    var q = select(words)
      ..where((w) => w.languageCode.equals(language) & w.feedback.equals(feedback))
      ..limit(limit);
    if (level != null && level != 'fav') {
      q = select(words)
        ..where((w) =>
            w.languageCode.equals(language) &
            w.level.equals(level) &
            w.feedback.equals(feedback))
        ..limit(limit);
    }
    return q.get();
  }

  Future<List<int>> fetchAllIsSeenId(String language) async {
    final rows = await (selectOnly(words)
          ..addColumns([words.id])
          ..where(words.languageCode.equals(language) & words.isSeen.equals(1)))
        .get();
    return rows.map((r) => r.read(words.id)!).toList();
  }

  Future<String?> getEarliestDate(String language) async {
    final row = await (selectOnly(words)
          ..addColumns([words.date])
          ..where(words.languageCode.equals(language) & words.date.isNotNull())
          ..orderBy([OrderingTerm.asc(words.date)])
          ..limit(1))
        .getSingleOrNull();
    return row?.read(words.date);
  }

  Future<List<Word>> fetchExamWords(String language, int id) =>
      (select(words)
            ..where((w) => w.languageCode.equals(language) & w.id.equals(id)))
          .get();

  Future<List<Word>> fetchExamOptions(String language, List<int> ids) {
    if (ids.isEmpty) return Future.value([]);
    return (select(words)
          ..where((w) => w.languageCode.equals(language) & w.id.isIn(ids)))
        .get();
  }

  Future<void> updateSrsState(int id,
      {required int cardState,
      required double stability,
      required double difficulty,
      String? due,
      required int elapsedDays,
      required int scheduledDays,
      required int reps,
      required int lapses,
      String? lastReview,
      int? legacyFeedback}) async {
    final values = WordsCompanion(
      cardState: Value(cardState),
      stability: Value(stability),
      difficulty: Value(difficulty),
      due: Value(due),
      elapsedDays: Value(elapsedDays),
      scheduledDays: Value(scheduledDays),
      reps: Value(reps),
      lapses: Value(lapses),
      lastReview: Value(lastReview),
      feedback: legacyFeedback != null ? Value(legacyFeedback) : const Value.absent(),
    );
    await (update(words)..where((w) => w.id.equals(id))).write(values);
  }

  Future<void> markAsSeen(int id, String date) =>
      (update(words)..where((w) => w.id.equals(id)))
          .write(WordsCompanion(isSeen: const Value(1), date: Value(date)));

  Future<void> markMultipleAsSeen(List<int> ids, String date) async {
    // Use customStatement for batch update (more efficient)
    if (ids.isEmpty) return;
    await customStatement(
        'UPDATE words SET isSeen = 1, date = ? WHERE id IN (${ids.join(',')})',
        [date]);
  }

  // ═══════════════════════════════════════════════════════════════
  //  Favorites (subset of words where language_code = 'fav')
  // ═══════════════════════════════════════════════════════════════

  Future<List<Word>> fetchAllFavorites() =>
      (select(words)..where((w) => w.languageCode.equals('fav'))).get();

  Future<bool> isFavorite(String word) async {
    final cnt = await (selectOnly(words)
          ..addColumns([words.id])
          ..where(words.word.equals(word) & words.languageCode.equals('fav')))
        .map((r) => r.read(words.id))
        .get();
    return cnt.isNotEmpty;
  }

  Future<void> removeFromFav(String word) async {
    await (delete(words)
          ..where((w) => w.word.equals(word) & w.languageCode.equals('fav')))
        .go();
  }

  Future<void> addToFav(
      {required String word,
      required String sentence,
      required String level,
      String? backWord,
      String? backSentence}) async {
    final maxIdRow = await customSelect(
        'SELECT MAX(id) as max_id FROM words WHERE language_code = "fav"').getSingle();
    final nextId = (maxIdRow.readNullable<int>('max_id') ?? 0) + 1;
    await into(words).insert(WordsCompanion.insert(
          id: nextId,
          word: word,
          sentence: sentence,
          level: level,
          languageCode: 'fav',
          backword: Value(backWord ?? ''),
          backsentence: Value(backSentence ?? ''),
        ));
  }

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
          String mainLanguage, String targetLanguage) async =>
      into(userSettings).insertOnConflictUpdate(
          UserSettingsCompanion.insert(
              mainLanguage: mainLanguage,
              targetLanguage: targetLanguage,
              firstTime: 'true'));

  // ═══════════════════════════════════════════════════════════════
  //  Revlog
  // ═══════════════════════════════════════════════════════════════

  Future<void> insertRevlogEntry(
          {required int cardId,
          required String deckTable,
          required int rating,
          required int state,
          required String due,
          required double stability,
          required double difficulty,
          required int elapsedDays,
          required int lastElapsedDays,
          required int scheduledDays,
          required String reviewDate}) async =>
      into(revlogEntries).insert(RevlogEntriesCompanion.insert(
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

  Future<({int newCount, int reviewCount})> getTodayCounts(String language,
      [String? level]) async {
    final today = DateTime.now();
    String ds(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final rows = await customSelect(
      '''SELECT
        SUM(CASE WHEN state = 0 THEN 1 ELSE 0 END) as new_cnt,
        SUM(CASE WHEN state IN (2,3) THEN 1 ELSE 0 END) as review_cnt
      FROM revlog WHERE deck_table = ? AND review_date >= ? AND review_date < ?''',
      variables: [
        Variable.withString(language),
        Variable.withString(ds(today)),
        Variable.withString(ds(today.add(const Duration(days: 1)))),
      ],
    ).get();
    return (
      newCount: rows.firstOrNull?.readNullable<int>('new_cnt') ?? 0,
      reviewCount: rows.firstOrNull?.readNullable<int>('review_cnt') ?? 0,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  Deck config
  // ═══════════════════════════════════════════════════════════════

  Future<DeckConfig?> getDeckConfig(String level) async {
    final rows =
        await (select(deckConfigs)..where((t) => t.level.equals(level))).get();
    if (rows.isNotEmpty) return rows.first;
    return (select(deckConfigs)..where((t) => t.level.equals('default')))
        .getSingleOrNull();
  }

  Future<void> saveDeckConfigEntry(
          {required String level,
          required int maxNewPerDay,
          required int maxReviewsPerDay,
          required String learningSteps,
          required bool enableFuzz,
          required double requestRetention,
          String? w}) async =>
      into(deckConfigs).insertOnConflictUpdate(DeckConfigsCompanion.insert(
            level: level,
            maxNewPerDay: Value(maxNewPerDay),
            maxReviewsPerDay: Value(maxReviewsPerDay),
            learningSteps: Value(learningSteps),
            enableFuzz: Value(enableFuzz ? 1 : 0),
            requestRetention: Value(requestRetention),
            w: Value(w),
          ));

  // ═══════════════════════════════════════════════════════════════
  //  Reset
  // ═══════════════════════════════════════════════════════════════

  Future<void> resetSrsState(String language) async {
    await (update(words)
          ..where((w) => w.languageCode.equals(language)))
        .write(const WordsCompanion(
          cardState: Value(0),
          stability: Value(0.0),
          difficulty: Value(0.0),
          due: Value.absent(),
          elapsedDays: Value(0),
          scheduledDays: Value(0),
          reps: Value(0),
          lapses: Value(0),
          lastReview: Value.absent(),
        ));
  }

  Future<void> resetAllProgress() async {
    await (update(words)).write(const WordsCompanion(
      isSeen: Value(0),
      date: Value(''),
      feedback: Value(0),
      cardState: Value(0),
      stability: Value(0.0),
      difficulty: Value(0.0),
      elapsedDays: Value(0),
      scheduledDays: Value(0),
      reps: Value(0),
      lapses: Value(0),
    ));
    await customStatement('DELETE FROM revlog');
  }
}
