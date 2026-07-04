/// Language codes used throughout the app.
///
/// Display codes, DB codes, and locale codes are all standard ISO 639-1.
/// Every new install uses the same `polydesk.db` with these exact codes.
class LanguageCodes {
  LanguageCodes._();

  /// All supported language codes (ISO 639-1).
  static const List<String> displayCodes = [
    'en',
    'tr',
    'de',
    'fr',
    'it',
    'pt',
    'es',
  ];

  /// Same as [displayCodes] — DB and display codes are identical.
  static String tableNameFor(String displayCode) => displayCode;

  /// Same as [tableNameFor] — DB and display codes are identical.
  static String displayCodeFor(String tableName) => tableName;
}
