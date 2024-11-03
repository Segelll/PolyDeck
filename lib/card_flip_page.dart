import 'package:flutter/material.dart';
import 'card_animations.dart';
import 'strings_loader.dart';
import 'card_deck.dart';
import 'card_model.dart';
import 'analysis_page.dart';
import 'analysis_result.dart';

class CardFlipPage extends StatefulWidget {
  final String level;

  const CardFlipPage({Key? key, required this.level}) : super(key: key);

  @override
  _CardFlipPageState createState() => _CardFlipPageState();
}

class _CardFlipPageState extends State<CardFlipPage> with TickerProviderStateMixin {
  final CardDeck _deck = CardDeck();
  int _currentCardIndex = 0;
  bool _isFlipped = false;
  Color _backCardColor = Colors.grey;
  List<Color> _colorTracker = List.generate(10, (_) => Colors.grey);
  List<AnalysisResult> _analysisResults = [];
  int _deckIndex = 1;

  AnimationController? _drawCardController;
  Animation<Offset>? _drawCardAnimation;

  final GlobalKey<CardFlipAnimationState> _cardKey = GlobalKey<CardFlipAnimationState>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeck();
  }

  Future<void> _loadDeck() async {
    try {
      await _deck.loadCards(widget.level);
      setState(() {
        _isLoading = false;
        _initDrawCardAnimation();
      });
    } catch (e) {
      print('Error in _loadDeck: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initDrawCardAnimation() {
    _drawCardController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _drawCardAnimation = Tween<Offset>(
      begin: const Offset(0, -2.0),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _drawCardController!,
        curve: Curves.easeOut,
      ),
    );

    _drawCardController!.forward();
  }

  void _flipCard(Color color) {
    setState(() {
      _isFlipped = true;
      _backCardColor = color;
      _colorTracker[_currentCardIndex] = color;

      final currentCard = _deck.cards[_currentCardIndex];
      _analysisResults.add(AnalysisResult(
        word: currentCard.frontText,
        meaning: currentCard.backText,
        color: color,
      ));
    });
  }

  void _reflipCard() {
    _cardKey.currentState?.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        setState(() {
          _backCardColor = Colors.grey;
          _colorTracker[_currentCardIndex] = Colors.grey;
          _analysisResults.removeWhere((result) =>
          result.word == _deck.cards[_currentCardIndex].frontText);
        });

        _cardKey.currentState?.removeStatusListener();
      }
    });

    setState(() {
      _isFlipped = false;
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
      _currentCardIndex++;
      _isFlipped = false;
      _backCardColor = Colors.grey;

      _drawCardController!.reset();
      _drawCardController!.forward();
    });
  }

  void _showAnalysis() {
    String previousDeckName =
    StringsLoader.get('deck').replaceAll('{index}', _deckIndex.toString());

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

  void _startNewDeck() async {
    setState(() {
      _deckIndex++;
      _currentCardIndex = 0;
      _analysisResults.clear();
      _colorTracker = List.generate(10, (_) => Colors.grey);
      _isFlipped = false;
      _backCardColor = Colors.grey;
      _isLoading = true;
    });

    await _deck.loadCards(widget.level);
    setState(() {
      _isLoading = false;
      _drawCardController!.reset();
      _drawCardController!.forward();
    });
  }

  @override
  void dispose() {
    _drawCardController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _deck.cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(StringsLoader.get('appTitle')),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final CardModel currentCard = _deck.cards[_currentCardIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(StringsLoader.get('appTitle')),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                StringsLoader.get('deck').replaceAll('{index}', _deckIndex.toString()),
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < _colorTracker.length; i++)
                    Container(
                      width: 30,
                      height: 45,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: _colorTracker[i],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Stack(
                  children: [
                    SlideTransition(
                      position: _drawCardAnimation!,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {},
                          child: CardFlipAnimation(
                            key: _cardKey,
                            isFlipped: _isFlipped,
                            frontCardColor: Colors.grey,
                            backCardColor: _backCardColor,
                            frontText: currentCard.frontText,
                            backText: currentCard.backText,
                            onFlipComplete: _reflipCard,
                            cardNumber: _currentCardIndex + 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (!_isFlipped) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _flipCard(Colors.red),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(100, 50),
                      ),
                      child: Text(StringsLoader.get('flipRed')),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _flipCard(Colors.yellow),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        minimumSize: const Size(100, 50),
                      ),
                      child: Text(StringsLoader.get('flipYellow')),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _flipCard(Colors.green),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(100, 50),
                      ),
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
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(100, 50),
                      ),
                      child: Text(StringsLoader.get('reflip')),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _nextCard,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(100, 50),
                      ),
                      child: Text(StringsLoader.get('newCard')),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              Text(
                StringsLoader.get('cardCount')
                    .replaceAll('{index}', (_currentCardIndex + 1).toString())
                    .replaceAll('{total}', _deck.cards.length.toString()),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
