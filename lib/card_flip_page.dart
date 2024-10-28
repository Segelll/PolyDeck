import 'package:flutter/material.dart';
import 'strings_loader.dart';
import 'card_deck.dart';
import 'card_model.dart';

class CardFlipPage extends StatefulWidget {
  @override
  _CardFlipPageState createState() => _CardFlipPageState();
}

class _CardFlipPageState extends State<CardFlipPage> {
  final CardDeck _deck = CardDeck();
  int _currentCardIndex = 0;
  bool _isFlipped = false;
  Color _cardColor = Colors.grey;

  void _flipCard(Color color) {
    setState(() {
      _isFlipped = true;
      _cardColor = color;
    });
  }

  void _reflipCard() {
    setState(() {
      _isFlipped = false;
      _cardColor = Colors.grey;
    });
  }

  void _nextCard() {
    setState(() {
      _isFlipped = false;
      _cardColor = Colors.grey;
      _currentCardIndex = (_currentCardIndex + 1) % _deck.cards.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final CardModel currentCard = _deck.cards[_currentCardIndex];

    String cardCountText = StringsLoader.get('cardCount')
        .replaceAll('{index}', (_currentCardIndex + 1).toString())
        .replaceAll('{total}', _deck.cards.length.toString());

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 300,
            color: _cardColor,
            alignment: Alignment.center,
            child: Text(
              _isFlipped ? currentCard.backText : currentCard.frontText,
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          SizedBox(height: 20),
          if (!_isFlipped) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _flipCard(Colors.red),
                  child: Text(StringsLoader.get('flipRed')),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _flipCard(Colors.yellow),
                  child: Text(StringsLoader.get('flipYellow')),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _flipCard(Colors.green),
                  child: Text(StringsLoader.get('flipGreen')),
                ),
              ],
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _reflipCard,
                  child: Text(StringsLoader.get('reflip')),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _nextCard,
                  child: Text(StringsLoader.get('newCard')),
                ),
              ],
            ),
          ],
          SizedBox(height: 20),
          Text(
            cardCountText,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
