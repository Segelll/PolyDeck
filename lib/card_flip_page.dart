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
  List<Color> _colorTracker = List.generate(10, (_) => Colors.grey); // Initialize with grey colors
  List<String> _analysisResults = []; // Store the results of flips
  int _deckIndex = 1; // Keep track of current deck number

  void _flipCard(Color color) {
    setState(() {
      _isFlipped = true;
      _cardColor = color;
      _colorTracker[_currentCardIndex] = color; // Track the color for this card
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
    // Reset the color in the color tracker for the current card
    setState(() {
      _isFlipped = false;
      _cardColor = Colors.grey; // Reset the color to grey
      _colorTracker[_currentCardIndex] = Colors.grey; // Reset the corresponding color in the tracker

      // Reset analysis entry for the current card
      _analysisResults.removeWhere((result) => result.startsWith('Card ${_currentCardIndex + 1}:'));
    });
  }

  void _nextCard() {
    if (_currentCardIndex < _deck.cards.length - 1) {
      _setNextCard();
    } else {
      _showAnalysis(); // Call to show the analysis
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
        _isFlipped = false; // Reset to show front face
        _cardColor = Colors.grey; // Reset color for the new card
      });
    });
  }

  void _showAnalysis() {
    // Store the previous deck name
    String previousDeckName = 'Deck $_deckIndex';
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AnalysisPage(
          analysisResults: _analysisResults,
          previousDeckName: previousDeckName, // Pass the previous deck name
          deckIndex: _deckIndex,
          onNewDeck: _startNewDeck, // Pass the function to start a new deck
        ),
      ),
    );
  }

  void _startNewDeck() {
    setState(() {
      _deckIndex++; // Increment the deck index
      _currentCardIndex = 0; // Reset the card index
      _deck.reset(); // Reset the deck
      _analysisResults.clear(); // Clear analysis results for new deck
      _colorTracker = List.generate(10, (_) => Colors.grey); // Reset color tracker for new deck
      _isFlipped = false; // Ensure the first card shows its front
      _cardColor = Colors.grey; // Set the first card color to gray
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
          // Display current deck number
          Text('Deck $_deckIndex', style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),

          // Small representation of the deck on top without text
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
              for (int i = _colorTracker.length; i < 10; i++) // Ensure 10 slots
                Container(
                  width: 30,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey, // Default color
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
