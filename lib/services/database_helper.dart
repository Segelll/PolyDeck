import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:poly2/domain/models/word.dart';
import 'package:poly2/domain/models/revlog_entry.dart';
import 'package:poly2/domain/models/deck_config.dart';
import 'package:poly2/core/constants/app_constants.dart';
import 'package:poly2/core/utils/random_utils.dart';
import 'package:poly2/core/utils/date_utils.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._privateConstructor();
  static Database? _database;

  factory DBHelper() => _instance;

  DBHelper._privateConstructor();

  static DBHelper get instance => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'language_data.db');

      final dbExists = await databaseExists(path);

      if (!dbExists) {
        // Copy prebuilt DB from assets (2.5 MB) — offloaded via async I/O
        final data = await rootBundle.load('assets/language_data.db');
        final bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
      }

      return await openDatabase(
        path,
        version: 3,
        onConfigure: _onConfigure,
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await _runMigrationV2(db);
          }
          if (oldVersion < 3) {
            await _runMigrationV3(db);
          }
        },
        onCreate: (db, version) async {
          if (version >= 2) {
            await _runMigrationV2(db);
          }
          if (version >= 3) {
            await _runMigrationV3(db);
          }
        },
      );
    } catch (e) {
      throw Exception('Database initialization failed: $e');
    }
  }

  /// Apply performance PRAGMAs before any queries run.
  Future<void> _onConfigure(Database db) async {
    // WAL mode: writers don't block readers → smoother UI during concurrent access
    await db.execute('PRAGMA journal_mode=WAL');
    // NORMAL synchronous: still safe, much faster than FULL (default)
    await db.execute('PRAGMA synchronous=NORMAL');
    // 64 MB page cache — the DB is ~2.5 MB so this holds everything in memory
    await db.execute('PRAGMA cache_size=-64000');
    // Temp tables in memory
    await db.execute('PRAGMA temp_store=MEMORY');
    // Enable memory-mapped I/O for faster reads (64 MB)
    await db.execute('PRAGMA mmap_size=67108864');
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys=ON');
  }

  /// Adds FSRS scheduling columns, revlog table, deck_config table,
  /// and performance indices — all wrapped in a single transaction.
  Future<void> _runMigrationV2(Database db) async {
    const tables = ['en', 'tr', 'de', 'fr', 'it', 'pr', 'esp', 'fav'];

    // Wrap the ENTIRE migration in a single transaction.
    // Without this, each ALTER/UPDATE/CREATE is its own disk sync.
    await db.transaction((tx) async {
      // ── Add FSRS columns per language table ──
      const srsColumns = [
        'card_state', 'stability', 'difficulty', 'due',
        'elapsed_days', 'scheduled_days', 'reps', 'lapses', 'last_review',
      ];
      const srsColumnDefs = [
        'card_state INTEGER NOT NULL DEFAULT 0',
        'stability REAL NOT NULL DEFAULT 0.0',
        'difficulty REAL NOT NULL DEFAULT 0.0',
        'due TEXT DEFAULT NULL',
        'elapsed_days INTEGER NOT NULL DEFAULT 0',
        'scheduled_days INTEGER NOT NULL DEFAULT 0',
        'reps INTEGER NOT NULL DEFAULT 0',
        'lapses INTEGER NOT NULL DEFAULT 0',
        'last_review TEXT DEFAULT NULL',
      ];

      for (final table in tables) {
        for (final colDef in srsColumnDefs) {
          try {
            await tx.execute('ALTER TABLE "$table" ADD COLUMN $colDef');
          } catch (_) {
            // Column may already exist — safe to ignore
          }
        }
      }

      // ── Seed initial FSRS params from legacy data ──
      for (final table in tables) {
        try {
          await tx.execute('''
            UPDATE "$table" SET
              card_state = 2, stability = 1.0, difficulty = 7.0,
              reps = 1, elapsed_days = 1, scheduled_days = 1, last_review = date
            WHERE isSeen = 1 AND feedback = 1
          ''');
          await tx.execute('''
            UPDATE "$table" SET
              card_state = 2, stability = 3.0, difficulty = 3.0,
              reps = 2, elapsed_days = 3, scheduled_days = 3, last_review = date
            WHERE isSeen = 1 AND feedback = 2
          ''');
          await tx.execute('''
            UPDATE "$table" SET
              card_state = 2, stability = 1.5, difficulty = 5.0,
              reps = 1, elapsed_days = 1, scheduled_days = 1, last_review = date
            WHERE isSeen = 1 AND feedback = 3
          ''');
          await tx.execute('''
            UPDATE "$table" SET
              card_state = 2, stability = 0.5, difficulty = 5.0,
              reps = 1, elapsed_days = 1, scheduled_days = 1, last_review = date
            WHERE isSeen = 1 AND feedback = 0 AND date IS NOT NULL AND date != '0'
          ''');
        } catch (e) {
          if (kDebugMode) print('Seed FSRS params for $table: $e');
        }
      }

      // ── Create revlog table ──
      await tx.execute('''
        CREATE TABLE IF NOT EXISTS "revlog" (
          "id"              INTEGER PRIMARY KEY AUTOINCREMENT,
          "card_id"         INTEGER NOT NULL,
          "deck_table"      TEXT NOT NULL,
          "rating"          INTEGER NOT NULL,
          "state"           INTEGER NOT NULL,
          "due"             TEXT NOT NULL,
          "stability"       REAL NOT NULL,
          "difficulty"      REAL NOT NULL,
          "elapsed_days"    INTEGER NOT NULL,
          "last_elapsed_days" INTEGER NOT NULL DEFAULT 0,
          "scheduled_days"  INTEGER NOT NULL,
          "review_date"     TEXT NOT NULL
        )
      ''');
      await tx.execute('''
        CREATE INDEX IF NOT EXISTS "idx_revlog_card"
          ON "revlog" ("deck_table", "card_id")
      ''');
      await tx.execute('''
        CREATE INDEX IF NOT EXISTS "idx_revlog_date"
          ON "revlog" ("review_date")
      ''');
      // Composite index for today-count queries
      await tx.execute('''
        CREATE INDEX IF NOT EXISTS "idx_revlog_deck_date_state"
          ON "revlog" ("deck_table", "review_date", "state")
      ''');

      // ── Create deck_config table ──
      await tx.execute('''
        CREATE TABLE IF NOT EXISTS "deck_config" (
          "level"               TEXT PRIMARY KEY,
          "max_new_per_day"     INTEGER NOT NULL DEFAULT 10,
          "max_reviews_per_day" INTEGER NOT NULL DEFAULT 20,
          "learning_steps"      TEXT NOT NULL DEFAULT '[1,10]',
          "enable_fuzz"         INTEGER NOT NULL DEFAULT 1,
          "request_retention"   REAL NOT NULL DEFAULT 0.9,
          "w"                   TEXT DEFAULT NULL
        )
      ''');

      final levels = ['default', 'A1', 'A2', 'B1', 'B2', 'C1'];
      for (final level in levels) {
        try {
          await tx.insert('deck_config',
              DeckConfig.defaults().copyWithLevel(level).toMap(),
              conflictAlgorithm: ConflictAlgorithm.ignore);
        } catch (_) {}
      }

      // ── Create performance indices on ALL language tables ──
      // These are critical for fast FSRS deck loading.
      for (final table in tables) {
        // FSRS due-card query: WHERE level=? AND card_state IN (1,2,3) AND due<=? ORDER BY due
        try {
          await tx.execute(
            'CREATE INDEX IF NOT EXISTS "idx_${table}_fsrs_due" ON "$table" ("level", "card_state", "due")');
        } catch (_) {}
        // FSRS new-card query: WHERE level=? AND card_state=0 AND isSeen=0
        try {
          await tx.execute(
            'CREATE INDEX IF NOT EXISTS "idx_${table}_fsrs_new" ON "$table" ("level", "card_state", "isSeen")');
        } catch (_) {}
        // Seen-word query: WHERE level=? AND isSeen=?
        try {
          await tx.execute(
            'CREATE INDEX IF NOT EXISTS "idx_${table}_level_isSeen" ON "$table" ("level", "isSeen")');
        } catch (_) {}
        // Feedback-based queries
        try {
          await tx.execute(
            'CREATE INDEX IF NOT EXISTS "idx_${table}_feedback" ON "$table" ("isSeen", "feedback")');
        } catch (_) {}
      }
    });
  }

  /// v3 migration: adds performance indices that were missing in v2.
  Future<void> _runMigrationV3(Database db) async {
    const tables = ['en', 'tr', 'de', 'fr', 'it', 'pr', 'esp', 'fav'];

    await db.transaction((tx) async {
      // Add the composite revlog index (missing in v2)
      try {
        await tx.execute('''
          CREATE INDEX IF NOT EXISTS "idx_revlog_deck_date_state"
            ON "revlog" ("deck_table", "review_date", "state")
        ''');
      } catch (_) {}

      // Add performance indices on all language tables
      for (final table in tables) {
        try {
          await tx.execute(
            'CREATE INDEX IF NOT EXISTS "idx_${table}_fsrs_due" ON "$table" ("level", "card_state", "due")');
        } catch (_) {}
        try {
          await tx.execute(
            'CREATE INDEX IF NOT EXISTS "idx_${table}_fsrs_new" ON "$table" ("level", "card_state", "isSeen")');
        } catch (_) {}
        try {
          await tx.execute(
            'CREATE INDEX IF NOT EXISTS "idx_${table}_level_isSeen" ON "$table" ("level", "isSeen")');
        } catch (_) {}
        try {
          await tx.execute(
            'CREATE INDEX IF NOT EXISTS "idx_${table}_feedback" ON "$table" ("isSeen", "feedback")');
        } catch (_) {}
      }
    });

    // Analyze after adding indices so the query planner uses them
    try {
      await db.execute('ANALYZE');
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────────
  //  Existing query methods
  // ─────────────────────────────────────────────────────────────

  Future<void> updateIsSeenDate(String tableName, int id) async {
    final now = DateTime.now();
    final dateFormatted = formatDate(now);
    try {
      final db = await database;
      await db.update(
        tableName,
        {'isSeen': 1, 'date': dateFormatted},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to update isSeen: $e');
    }
  }

  Future<void> saveUserChoices(
      String tableName, String mainLanguage, String targetLanguage) async {
    try {
      final db = await database;
      await db.delete(tableName);
      await db.insert(tableName, {
        'mainLanguage': mainLanguage,
        'targetLanguage': targetLanguage,
        'firstTime': "true"
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw Exception('Failed to save user choices: $e');
    }
  }

  Future<String?> getEarliestDate(String tableName) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
          'SELECT MIN(date) as earliestDate FROM $tableName WHERE date != 0');
      if (result.isNotEmpty && result.first['earliestDate'] != null) {
        return result.first['earliestDate'] as String;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get earliest date: $e');
    }
  }

  Future<Map<String, String>?> getUserChoices(String tableName) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> result = await db.query(tableName);
      if (result.isNotEmpty) {
        return {
          'mainLanguage': result.first['mainLanguage'] as String,
          'targetLanguage': result.first['targetLanguage'] as String,
          'firstTime': result.first['firstTime'] as String,
        };
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user choices: $e');
    }
  }

  Future<void> updateFeedback(String tableName, int id, int feedback) async {
    try {
      final db = await database;
      await db.update(
        tableName,
        {'feedback': feedback},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to update feedback: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchWordsByFeedback(
      String tableName, String? level, int feedback, int limit) async {
    try {
      final db = await database;
      final whereClause =
          level != null ? 'level = ? AND feedback = ?' : 'feedback = ?';
      final whereArgs = level != null ? [level, feedback] : [feedback];
      return await db.query(tableName,
          where: whereClause, whereArgs: whereArgs, limit: limit);
    } catch (e) {
      throw Exception('Failed to fetch words by feedback: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchWordsByIsSeen(
      String tableName, String? level, int isSeen, int limit) async {
    try {
      final db = await database;
      final whereClause =
          level != null ? 'level = ? AND isSeen = ?' : 'isSeen = ?';
      final whereArgs = level != null ? [level, isSeen] : [isSeen];
      return await db.query(tableName,
          where: whereClause, whereArgs: whereArgs, limit: limit);
    } catch (e) {
      throw Exception('Failed to fetch words by isSeen: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllIsSeenId(
      String tableName) async {
    try {
      final db = await database;
      return await db.query(tableName,
          columns: ['id'], where: 'isSeen = ?', whereArgs: [1]);
    } catch (e) {
      throw Exception('Failed to fetch isSeen IDs: $e');
    }
  }

  Future<Word?> fetchWordById(String tableName, int id) async {
    try {
      final db = await database;
      final result = await db.query(tableName,
          where: 'id = ?', whereArgs: [id]);
      if (result.isNotEmpty) return Word.fromMap(result.first);
      return null;
    } catch (e) {
      throw Exception('Failed to fetch word by ID: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchExamWords(
      String tableName, int id) async {
    try {
      final db = await database;
      return await db.query(tableName, where: "id=?", whereArgs: [id]);
    } catch (e) {
      throw Exception('Failed to fetch exam words: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchExamOptions(
      String tableName) async {
    try {
      final db = await database;
      final randomIds = generateRandomIds(
        AppConstants.minWordId,
        AppConstants.maxWordId,
        AppConstants.distractorsPerQuestion,
      );
      // Batch query instead of N individual queries
      if (randomIds.isEmpty) return [];
      final placeholders = randomIds.map((_) => '?').join(',');
      return await db.rawQuery(
        'SELECT * FROM "$tableName" WHERE id IN ($placeholders)',
        randomIds,
      );
    } catch (e) {
      throw Exception('Failed to fetch exam options: $e');
    }
  }

  Future<void> addToFavorites(String word, String sentence, String level,
      String? backWord, String? backSentence) async {
    final db = await instance.database;
    await db.insert('fav', {
      'word': word,
      'sentence': sentence,
      'level': "fav",
      'backword': backWord ?? '',
      'backsentence': backSentence ?? '',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeFromFavorites(String word) async {
    final db = await instance.database;
    await db.delete('fav', where: 'word = ?', whereArgs: [word]);
  }

  Future<bool> isFavorite(String word) async {
    try {
      final db = await instance.database;
      final result = await db.query('fav',
          where: 'word = ?', whereArgs: [word]);
      return result.isNotEmpty;
    } catch (e) {
      if (kDebugMode) print('Error checking favorite: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllFavWords() async {
    final db = await instance.database;
    try {
      return await db.query('fav');
    } catch (e) {
      if (kDebugMode) print('Error fetching favorites: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  FSRS scheduling methods (optimized)
  // ─────────────────────────────────────────────────────────────

  /// Fetches cards due for review on or before [date] for a given level.
  Future<List<Map<String, dynamic>>> fetchDueCards(
    String tableName,
    String? level,
    String date,
    int limit,
  ) async {
    final db = await database;
    final where = level != null
        ? 'level = ? AND due IS NOT NULL AND due <= ? AND card_state IN (1,2,3)'
        : 'due IS NOT NULL AND due <= ? AND card_state IN (1,2,3)';
    final args = level != null ? [level, date] : [date];
    return db.query(tableName,
        where: where, whereArgs: args, orderBy: 'due ASC', limit: limit);
  }

  /// Fetches multiple words by their IDs in a single query.
  Future<List<Map<String, dynamic>>> fetchWordsByIds(
    String tableName,
    List<int> ids,
  ) async {
    if (ids.isEmpty) return [];
    final db = await database;
    final placeholders = ids.map((_) => '?').join(',');
    return db.rawQuery(
      'SELECT * FROM "$tableName" WHERE id IN ($placeholders)',
      ids,
    );
  }

  /// Fetches new (unseen, never-reviewed) cards up to [limit].
  /// Uses rowid-based random sampling instead of ORDER BY RANDOM() for performance.
  Future<List<Map<String, dynamic>>> fetchNewCards(
    String tableName,
    String? level,
    int limit,
  ) async {
    final db = await database;
    // Use ABS(RANDOM() % maxId) trick to pick random rows efficiently.
    // Much faster than ORDER BY RANDOM() which does O(n log n) sort.
    final where = level != null
        ? 'level = ? AND card_state = 0 AND isSeen = 0'
        : 'card_state = 0 AND isSeen = 0';
    final args = level != null ? [level] : <Object>[];

    // First, get a pool of candidates (up to 100) then randomly pick
    final candidates = await db.query(
      tableName,
      where: where,
      whereArgs: args.isNotEmpty ? args : null,
      limit: 100,
      columns: ['id'],
    );

    if (candidates.length <= limit) {
      // Not enough candidates, fetch all of them
      final result = await db.query(
        tableName,
        where: where,
        whereArgs: args.isNotEmpty ? args : null,
        limit: limit,
      );
      result.shuffle();
      return result;
    }

    // Randomly select `limit` IDs from the candidate pool
    candidates.shuffle();
    final selectedIds = candidates.take(limit).map((c) => c['id'] as int).toList();
    if (selectedIds.isEmpty) return [];

    final placeholders = selectedIds.map((_) => '?').join(',');
    final result = await db.rawQuery(
      'SELECT * FROM "$tableName" WHERE id IN ($placeholders)',
      selectedIds,
    );
    result.shuffle();
    return result;
  }

  /// Updates all FSRS scheduling fields for a card (including legacy feedback).
  Future<void> updateSrsState(
    String tableName,
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
    int? legacyFeedback,
  }) async {
    final db = await database;
    final values = <String, dynamic>{
      'card_state': cardState,
      'stability': stability,
      'difficulty': difficulty,
      'due': due,
      'elapsed_days': elapsedDays,
      'scheduled_days': scheduledDays,
      'reps': reps,
      'lapses': lapses,
      'last_review': lastReview,
    };
    if (legacyFeedback != null) {
      values['feedback'] = legacyFeedback;
    }
    await db.update(
      tableName,
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Batch marks multiple cards as seen.
  Future<void> markMultipleAsSeen(
      String tableName, List<int> ids, String date) async {
    if (ids.isEmpty) return;
    final db = await database;
    final placeholders = ids.map((_) => '?').join(',');
    await db.rawUpdate(
      'UPDATE "$tableName" SET isSeen = 1, date = ? WHERE id IN ($placeholders)',
      [date, ...ids],
    );
  }

  /// Inserts a review log entry.
  Future<void> insertRevlog(RevlogEntry entry) async {
    final db = await database;
    await db.insert('revlog', entry.toMap());
  }

  /// Combined query: fetches both today's new and review counts in a single query.
  Future<({int newCount, int reviewCount})> getTodayCounts(
      String tableName, String? level) async {
    final db = await database;
    final today = formatDate(DateTime.now());
    final tomorrow = formatDate(DateTime.now().add(const Duration(days: 1)));

    // Use >= AND < instead of LIKE for index-friendly date range
    final where = level != null
        ? 'deck_table = ? AND review_date >= ? AND review_date < ?'
        : 'review_date >= ? AND review_date < ?';
    final args = level != null
        ? [tableName, today, tomorrow]
        : [today, tomorrow];

    final result = await db.rawQuery('''
      SELECT
        SUM(CASE WHEN state = 0 THEN 1 ELSE 0 END) as new_cnt,
        SUM(CASE WHEN state IN (2,3) THEN 1 ELSE 0 END) as review_cnt
      FROM revlog
      WHERE $where
    ''', args);

    return (
      newCount: result.first['new_cnt'] as int? ?? 0,
      reviewCount: result.first['review_cnt'] as int? ?? 0,
    );
  }

  /// Loads deck config from the database.
  Future<DeckConfig?> getDeckConfig(String level) async {
    final db = await database;
    final result = await db.query('deck_config',
        where: 'level = ?', whereArgs: [level]);
    if (result.isNotEmpty) return DeckConfig.fromMap(result.first);
    // Fall back to default
    final defaultResult = await db.query('deck_config',
        where: 'level = ?', whereArgs: ['default']);
    if (defaultResult.isNotEmpty) {
      return DeckConfig.fromMap(defaultResult.first).copyWithLevel(level);
    }
    return DeckConfig.defaults().copyWithLevel(level);
  }

  /// Saves deck config to the database.
  Future<void> saveDeckConfig(DeckConfig config) async {
    final db = await database;
    await db.insert('deck_config', config.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Resets FSRS state for a table (sets all cards to New).
  Future<void> resetSrsState(String tableName) async {
    final db = await database;
    await db.update(tableName, {
      'card_state': 0,
      'stability': 0.0,
      'difficulty': 0.0,
      'due': null,
      'elapsed_days': 0,
      'scheduled_days': 0,
      'reps': 0,
      'lapses': 0,
      'last_review': null,
    });
  }
}

// ─────────────────────────────────────────────────────────────
//  DeckConfig helper extension
// ─────────────────────────────────────────────────────────────

extension DeckConfigCopy on DeckConfig {
  DeckConfig copyWithLevel(String newLevel) {
    return DeckConfig(
      level: newLevel,
      maxNewPerDay: maxNewPerDay,
      maxReviewsPerDay: maxReviewsPerDay,
      learningSteps: learningSteps,
      enableFuzz: enableFuzz,
      requestRetention: requestRetention,
      w: w,
    );
  }
}
