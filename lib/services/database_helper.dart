import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:poly2/models/word_model.dart';

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
      await deleteDatabase(path);
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
  } catch (e) {
    throw Exception('Failed to update isSeen: $e');
  }
}

Future<String?> getEarliestDate(String tableName) async {
  try {
    final db = await database;
    final result = await db.rawQuery('SELECT MIN(date) as earliestDate FROM $tableName');
    if (result.isNotEmpty && result.first['earliestDate'] != null) {
      return result.first['earliestDate'] as String;
    }
    return null;
  } catch (e) {
    throw Exception('Failed to get the earliest date: $e');
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
List<int> _generateRandomIds(int min, int max, int count) {
  Random random = Random();
  Set<int> randomIds = Set();

  while (randomIds.length < count) {
    randomIds.add(min + random.nextInt(max - min + 1));
  }

  return randomIds.toList();
}
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

