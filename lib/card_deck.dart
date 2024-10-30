import 'card_model.dart';

class CardDeck {
  final List<CardModel> _cards = [
    CardModel('Word 1', 'Definition 1'),
    CardModel('Word 2', 'Definition 2'),
    CardModel('Word 3', 'Definition 3'),
    CardModel('Word 4', 'Definition 4'),
    CardModel('Word 5', 'Definition 5'),
    CardModel('Word 6', 'Definition 6'),
    CardModel('Word 7', 'Definition 7'),
    CardModel('Word 8', 'Definition 8'),
    CardModel('Word 9', 'Definition 9'),
    CardModel('Word 10', 'Definition 10'),
  ];

  int currentDeckIndex = 0;

  List<CardModel> get cards => _cards;

  void reset() {
    currentDeckIndex++;
  }
}
