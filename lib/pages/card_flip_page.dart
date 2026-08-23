import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/domain/enums/flip_direction.dart';
import 'package:poly2/domain/enums/rating.dart';
import 'package:poly2/domain/enums/review_input_mode.dart';
import 'package:poly2/domain/models/deck_summary.dart';
import 'package:poly2/presentation/widgets/card_flip_animation.dart';
import 'package:poly2/presentation/providers/deck_provider.dart';
import 'package:poly2/presentation/providers/deck_repository_provider.dart';
import 'package:poly2/presentation/providers/settings_provider.dart';
import 'package:poly2/pages/add_to_deck_sheet.dart';
import 'package:poly2/core/theme/app_palette.dart';
import 'package:poly2/core/theme/app_theme.dart';
import 'package:poly2/pages/analysis_page.dart';
import 'package:poly2/pages/settings_page.dart';
import 'package:poly2/l10n/generated/app_localizations.dart';
import 'package:poly2/presentation/widgets/half_colored_title.dart';

class CardFlipPage extends ConsumerStatefulWidget {
  final String levels;
  final int? deckId;
  final String? deckName;

  const CardFlipPage({
    super.key,
    required this.levels,
    this.deckId,
    this.deckName,
  });

  @override
  ConsumerState<CardFlipPage> createState() => _CardFlipPageState();
}

class _CardFlipPageState extends ConsumerState<CardFlipPage>
    with TickerProviderStateMixin {
  FlipDirection _flipDirection = FlipDirection.leftToRight;
  AnimationController? _drawCardController;
  Animation<Offset>? _drawCardAnimation;

  final List<AnimationController> _indicatorControllers = [];
  final List<Animation<double>> _indicatorAnimations = [];

  @override
  void initState() {
    super.initState();
    // Schedule after first frame to avoid modifying provider during build
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_loadDeck()));
  }

  Future<void> _loadDeck() async {
    final notifier = ref.read(deckProvider.notifier);
    await notifier.loadDeck(widget.levels, deckId: widget.deckId);
    if (!mounted) return;
    _initDrawCardAnimation();
  }

  void _initDrawCardAnimation() {
    _drawCardController?.dispose();
    _drawCardController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _drawCardAnimation =
        Tween<Offset>(
          begin: const Offset(0, -2.0),
          end: const Offset(0, 0),
        ).animate(
          CurvedAnimation(parent: _drawCardController!, curve: Curves.easeOut),
        );
    unawaited(_drawCardController!.forward());
  }

  Widget _buildRatingButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: AppTheme.ratingOnColor,
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

  void _revealCard(FlipDirection direction) {
    if (ref.read(deckProvider).isReviewing) return;
    setState(() => _flipDirection = direction);
    ref.read(deckProvider.notifier).revealCard();
  }

  void _animateIndicator(int index) {
    while (_indicatorControllers.length < 10) {
      final ctrl = AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      );
      _indicatorControllers.add(ctrl);
      _indicatorAnimations.add(
        Tween<double>(
          begin: 0,
          end: 1,
        ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOut)),
      );
    }
    unawaited(_indicatorControllers[index].forward(from: 0));
  }

  void _reflipCard() {
    ref.read(deckProvider.notifier).reflipCard();
  }

  Future<void> _nextCard() async {
    if (ref.read(deckProvider).isLastCard) {
      _showAnalysis();
    } else {
      await ref.read(deckProvider.notifier).nextCard();
      if (!mounted || _drawCardController == null) return;
      _drawCardController!.reset();
      unawaited(_drawCardController!.forward());
    }
  }

  void _showAnalysis() {
    final st = ref.read(deckProvider);
    final local = AppLocalizations.of(context)!;
    final deckLabel = widget.deckName ?? local.deck(st.deckIndex);

    unawaited(
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
      ),
    );
  }

  Future<void> _startNewDeck() async {
    ref.read(deckProvider.notifier).startNewDeck();
    await _loadDeck();
  }

  Future<void> _submitRating(Rating rating) async {
    final currentState = ref.read(deckProvider);
    if (currentState.lastRating != null || currentState.isReviewing) {
      return;
    }
    await ref.read(deckProvider.notifier).reviewCard(rating);
    if (!mounted) return;
    _animateIndicator(ref.read(deckProvider).currentIndex);
  }

  Rating? _ratingForSwipe({double? horizontal, double? vertical}) {
    if (horizontal != null) {
      if (horizontal < 0) return Rating.again;
      if (horizontal > 0) return Rating.good;
    }
    if (vertical != null) {
      if (vertical < 0) return Rating.easy;
      if (vertical > 0) return Rating.hard;
    }
    return null;
  }

  Future<void> _openAddToDeck() async {
    final state = ref.read(deckProvider);
    if (state.isEmpty || state.isReviewing) return;

    final repo = ref.read(deckRepositoryProvider);
    final card = state.currentCard;
    // Open immediately. The deck query runs while the sheet is visible so a
    // slow database read never makes the tap appear to be ignored.
    final decksFuture = repo.fetchDeckSummaries();
    final addedDeckId = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => FutureBuilder<List<DeckSummary>>(
        future: decksFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const SafeArea(
              child: SizedBox(
                height: 180,
                child: Center(child: Text('Desteler yüklenemedi.')),
              ),
            );
          }
          final decks = snapshot.data;
          if (decks == null) {
            return const SafeArea(
              child: SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }
          return AddToDeckSheet(
            decks: decks,
            wordId: card.id,
            sourceLanguage: card.sourceLanguageCode,
            targetLanguage: card.targetLanguageCode,
          );
        },
      ),
    );

    if (addedDeckId != null && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Kart desteye eklendi')));
    }
  }

  void _showInstructions() {
    final local = AppLocalizations.of(context)!;
    unawaited(
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
    final currentCard = ref.watch(
      deckProvider.select((s) => s.isEmpty ? null : s.currentCard),
    );
    final currentIndex = ref.watch(deckProvider.select((s) => s.currentIndex));
    final isReviewing = ref.watch(deckProvider.select((s) => s.isReviewing));
    final lastRating = ref.watch(deckProvider.select((s) => s.lastRating));
    final colorTracker = ref.watch(deckProvider.select((s) => s.colorTracker));
    final reviewInputMode = ref.watch(
      settingsProvider.select(
        (state) =>
            state.valueOrNull?.reviewInputMode ?? ReviewInputMode.buttons,
      ),
    );
    final backColor = isFlipped && currentIndex < colorTracker.length
        ? colorTracker[currentIndex]
        : AppTheme.cardDefault;

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
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppPalette.raindropsOnRoses,
              ),
              const SizedBox(height: 16),
              Text(errorMessage, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => unawaited(_loadDeck()),
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
              const Icon(
                Icons.check_circle_outline,
                size: 64,
                color: AppPalette.almostAqua,
              ),
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
        title: Text(widget.deckName ?? local.appTitle),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Desteye ekle',
            icon: const Icon(Icons.add),
            onPressed: isReviewing ? null : () => unawaited(_openAddToDeck()),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => unawaited(
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bodyGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Color indicator dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < colorTracker.length; i++)
                      AnimatedBuilder(
                        animation: i < _indicatorAnimations.length
                            ? _indicatorAnimations[i]
                            : const AlwaysStoppedAnimation(0),
                        builder: (_, _) {
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
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: colorTracker[i],
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppPalette.shadow,
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
                              onTap: !isFlipped && !isReviewing
                                  ? () => _revealCard(_flipDirection)
                                  : null,
                              onHorizontalDragEnd:
                                  reviewInputMode == ReviewInputMode.swipe &&
                                      isFlipped &&
                                      lastRating == null &&
                                      !isReviewing
                                  ? (details) {
                                      final rating = _ratingForSwipe(
                                        horizontal: details.primaryVelocity,
                                      );
                                      if (rating != null) {
                                        unawaited(_submitRating(rating));
                                      }
                                    }
                                  : null,
                              onVerticalDragEnd:
                                  reviewInputMode == ReviewInputMode.swipe &&
                                      isFlipped &&
                                      lastRating == null &&
                                      !isReviewing
                                  ? (details) {
                                      final rating = _ratingForSwipe(
                                        vertical: details.primaryVelocity,
                                      );
                                      if (rating != null) {
                                        unawaited(_submitRating(rating));
                                      }
                                    }
                                  : null,
                              child: CardFlipAnimation(
                                isFlipped: isFlipped,
                                frontCardColor: AppPalette.iceMelt,
                                backCardColor: backColor,
                                frontText: currentCard.frontText,
                                backText: currentCard.backText,
                                frontSentence: currentCard.frontSentence,
                                backSentence: currentCard.backSentence,
                                flipDirection: _flipDirection,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // 4-button FSRS rating (visible after flip)
                if (reviewInputMode == ReviewInputMode.buttons &&
                    isFlipped &&
                    lastRating == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildRatingButton(
                          label: local.again,
                          color: AppTheme.ratingAgain,
                          icon: Icons.replay,
                          onPressed: isReviewing
                              ? null
                              : () => _submitRating(Rating.again),
                        ),
                        _buildRatingButton(
                          label: local.hard,
                          color: AppTheme.ratingHard,
                          icon: Icons.trending_down,
                          onPressed: isReviewing
                              ? null
                              : () => _submitRating(Rating.hard),
                        ),
                        _buildRatingButton(
                          label: local.good,
                          color: AppTheme.ratingGood,
                          icon: Icons.check,
                          onPressed: isReviewing
                              ? null
                              : () => _submitRating(Rating.good),
                        ),
                        _buildRatingButton(
                          label: local.easy,
                          color: AppTheme.ratingEasy,
                          icon: Icons.thumb_up,
                          onPressed: isReviewing
                              ? null
                              : () => _submitRating(Rating.easy),
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

                if (isFlipped)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (lastRating == null)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          onPressed: isReviewing ? null : _reflipCard,
                          label: Text(local.reflip),
                        ),
                      if (lastRating == null) const SizedBox(width: 10),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.skip_next),
                        onPressed: isReviewing
                            ? null
                            : () => unawaited(_nextCard()),
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
