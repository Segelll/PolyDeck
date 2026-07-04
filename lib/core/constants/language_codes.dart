/// Maps display/locale language codes to database table names.
///
/// The database now uses standard ISO 639-1 codes (same as display codes).
/// The unified `words` table stores language_code as 'en','tr','de','fr','it','pt','es'.
///
/// Legacy mapping ('pr'→'pt', 'esp'→'es') is kept in [displayCodeFor] for
/// backward-compatible import of old backup files only.
class LanguageCodes {
  LanguageCodes._();

  /// Proper ISO 639-1 codes used for display, l10n, and the active database.
  static const List<String> displayCodes = [
    'en',
    'tr',
    'de',
    'fr',
    'it',
    'pt',
    'es',
  ];

  /// Active database language codes (identical to display codes since the
  /// unified-words migration).
  static const List<String> tableNames = [
    'en',
    'tr',
    'de',
    'fr',
    'it',
    'pt',
    'es',
  ];

  /// Maps a display/locale code to its database language_code.
  /// Since the unified-words migration, display and DB codes are the same.
  static String tableNameFor(String displayCode) {
    // Legacy fallback for old backup files that may still contain 'pr'/'esp'.
    final normalized = switch (displayCode) {
      'pr' => 'pt',
      'esp' => 'es',
      _ => displayCode,
    };
    return normalized;
  }

  /// Maps a database code (or legacy table name) back to its display/locale code.
  /// Keeps legacy 'pr'→'pt' and 'esp'→'es' for backward-compatible import.
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
