import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const motherLanguageKey = 'motherLanguage';
  static const targetLanguageKey = 'targetLanguage';
  static const firstTimeKey = 'firstTime';

  static Future<void> setMotherLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(motherLanguageKey, language);
  }

  static Future<String?> getMotherLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(motherLanguageKey);
  }

  static Future<void> setTargetLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(targetLanguageKey, language);
  }

  static Future<String?> getTargetLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(targetLanguageKey);
  }

  static Future<void> setFirstTime(bool isFirstTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(firstTimeKey, isFirstTime);
  }

  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(firstTimeKey) ?? true;
  }
}
