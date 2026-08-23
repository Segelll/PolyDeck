import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poly2/data/database/database.dart';
import 'package:poly2/data/repositories/deck_repository.dart';
import 'package:poly2/data/repositories/user_repository.dart';
import 'package:poly2/data/repositories/word_repository.dart';
import 'package:poly2/l10n/generated/app_localizations.dart';
import 'package:poly2/pages/analysis_page.dart';
import 'package:poly2/presentation/providers/deck_provider.dart';
import 'package:poly2/presentation/widgets/card_flip_animation.dart';
import 'package:poly2/presentation/widgets/highlighted_sentence.dart';
import 'package:poly2/domain/enums/flip_direction.dart';
import 'package:poly2/services/fsrs_service.dart';

void main() {
  test('earliest progress date ignores legacy sentinel values', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await db
        .into(db.words)
        .insert(
          WordsCompanion.insert(
            id: 1,
            word: 'sentinel',
            sentence: 'sentinel',
            level: 'A1',
            languageCode: 'tr',
            date: const Value('0'),
          ),
        );
    await db
        .into(db.words)
        .insert(
          WordsCompanion.insert(
            id: 2,
            word: 'valid',
            sentence: 'valid',
            level: 'A1',
            languageCode: 'tr',
            date: const Value('2026-08-01'),
          ),
        );

    expect(await db.getEarliestDate('tr'), '2026-08-01');
    await db.close();
  });

  test('user settings expose a single persisted review mode', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await db.saveUserChoices('en', 'tr');

    final choices = await db.getUserChoices();
    expect(choices?['reviewMode'], 'buttons');

    await db.saveUserChoices('en', 'tr', reviewMode: 'swipe');
    expect((await db.getUserChoices())?['reviewMode'], 'swipe');
    await db.close();
  });

  test('fresh databases use the single current schema', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    expect(db.schemaVersion, 1);

    final tableRows = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    final tableNames = tableRows.map((row) => row.read<String>('name')).toSet();

    expect(
      tableNames,
      containsAll(<String>[
        'words',
        'revlog',
        'deck_config',
        'user',
        'decks',
        'deck_cards',
      ]),
    );

    final userColumns = await db
        .customSelect("PRAGMA table_info('user')")
        .get();
    expect(
      userColumns.map((row) => row.read<String>('name')),
      contains('review_mode'),
    );
    await db.close();
  });

  test('today review limits are scoped to the requested level', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final now = DateTime.now().toUtc().toIso8601String();

    for (final entry in [(id: 1, level: 'A1'), (id: 2, level: 'A2')]) {
      await db
          .into(db.words)
          .insert(
            WordsCompanion.insert(
              id: entry.id,
              word: 'word-${entry.id}',
              sentence: 'sentence-${entry.id}',
              level: entry.level,
              languageCode: 'tr',
            ),
          );
      await db.insertRevlogEntry(
        cardId: entry.id,
        deckTable: 'tr',
        rating: 3,
        state: 0,
        due: '',
        stability: 1,
        difficulty: 1,
        elapsedDays: 0,
        lastElapsedDays: 0,
        scheduledDays: 0,
        reviewDate: now,
      );
    }

    final a1 = await db.getTodayCounts('tr', 'A1');

    expect(a1.newCount, 1);
    expect(a1.reviewCount, 0);
    await db.close();
  });

  test('resetting SRS clears due dates and last review timestamps', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db
        .into(db.words)
        .insert(
          WordsCompanion.insert(
            id: 1,
            word: 'scheduled',
            sentence: 'scheduled sentence',
            level: 'A1',
            languageCode: 'tr',
            isSeen: const Value(1),
            date: const Value('2026-08-23'),
            cardState: const Value(2),
            stability: const Value(4.0),
            difficulty: const Value(6.0),
            due: const Value('2026-08-30'),
            lastReview: const Value('2026-08-23T10:00:00.000Z'),
            reps: const Value(4),
            lapses: const Value(1),
          ),
        );

    await db.resetSrsState('tr');
    final word = await db.fetchWordById('tr', 1);

    expect(word?.cardState, 0);
    expect(word?.due, null);
    expect(word?.lastReview, null);
    expect(word?.reps, 0);
    expect(word?.lapses, 0);
    await db.close();
  });

  test('a new-card review counts toward the new-card daily limit', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final now = DateTime.now().toUtc().toIso8601String();
    await db
        .into(db.words)
        .insert(
          WordsCompanion.insert(
            id: 1,
            word: 'new-card',
            sentence: 'new-card sentence',
            level: 'A1',
            languageCode: 'tr',
          ),
        );

    await db.reviewWord(
      wordId: 1,
      deckTable: 'tr',
      rating: 3,
      cardState: 1,
      stability: 1,
      difficulty: 1,
      reviewState: 0,
      due: '2026-08-24',
      elapsedDays: 0,
      scheduledDays: 1,
      reps: 1,
      lapses: 0,
      lastReview: now,
      feedbackValue: 2,
      reviewDate: now,
      guardLastReview: null,
    );

    final counts = await db.getTodayCounts('tr', 'A1');

    expect(counts.newCount, 1);
    await db.close();
  });

  test('deck loading does not bypass the daily new-card limit', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.saveUserChoices('en', 'tr');
    await db.saveDeckConfigEntry(
      level: 'A1',
      maxNewPerDay: 1,
      maxReviewsPerDay: 20,
      learningSteps: '[1,10]',
      enableFuzz: true,
      requestRetention: 0.9,
    );

    for (final id in [1, 2]) {
      await db
          .into(db.words)
          .insert(
            WordsCompanion.insert(
              id: id,
              word: 'target-$id',
              sentence: 'target sentence',
              level: 'A1',
              languageCode: 'tr',
            ),
          );
      await db
          .into(db.words)
          .insert(
            WordsCompanion.insert(
              id: id,
              word: 'source-$id',
              sentence: 'source sentence',
              level: 'A1',
              languageCode: 'en',
            ),
          );
    }

    final now = DateTime.now().toUtc().toIso8601String();
    await db.insertRevlogEntry(
      cardId: 1,
      deckTable: 'tr',
      rating: 3,
      state: 0,
      due: '',
      stability: 1,
      difficulty: 1,
      elapsedDays: 0,
      lastElapsedDays: 0,
      scheduledDays: 0,
      reviewDate: now,
    );

    final notifier = DeckNotifier(
      WordRepository(db),
      UserRepository(db),
      DeckRepository(db),
      FsrsService(),
      () {},
    );
    await notifier.loadDeck('A1');

    expect(notifier.state.cards, isEmpty);
    await db.close();
  });

  test('standard cards carry the source-language sentence', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.saveUserChoices('en', 'tr');
    await db
        .into(db.words)
        .insert(
          WordsCompanion.insert(
            id: 1,
            word: 'merhaba',
            sentence: 'Merhaba dünya.',
            level: 'A1',
            languageCode: 'tr',
          ),
        );
    await db
        .into(db.words)
        .insert(
          WordsCompanion.insert(
            id: 1,
            word: 'hello',
            sentence: 'Hello world.',
            level: 'A1',
            languageCode: 'en',
          ),
        );

    final notifier = DeckNotifier(
      WordRepository(db),
      UserRepository(db),
      DeckRepository(db),
      FsrsService(),
      () {},
    );
    await notifier.loadDeck('A1');

    expect(notifier.state.currentCard.backSentence, 'Hello world.');
    expect(notifier.state.cards, hasLength(1));
    await db.close();
  });

  test('a stale deck load cannot overwrite a newer deck load', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.saveUserChoices('en', 'tr');
    for (final entry in [
      (id: 1, word: 'a1-word', level: 'A1'),
      (id: 2, word: 'a2-word', level: 'A2'),
    ]) {
      await db
          .into(db.words)
          .insert(
            WordsCompanion.insert(
              id: entry.id,
              word: entry.word,
              sentence: '${entry.word} sentence',
              level: entry.level,
              languageCode: 'tr',
            ),
          );
      await db
          .into(db.words)
          .insert(
            WordsCompanion.insert(
              id: entry.id,
              word: 'source-${entry.word}',
              sentence: 'source sentence',
              level: entry.level,
              languageCode: 'en',
            ),
          );
    }

    final wordRepo = _ControlledWordRepository(db);
    final notifier = DeckNotifier(
      wordRepo,
      UserRepository(db),
      DeckRepository(db),
      FsrsService(),
      () {},
    );

    final firstLoad = notifier.loadDeck('A1');
    await wordRepo.firstNewCardFetchStarted.future;
    final secondLoad = notifier.loadDeck('A2');
    await secondLoad;
    wordRepo.releaseFirstNewCardFetch();
    await firstLoad;

    expect(notifier.state.cards.single.frontText, 'a2-word');
    await db.close();
  });

  testWidgets('card face does not show card number or level labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CardFlipAnimation(
          isFlipped: true,
          frontCardColor: Colors.blue,
          backCardColor: Colors.green,
          frontText: 'hello',
          backText: 'merhaba',
          frontSentence: 'Hello world.',
          backSentence: 'Merhaba dünya.',
          flipDirection: FlipDirection.leftToRight,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Card 1'), findsNothing);
    expect(find.text('A1'), findsNothing);
    expect(find.text('Merhaba dünya.'), findsOneWidget);
  });

  test('sentence highlighting matches the whole vocabulary word', () {
    final spans = buildHighlightedSentenceSpans(
      'The cat sat beside a concatenate example.',
      'CAT',
    );

    final highlighted = spans
        .whereType<TextSpan>()
        .where((span) => span.style?.decoration == TextDecoration.underline)
        .map((span) => span.text)
        .toList();

    expect(highlighted, ['cat']);
  });

  testWidgets('long card sentences wrap at a fixed readable font size', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CardFlipAnimation(
          isFlipped: false,
          frontCardColor: Colors.blue,
          backCardColor: Colors.green,
          frontText: 'word',
          backText: 'kelime',
          frontSentence: 'word appears in a deliberately long sentence that should wrap across multiple lines.',
          backSentence: 'Kelime kısa bir cümlededir.',
          flipDirection: FlipDirection.leftToRight,
        ),
      ),
    );
    await tester.pump();

    final sentenceFinder = find.byType(HighlightedSentence).first;
    final sentence = tester.widget<HighlightedSentence>(sentenceFinder);

    expect(sentence.maxLines, equals(null));
    expect(sentence.style.fontSize, 16);
    expect(find.byType(FittedBox), findsNothing);

    final richText = tester.widget<RichText>(
      find.descendant(of: sentenceFinder, matching: find.byType(RichText)),
    );
    final textPainter = TextPainter(
      text: richText.text,
      textAlign: richText.textAlign,
      textDirection: richText.textDirection ?? TextDirection.ltr,
      textScaler: richText.textScaler,
      maxLines: richText.maxLines,
    )..layout(maxWidth: 218);
    addTearDown(textPainter.dispose);

    expect(textPainter.computeLineMetrics().length, greaterThan(1));
  });

  testWidgets('new deck starts after the analysis route closes', (
    tester,
  ) async {
    var callbackCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AnalysisPage(
                  analysisResults: const [],
                  previousDeckName: 'A1',
                  deckIndex: 1,
                  onNewDeck: () async => callbackCount++,
                ),
              ),
            ),
            child: const Text('open analysis'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open analysis'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start New Deck'));
    await tester.pumpAndSettle();

    expect(callbackCount, 1);
    expect(find.byType(AnalysisPage), findsNothing);
  });
}

class _ControlledWordRepository extends WordRepository {
  _ControlledWordRepository(super.db);

  final firstNewCardFetchStarted = Completer<void>();
  final _releaseFirstNewCardFetch = Completer<void>();
  var _newCardFetchCount = 0;

  void releaseFirstNewCardFetch() {
    _releaseFirstNewCardFetch.complete();
  }

  @override
  Future<List<Word>> fetchNewCards(
    String language,
    String? level,
    int limit,
  ) async {
    _newCardFetchCount++;
    if (_newCardFetchCount == 1) {
      firstNewCardFetchStarted.complete();
      await _releaseFirstNewCardFetch.future;
    }
    return super.fetchNewCards(language, level, limit);
  }
}
