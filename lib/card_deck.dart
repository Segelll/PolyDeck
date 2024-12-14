import 'dart:math';
import 'package:poly2/card_model.dart';
import 'package:poly2/services/database_helper.dart';

class CardDeck {
  List<CardModel> _cards = [];
  int currentDeckIndex = 0;

  List<CardModel> get cards => _cards;

  Future<void> updateIsSeen(String tableName, int id) async {
    try {
      await DBHelper.instance.updateIsSeenDate(tableName, id);
    } catch (e) {
      print('Error updating isSeen: $e');
    }
  }

  Future<void> loadCards({String? level, required String language}) async {
    try {
      List<Map<String, dynamic>> allWords = [];

      final List<Map<String, dynamic>> feedback1Words = await DBHelper.instance.fetchWordsByFeedback(language, level, 1, 4);
      final List<Map<String, dynamic>> feedback2Words = await DBHelper.instance.fetchWordsByFeedback(language, level, 2, 1);

      allWords = [...feedback1Words, ...feedback2Words];

      final int missingCards = 10 - allWords.length;
      if (missingCards > 0) {
        final List<Map<String, dynamic>> additionalIsSeenWords = await DBHelper.instance.fetchWordsByIsSeen(language, level, 0, missingCards);
        allWords.addAll(additionalIsSeenWords);
      }

      List<CardModel> allCards = [];
      for (var word in allWords) {
        final int wordId = word['id'];
        final translation = await DBHelper.instance.fetchWordById("tr", wordId);

        if (translation != null) {
          allCards.add(
            CardModel(
              word['id'],
              word['word'],
              word['sentence'],
              translation.backText,
              translation.backSentence,
              word['level'],
            ),
          );
        }
      }
      allCards.shuffle(Random());
      _cards = allCards.take(10).toList();

      for (var card in _cards) {
        await updateIsSeen(language, card.id);
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
