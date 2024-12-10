import 'package:flutter/material.dart';
import 'package:poly2/services/database_helper.dart';
import 'card_animations.dart';
import 'strings_loader.dart';
import 'card_deck.dart';
import 'card_model.dart';
import 'analysis_page.dart';
import 'analysis_result.dart';
import 'dart:math';

class CardFlipPage extends StatefulWidget {
  final String level;
  final String language;

  const CardFlipPage({Key? key, required this.level, required this.language}) : super(key: key);

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

  FlipDirection _flipDirection = FlipDirection.leftToRight;

  List<AnimationController> _indicatorControllers = [];
  List<Animation<double>> _indicatorAnimations = [];

  @override
  void initState() {
    super.initState();
    _loadDeck();
  }

  Future<void> _loadDeck() async {
    try {
      await _deck.loadCards(level:widget.level,language:widget.language);
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

  Future<void> updateFeedback(String tableName, int id, int feedback) async {
    setState(() {
      print("Feedback güncelleniyor...");
    });

    try {
      await DBHelper.instance.updateFeedback(tableName, id, feedback);
      setState(() {
        print("Feedback başarıyla güncellendi.");
      });
    } catch (e) {
      setState(() {
        print("Hata: Feedback güncellenirken bir sorun oluştu: $e");
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

  void _flipCard(Color color, FlipDirection direction) {
    setState(() {
      _isFlipped = true;
      _backCardColor = color;
      _colorTracker[_currentCardIndex] = color;
      _flipDirection = direction;

      final currentCard = _deck.cards[_currentCardIndex];
      _analysisResults.add(AnalysisResult(
        word: currentCard.frontText,
        meaning: currentCard.backText,
        color: color,
      ));

      _animateIndicator(_currentCardIndex);
    });
  }

  void _animateIndicator(int index) {
    if (_indicatorControllers.length < _colorTracker.length) {
      for (int i = 0; i < _colorTracker.length; i++) {
        _indicatorControllers.add(AnimationController(
          duration: const Duration(milliseconds: 400),
          vsync: this,
        ));
        _indicatorAnimations.add(Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _indicatorControllers[i],
            curve: Curves.easeOut,
          ),
        ));
      }
    }

    _indicatorControllers[index].forward(from: 0);
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

    await _deck.loadCards(level:widget.level, language:widget.language);
    setState(() {
      _isLoading = false;
      _drawCardController!.reset();
      _drawCardController!.forward();
    });
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(StringsLoader.get('instructionsTitle')),
          content: Text(StringsLoader.get('instructionsContent')),
          actions: [
            TextButton(
              child: Text(StringsLoader.get('close')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _openSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(StringsLoader.get('settings')),
          content: Text(StringsLoader.get('settingsContent')),
          actions: [
            TextButton(
              child: Text(StringsLoader.get('close')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }



  @override
  void dispose() {
    _drawCardController?.dispose();
    for (var controller in _indicatorControllers) {
      controller.dispose();
    }
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

    Color frontCardColor = Theme.of(context).brightness == Brightness.light
        ? Colors.grey[200]!
        : Colors.grey[800]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(StringsLoader.get('appTitle')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
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
                    AnimatedBuilder(
                      animation: _indicatorControllers.isNotEmpty
                          ? _indicatorAnimations[i]
                          : AlwaysStoppedAnimation(0),
                      builder: (context, child) {
                        return Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(_indicatorAnimations.isNotEmpty
                                ? _indicatorAnimations[i].value * pi
                                : 0),
                          alignment: Alignment.center,
                          child: Container(
                            width: 30,
                            height: 45,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: _colorTracker[i],
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      },
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
                          onHorizontalDragEnd: !_isFlipped
                              ? (details) {
                            if (details.primaryVelocity! < 0) {
                              _flipCard(Colors.red, FlipDirection.leftToRight);
                               updateFeedback(widget.language, currentCard.id, 1);
                              
                            } else if (details.primaryVelocity! > 0) {
                              _flipCard(Colors.green, FlipDirection.rightToLeft);
                               updateFeedback(widget.language,currentCard.id, 2);
                            }
                          }
                              : null,
                          onVerticalDragEnd: !_isFlipped
                              ? (details) {
                            if (details.primaryVelocity! > 0) {
                              _flipCard(Colors.yellow, FlipDirection.topToBottom);
                               updateFeedback(widget.language, currentCard.id, 3);
                            }
                          }
                              : null,
                          onTap: () {},
                          child: CardFlipAnimation(
                            key: _cardKey,
                            isFlipped: _isFlipped,
                            frontCardColor: frontCardColor,
                            backCardColor: _backCardColor,
                            frontText: currentCard.frontText,
                            backText: currentCard.backText,
                            frontSentence: currentCard.frontSentence,
                            backSentence: currentCard.backSentence,
                            onFlipComplete: _reflipCard,
                            cardNumber: _currentCardIndex + 1,
                            flipDirection: _flipDirection,
                            level: currentCard.level,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  icon: const Icon(Icons.help_outline),
                  onPressed: _showInstructions,
                ),
              ),
              if (_isFlipped) ...[
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
