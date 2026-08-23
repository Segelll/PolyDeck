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
import '../../domain/models/deck_summary.dart';

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

/// A vocabulary row together with the language pair stored in a deck.
class DeckWordEntry {
  final Word word;
  final String sourceLanguage;
  final String targetLanguage;
  final String? sourceWord;
  final String? sourceSentence;

  const DeckWordEntry({
    required this.word,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.sourceWord,
    this.sourceSentence,
  });
}

@DriftDatabase(
  tables: [Words, RevlogEntries, DeckConfigs, UserSettings, Decks, DeckCards],
)
class AppDatabase extends _$AppDatabase {
  final bool _validatePreloadedData;

  AppDatabase()
    : _validatePreloadedData = true,
      super(DatabaseConnection.delayed(_connect()));

  /// In-memory constructor for repository/database tests.
  AppDatabase.forTesting(QueryExecutor executor)
    : _validatePreloadedData = false,
      super(DatabaseConnection(executor));

  static Future<DatabaseConnection> _connect() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(appDir.path, 'polydesk.db');

    if (!await File(dbPath).exists()) {
      await PerfTrace.timeAsync('db.copyAsset', () async {
        try {
          final data = await rootBundle.load('assets/polydesk.db');
          final bytes = data.buffer.asUint8List(
            data.offsetInBytes,
            data.lengthInBytes,
          );
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
        NativeDatabase.createInBackground(
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

  // Drift requires a positive schema identifier. This app ships one schema
  // and intentionally has no upgrade path; reset the local database when the
  // schema changes before production.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    beforeOpen: (details) async {
      // The shipped asset already contains its indexes and the favorites
      // system deck. Avoid issuing schema-write statements on every launch.
      // In-memory databases use Drift's normal createAll path; the favorites
      // deck is ensured by the repository before it is queried.
      if (_validatePreloadedData) await _validateDatabase();
    },
  );

  Future<void> _ensureFavoritesDeck() async {
    final existing = await (select(
      decks,
    )..where((d) => d.systemKey.equals('favorites'))).getSingleOrNull();
    if (existing != null) return;

    await into(decks).insert(
      DecksCompanion.insert(
        name: 'Favoriler',
        deckType: 'system',
        systemKey: const Value('favorites'),
        createdAt: DateTime.now().toUtc().toIso8601String(),
      ),
    );
  }

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
    // One grouped read replaces separate count, language, and level queries.
    // The shipped vocabulary is small enough that the result is only one row
    // per language-level pair, while startup avoids seven DB round trips.
    final rows = await customSelect(
      'SELECT language_code, level, COUNT(*) AS word_count '
      'FROM words GROUP BY language_code, level',
    ).get();
    if (rows.isEmpty) {
      throw const DatabaseIntegrityException(
        'Database is empty. Please reinstall the app.',
      );
    }

    final languages = <String>{};
    final levels = <String>{};
    for (final row in rows) {
      languages.add(row.read<String>('language_code'));
      levels.add(row.read<String>('level'));
    }

    // Expected language codes must be present.
    const expectedLangs = ['en', 'tr', 'de', 'fr', 'it', 'pt', 'es'];
    for (final lang in expectedLangs) {
      if (!languages.contains(lang)) {
        throw DatabaseIntegrityException(
          'Missing language data for "$lang". Please reinstall the app.',
        );
      }
    }

    // All five CEFR levels must be present for at least one language.
    const expectedLevels = ['A1', 'A2', 'B1', 'B2', 'C1'];
    for (final level in expectedLevels) {
      if (!levels.contains(level)) {
        throw DatabaseIntegrityException(
          'Missing CEFR level "$level". Please reinstall the app.',
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  Type-safe word queries (unified words table)
  // ═══════════════════════════════════════════════════════════════

  /// Fetches a word by its composite primary key `(languageCode, id)`.
  /// The same `id` exists across all 7 languages, so the language filter
  /// is required to avoid returning the wrong language's row.
  Future<Word?> fetchWordById(String languageCode, int id) =>
      (select(words)..where(
            (w) => w.languageCode.equals(languageCode) & w.id.equals(id),
          ))
          .getSingleOrNull();

  Future<List<Word>> fetchWordsByIds(String language, List<int> ids) {
    if (ids.isEmpty) return Future.value([]);
    return (select(
      words,
    )..where((w) => w.languageCode.equals(language) & w.id.isIn(ids))).get();
  }

  Future<List<Word>> fetchDueCards(
    String language,
    String? level,
    String date,
    int limit,
  ) {
    if (limit <= 0) return Future.value([]);
    // Build the query once with a conditional level predicate.
    // The old code overwrote q when level was set — this is cleaner.
    final q = select(words);
    if (level != null && level != 'fav') {
      q.where(
        (w) =>
            w.languageCode.equals(language) &
            w.level.equals(level) &
            w.due.isNotNull() &
            w.due.isSmallerOrEqualValue(date) &
            w.cardState.isIn([1, 2, 3]),
      );
    } else {
      q.where(
        (w) =>
            w.languageCode.equals(language) &
            w.due.isNotNull() &
            w.due.isSmallerOrEqualValue(date) &
            w.cardState.isIn([1, 2, 3]),
      );
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
    String language,
    String? level,
    int limit,
  ) async {
    if (limit <= 0) return [];
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
    final startId =
        minId + (idRange > limit ? rng.nextInt(idRange - limit + 1) : 0);

    // ── Fetch a window starting from startId ──
    final fetchVars = <Variable<Object>>[
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

    // IDs can have gaps after an import or a data reset. Wrap around to the
    // beginning so sparse IDs do not make a deck appear shorter than it is.
    if (rows.length < limit) {
      final remaining = limit - rows.length;
      final wrappedRows = await customSelect(
        'SELECT * FROM words WHERE $whereSql AND id < ? '
        'ORDER BY id LIMIT ?',
        variables: [
          ...vars,
          Variable.withInt(startId),
          Variable.withInt(remaining),
        ],
        readsFrom: {words},
      ).get();
      rows.addAll(wrappedRows);
    }

    final result = <Word>[];
    for (final row in rows) {
      result.add(await words.mapFromRow(row));
    }
    return result;
  }

  Future<List<Word>> fetchWordsByIsSeen(
    String language,
    String? level,
    int isSeen,
    int limit, {
    List<int> excludeIds = const [],
  }) {
    if (limit <= 0) return Future.value([]);

    return (select(words)
          ..where((w) {
            Expression<bool> condition =
                w.languageCode.equals(language) & w.isSeen.equals(isSeen);
            if (level != null && level != 'fav') {
              condition = condition & w.level.equals(level);
            }
            if (excludeIds.isNotEmpty) {
              condition = condition & w.id.isNotIn(excludeIds);
            }
            return condition;
          })
          ..limit(limit))
        .get();
  }

  Future<List<Word>> fetchWordsByFeedback(
    String language,
    String? level,
    int feedback,
    int limit,
  ) {
    var q = select(words)
      ..where(
        (w) => w.languageCode.equals(language) & w.feedback.equals(feedback),
      )
      ..limit(limit);
    if (level != null && level != 'fav') {
      q = select(words)
        ..where(
          (w) =>
              w.languageCode.equals(language) &
              w.level.equals(level) &
              w.feedback.equals(feedback),
        )
        ..limit(limit);
    }
    return q.get();
  }

  Future<List<int>> fetchAllIsSeenId(String language) async {
    final rows =
        await (selectOnly(words)
              ..addColumns([words.id])
              ..where(
                words.languageCode.equals(language) & words.isSeen.equals(1),
              ))
            .get();
    return rows.map((r) => r.read(words.id)!).toList();
  }

  Future<String?> getEarliestDate(String language) async {
    final rows = await customSelect(
      'SELECT date FROM words '
      'WHERE language_code = ? AND date IS NOT NULL '
      "AND date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]*' "
      'ORDER BY date ASC LIMIT 1',
      variables: [Variable.withString(language)],
      readsFrom: {words},
    ).get();
    return rows.firstOrNull?.readNullable<String>('date');
  }

  /// Fetches all word IDs for [language] + [level], ordered by id.
  /// Used by exam generation to sample questions without hardcoded ranges.
  Future<List<int>> fetchWordIds({
    required String language,
    required String level,
  }) async {
    final rows =
        await (selectOnly(words)
              ..addColumns([words.id])
              ..where(
                words.languageCode.equals(language) & words.level.equals(level),
              )
              ..orderBy([OrderingTerm.asc(words.id)]))
            .get();
    return rows.map((r) => r.read<int>(words.id)!).toList();
  }

  /// Fetches word IDs for several CEFR levels with one database query.
  ///
  /// The returned map contains every requested level, including levels with
  /// no matching words. IDs are ordered so callers can apply the same random
  /// sampling policy without depending on SQLite row order.
  Future<Map<String, List<int>>> fetchWordIdsByLevels({
    required String language,
    required List<String> levels,
  }) async {
    if (levels.isEmpty) return {};

    final rows =
        await (selectOnly(words)
              ..addColumns([words.level, words.id])
              ..where(
                words.languageCode.equals(language) & words.level.isIn(levels),
              )
              ..orderBy([
                OrderingTerm.asc(words.level),
                OrderingTerm.asc(words.id),
              ]))
            .get();

    final result = <String, List<int>>{
      for (final level in levels) level: <int>[],
    };
    for (final row in rows) {
      final level = row.read<String>(words.level);
      result[level]!.add(row.read<int>(words.id)!);
    }
    return result;
  }

  Future<List<Word>> fetchExamWords(String language, int id) => (select(
    words,
  )..where((w) => w.languageCode.equals(language) & w.id.equals(id))).get();

  Future<List<Word>> fetchExamOptions(String language, List<int> ids) {
    if (ids.isEmpty) return Future.value([]);
    return (select(
      words,
    )..where((w) => w.languageCode.equals(language) & w.id.isIn(ids))).get();
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
    required int reviewState,
    String? due,
    required int elapsedDays,
    required int scheduledDays,
    required int reps,
    required int lapses,
    String? lastReview,
    int? feedbackValue,
    required String reviewDate,
    String? guardLastReview,
  }) async {
    return transaction(() async {
      // ── Optimistic guard ──
      // Always re-fetch the current row by its full PK to detect duplicate
      // reviews. Works for both new cards (guardLastReview == null) and
      // reviewed cards.
      final currentWord =
          await (select(words)..where(
                (w) => w.languageCode.equals(deckTable) & w.id.equals(wordId),
              ))
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
        feedback: feedbackValue != null
            ? Value(feedbackValue)
            : const Value.absent(),
      );
      await (update(words)..where(
            (w) => w.languageCode.equals(deckTable) & w.id.equals(wordId),
          ))
          .write(values);

      // ── Insert revlog entry ──
      await into(revlogEntries).insert(
        RevlogEntriesCompanion.insert(
          cardId: wordId,
          deckTable: deckTable,
          rating: rating,
          // Revlog state is the state before the review. The word row stores
          // the resulting state used by the next FSRS review.
          state: reviewState,
          due: due ?? '',
          stability: stability,
          difficulty: difficulty,
          elapsedDays: elapsedDays,
          lastElapsedDays: Value(elapsedDays),
          scheduledDays: scheduledDays,
          reviewDate: reviewDate,
        ),
      );

      return true;
    });
  }

  Future<void> updateSrsState(
    String languageCode,
    int id, {
    required int cardState,
    required double stability,
    required double difficulty,
    String? due,
    required int elapsedDays,
    required int scheduledDays,
    required int reps,
    required int lapses,
    String? lastReview,
    int? feedbackValue,
  }) async {
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
      feedback: feedbackValue != null
          ? Value(feedbackValue)
          : const Value.absent(),
    );
    await (update(words)
          ..where((w) => w.languageCode.equals(languageCode) & w.id.equals(id)))
        .write(values);
  }

  Future<void> markAsSeen(String languageCode, int id, String date) =>
      (update(words)..where(
            (w) => w.languageCode.equals(languageCode) & w.id.equals(id),
          ))
          .write(WordsCompanion(isSeen: const Value(1), date: Value(date)));

  Future<void> markMultipleAsSeen(
    String languageCode,
    List<int> ids,
    String date,
  ) async {
    if (ids.isEmpty) return;
    // Build parameterized IN clause: language_code = ? AND id IN (?, ?, ...)
    final placeholders = ids.map((_) => '?').join(',');
    await customStatement(
      'UPDATE words SET isSeen = 1, date = ? '
      'WHERE language_code = ? AND id IN ($placeholders)',
      [date, languageCode, ...ids],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  User decks
  // ═══════════════════════════════════════════════════════════════

  Future<int> ensureFavoritesDeck() async {
    await _ensureFavoritesDeck();
    final row = await (select(
      decks,
    )..where((d) => d.systemKey.equals('favorites'))).getSingle();
    return row.id;
  }

  Future<List<DeckSummary>> fetchDeckSummaries() async {
    await _ensureFavoritesDeck();
    final rows = await customSelect('''
      SELECT d.id, d.name, d.deck_type, d.system_key, d.created_at,
             COUNT(dc.deck_id) AS card_count
      FROM decks d
      LEFT JOIN deck_cards dc ON dc.deck_id = d.id
      WHERE d.deck_type IN ('system', 'custom')
      GROUP BY d.id
      ORDER BY CASE WHEN d.system_key = 'favorites' THEN 0 ELSE 1 END,
               d.created_at ASC
    ''').get();

    return rows
        .map(
          (row) => DeckSummary(
            id: row.read<int>('id'),
            name: row.read<String>('name'),
            deckType: row.read<String>('deck_type'),
            systemKey: row.readNullable<String>('system_key'),
            cardCount: row.read<int>('card_count'),
          ),
        )
        .toList();
  }

  Future<int> createCustomDeck(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError('Deck name cannot be empty');
    if (trimmed.length > 60) {
      throw ArgumentError('Deck name cannot exceed 60 characters');
    }

    return into(decks).insert(
      DecksCompanion.insert(
        name: trimmed,
        deckType: 'custom',
        createdAt: DateTime.now().toUtc().toIso8601String(),
      ),
    );
  }

  Future<void> deleteCustomDeck(int deckId) async {
    await transaction(() async {
      await (delete(deckCards)..where((c) => c.deckId.equals(deckId))).go();
      await (delete(
        decks,
      )..where((d) => d.id.equals(deckId) & d.deckType.equals('custom'))).go();
    });
  }

  Future<void> addWordToDeck({
    required int deckId,
    required int wordId,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    await into(deckCards).insertOnConflictUpdate(
      DeckCardsCompanion.insert(
        deckId: deckId,
        wordId: wordId,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        addedAt: DateTime.now().toUtc().toIso8601String(),
      ),
    );
  }

  Future<bool> isWordInDeck({
    required int deckId,
    required int wordId,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    final row =
        await (select(deckCards)..where(
              (c) =>
                  c.deckId.equals(deckId) &
                  c.wordId.equals(wordId) &
                  c.sourceLanguage.equals(sourceLanguage) &
                  c.targetLanguage.equals(targetLanguage),
            ))
            .getSingleOrNull();
    return row != null;
  }

  Future<List<DeckWordEntry>> fetchDeckWords(int deckId, int limit) async {
    if (limit <= 0) return [];
    final now = DateTime.now().toUtc();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final rows = await customSelect(
      '''
      SELECT w.*,
             dc.source_language AS deck_source_language,
             dc.target_language AS deck_target_language,
             source.word AS source_word,
             source.sentence AS source_sentence
      FROM deck_cards dc
      JOIN words w
        ON w.language_code = dc.target_language AND w.id = dc.word_id
      LEFT JOIN words source
        ON source.language_code = dc.source_language AND source.id = dc.word_id
      WHERE dc.deck_id = ?
      ORDER BY CASE
                 WHEN w.due IS NOT NULL AND w.due <= ?
                      AND w.card_state IN (1, 2, 3) THEN 0
                 WHEN w.card_state = 0 THEN 1
                 ELSE 2
               END,
               COALESCE(w.due, '9999-12-31'), dc.added_at
      LIMIT ?
    ''',
      variables: [
        Variable.withInt(deckId),
        Variable.withString(today),
        Variable.withInt(limit),
      ],
      readsFrom: {words, deckCards},
    ).get();

    final entries = <DeckWordEntry>[];
    for (final row in rows) {
      entries.add(
        DeckWordEntry(
          word: await words.mapFromRow(row),
          sourceLanguage: row.read<String>('deck_source_language'),
          targetLanguage: row.read<String>('deck_target_language'),
          sourceWord: row.readNullable<String>('source_word'),
          sourceSentence: row.readNullable<String>('source_sentence'),
        ),
      );
    }
    return entries;
  }

  Future<int> getTodaySeenCount(String language) async {
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final row = await customSelect(
      'SELECT COUNT(*) AS count FROM words '
      'WHERE language_code = ? AND isSeen = 1 AND date = ?',
      variables: [Variable.withString(language), Variable.withString(today)],
    ).getSingle();
    return row.read<int>('count');
  }

  Future<Word?> fetchWordByText(String language, String text) =>
      (select(words)..where(
            (w) => w.languageCode.equals(language) & w.word.equals(text),
          ))
          .getSingleOrNull();

  Future<List<Map<String, dynamic>>> fetchAllDeckCardsForExport() async {
    final rows = await customSelect('''
      SELECT deck_id, word_id, source_language, target_language, added_at
      FROM deck_cards ORDER BY deck_id, added_at
    ''').get();
    return rows
        .map(
          (row) => {
            'deck_id': row.read<int>('deck_id'),
            'word_id': row.read<int>('word_id'),
            'source_language': row.read<String>('source_language'),
            'target_language': row.read<String>('target_language'),
            'added_at': row.read<String>('added_at'),
          },
        )
        .toList();
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
      'reviewMode': r.reviewMode,
    };
  }

  Future<void> saveUserChoices(
    String mainLanguage,
    String targetLanguage, {
    String reviewMode = 'buttons',
  }) async {
    final normalizedMode = reviewMode == 'swipe' ? 'swipe' : 'buttons';
    await transaction(() async {
      // The preferences table intentionally stores one row and has no primary
      // key, so replacing the row is clearer than using an invalid upsert.
      await delete(userSettings).go();
      await into(userSettings).insert(
        UserSettingsCompanion.insert(
          mainLanguage: mainLanguage,
          targetLanguage: targetLanguage,
          firstTime: 'false',
          reviewMode: Value(normalizedMode),
        ),
      );
    });
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
  }) async => into(revlogEntries).insert(
    RevlogEntriesCompanion.insert(
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
    ),
  );

  /// Counts today's new and review cards for [language].
  ///
  /// Date storage strategy (see plan §1.6):
  /// - Day-level fields (`date`, `due`): `YYYY-MM-DD` string
  /// - Timestamps (`last_review`, `review_date`): UTC ISO-8601
  /// - The local calendar day is converted to a UTC range before querying so
  ///   the daily limit matches the local "today" counter.
  Future<({int newCount, int reviewCount})> getTodayCounts(
    String language, [
    String? level,
  ]) async {
    final nowLocal = DateTime.now();
    final localStart = DateTime(
      nowLocal.year,
      nowLocal.month,
      nowLocal.day,
    ).toUtc();
    final localEnd = localStart.add(const Duration(days: 1));
    final startIso = localStart.toIso8601String();
    final endIso = localEnd.toIso8601String();

    var sql = '''SELECT
          SUM(CASE WHEN r.state = 0 THEN 1 ELSE 0 END) as new_cnt,
          SUM(CASE WHEN r.state IN (2,3) THEN 1 ELSE 0 END) as review_cnt
        FROM revlog r
        LEFT JOIN words w
          ON w.language_code = r.deck_table AND w.id = r.card_id
        WHERE r.deck_table = ? AND r.review_date >= ? AND r.review_date < ?''';
    final variables = <Variable<Object>>[
      Variable.withString(language),
      Variable.withString(startIso),
      Variable.withString(endIso),
    ];
    if (level != null && level != 'fav') {
      sql += ' AND w.level = ?';
      variables.add(Variable.withString(level));
    }

    final rows = await customSelect(
      sql,
      variables: variables,
      readsFrom: {revlogEntries, words},
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
    final rows = await (select(
      deckConfigs,
    )..where((t) => t.level.equals(level))).get();
    if (rows.isNotEmpty) return rows.first;
    return (select(
      deckConfigs,
    )..where((t) => t.level.equals('default'))).getSingleOrNull();
  }

  Future<void> saveDeckConfigEntry({
    required String level,
    required int maxNewPerDay,
    required int maxReviewsPerDay,
    required String learningSteps,
    required bool enableFuzz,
    required double requestRetention,
    String? w,
  }) async => into(deckConfigs).insertOnConflictUpdate(
    DeckConfigsCompanion.insert(
      level: level,
      maxNewPerDay: Value(maxNewPerDay),
      maxReviewsPerDay: Value(maxReviewsPerDay),
      learningSteps: Value(learningSteps),
      enableFuzz: Value(enableFuzz ? 1 : 0),
      requestRetention: Value(requestRetention),
      w: Value(w),
    ),
  );

  // ═══════════════════════════════════════════════════════════════
  //  Export helpers
  // ═══════════════════════════════════════════════════════════════

  /// All revlog entries for export.
  Future<List<Map<String, dynamic>>> fetchAllRevlog() async {
    final rows = await customSelect('SELECT * FROM revlog').get();
    return rows
        .map(
          (r) => {
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
          },
        )
        .toList();
  }

  /// All deck configs for export.
  Future<List<Map<String, dynamic>>> fetchAllDeckConfigs() async {
    final rows = await customSelect('SELECT * FROM deck_config').get();
    return rows
        .map(
          (r) => {
            'level': r.read<String>('level'),
            'max_new_per_day': r.read<int>('max_new_per_day'),
            'max_reviews_per_day': r.read<int>('max_reviews_per_day'),
            'learning_steps': r.read<String>('learning_steps'),
            'enable_fuzz': r.read<int>('enable_fuzz'),
            'request_retention': r.read<double>('request_retention'),
            'w': r.readNullable<String>('w'),
          },
        )
        .toList();
  }

  /// Words with SRS progress (isSeen=1 or cardState != 0).
  Future<List<Map<String, dynamic>>> fetchSrsProgress() async {
    final rows = await customSelect(
      'SELECT * FROM words WHERE isSeen = 1 OR card_state != 0',
    ).get();
    return rows
        .map(
          (r) => {
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
          },
        )
        .toList();
  }

  // ═══════════════════════════════════════════════════════════════
  //  Reset
  // ═══════════════════════════════════════════════════════════════

  Future<void> resetSrsState(String language) async {
    await (update(words)..where((w) => w.languageCode.equals(language))).write(
      const WordsCompanion(
        cardState: Value(0),
        stability: Value(0.0),
        difficulty: Value(0.0),
        due: Value(null),
        elapsedDays: Value(0),
        scheduledDays: Value(0),
        reps: Value(0),
        lapses: Value(0),
        lastReview: Value(null),
      ),
    );
  }

  Future<void> resetAllProgress() async {
    await (update(words)).write(
      const WordsCompanion(
        isSeen: Value(0),
        date: Value(''),
        feedback: Value(0),
        cardState: Value(0),
        stability: Value(0.0),
        difficulty: Value(0.0),
        due: Value(null),
        elapsedDays: Value(0),
        scheduledDays: Value(0),
        reps: Value(0),
        lapses: Value(0),
        lastReview: Value(null),
      ),
    );
    await delete(deckCards).go();
    await (delete(decks)..where((d) => d.deckType.equals('custom'))).go();
    await _ensureFavoritesDeck();
    await customStatement('DELETE FROM revlog');
  }
}
