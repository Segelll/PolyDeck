/// Compact deck metadata used by the deck list and add-to-deck sheet.
class DeckSummary {
  final int id;
  final String name;
  final String deckType;
  final String? systemKey;
  final int cardCount;

  const DeckSummary({
    required this.id,
    required this.name,
    required this.deckType,
    required this.systemKey,
    required this.cardCount,
  });

  bool get isCustom => deckType == 'custom';
  bool get isFavorites => systemKey == 'favorites';
}
