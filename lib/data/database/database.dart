import 'dart:io';
import 'dart:math';

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
        beforeOpen: (details) async {
          // Fresh install — the DB was just copied from assets.
          // Ensure indices and validate integrity.
          await _ensureIndices();
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
    // Column order matters — filtering columns first, then range/order columns.
    const idxs = [
      // Due-card queue: `due` before `card_state` so ORDER BY due uses the index.
      'CREATE INDEX IF NOT EXISTS idx_words_due_queue ON words (language_code, level, due, card_state)',
      // New-card queue: `id` at end for deterministic range selection.
      'CREATE INDEX IF NOT EXISTS idx_words_new_queue ON words (language_code, level, card_state, isSeen, id)',
      // Progress: optimize GROUP BY date and date-range filters.
      'CREATE INDEX IF NOT EXISTS idx_words_progress_date ON words (language_code, date)',
      // Favorites: word lookup within the fav partition.
      'CREATE INDEX IF NOT EXISTS idx_words_fav_word ON words (language_code, word)',
      // Today's review counts.
      'CREATE INDEX IF NOT EXISTS idx_revlog_today_counts ON revlog (deck_table, review_date, state)',
      // Supporting indexes.
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

  /// Fetches a word by its composite primary key `(languageCode, id)`.
  /// The same `id` exists across all 7 languages, so the language filter
  /// is required to avoid returning the wrong language's row.
  Future<Word?> fetchWordById(String languageCode, int id) =>
      (select(words)
            ..where((w) =>
                w.languageCode.equals(languageCode) & w.id.equals(id)))
          .getSingleOrNull();

  Future<List<Word>> fetchWordsByIds(String language, List<int> ids) {
    if (ids.isEmpty) return Future.value([]);
    return (select(words)..where((w) => w.languageCode.equals(language) & w.id.isIn(ids))).get();
  }

  Future<List<Word>> fetchDueCards(
      String language, String? level, String date, int limit) {
    // Build the query once with a conditional level predicate.
    // The old code overwrote q when level was set — this is cleaner.
    final q = select(words);
    if (level != null && level != 'fav') {
      q.where((w) =>
          w.languageCode.equals(language) &
          w.level.equals(level) &
          w.due.isNotNull() &
          w.due.isSmallerOrEqualValue(date) &
          w.cardState.isIn([1, 2, 3]));
    } else {
      q.where((w) =>
          w.languageCode.equals(language) &
          w.due.isNotNull() &
          w.due.isSmallerOrEqualValue(date) &
          w.cardState.isIn([1, 2, 3]));
    }
    q
      ..orderBy([(u) => OrderingTerm.asc(u.due)])
      ..limit(limit);
    return q.get();
  }

  /// Fetches a random-ish selection of unseen new cards.
  ///
  /// Replaces `ORDER BY RANDOM()` (which forces a full-scan + temp B-tree sort)
  /// with a count → random-start-id → id-range strategy.  The result set is
  /// a deterministic slice ordered by id; the deck provider shuffles the
  /// combined deck in Dart so the user still sees variety.
  Future<List<Word>> fetchNewCards(
      String language, String? level, int limit) async {
    // ── Shared WHERE clause ──
    final conditions = StringBuffer(
      'language_code = ? AND card_state = 0 AND isSeen = 0',
    );
    final vars = <Variable>[Variable.withString(language)];
    if (level != null && level != 'fav') {
      conditions.write(' AND level = ?');
      vars.add(Variable.withString(level));
    }
    final whereSql = conditions.toString();

    // ── Find the id range for candidates ──
    final rangeRow = await customSelect(
      'SELECT MIN(id) as min_id, MAX(id) as max_id FROM words WHERE $whereSql',
      variables: vars,
    ).getSingle();
    final minId = rangeRow.readNullable<int>('min_id');
    final maxId = rangeRow.readNullable<int>('max_id');
    if (minId == null || maxId == null) return [];

    // ── Pick a random start id ──
    final rng = Random();
    final idRange = maxId - minId + 1;
    final startId = minId +
        (idRange > limit ? rng.nextInt(idRange - limit) : 0);

    // ── Fetch contiguous window starting from startId ──
    final fetchVars = [
      ...vars,
      Variable.withInt(startId),
      Variable.withInt(limit),
    ];
    final rows = await customSelect(
      'SELECT * FROM words WHERE $whereSql AND id >= ? '
      'ORDER BY id LIMIT ?',
      variables: fetchVars,
      readsFrom: {words},
    ).get();

    final result = <Word>[];
    for (final row in rows) {
      result.add(await words.mapFromRow(row));
    }
    return result;
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

  /// Fetches all word IDs for [language] + [level], ordered by id.
  /// Used by exam generation to sample questions without hardcoded ranges.
  Future<List<int>> fetchWordIds(
      {required String language, required String level}) async {
    final rows = await (selectOnly(words)
          ..addColumns([words.id])
          ..where(words.languageCode.equals(language) & words.level.equals(level))
          ..orderBy([OrderingTerm.asc(words.id)]))
        .get();
    return rows.map((r) => r.read<int>(words.id)!).toList();
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

  // ═══════════════════════════════════════════════════════════════
  //  Transactional card review
  // ═══════════════════════════════════════════════════════════════

  /// Performs a complete card review in a single transaction.
  ///
  /// On success returns `true`.  Returns `false` when the optimistic guard
  /// detects a double-write (the card's review has already been persisted).
  ///
  /// The [guardLastReview] should be the `last_review` value from the card
  /// *before* this review started — if the DB's current `last_review` no
  /// longer matches, another write already landed and this call is rejected.
  ///
  /// For new cards (where `last_review` is null), the guard still fires:
  /// if the current `last_review` has become non-null, someone else reviewed
  /// this card first.
  Future<bool> reviewWord({
    required int wordId,
    required String deckTable,
    required int rating,
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
    required String reviewDate,
    String? guardLastReview,
  }) async {
    return transaction(() async {
      // ── Optimistic guard ──
      // Always re-fetch the current row by its full PK to detect duplicate
      // reviews. Works for both new cards (guardLastReview == null) and
      // reviewed cards.
      final currentWord = await (select(words)
            ..where((w) =>
                w.languageCode.equals(deckTable) & w.id.equals(wordId)))
          .getSingleOrNull();
      if (currentWord == null) return false;
      if (currentWord.lastReview != guardLastReview) return false;

      // ── Update SRS state ──
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
        feedback: legacyFeedback != null
            ? Value(legacyFeedback)
            : const Value.absent(),
      );
      await (update(words)
            ..where((w) =>
                w.languageCode.equals(deckTable) & w.id.equals(wordId)))
          .write(values);

      // ── Insert revlog entry ──
      await into(revlogEntries).insert(RevlogEntriesCompanion.insert(
            cardId: wordId,
            deckTable: deckTable,
            rating: rating,
            state: cardState,
            due: due ?? '',
            stability: stability,
            difficulty: difficulty,
            elapsedDays: elapsedDays,
            lastElapsedDays: Value(elapsedDays),
            scheduledDays: scheduledDays,
            reviewDate: reviewDate,
          ));

      return true;
    });
  }

  Future<void> updateSrsState(String languageCode, int id,
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
    await (update(words)
          ..where((w) =>
              w.languageCode.equals(languageCode) & w.id.equals(id)))
        .write(values);
  }

  Future<void> markAsSeen(String languageCode, int id, String date) =>
      (update(words)
            ..where((w) =>
                w.languageCode.equals(languageCode) & w.id.equals(id)))
          .write(WordsCompanion(isSeen: const Value(1), date: Value(date)));

  Future<void> markMultipleAsSeen(
      String languageCode, List<int> ids, String date) async {
    if (ids.isEmpty) return;
    // Build parameterized IN clause: language_code = ? AND id IN (?, ?, ...)
    final placeholders = ids.map((_) => '?').join(',');
    await customStatement(
        'UPDATE words SET isSeen = 1, date = ? '
        'WHERE language_code = ? AND id IN ($placeholders)',
        [date, languageCode, ...ids]);
  }

  // ═══════════════════════════════════════════════════════════════
  //  Favorites (subset of words where language_code = 'fav')
  // ═══════════════════════════════════════════════════════════════

  /// Fetches a bounded, deterministic-random window of favorite cards.
  ///
  /// The count keeps the result bounded in memory while the random offset
  /// preserves variety without sorting the whole favorites table with
  /// `ORDER BY RANDOM()`.
  Future<List<Word>> fetchFavoriteDeckWords(int limit) async {
    if (limit <= 0) return [];

    final countRow = await customSelect(
      'SELECT COUNT(*) AS favorite_count '
      'FROM words WHERE language_code = ?',
      variables: [Variable.withString('fav')],
    ).getSingle();
    final count = countRow.read<int>('favorite_count');
    if (count == 0) return [];

    final windowSize = min(limit, count);
    final offset =
        count > windowSize ? Random().nextInt(count - windowSize + 1) : 0;

    return (select(words)
          ..where((w) => w.languageCode.equals('fav'))
          ..orderBy([(w) => OrderingTerm.asc(w.id)])
          ..limit(windowSize, offset: offset))
        .get();
  }

  /// Fetches all favorites for export and backup operations.
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
    // Keep favorite insertion idempotent. This also protects callers whose
    // cached favorite state has not been initialized yet.
    if (await isFavorite(word)) return;

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

  /// Counts today's new and review cards for [language].
  ///
  /// Date storage strategy (see plan §1.6):
  /// - Day-level fields (`date`, `due`): `YYYY-MM-DD` string
  /// - Timestamps (`last_review`, `review_date`): UTC ISO-8601
  /// - This query uses ISO-8601 prefix comparison (lexicographic) to
  ///   select today's revlog entries regardless of time-of-day or timezone.
  Future<({int newCount, int reviewCount})> getTodayCounts(String language,
      [String? level]) async {
    final nowUtc = DateTime.now().toUtc();
    // Start of today UTC, as an ISO-8601 date-only prefix.
    final todayPrefix =
        '${nowUtc.year}-${nowUtc.month.toString().padLeft(2, '0')}-${nowUtc.day.toString().padLeft(2, '0')}';
    final tomorrow = nowUtc.add(const Duration(days: 1));
    final tomorrowPrefix =
        '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';

    final rows = await customSelect(
      '''SELECT
        SUM(CASE WHEN state = 0 THEN 1 ELSE 0 END) as new_cnt,
        SUM(CASE WHEN state IN (2,3) THEN 1 ELSE 0 END) as review_cnt
      FROM revlog WHERE deck_table = ? AND review_date >= ? AND review_date < ?''',
      variables: [
        Variable.withString(language),
        Variable.withString(todayPrefix),
        Variable.withString(tomorrowPrefix),
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
  //  Export helpers
  // ═══════════════════════════════════════════════════════════════

  /// All revlog entries for export.
  Future<List<Map<String, dynamic>>> fetchAllRevlog() async {
    final rows = await customSelect('SELECT * FROM revlog').get();
    return rows
        .map((r) => {
              'card_id': r.read<int>('card_id'),
              'deck_table': r.read<String>('deck_table'),
              'rating': r.read<int>('rating'),
              'state': r.read<int>('state'),
              'due': r.read<String>('due'),
              'stability': r.read<double>('stability'),
              'difficulty': r.read<double>('difficulty'),
              'elapsed_days': r.read<int>('elapsed_days'),
              'last_elapsed_days': r.read<int>('last_elapsed_days'),
              'scheduled_days': r.read<int>('scheduled_days'),
              'review_date': r.read<String>('review_date'),
            })
        .toList();
  }

  /// All deck configs for export.
  Future<List<Map<String, dynamic>>> fetchAllDeckConfigs() async {
    final rows = await customSelect('SELECT * FROM deck_config').get();
    return rows
        .map((r) => {
              'level': r.read<String>('level'),
              'max_new_per_day': r.read<int>('max_new_per_day'),
              'max_reviews_per_day': r.read<int>('max_reviews_per_day'),
              'learning_steps': r.read<String>('learning_steps'),
              'enable_fuzz': r.read<int>('enable_fuzz'),
              'request_retention': r.read<double>('request_retention'),
              'w': r.readNullable<String>('w'),
            })
        .toList();
  }

  /// Words with SRS progress (isSeen=1 or cardState != 0).
  Future<List<Map<String, dynamic>>> fetchSrsProgress() async {
    final rows = await customSelect(
      'SELECT * FROM words WHERE isSeen = 1 OR card_state != 0',
    ).get();
    return rows
        .map((r) => {
              'id': r.read<int>('id'),
              'language_code': r.read<String>('language_code'),
              'word': r.read<String>('word'),
              'level': r.read<String>('level'),
              'card_state': r.read<int>('card_state'),
              'stability': r.read<double>('stability'),
              'difficulty': r.read<double>('difficulty'),
              'due': r.readNullable<String>('due'),
              'elapsed_days': r.read<int>('elapsed_days'),
              'scheduled_days': r.read<int>('scheduled_days'),
              'reps': r.read<int>('reps'),
              'lapses': r.read<int>('lapses'),
              'last_review': r.readNullable<String>('last_review'),
              'isSeen': r.read<int>('isSeen'),
              'date': r.readNullable<String>('date'),
            })
        .toList();
  }

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
