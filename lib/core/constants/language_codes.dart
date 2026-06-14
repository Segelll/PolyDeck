/// Maps display/locale language codes to database table names.
///
/// The database uses legacy table names ('esp', 'pr') while the Flutter
/// localization system uses proper ISO codes ('es', 'pt'). This mapping
/// bridges the two, allowing us to migrate the database independently.
class LanguageCodes {
  LanguageCodes._();

  /// Proper ISO 639-1 codes used for display and l10n.
  static const List<String> displayCodes = [
    'en',
    'tr',
    'de',
    'fr',
    'it',
    'pt',
    'es',
  ];

  /// Database table names (may differ from display codes for legacy reasons).
  static const List<String> tableNames = [
    'en',
    'tr',
    'de',
    'fr',
    'it',
    'pr',  // Portuguese — legacy table name
    'esp', // Spanish — legacy table name
  ];

  /// Maps a display/locale code to its database table name.
  static String tableNameFor(String displayCode) {
    switch (displayCode) {
      case 'pt':
        return 'pr';
      case 'es':
        return 'esp';
      default:
        return displayCode;
    }
  }

  /// Maps a database table name back to its display/locale code.
  static String displayCodeFor(String tableName) {
    switch (tableName) {
      case 'pr':
        return 'pt';
      case 'esp':
        return 'es';
      default:
        return tableName;
    }
  }
}
