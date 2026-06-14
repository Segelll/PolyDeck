import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/domain/enums/flip_direction.dart';
import 'package:poly2/domain/enums/rating.dart';
import 'package:poly2/presentation/widgets/card_flip_animation.dart';
import 'package:poly2/presentation/providers/deck_provider.dart';
import 'package:poly2/core/theme/app_theme.dart';
import 'package:poly2/pages/analysis_page.dart';
import 'package:poly2/pages/settings_page.dart';
import 'package:poly2/l10n/generated/app_localizations.dart';
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
  bool _isFlippedLocally = false;
  final GlobalKey<CardFlipAnimationState> _cardKey =
      GlobalKey<CardFlipAnimationState>();

  AnimationController? _drawCardController;
  Animation<Offset>? _drawCardAnimation;

  final List<AnimationController> _indicatorControllers = [];
  final List<Animation<double>> _indicatorAnimations = [];

  @override
  void initState() {
    super.initState();
    // Schedule after first frame to avoid modifying provider during build
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDeck());
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

  Widget _buildRatingButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(12),
            shape: const CircleBorder(),
          ),
          child: Icon(icon, size: 28),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Color _colorForFeedback(int feedback) {
    switch (feedback) {
      case 1:
        return AppTheme.ratingAgain;
      case 2:
        return AppTheme.ratingGood;
      case 3:
        return AppTheme.ratingHard;
      default:
        return AppTheme.cardDefault;
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
    _isFlippedLocally = false;
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
      _isFlippedLocally = false;
      await notifier.nextCard();
      _drawCardController!.reset();
      _drawCardController!.forward();
    }
  }

  void _showAnalysis() {
    final st = ref.read(deckProvider);
    final local = AppLocalizations.of(context)!;
    final deckLabel = local.deck(st.deckIndex);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalysisPage(
          analysisResults: st.analysisResults,
          previousDeckName: deckLabel,
          deckIndex: st.deckIndex,
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
    // Use .select() to only rebuild on critical state changes
    final isLoading = ref.watch(deckProvider.select((s) => s.isLoading));
    final isEmpty = ref.watch(deckProvider.select((s) => s.isEmpty));
    final errorMessage = ref.watch(deckProvider.select((s) => s.errorMessage));
    final isFlipped = ref.watch(deckProvider.select((s) => s.isFlipped));
    final currentCard = ref.watch(deckProvider.select((s) =>
        s.isEmpty ? null : s.currentCard));
    final currentIndex = ref.watch(deckProvider.select((s) => s.currentIndex));
    final isFavorite = ref.watch(deckProvider.select((s) => s.isFavorite));
    final isLast = ref.watch(deckProvider.select((s) => s.isLastCard));
    final colorTracker = ref.watch(deckProvider.select((s) => s.colorTracker));
    final deckIndex = ref.watch(deckProvider.select((s) => s.deckIndex));
    final backColor = isFlipped && currentIndex < colorTracker.length
        ? colorTracker[currentIndex]
        : Colors.grey;

    if (errorMessage != null) {
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
              Text(errorMessage, textAlign: TextAlign.center),
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

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: HalfColoredTitle(local.appTitle),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: HalfColoredTitle(local.appTitle),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
              const SizedBox(height: 16),
              const Text(
                'Tebrikler! Bu destede çalışılacak kelime kalmadı.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Geri Dön'),
              ),
            ],
          ),
        ),
      );
    }

    if (currentCard == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: HalfColoredTitle(local.appTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
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
                  local.deck(deckIndex),
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 20),

                // Color indicator dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < colorTracker.length; i++)
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
                                color: colorTracker[i],
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
                              // Tap to flip (no rating yet)
                              onTap: !isFlipped
                                  ? () => setState(() => _isFlippedLocally = true)
                                  : null,
                              // Swipe shortcuts for rating
                              onHorizontalDragEnd: !isFlipped
                                  ? (details) {
                                      if (details.primaryVelocity! < 0) {
                                        ref
                                            .read(deckProvider.notifier)
                                            .flipCard(AppTheme.ratingAgain);
                                        setState(() => _isFlippedLocally = true);
                                      } else if (details.primaryVelocity! > 0) {
                                        ref
                                            .read(deckProvider.notifier)
                                            .flipCard(AppTheme.ratingGood);
                                        setState(() => _isFlippedLocally = true);
                                      }
                                    }
                                  : null,
                              onVerticalDragEnd: !isFlipped
                                  ? (details) {
                                      if (details.primaryVelocity! < 0) {
                                        ref
                                            .read(deckProvider.notifier)
                                            .flipCard(AppTheme.ratingEasy);
                                        setState(() => _isFlippedLocally = true);
                                      } else if (details.primaryVelocity! > 0) {
                                        ref
                                            .read(deckProvider.notifier)
                                            .flipCard(AppTheme.ratingHard);
                                        setState(() => _isFlippedLocally = true);
                                      }
                                    }
                                  : null,
                              child: CardFlipAnimation(
                                key: _cardKey,
                                isFlipped: isFlipped || _isFlippedLocally,
                                frontCardColor: Colors.blue.shade200,
                                backCardColor: backColor,
                                frontText: currentCard.frontText,
                                backText: currentCard.backText,
                                frontSentence: currentCard.frontSentence,
                                backSentence: currentCard.backSentence,
                                onFlipComplete: _reflipCard,
                                cardNumber: currentIndex + 1,
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

                // 4-button FSRS rating (visible after flip)
                if (isFlipped || _isFlippedLocally)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildRatingButton(
                          label: local.again,
                          color: AppTheme.ratingAgain,
                          icon: Icons.replay,
                          onPressed: () {
                            ref
                                .read(deckProvider.notifier)
                                .reviewCard(Rating.again);
                            setState(() => _isFlippedLocally = false);
                          },
                        ),
                        _buildRatingButton(
                          label: local.hard,
                          color: AppTheme.ratingHard,
                          icon: Icons.trending_down,
                          onPressed: () {
                            ref
                                .read(deckProvider.notifier)
                                .reviewCard(Rating.hard);
                            setState(() => _isFlippedLocally = false);
                          },
                        ),
                        _buildRatingButton(
                          label: local.good,
                          color: AppTheme.ratingGood,
                          icon: Icons.check,
                          onPressed: () {
                            ref
                                .read(deckProvider.notifier)
                                .reviewCard(Rating.good);
                            setState(() => _isFlippedLocally = false);
                          },
                        ),
                        _buildRatingButton(
                          label: local.easy,
                          color: AppTheme.ratingEasy,
                          icon: Icons.thumb_up,
                          onPressed: () {
                            ref
                                .read(deckProvider.notifier)
                                .reviewCard(Rating.easy);
                            setState(() => _isFlippedLocally = false);
                          },
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

                if (isFlipped || _isFlippedLocally)
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
