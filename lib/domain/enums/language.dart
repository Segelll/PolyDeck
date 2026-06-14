/// Supported languages in the application.
///
/// Each language corresponds to a table name in the SQLite database
/// and a localization .arb file.
enum Language {
  english('en', 'English'),
  turkish('tr', 'Türkçe'),
  german('de', 'Deutsch'),
  french('fr', 'Français'),
  italian('it', 'Italiano'),
  portuguese('pt', 'Português'),
  spanish('es', 'Español');

  const Language(this.code, this.displayName);

  /// Short ISO 639-1 language code used in the database table names.
  final String code;

  /// Human-readable name for display in dropdowns.
  final String displayName;

  /// All language codes used as database table names.
  static List<String> get tableNames =>
      Language.values.map((l) => l.code).toList();

  /// Finds a [Language] by its [code], returns null if not found.
  static Language? fromCode(String code) {
    for (final lang in Language.values) {
      if (lang.code == code) return lang;
    }
    return null;
  }
}
