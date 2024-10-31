import 'package:flutter/material.dart';
import 'card_animations.dart';
import 'strings_loader.dart';
import 'card_deck.dart';
import 'card_model.dart';
import 'analysis_page.dart';

class CardFlipPage extends StatefulWidget {
  @override
  _CardFlipPageState createState() => _CardFlipPageState();
}

class _CardFlipPageState extends State<CardFlipPage> {
  final CardDeck _deck = CardDeck();
  int _currentCardIndex = 0;
  bool _isFlipped = false;
  bool _isCardVisible = true;
  Color _cardColor = Colors.grey;
  List<Color> _colorTracker = List.generate(10, (_) => Colors.grey); 
  List<String> _analysisResults = []; 
  int _deckIndex = 1; 
  void _flipCard(Color color) {
    setState(() {
      _isFlipped = true;
      _cardColor = color;
      _colorTracker[_currentCardIndex] = color; 
      _analysisResults.add('Card ${_currentCardIndex + 1}: ${_getColorString(color)}');
    });
  }

  String _getColorString(Color color) {
    if (color == Colors.red) return 'Red';
    if (color == Colors.yellow) return 'Yellow';
    if (color == Colors.green) return 'Green';
    return '';
  }

  void _reflipCard() {
    setState(() {
      _isFlipped = false;
      _cardColor = Colors.grey; 
      _colorTracker[_currentCardIndex] = Colors.grey; 

      _analysisResults.removeWhere((result) => result.startsWith('Card ${_currentCardIndex + 1}:'));
    });
  }

  void _nextCard() {
    if (_currentCardIndex < _deck.cards.length - 1) {
      _setNextCard();
    } else {
      _showAnalysis(); 
    }
  }

  void _setNextCard() {
    setState(() {
      _isCardVisible = false;
    });

    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _currentCardIndex++;
        _isCardVisible = true;
        _isFlipped = false; 
        _cardColor = Colors.grey; 
      });
    });
  }

  void _showAnalysis() {
    String previousDeckName = 'Deck $_deckIndex';
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AnalysisPage(
          analysisResults: _analysisResults,
          previousDeckName: previousDeckName, 
          deckIndex: _deckIndex,
          onNewDeck: _startNewDeck, 
        ),
      ),
    );
  }

  void _startNewDeck() {
    setState(() {
      _deckIndex++; 
      _currentCardIndex = 0; 
      _deck.reset(); 
      _analysisResults.clear(); 
      _colorTracker = List.generate(10, (_) => Colors.grey); 
      _isFlipped = false; 
      _cardColor = Colors.grey; 
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_deck.cards.isEmpty) return Center(child: CircularProgressIndicator());

    final CardModel currentCard = _deck.cards[_currentCardIndex];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          
          Text('Deck $_deckIndex', style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),

        
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var color in _colorTracker)
                Container(
                  width: 30,
                  height: 45,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              for (int i = _colorTracker.length; i < 10; i++) 
                Container(
                  width: 30,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey, 
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
            ],
          ),
          SizedBox(height: 20),

          AnimatedOpacity(
            opacity: _isCardVisible ? 1.0 : 0.0,
            duration: Duration(milliseconds: 300),
            child: CardDropAnimation(
              child: CardFlipAnimation(
                isFlipped: _isFlipped,
                cardColor: _cardColor,
                frontText: currentCard.frontText,
                backText: currentCard.backText,
                onFlipComplete: _reflipCard,
              ),
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
            StringsLoader.get('cardCount')
                .replaceAll('{index}', (_currentCardIndex + 1).toString())
                .replaceAll('{total}', _deck.cards.length.toString()),
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
