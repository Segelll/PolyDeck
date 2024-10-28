import 'card_model.dart';

class CardDeck {
  final List<CardModel> _cards;

  CardDeck()
      : _cards = List.generate(
          10,
          (index) => CardModel(
            frontText: 'Card Front $index',
            backText: 'Card Back $index',
          ),
        );

  List<CardModel> get cards => _cards;
}
