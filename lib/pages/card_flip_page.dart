import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:poly2/services/database_helper.dart';
import 'package:poly2/card_animations.dart';
import 'package:poly2/card_deck.dart';
import 'package:poly2/models/card_model.dart';
import 'package:poly2/pages/analysis_page.dart';
import 'package:poly2/models/analysis_result.dart';
import 'package:poly2/pages/settings_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/Half_Color.dart';
class CardFlipPage extends StatefulWidget {
  final String levels;

  const CardFlipPage({super.key, required this.levels});

  @override
  State<CardFlipPage> createState() => _CardFlipPageState();
}

class _CardFlipPageState extends State<CardFlipPage> with TickerProviderStateMixin {
  final CardDeck _deck = CardDeck();
  final DBHelper _dbHelper = DBHelper();
  bool _isLoading = true;
  int _currentCardIndex = 0;
  bool _isFlipped = false;
  Color _backCardColor = Colors.grey;
  List<Color> _colorTracker = List.generate(10, (_) => Colors.grey);
  final List<AnalysisResult> _analysisResults = [];
  int _deckIndex = 1;
  String? _targetLang;
  String? _motherLang;
  bool _isFavorite = false;

  FlipDirection _flipDirection = FlipDirection.leftToRight;
  final GlobalKey<CardFlipAnimationState> _cardKey = GlobalKey<CardFlipAnimationState>();

  AnimationController? _drawCardController;
  Animation<Offset>? _drawCardAnimation;

  final List<AnimationController> _indicatorControllers = [];
  final List<Animation<double>> _indicatorAnimations = [];

  @override
  void initState() {
    super.initState();
    _loadPrefss();
    _loadDeck();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final isFav = await _dbHelper.isFavorite(_deck.cards[_currentCardIndex].frontText);
    setState(() {
      _isFavorite = isFav;
    });
  }

  Future<void> _loadPrefss() async {
    final userSettings = await _dbHelper.getUserChoices('user');
    setState(() {
      _motherLang = userSettings?['mainLanguage'];
      _targetLang = userSettings?['targetLanguage'];
    });
  }

  Future<void> _loadDeck() async {
    setState(() => _isLoading = true);

    try {
      List<CardModel> combined = [];
      await _deck.loadCards(level: widget.levels);
      combined.addAll(_deck.cards);

      combined.shuffle(Random());

      final selected = combined.take(10).toList();
      _deck.cards.clear();
      _deck.cards.addAll(selected);
    } catch (e) {
      if (kDebugMode) {
        print('Error in _loadDeck: $e');
      }
    }

    setState(() {
      _isLoading = false;
      _initDrawCardAnimation();
    });
  }

  Future<void> updateFeedback(String tableName, int id, int feedback) async {
    setState(() {
      if (kDebugMode) {
        print("Feedback updating...");
      }
    });

    try {
      await DBHelper.instance.updateFeedback(tableName, id, feedback);
      setState(() {
        if (kDebugMode) {
          print("Feedback updated successfully.");
        }
      });
    } catch (e) {
      setState(() {
        if (kDebugMode) {
          print("Error: Feedback could not be updated: $e");
        }
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
      CurvedAnimation(parent: _drawCardController!, curve: Curves.easeOut),
    );
    _drawCardController!.forward();
  }

  void _flipCard(Color color, FlipDirection direction) {
    final currentCard = _deck.cards[_currentCardIndex];

    setState(() {
      _isFlipped = true;
      _backCardColor = color;
      _flipDirection = direction;
      _colorTracker[_currentCardIndex] = color;

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

  void _nextCard() async {
    if (_currentCardIndex < _deck.cards.length - 1) {
      setState(() {
        _currentCardIndex++;
        _isFlipped = false;
        _backCardColor = Colors.grey;
        _isFavorite = false;
        _drawCardController!.reset();
        _drawCardController!.forward();
      });
      await _checkIfFavorite();
    } else {
      _showAnalysis();
    }
  }

  void _showAnalysis() {
    final local = AppLocalizations.of(context)!;
    String deckLabel = local.deck(_deckIndex);

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
    final local = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(local.instructionsTitle),
        content: Text(local.instructionsContent),
        actions: [
          TextButton(
            child: Text(local.close),
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

  void _toggleFavorite() async {
    final currentCard = _deck.cards[_currentCardIndex];
    try {
      if (_isFavorite) {
        await _dbHelper.removeFromFavorites(currentCard.frontText);
        setState(() {
          _isFavorite = false;
        });
      } else {
        await _dbHelper.addToFavorites(
          currentCard.frontText,
          currentCard.frontSentence,
          currentCard.level,
          currentCard.backText,
          currentCard.backSentence,
        );
        setState(() {
          _isFavorite = true;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling favorite: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating favorite status!')),
      );
    }
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
    final local = AppLocalizations.of(context)!;

    if (_isLoading || _deck.cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: halfColoredTitle(local.appTitle),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentCard = _deck.cards[_currentCardIndex];
    final Color frontColor = Colors.blue.shade200;

    return Scaffold(
      appBar: AppBar(
        title: halfColoredTitle(local.appTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: Colors.yellow.shade700,
            ),
            onPressed: _toggleFavorite,
          ),
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
                  local.deck(_deckIndex),
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
                                updateFeedback(_targetLang!, currentCard.id, 1);
                              } else if (details.primaryVelocity! > 0) {
                                _flipCard(Colors.green, FlipDirection.rightToLeft);
                                updateFeedback(_targetLang!, currentCard.id, 2);
                              }
                            }
                                : null,
                            onVerticalDragEnd: !_isFlipped
                                ? (details) {
                              if (details.primaryVelocity! > 0) {
                                _flipCard(
                                  const Color.fromARGB(255, 179, 130, 8),
                                  FlipDirection.topToBottom,
                                );
                                updateFeedback(_targetLang!, currentCard.id, 3);
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
                        label: Text(local.reflip),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.skip_next),
                        onPressed: _nextCard,
                        label: Text(local.newCard),
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
