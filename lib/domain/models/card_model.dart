class CardModel {
  final int id;
  final String frontText;
  final String frontSentence;
  final String backText;
  final String backSentence;
  final String level;
  /// The language this card belongs to (`language_code` in the DB).
  /// Either a standard ISO code (e.g. 'tr') or 'fav' for favorites.
  final String languageCode;

  CardModel(this.id, this.frontText, this.frontSentence, this.backText,
      this.backSentence, this.level, this.languageCode);
}
