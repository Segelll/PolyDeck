import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'card_model.dart';

class CardDeck {
  List<CardModel> _cards = [];
  int currentDeckIndex = 0;

  List<CardModel> get cards => _cards;

  Future<void> loadCards(String level) async {
    try {
      // Load English words
      final String englishJsonString = await rootBundle.loadString('assets/english_words_$level.json');
      final List<dynamic> englishJsonData = jsonDecode(englishJsonString);

      // Load Turkish words
      final String turkishJsonString = await rootBundle.loadString('assets/turkish_words_$level.json');
      final List<dynamic> turkishJsonData = jsonDecode(turkishJsonString);

      // Create maps from id to word
      final Map<int, String> englishWordsById = {};
      for (var item in englishJsonData) {
        int id = item['id'];
        String word = item['word'];
        englishWordsById[id] = word;
      }

      final Map<int, String> turkishWordsById = {};
      for (var item in turkishJsonData) {
        int id = item['id'];
        String word = item['word'];
        turkishWordsById[id] = word;
      }

      // Get list of common IDs
      final List<int> commonIds = englishWordsById.keys.toSet().intersection(turkishWordsById.keys.toSet()).toList();

      // Shuffle and select 10 random IDs
      commonIds.shuffle(Random());
      final List<int> selectedIds = commonIds.take(10).toList();

      // Create cards
      _cards = selectedIds.map((id) {
        return CardModel(englishWordsById[id]!, turkishWordsById[id]!);
      }).toList();
    } catch (e) {
      print('Error loading cards: $e');
      _cards = [];
    }
  }

  void reset() {
    currentDeckIndex++;
    // You can reload cards here if needed
  }
}
