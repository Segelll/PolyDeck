import 'package:poly2/data/database/database.dart';
import 'package:poly2/domain/models/deck_summary.dart';

/// Owns user-created decks and their card memberships.
class DeckRepository {
  final AppDatabase _db;

  DeckRepository(this._db);

  Future<int> ensureFavoritesDeck() => _db.ensureFavoritesDeck();

  Future<List<DeckSummary>> fetchDeckSummaries() =>
      _db.fetchDeckSummaries();

  Future<List<Map<String, dynamic>>> fetchAllDeckCardsForExport() =>
      _db.fetchAllDeckCardsForExport();

  Future<int> createCustomDeck(String name) => _db.createCustomDeck(name);

  Future<void> deleteCustomDeck(int deckId) => _db.deleteCustomDeck(deckId);

  Future<void> addWordToDeck({
    required int deckId,
    required int wordId,
    required String sourceLanguage,
    required String targetLanguage,
  }) => _db.addWordToDeck(
        deckId: deckId,
        wordId: wordId,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );

  Future<bool> isWordInDeck({
    required int deckId,
    required int wordId,
    required String sourceLanguage,
    required String targetLanguage,
  }) => _db.isWordInDeck(
        deckId: deckId,
        wordId: wordId,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );

  Future<List<DeckWordEntry>> fetchDeckWords(int deckId, int limit) =>
      _db.fetchDeckWords(deckId, limit);
}
