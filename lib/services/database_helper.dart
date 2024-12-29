import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
      //await deleteDatabase(path);
      final dbExists = await databaseExists(path);

      if (!dbExists) {
        ByteData data = await rootBundle.load('assets/language_data.db');
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
      }

      return await openDatabase(path);
      
    } catch (e) {
      throw Exception('Database initialization failed: $e');
    }
  }

  Future<void> updateIsSeenDate(String tableName, int id) async {
    final DateTime now = DateTime.now();
    final String dateFormatted = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  try {
    final db = await database;
    await db.update(
      tableName,
      {
        'isSeen': 1,
        'date': dateFormatted,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    print(dateFormatted);
  } catch (e) {
    throw Exception('Failed to update isSeen: $e');
  }
}

Future<void> saveUserChoices(String tableName, String mainLanguage, String targetLanguage) async {
  try {
    final db = await database;
    await db.delete(tableName);
    await db.insert(
      tableName,
      {
        'mainLanguage': mainLanguage,
        'targetLanguage': targetLanguage,
        'firstTime': "true"
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
     print("User choices saved: $mainLanguage, $targetLanguage");
  } catch (e) {
    throw Exception('Failed to save user choices: $e');
  }
  
}

Future<String?> getEarliestDate(String tableName) async {
  try {
    final db = await database;
    final result = await db.rawQuery('SELECT MIN(date) as earliestDate FROM $tableName WHERE date != 0');
    if (result.isNotEmpty && result.first['earliestDate'] != null) {
      return result.first['earliestDate'] as String;
    }
    return null;
  } catch (e) {
    throw Exception('Failed to get the earliest date excluding zero values: $e');
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
      throw Exception('Failed to update isSeen: $e');
    }
  }
  Future<List<Map<String, dynamic>>> fetchWordsByFeedback(
      String tableName, String? level, int feedback, int limit) async {
    try {
      final db = await database;
      final whereClause = level != null ? 'level = ? AND feedback = ?' : 'feedback = ?';
      final whereArgs = level != null ? [level, feedback] : [feedback];

      return await db.query(
        tableName,
        where: whereClause,
        whereArgs: whereArgs,
        limit: limit,
      );
    } catch (e) {
      throw Exception('Failed to fetch words by feedback: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchWordsByIsSeen(
      String tableName, String? level, int isSeen, int limit) async {
    try {
      final db = await database;
      final whereClause = level != null ? 'level = ? AND isSeen = ?' : 'isSeen = ?';
      final whereArgs = level != null ? [level, isSeen] : [isSeen];

      return await db.query(
        tableName,
        where: whereClause,
        whereArgs: whereArgs,
        limit: limit,
      );
    } catch (e) {
      throw Exception('Failed to fetch words by isSeen: $e');
    }
  }
    Future<List<Map<String, dynamic>>> fetchAllIsSeenId(String tableName) async {
    try {
      final db = await database;

      return await db.query(
        tableName,
        columns: ['id'],
        where: 'isSeen = ?',
        whereArgs: [1],
      );
    } catch (e) {
      throw Exception('Failed to fetch words by isSeen: $e');
    }
  }

  Future<WordModel?> fetchWordById(String tableName, int id) async {
    try {
      final db = await database;
      final result = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (result.isNotEmpty) {
        return WordModel.fromMap(result.first);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to fetch word by ID: $e');
    }
  }
  Future<List<Map<String, dynamic>>> fetchExamWords(
      String tableName, int id) async {
    try {
      final db = await database;

      return await db.query(
        tableName,
        where: "id=?",
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to fetch words by isSeen: $e');
    }
  }
Future<List<Map<String, dynamic>>> fetchExamOptions(String tableName) async {
  try {
    final db = await database;
    List<int> randomIds = _generateRandomIds(1, 4799, 3);
    List<Map<String, dynamic>> options = [];
    
    for (int id in randomIds) {
      final result = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (result.isNotEmpty) {
        options.add(result.first);
      }
    }

    if (options.isEmpty) {
      print("No options found for $tableName");
    }

    return options;
  } catch (e) {
    throw Exception('Failed to fetch options: $e');
  }
}

Future<void> addToFavorites(String word, String sentence, String level, 
  String? backWord, String? backSentence) async {
  final db = await instance.database;

  await db.insert(
    'fav',
    {
      'word': word,
      'sentence': sentence,
      'level': "fav",
      'backword': backWord ?? '',
      'backsentence': backSentence ?? '',
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}


  Future<void> removeFromFavorites(String word) async {
    final db = await instance.database;
    await db.delete(
      'fav',
      where: 'word = ?',
      whereArgs: [word],
    );
  }

Future<bool> isFavorite(String word) async {
  try {
    final db = await instance.database;
    final result = await db.query(
      'fav',
      where: 'word = ?', 
      whereArgs: [word],
    );

    return result.isNotEmpty;
  } catch (e) {
    print('Error checking favorite: $e');
    return false;
  }
}
Future<List<Map<String, dynamic>>> fetchAllFavWords() async {
    final db = await instance.database;
    try {
      final List<Map<String, dynamic>> favWords = await db.query('fav');
      
      return favWords;
    } catch (e) {
      print('Error fetching all favorite words: $e');
      return [];
    }
  }
}


List<int> _generateRandomIds(int min, int max, int count) {
  Random random = Random();
  Set<int> randomIds = Set();

  while (randomIds.length < count) {
    randomIds.add(min + random.nextInt(max - min + 1));
  }

  return randomIds.toList();
}

class WordModel {
  final int id;
  final String backText;
  final String backSentence;

  WordModel({
    required this.id,
    required this.backText,
    required this.backSentence,
  });

  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      id: map['id'],
      backText: map['word'] ?? '',
      backSentence: map['sentence'] ?? '',
    );
  }



}