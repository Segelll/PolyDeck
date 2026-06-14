/// Immutable value object for user language preferences.
class LanguagePreferences {
  final String mainLanguage;
  final String targetLanguage;
  final bool isFirstTime;

  const LanguagePreferences({
    required this.mainLanguage,
    required this.targetLanguage,
    required this.isFirstTime,
  });

  static const defaultPreferences = LanguagePreferences(
    mainLanguage: 'en',
    targetLanguage: 'tr',
    isFirstTime: true,
  );
}
