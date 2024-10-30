import 'dart:convert';
import 'package:flutter/services.dart';

class StringsLoader {
  static Map<String, String> _strings = {};
  static String _currentLanguage = 'en'; 

  static Future<void> loadStrings() async {
    final String response = await rootBundle.loadString('lib/strings.json');
    final Map<String, dynamic> jsonData = json.decode(response);
    _strings = Map<String, String>.from(jsonData[_currentLanguage]);
  }

  static String get(String key) {
    return _strings[key] ?? '';
  }

  static void setLanguage(String language) {
    _currentLanguage = language;
  }

  static Future<void> changeLanguage(String language) async {
    setLanguage(language);
    await loadStrings();
  }
  
}
