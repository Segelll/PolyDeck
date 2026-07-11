import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poly2/data/database/database.dart';

void main() {
  test('custom deck stores and returns the language pair', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await db.into(db.words).insert(WordsCompanion.insert(
          id: 1,
          word: 'merhaba',
          sentence: 'Merhaba dünya.',
          level: 'A1',
          languageCode: 'tr',
        ));
    await db.into(db.words).insert(WordsCompanion.insert(
          id: 1,
          word: 'hello',
          sentence: 'Hello world.',
          level: 'A1',
          languageCode: 'en',
        ));

    final favoriteId = await db.ensureFavoritesDeck();
    final customId = await db.createCustomDeck('Seyahat');
    await db.addWordToDeck(
      deckId: customId,
      wordId: 1,
      sourceLanguage: 'en',
      targetLanguage: 'tr',
    );
    await db.addWordToDeck(
      deckId: favoriteId,
      wordId: 1,
      sourceLanguage: 'en',
      targetLanguage: 'tr',
    );

    final entries = await db.fetchDeckWords(customId, 10);
    final summaries = await db.fetchDeckSummaries();

    expect(entries, hasLength(1));
    expect(entries.single.word.word, 'merhaba');
    expect(entries.single.sourceWord, 'hello');
    expect(entries.single.sourceLanguage, 'en');
    expect(entries.single.targetLanguage, 'tr');
    expect(summaries.any((deck) => deck.isFavorites), isTrue);
    expect(summaries.any((deck) => deck.name == 'Seyahat'), isTrue);

    await db.close();
  });
}
