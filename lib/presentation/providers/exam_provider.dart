import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/data/repositories/word_repository.dart';
import 'package:poly2/data/repositories/user_repository.dart';
import 'package:poly2/domain/models/exam_model.dart';
import 'package:poly2/domain/state/exam_state.dart';
import 'package:poly2/presentation/providers/database_provider.dart';
import 'package:poly2/core/constants/app_constants.dart';
import 'package:poly2/core/constants/language_codes.dart';
import 'package:poly2/core/performance/perf_trace.dart';

class ExamNotifier extends StateNotifier<ExamState> {
  final WordRepository _wordRepo;
  final UserRepository _userRepo;

  ExamNotifier(this._wordRepo, this._userRepo) : super(const ExamState());

  Future<void> loadQuestions() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await PerfTrace.timeAsync('exam.loadQuestions', () async {
      try {
        final userSettings = await _userRepo.getUserChoices();
        final questionLanguage = userSettings?['targetLanguage'] ?? 'tr';
        final answerLanguage = userSettings?['mainLanguage'] ?? 'en';
        final questionLang = LanguageCodes.tableNameFor(questionLanguage);
        final answerLang = LanguageCodes.tableNameFor(answerLanguage);
        final rng = Random();

        // ── Phase 1: pick random question IDs per level ──
        const levels = ['A1', 'A2', 'B1', 'B2', 'C1'];
        final allQuestionIds = <int>[];
        final idsByLevel = await PerfTrace.timeAsync(
          'exam.fetchQuestionIds',
          () => _wordRepo.fetchWordIdsByLevels(
            language: questionLang,
            levels: levels,
          ),
        );
        for (final level in levels) {
          final ids = List<int>.from(idsByLevel[level] ?? const <int>[]);
          if (ids.isEmpty) continue;
          ids.shuffle(rng);
          allQuestionIds.addAll(ids.take(AppConstants.questionsPerLevel));
        }

        if (allQuestionIds.isEmpty) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'No words found',
          );
          return;
        }

        // ── Phase 2: batch-fetch question + answer words ──
        final wordBatches = await Future.wait([
          PerfTrace.timeAsync(
            'exam.fetchQuestions',
            () => _wordRepo.fetchWordsByIds(questionLang, allQuestionIds),
          ),
          PerfTrace.timeAsync(
            'exam.fetchAnswers',
            () => _wordRepo.fetchWordsByIds(answerLang, allQuestionIds),
          ),
        ]);
        final questionWords = wordBatches[0];
        final answerWords = wordBatches[1];

        final qMap = <int, String>{};
        for (final w in questionWords) {
          qMap[w.id] = w.word;
        }
        final aMap = <int, String>{};
        for (final w in answerWords) {
          aMap[w.id] = w.word;
        }

        // ── Phase 3: build a global distractor pool ──
        // Fetch a larger pool of words in the answer language, then sample
        // per question.
        final poolIds = <int>[];
        final answerIdsByLevel = await PerfTrace.timeAsync(
          'exam.fetchAnswerPoolIds',
          () => _wordRepo.fetchWordIdsByLevels(
            language: answerLang,
            levels: levels,
          ),
        );
        for (final level in levels) {
          final ids = List<int>.from(answerIdsByLevel[level] ?? const <int>[]);
          ids.shuffle(rng);
          poolIds.addAll(ids.take(30)); // generous pool per level
        }
        final poolWords = await _wordRepo.fetchWordsByIds(answerLang, poolIds);
        final globalPool = poolWords.map((w) => w.word).toList();

        // ── Phase 4: assemble questions ──
        final generatedQuestions = <Question>[];
        for (final id in allQuestionIds) {
          final questionText = qMap[id];
          final correctAnswer = aMap[id];
          if (questionText == null || correctAnswer == null) continue;

          // Pick distractors from the global pool, excluding the correct answer.
          final candidates = globalPool
              .where((w) => w != correctAnswer)
              .toList();
          candidates.shuffle(rng);
          final distractors = candidates
              .take(AppConstants.distractorsPerQuestion)
              .toList();

          final options = [correctAnswer, ...distractors]..shuffle(rng);
          generatedQuestions.add(
            Question(
              questionText: questionText,
              options: options,
              correctAnswerIndex: options.indexOf(correctAnswer),
            ),
          );
        }

        state = state.copyWith(
          questions: generatedQuestions,
          userAnswers: List.filled(generatedQuestions.length, null),
          isLoading: false,
          currentIndex: 0,
          answered: false,
          selectedAnswerIndex: null,
        );
      } catch (e) {
        if (kDebugMode) print('ExamNotifier.loadQuestions error: $e');
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load exam: $e',
        );
      }
    }); // end exam.loadQuestions trace
  }

  void selectAnswer(int answerIndex) {
    if (state.answered) return;
    final newAnswers = List<int?>.from(state.userAnswers);
    newAnswers[state.currentIndex] = answerIndex;
    state = state.copyWith(
      userAnswers: newAnswers,
      answered: true,
      selectedAnswerIndex: answerIndex,
    );
  }

  void nextQuestion() {
    if (state.isLastQuestion) return;
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      answered: false,
      selectedAnswerIndex: null,
    );
  }
}

final examProvider = StateNotifierProvider.autoDispose<ExamNotifier, ExamState>(
  (ref) {
    final wordRepo = ref.read(wordRepositoryProvider);
    final userRepo = ref.read(userRepositoryProvider);
    return ExamNotifier(wordRepo, userRepo);
  },
);
