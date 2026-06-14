import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/presentation/widgets/card_flip_animation.dart';
import 'package:poly2/presentation/providers/deck_provider.dart';
import 'package:poly2/pages/analysis_page.dart';
import 'package:poly2/pages/settings_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poly2/presentation/widgets/half_colored_title.dart';

class CardFlipPage extends ConsumerStatefulWidget {
  final String levels;

  const CardFlipPage({super.key, required this.levels});

  @override
  ConsumerState<CardFlipPage> createState() => _CardFlipPageState();
}

class _CardFlipPageState extends ConsumerState<CardFlipPage>
    with TickerProviderStateMixin {
  FlipDirection _flipDirection = FlipDirection.leftToRight;
  final GlobalKey<CardFlipAnimationState> _cardKey =
      GlobalKey<CardFlipAnimationState>();

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
    final notifier = ref.read(deckProvider.notifier);
    await notifier.loadDeck(widget.levels);
    _initDrawCardAnimation();
  }

  void _initDrawCardAnimation() {
    _drawCardController?.dispose();
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

  Color _colorForFeedback(int feedback) {
    switch (feedback) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.green;
      case 3:
        return const Color.fromARGB(255, 179, 130, 8);
      default:
        return Colors.grey;
    }
  }

  void _flipCard(Color color, FlipDirection direction) async {
    final notifier = ref.read(deckProvider.notifier);
    setState(() => _flipDirection = direction);
    await notifier.flipCard(color);
    _animateIndicator(notifier.state.currentIndex);
  }

  void _animateIndicator(int index) {
    while (_indicatorControllers.length < 10) {
      final ctrl = AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      );
      _indicatorControllers.add(ctrl);
      _indicatorAnimations.add(
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: ctrl, curve: Curves.easeOut),
        ),
      );
    }
    _indicatorControllers[index].forward(from: 0);
  }

  void _reflipCard() {
    _cardKey.currentState?.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        ref.read(deckProvider.notifier).reflipCard();
        _cardKey.currentState?.removeStatusListener();
      }
    });
  }

  void _nextCard() async {
    final notifier = ref.read(deckProvider.notifier);
    if (notifier.state.isLastCard) {
      _showAnalysis();
    } else {
      await notifier.nextCard();
      _drawCardController!.reset();
      _drawCardController!.forward();
    }
  }

  void _showAnalysis() {
    final state = ref.read(deckProvider);
    final local = AppLocalizations.of(context)!;
    final deckLabel = local.deck(state.deckIndex);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalysisPage(
          analysisResults: state.analysisResults,
          previousDeckName: deckLabel,
          deckIndex: state.deckIndex,
          onNewDeck: _startNewDeck,
        ),
      ),
    );
  }

  void _startNewDeck() {
    ref.read(deckProvider.notifier).startNewDeck();
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

  @override
  void dispose() {
    _drawCardController?.dispose();
    for (final ctrl in _indicatorControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final state = ref.watch(deckProvider);

    if (state.isLoading || state.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: HalfColoredTitle(local.appTitle),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: HalfColoredTitle(local.appTitle),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(state.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDeck,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final currentCard = state.currentCard;
    final backColor = state.isFlipped
        ? state.colorTracker[state.currentIndex]
        : Colors.grey;

    return Scaffold(
      appBar: AppBar(
        title: HalfColoredTitle(local.appTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              state.isFavorite ? Icons.star : Icons.star_border,
              color: Colors.yellow.shade700,
            ),
            onPressed: () => ref.read(deckProvider.notifier).toggleFavorite(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
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
                  local.deck(state.deckIndex),
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 20),

                // Color indicator dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < state.colorTracker.length; i++)
                      AnimatedBuilder(
                        animation: i < _indicatorAnimations.length
                            ? _indicatorAnimations[i]
                            : const AlwaysStoppedAnimation(0),
                        builder: (_, __) {
                          final val = i < _indicatorAnimations.length
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
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: state.colorTracker[i],
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
                      if (_drawCardAnimation != null)
                        SlideTransition(
                          position: _drawCardAnimation!,
                          child: Center(
                            child: GestureDetector(
                              onHorizontalDragEnd: !state.isFlipped
                                  ? (details) {
                                      if (details.primaryVelocity! < 0) {
                                        _flipCard(Colors.red,
                                            FlipDirection.leftToRight);
                                      } else if (details.primaryVelocity! > 0) {
                                        _flipCard(Colors.green,
                                            FlipDirection.rightToLeft);
                                      }
                                    }
                                  : null,
                              onVerticalDragEnd: !state.isFlipped
                                  ? (details) {
                                      if (details.primaryVelocity! > 0) {
                                        _flipCard(
                                          const Color.fromARGB(
                                              255, 179, 130, 8),
                                          FlipDirection.topToBottom,
                                        );
                                      }
                                    }
                                  : null,
                              child: CardFlipAnimation(
                                key: _cardKey,
                                isFlipped: state.isFlipped,
                                frontCardColor: Colors.blue.shade200,
                                backCardColor: backColor,
                                frontText: currentCard.frontText,
                                backText: currentCard.backText,
                                frontSentence: currentCard.frontSentence,
                                backSentence: currentCard.backSentence,
                                onFlipComplete: _reflipCard,
                                cardNumber: state.currentIndex + 1,
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

                if (state.isFlipped)
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
