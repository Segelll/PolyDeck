import 'package:poly2/models/word_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('language_word_data.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(
      path,
      version: 1,
    );
  }

  Future<void> createTable(String tableName) async {
    final db = await instance.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER PRIMARY KEY NOT NULL,
        word TEXT NOT NULL,
        sentence TEXT NOT NULL,
        level TEXT NOT NULL,
        isSeen INTEGER DEFAULT 0,
        feedback INTEGER DEFAULT 0
      )
    ''');
  }

    Future<void> createFavouriteTable() async {
    final db = await instance.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS fav (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        word TEXT NOT NULL,
        sentence TEXT NOT NULL,
        level TEXT NOT NULL,
        isSeen INTEGER DEFAULT 0,
        feedback INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> insertWords(String tableName, List<WordModel> words) async {
    final db = await instance.database;
    final batch = db.batch();

    for (var word in words) {
      batch.insert(
        tableName,
        word.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<WordModel>> fetchWords(String tableName) async {
    final db = await instance.database;
    final maps = await db.query(tableName);

    return maps.map((map) => WordModel.fromMap(map)).toList();
  }
  
  Future<WordModel?> fetchWordById(String tableName, int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return WordModel.fromMap(maps.first);
    }
    return null;
  }

   Future<int> updateWord(String tableName, WordModel word) async {
    final db = await instance.database;
    return await db.update(
      tableName,
      word.toMap(),
      where: 'id = ?',
      whereArgs: [word.id],
    );
  }
  Future<int> deleteWord(String tableName, int id) async {
    final db = await instance.database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteTable(String tableName) async {
    final db = await instance.database;
    await db.execute('DROP TABLE IF EXISTS $tableName');
  }

  Future<int> deleteAllWords(String tableName) async {
    final db = await instance.database;
    return await db.delete(tableName);
  }

  Future<int> updateFeedback(String tableName, int id, int feedback) async {
  final db = await instance.database;
  return await db.update(
    tableName,
    {'feedback': feedback},
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<int> updateIsSeen(String tableName, int id, int isSeen) async {
  final db = await instance.database;
  return await db.update(
    tableName,
    {'isSeen': isSeen},
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<List<Map<String, dynamic>>> fetchWordsByLevel(
      String tableName, String level) async {
    final db = await instance.database;
    return await db.query(
      tableName,
      where: 'level = ?',
      whereArgs: [level],
    );
  }

Future<List<Map<String, dynamic>>> fetchWordsByIsSeen(
  String tableName,
  String? level,
  int feedback,
  int limit,
) async {
  final db = await instance.database;
  if (level == null) {
    return await db.query(
      tableName,
      where: 'feedback = ?',
      whereArgs: [feedback],
      limit: limit,
    );
  } else {
    return await db.query(
      tableName,
      where: 'feedback = ? AND level = ?',
      whereArgs: [feedback, level],
      limit: limit,
    );
  }
}

Future<List<Map<String, dynamic>>> fetchWordsByFeedback(
  String tableName,
  String? level,
  int feedback,
  int limit,
) async {
  final db = await instance.database;

  if (level == null) {
    return await db.query(
      tableName,
      where: 'feedback = ?',
      whereArgs: [feedback],
      limit: limit,
    );
  } else {
    return await db.query(
      tableName,
      where: 'feedback = ? AND level = ?',
      whereArgs: [feedback, level],
      limit: limit,
    );
  }
}

Future<int> feedBackCount(
  String tableName,
  String level,
  int feedback
) async {
  final db = await instance.database;
  return Sqflite.firstIntValue(await db.rawQuery(
    'SELECT COUNT(DISTINCT feedback) as count FROM $tableName WHERE level = ? AND feedback = ?',
    [level, feedback]
  )) ?? 0;
}
Future<int> isSeenCount(
  String tableName,
  String level,
) async {
  final db = await instance.database;
  return Sqflite.firstIntValue(await db.rawQuery(
    'SELECT COUNT(*) as count FROM $tableName WHERE level = 0',
    [level]
  )) ?? 0;
}

Future<void> insertFavourite(String word, String sentence, String level) async {
    final db = await instance.database;
    await db.insert(
      'fav',
      {
        'word': word,
        'sentence': sentence,
        'level': level,
        'isSeen': 0,
        'feedback': 0, 
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
