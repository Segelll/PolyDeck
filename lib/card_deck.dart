import 'dart:math';
import 'package:poly2/card_model.dart';
import 'package:poly2/services/database_helper.dart';

class CardDeck {
  List<CardModel> _cards = [];
  int currentDeckIndex = 0;

  List<CardModel> get cards => _cards;

  Future<void> updateIsSeen(String tableName, int id, int feedback) async {
    try {
      await DBHelper.instance.updateIsSeen(tableName, id, 1);
    } catch (e) {
      print('Error updating isSeen: $e');
    }
  }

  Future<void> loadCards(String level, String language) async {
    try {
      final List<Map<String, dynamic>> feedback1Words =
          await DBHelper.instance.fetchWordsByFeedback(language, level, 1, 4);
      final List<Map<String, dynamic>> feedback2Words =
          await DBHelper.instance.fetchWordsByFeedback(language, level, 2, 1);

      final List<Map<String, dynamic>> allWords = [
        ...feedback1Words,
        ...feedback2Words,
      ];

      final int missingCards = 10 - allWords.length;
      if (missingCards > 0) {
        final List<Map<String, dynamic>> additionalIsSeenWords =
            await DBHelper.instance.fetchWordsByIsSeen(language, level, 0, missingCards);

        allWords.addAll(additionalIsSeenWords);
      }

      List<Map<String, dynamic>> turkishWords = [];

      for (var word in allWords) {
        final int wordId = word['id'];
        final turkishWord = await DBHelper.instance.fetchWordById("tr", wordId);

        if (turkishWord != null) {
          turkishWords.add(turkishWord.toMap());
        }
      }

      final List<CardModel> allCards = allWords.map((englishWord) {
        final int id = englishWord['id'];

        final turkishWord = turkishWords.firstWhere(
          (tWord) => tWord['id'] == id,
          orElse: () => {}
        );
        if (turkishWord.isEmpty) {
          return null;
        }

        return CardModel(
          englishWord['id'],
          englishWord['word'],
          englishWord['sentence'],
          turkishWord['word'],
          turkishWord['sentence'],
          englishWord['level'],
        );
      }).whereType<CardModel>().toList();

      allCards.shuffle(Random());
      _cards = allCards.take(10).toList();

      for (var card in _cards) {
        updateIsSeen(language, card.id, 1);
      }
    } catch (e) {
      print('Error loading cards: $e');
      _cards = [];
    }
  }

  void reset() {
    currentDeckIndex++;
  }
}
