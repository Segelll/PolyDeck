import 'dart:math';
import 'package:poly2/card_model.dart';
import 'package:poly2/preferences_helper.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class CardDeck {
  List<CardModel> _cards = [];
  List<CardModel> get cards => _cards;


  Future<void> loadCards(String level) async {
    try {
      final motherLang = await PreferencesHelper.getMotherLanguage() ?? 'en';
      final targetLang = await PreferencesHelper.getTargetLanguage() ?? 'tr';


      final targetJsonStr = await rootBundle.loadString('assets/json/$targetLang.json');
      final motherJsonStr = await rootBundle.loadString('assets/json/$motherLang.json');

      final List<dynamic> targetData = json.decode(targetJsonStr);
      final List<dynamic> motherData = json.decode(motherJsonStr);


      final targetItems = targetData.where((item) => item['level'] == level).toList();
      final motherItems = motherData.where((item) => item['level'] == level).toList();


      final Map<int, Map<String, dynamic>> targetMap = {
        for (var x in targetItems) x['id']: x
      };
      final Map<int, Map<String, dynamic>> motherMap = {
        for (var x in motherItems) x['id']: x
      };


      final commonIds = targetMap.keys.toSet().intersection(motherMap.keys.toSet()).toList();
      final List<CardModel> result = [];

      for (var id in commonIds) {
        final tObj = targetMap[id]!;
        final mObj = motherMap[id]!;


        result.add(
          CardModel(
            id,
            tObj['word'],        // frontText
            tObj['sentence'],    // frontSentence
            mObj['word'],        // backText
            mObj['sentence'],    // backSentence
            tObj['level'],       // or store the level if needed
          ),
        );
      }


      result.shuffle(Random());


      _cards = result;
    } catch (e) {
      print('Error in loadCards: $e');
      _cards = [];
    }
  }

  void reset() {

  }
}
