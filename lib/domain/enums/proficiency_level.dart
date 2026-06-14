/// CEFR proficiency levels used for word decks.
enum ProficiencyLevel {
  a1('A1', 'Beginner'),
  a2('A2', 'Elementary'),
  b1('B1', 'Intermediate'),
  b2('B2', 'Upper-Interm.'),
  c1('C1', 'Advanced'),
  favourites('fav', 'Favourites');

  const ProficiencyLevel(this.code, this.label);

  final String code;
  final String label;

  /// All standard (non-favourite) levels.
  static List<ProficiencyLevel> get standardLevels =>
      values.where((l) => l != favourites).toList();

  /// Creates from a database level string.
  factory ProficiencyLevel.fromCode(String code) {
    for (final level in values) {
      if (level.code == code) return level;
    }
    throw ArgumentError('Unknown proficiency level code: $code');
  }
}
