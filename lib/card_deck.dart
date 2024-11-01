import 'card_model.dart';

class CardDeck {
  final List<CardModel> _cards = [
    CardModel('action', 'eylem'),
    CardModel('activity', 'aktivite'),
    CardModel('actor', 'aktör'),
    CardModel('actress', 'aktris'),
    CardModel('adress', 'adres'),
    CardModel('adult', 'yetişkin'),
    CardModel('advice', 'tavsiye'),
    CardModel('after', 'sonra'),
    CardModel('afternoon', 'öğleden sonra'),
    CardModel('age', 'yaş'),
  ];

  int currentDeckIndex = 0;

  List<CardModel> get cards => _cards;

  void reset() {
    currentDeckIndex++;
  }
}
