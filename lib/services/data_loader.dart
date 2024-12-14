/*import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:poly2/models/word_model.dart';
import 'database_helper.dart';

class DataLoader {
  Future<void> loadJsonFilesToDatabase() async {
    final List<String> fileNames = [
      'en.json',
      'de.json',
      'fr.json',
      'esp.json',
      'tr.json',
      'it.json',
      'pr.json',
    ];
    //favori sayfası
    await DBHelper.instance.createFavouriteTable();

    for (var fileName in fileNames) {
      final tableName = fileName.split('.').first;

      await DBHelper.instance.createTable(tableName);

      final jsonString = await rootBundle.loadString('assets/json/$fileName');
      final jsonData = json.decode(jsonString);

List<WordModel> words = [];

if (jsonData is Map<String, dynamic>) {
  for (var level in jsonData.keys) {
    for (var wordData in jsonData[level] as List) {
      words.add(WordModel(
        id: wordData['id'],
        word: wordData['word'],
        sentence: wordData['sentence'],
        level: level,
      ));
    }
  }
} else if (jsonData is List<dynamic>) {
  for (var wordData in jsonData) {
    words.add(WordModel(
      id: wordData['id'],
      word: wordData['word'],
      sentence: wordData['sentence'],
      level: wordData['level'],
    ));
  }
} else {
  throw Exception("Beklenmeyen JSON formatı.");
}
      await DBHelper.instance.insertWords(tableName, words);
    }
  }
}*/
