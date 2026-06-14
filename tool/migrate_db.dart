import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  // Initialize FFI
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;

  // Path to your asset db
  final dbPath = 'assets/polydesk.db';
  if (!File(dbPath).existsSync()) {
    print('Database file not found at $dbPath');
    return;
  }

  print('Opening database...');
  final db = await databaseFactory.openDatabase(dbPath);

  try {
    print('Creating deck_config table...');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS deck_config (
        level TEXT PRIMARY KEY,
        max_new_per_day INTEGER DEFAULT 10,
        max_reviews_per_day INTEGER DEFAULT 20,
        learning_steps TEXT DEFAULT '[1,10]',
        enable_fuzz INTEGER DEFAULT 1,
        request_retention REAL DEFAULT 0.9,
        w TEXT
      )
    ''');

    print('Creating revlog table...');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS revlog (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_id INTEGER NOT NULL,
        deck_table TEXT NOT NULL,
        rating INTEGER NOT NULL,
        state INTEGER NOT NULL,
        due TEXT NOT NULL,
        stability REAL NOT NULL,
        difficulty REAL NOT NULL,
        elapsed_days INTEGER NOT NULL,
        last_elapsed_days INTEGER DEFAULT 0,
        scheduled_days INTEGER NOT NULL,
        review_date TEXT NOT NULL
      )
    ''');

    print('Altering language tables to add FSRS columns...');
    const langs = ['en', 'tr', 'de', 'fr', 'it', 'pr', 'esp', 'fav'];
    final cols = [
      'card_state INTEGER DEFAULT 0',
      'stability REAL DEFAULT 0.0',
      'difficulty REAL DEFAULT 0.0',
      'due TEXT',
      'elapsed_days INTEGER DEFAULT 0',
      'scheduled_days INTEGER DEFAULT 0',
      'reps INTEGER DEFAULT 0',
      'lapses INTEGER DEFAULT 0',
      'last_review TEXT'
    ];

    for (final lang in langs) {
      print('Updating table: $lang');
      for (final col in cols) {
        try {
          await db.execute('ALTER TABLE "$lang" ADD COLUMN $col');
        } catch (e) {
          // Ignore if column already exists
        }
      }
    }

    print('Adding extra columns to fav table...');
    try {
      await db.execute('ALTER TABLE fav ADD COLUMN backword TEXT');
    } catch (_) {}
    try {
      await db.execute('ALTER TABLE fav ADD COLUMN backsentence TEXT');
    } catch (_) {}

    print('Inserting default deck_config...');
    try {
      await db.execute("INSERT OR IGNORE INTO deck_config (level) VALUES ('default')");
    } catch (e) {
      print('Could not insert default deck_config: $e');
    }

    print('Creating indices for performance...');
    for (final lang in langs) {
      try {
        await db.execute('CREATE INDEX IF NOT EXISTS "idx_${lang}_fsrs_due" ON "$lang" ("level", "card_state", "due")');
      } catch (_) {}
      try {
        await db.execute('CREATE INDEX IF NOT EXISTS "idx_${lang}_fsrs_new" ON "$lang" ("level", "card_state", "isSeen")');
      } catch (_) {}
      try {
        await db.execute('CREATE INDEX IF NOT EXISTS "idx_${lang}_level_isSeen" ON "$lang" ("level", "isSeen")');
      } catch (_) {}
      try {
        await db.execute('CREATE INDEX IF NOT EXISTS "idx_${lang}_feedback" ON "$lang" ("isSeen", "feedback")');
      } catch (_) {}
    }
    try {
      await db.execute('CREATE INDEX IF NOT EXISTS "idx_revlog_card" ON "revlog" ("deck_table", "card_id")');
    } catch (_) {}
    try {
      await db.execute('CREATE INDEX IF NOT EXISTS "idx_revlog_date" ON "revlog" ("review_date")');
    } catch (_) {}
    try {
      await db.execute('CREATE INDEX IF NOT EXISTS "idx_revlog_deck_date_state" ON "revlog" ("deck_table", "review_date", "state")');
    } catch (_) {}

    print('Migration completed successfully!');
  } catch (e) {
    print('Error during migration: $e');
  } finally {
    await db.close();
  }
}
