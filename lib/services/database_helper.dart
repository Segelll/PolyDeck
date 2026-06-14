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
        ByteData data = await rootBundle.load('assets/language_data.db');
        List<int> bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
      }

      return await openDatabase(
        path,
        version: 2,
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await _runMigrationV2(db);
          }
        },
        onCreate: (db, version) async {
          // If created fresh (not from asset), run v2 migration to add SRS columns
          if (version >= 2) {
            await _runMigrationV2(db);
          }
        },
      );
    } catch (e) {
      throw Exception('Database initialization failed: $e');
    }
  }

  /// Adds FSRS scheduling columns, revlog table, and deck_config table.
  Future<void> _runMigrationV2(Database db) async {
    const srsColumns = [
      'ALTER TABLE "en" ADD COLUMN "card_state" INTEGER NOT NULL DEFAULT 0',
      'ALTER TABLE "en" ADD COLUMN "stability" REAL NOT NULL DEFAULT 0.0',
      'ALTER TABLE "en" ADD COLUMN "difficulty" REAL NOT NULL DEFAULT 0.0',
      'ALTER TABLE "en" ADD COLUMN "due" TEXT DEFAULT NULL',
      'ALTER TABLE "en" ADD COLUMN "elapsed_days" INTEGER NOT NULL DEFAULT 0',
      'ALTER TABLE "en" ADD COLUMN "scheduled_days" INTEGER NOT NULL DEFAULT 0',
      'ALTER TABLE "en" ADD COLUMN "reps" INTEGER NOT NULL DEFAULT 0',
      'ALTER TABLE "en" ADD COLUMN "lapses" INTEGER NOT NULL DEFAULT 0',
      'ALTER TABLE "en" ADD COLUMN "last_review" TEXT DEFAULT NULL',
    ];

    const tables = ['en', 'tr', 'de', 'fr', 'it', 'pr', 'esp', 'fav'];

    for (final table in tables) {
      for (final col in srsColumns) {
        try {
          await db.execute(col.replaceAll('"en"', '"$table"'));
        } catch (_) {
          // Column may already exist — safe to ignore
        }
      }
    }

    // Seed initial FSRS params from legacy data where available
    for (final table in tables) {
      try {
        // Words seen with hard feedback → moderate initial stability
        await db.execute('''
          UPDATE "$table" SET
            card_state = 2,
            stability = 1.0,
            difficulty = 7.0,
            reps = 1,
            elapsed_days = 1,
            scheduled_days = 1,
            last_review = date
          WHERE isSeen = 1 AND feedback = 1
        ''');
        // Words seen with easy feedback → higher initial stability
        await db.execute('''
          UPDATE "$table" SET
            card_state = 2,
            stability = 3.0,
            difficulty = 3.0,
            reps = 2,
            elapsed_days = 3,
            scheduled_days = 3,
            last_review = date
          WHERE isSeen = 1 AND feedback = 2
        ''');
        // Words seen with medium feedback → moderate stability
        await db.execute('''
          UPDATE "$table" SET
            card_state = 2,
            stability = 1.5,
            difficulty = 5.0,
            reps = 1,
            elapsed_days = 1,
            scheduled_days = 1,
            last_review = date
          WHERE isSeen = 1 AND feedback = 3
        ''');
        // Words seen but no feedback → low initial stability
        await db.execute('''
          UPDATE "$table" SET
            card_state = 2,
            stability = 0.5,
            difficulty = 5.0,
            reps = 1,
            elapsed_days = 1,
            scheduled_days = 1,
            last_review = date
          WHERE isSeen = 1 AND feedback = 0 AND date IS NOT NULL AND date != '0'
        ''');
      } catch (e) {
        if (kDebugMode) print('Seed FSRS params for $table: $e');
      }
    }

    await db.execute('''
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

    await db.execute('''
      CREATE INDEX IF NOT EXISTS "idx_revlog_card"
        ON "revlog" ("deck_table", "card_id")
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS "idx_revlog_date"
        ON "revlog" ("review_date")
    ''');

    await db.execute('''
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

    // Seed default configs for all levels
    final levels = ['default', 'A1', 'A2', 'B1', 'B2', 'C1'];
    for (final level in levels) {
      try {
        await db.insert('deck_config', DeckConfig.defaults().copyWithLevel(level).toMap(),
            conflictAlgorithm: ConflictAlgorithm.ignore);
      } catch (_) {}
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  Existing methods (unchanged)
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
      final whereArgs =
          level != null ? [level, feedback] : [feedback];
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
      final whereArgs =
          level != null ? [level, isSeen] : [isSeen];
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
      List<Map<String, dynamic>> options = [];
      for (int id in randomIds) {
        final result =
            await db.query(tableName, where: 'id = ?', whereArgs: [id]);
        if (result.isNotEmpty) options.add(result.first);
      }
      return options;
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
  //  New FSRS scheduling methods
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

  /// Fetches new (unseen, never-reviewed) cards up to [limit].
  Future<List<Map<String, dynamic>>> fetchNewCards(
    String tableName,
    String? level,
    int limit,
  ) async {
    final db = await database;
    final where = level != null
        ? 'level = ? AND card_state = 0 AND isSeen = 0'
        : 'card_state = 0 AND isSeen = 0';
    final args = level != null ? [level] : null;
    return db.query(tableName,
        where: where, whereArgs: args, limit: limit, orderBy: 'RANDOM()');
  }

  /// Updates all FSRS scheduling fields for a card.
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
  }) async {
    final db = await database;
    await db.update(
      tableName,
      {
        'card_state': cardState,
        'stability': stability,
        'difficulty': difficulty,
        'due': due,
        'elapsed_days': elapsedDays,
        'scheduled_days': scheduledDays,
        'reps': reps,
        'lapses': lapses,
        'last_review': lastReview,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Inserts a review log entry.
  Future<void> insertRevlog(RevlogEntry entry) async {
    final db = await database;
    await db.insert('revlog', entry.toMap());
  }

  /// Counts today's reviews for a given level.
  Future<int> getTodayReviewCount(String tableName, String? level) async {
    final db = await database;
    final today = formatDate(DateTime.now());
    String where;
    List<Object?> args;
    if (level != null) {
      where =
          'SELECT COUNT(*) as cnt FROM revlog WHERE deck_table = ? AND review_date LIKE ? AND state IN (2,3)';
      args = [tableName, '$today%'];
    } else {
      where =
          'SELECT COUNT(*) as cnt FROM revlog WHERE review_date LIKE ? AND state IN (2,3)';
      args = ['$today%'];
    }
    final result = await db.rawQuery(where, args);
    return result.first['cnt'] as int? ?? 0;
  }

  /// Counts today's new cards for a given level.
  Future<int> getTodayNewCardCount(String tableName, String? level) async {
    final db = await database;
    final today = formatDate(DateTime.now());
    String where;
    List<Object?> args;
    if (level != null) {
      where =
          'SELECT COUNT(*) as cnt FROM revlog WHERE deck_table = ? AND review_date LIKE ? AND state = 0';
      args = [tableName, '$today%'];
    } else {
      where =
          'SELECT COUNT(*) as cnt FROM revlog WHERE review_date LIKE ? AND state = 0';
      args = ['$today%'];
    }
    final result = await db.rawQuery(where, args);
    return result.first['cnt'] as int? ?? 0;
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
