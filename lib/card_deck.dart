import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:poly2/models/card_model.dart';
import 'package:poly2/services/database_helper.dart';

class CardDeck {
  List<CardModel> _cards = [];
  int currentDeckIndex = 0;
  String? _motherLang;
  String? _targetLang;

  List<CardModel> get cards => _cards;

  final DBHelper _dbHelper = DBHelper();

  Future<void> _loadPrefs() async {
    final userSettings = await _dbHelper.getUserChoices('user');
      _motherLang = userSettings?['mainLanguage'];
      _targetLang = userSettings?['targetLanguage'];
  }

  Future<void> updateIsSeen(String tableName, int id) async {
    try {
      await DBHelper.instance.updateIsSeenDate(tableName, id);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating isSeen: $e');
      }
    }
  }

Future<void> loadCards({String? level}) async {
  try {
    await _loadPrefs();

    List<Map<String, dynamic>> allWords = [];

    if (level == 'fav') {
      final List<Map<String, dynamic>> favWords = await DBHelper.instance.fetchAllFavWords();
      
      final random = Random();
      final randomIndices = <int>{};

      while (randomIndices.length < 10 && randomIndices.length < favWords.length) {
        randomIndices.add(random.nextInt(favWords.length));
      }
      for (var index in randomIndices) {
        allWords.add(favWords[index]);
      }
    } else {
      final List<Map<String, dynamic>> feedback1Words = await DBHelper.instance.fetchWordsByFeedback(
        _targetLang!, level, 1, 4,
      );
      final List<Map<String, dynamic>> feedback2Words = await DBHelper.instance.fetchWordsByFeedback(
        _targetLang!, level, 2, 1,
      );

      allWords = [...feedback1Words, ...feedback2Words];

      final int missingCards = 10 - allWords.length;
      if (missingCards > 0) {
        final List<Map<String, dynamic>> additionalIsSeenWords = await DBHelper.instance.fetchWordsByIsSeen(
          _targetLang!, level, 0, missingCards,
        );
        allWords.addAll(additionalIsSeenWords);
      }
    }

    List<CardModel> allCards = [];
    for (var word in allWords) {
      final int wordId = word['id'];
      final translation = await DBHelper.instance.fetchWordById(
        _motherLang!, wordId,
      );

      if (translation != null) {
        allCards.add(
          CardModel(
            word['id'],
            word['word'],
            word['sentence'],
            word['level'] == 'fav' ? word['backword'] : translation.backText,
            word['level'] == 'fav' ? word['backsentence'] : translation.backSentence,
            word['level'],
          ),
        );
      }
    }

    allCards.shuffle(Random());
    _cards = allCards.take(10).toList();

    for (var card in _cards) {
      await updateIsSeen(_targetLang!, card.id);
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error loading cards: $e');
    }
    _cards = [];
  }
}


  void reset() {
    currentDeckIndex++;
  }
}
