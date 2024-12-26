import 'dart:math';
import 'package:flutter/material.dart';
import 'package:poly2/services/database_helper.dart';
import 'package:poly2/card_animations.dart';
import 'package:poly2/strings_loader.dart';
import 'package:poly2/card_deck.dart';
import 'package:poly2/card_model.dart';
import 'package:poly2/analysis_page.dart';
import 'package:poly2/analysis_result.dart';
import 'package:poly2/settings_page.dart';

class CardFlipPage extends StatefulWidget {
  final List<String> levels;

  const CardFlipPage({Key? key, required this.levels}) : super(key: key);

  @override
  State<CardFlipPage> createState() => _CardFlipPageState();
}

class _CardFlipPageState extends State<CardFlipPage> with TickerProviderStateMixin {
  final CardDeck _deck = CardDeck();

  bool _isLoading = true;
  int _currentCardIndex = 0;
  bool _isFlipped = false;
  Color _backCardColor = Colors.grey;
  List<Color> _colorTracker = List.generate(10, (_) => Colors.grey);
  List<AnalysisResult> _analysisResults = [];
  int _deckIndex = 1;

  FlipDirection _flipDirection = FlipDirection.leftToRight;
  final GlobalKey<CardFlipAnimationState> _cardKey = GlobalKey<CardFlipAnimationState>();


  AnimationController? _drawCardController;
  Animation<Offset>? _drawCardAnimation;

  final List<AnimationController> _indicatorControllers = [];
  final List<Animation<double>> _indicatorAnimations = [];

  @override
  void initState() {
    super.initState();
    _loadDeck();
  }

  Future<void> _loadDeck() async {
    setState(() => _isLoading = true);

    try {
      List<CardModel> combined = [];

      for (String level in widget.levels) {
        await _deck.loadCards(level);
        combined.addAll(_deck.cards);
      }
      combined.shuffle(Random());

      final selected = combined.take(10).toList();
      _deck.cards.clear();
      _deck.cards.addAll(selected);
    } catch (e) {
      print('Error in _loadDeck: $e');
    }

    setState(() {
      _isLoading = false;
      _initDrawCardAnimation();
    });
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
      CurvedAnimation(parent: _drawCardController!, curve: Curves.easeOut),
    );
    _drawCardController!.forward();
  }

  void _flipCard(Color color, FlipDirection direction) {
    setState(() {
      _isFlipped = true;
      _backCardColor = color;
      _flipDirection = direction;
      _colorTracker[_currentCardIndex] = color;

      final currentCard = _deck.cards[_currentCardIndex];
      _analysisResults.add(
        AnalysisResult(
          word: currentCard.frontText,
          meaning: currentCard.backText,
          color: color,
        ),
      );
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
        _indicatorAnimations.add(
          Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(
              parent: _indicatorControllers[i],
              curve: Curves.easeOut,
            ),
          ),
        );
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
          final frontText = _deck.cards[_currentCardIndex].frontText;
          _analysisResults.removeWhere((res) => res.word == frontText);
        });
        _cardKey.currentState?.removeStatusListener();
      }
    });

    setState(() => _isFlipped = false);
  }

  void _nextCard() {
    if (_currentCardIndex < _deck.cards.length - 1) {
      setState(() {
        _currentCardIndex++;
        _isFlipped = false;
        _backCardColor = Colors.grey;

        _drawCardController!.reset();
        _drawCardController!.forward();
      });
    } else {
      _showAnalysis();
    }
  }

  void _showAnalysis() {
    String deckLabel =
    StringsLoader.get('deck').replaceAll('{index}', _deckIndex.toString());
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalysisPage(
          analysisResults: _analysisResults,
          previousDeckName: deckLabel,
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
      _analysisResults.clear();
      _colorTracker = List.generate(10, (_) => Colors.grey);
      _isFlipped = false;
      _backCardColor = Colors.grey;
      _isLoading = true;
    });
    _loadDeck();
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(StringsLoader.get('instructionsTitle')),
        content: Text(StringsLoader.get('instructionsContent')),
        actions: [
          TextButton(
            child: Text(StringsLoader.get('close')),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
  }

  @override
  void dispose() {
    _drawCardController?.dispose();
    for (var ctrl in _indicatorControllers) {
      ctrl.dispose();
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

    final currentCard = _deck.cards[_currentCardIndex];
    final Color frontColor = Colors.blue.shade200;

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                Text(
                  StringsLoader
                      .get('deck')
                      .replaceAll('{index}', _deckIndex.toString()),
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 20),


                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < _colorTracker.length; i++)
                      AnimatedBuilder(
                        animation: (i < _indicatorAnimations.length)
                            ? _indicatorAnimations[i]
                            : const AlwaysStoppedAnimation(0),
                        builder: (_, __) {
                          final val = (i < _indicatorAnimations.length)
                              ? _indicatorAnimations[i].value
                              : 0.0;
                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(val * pi),
                            alignment: Alignment.center,
                            child: Container(
                              width: 24,
                              height: 35,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: _colorTracker[i],
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 3,
                                    offset: Offset(1, 1),
                                  ),
                                ],
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
                              } else if (details.primaryVelocity! > 0) {
                                _flipCard(Colors.green, FlipDirection.rightToLeft);
                              }
                            }
                                : null,
                            onVerticalDragEnd: !_isFlipped
                                ? (details) {
                              if (details.primaryVelocity! > 0) {
                                _flipCard(Colors.yellow, FlipDirection.topToBottom);
                              }
                            }
                                : null,
                            child: CardFlipAnimation(
                              key: _cardKey,
                              isFlipped: _isFlipped,
                              frontCardColor: frontColor,
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
                const SizedBox(height: 10),


                Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    icon: const Icon(Icons.help_outline),
                    onPressed: _showInstructions,
                  ),
                ),
                const SizedBox(height: 10),


                if (_isFlipped)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        onPressed: _reflipCard,
                        label: Text(StringsLoader.get('reflip')),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.skip_next),
                        onPressed: _nextCard,
                        label: Text(StringsLoader.get('newCard')),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
