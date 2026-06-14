import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/data/repositories/word_repository.dart';
import 'package:poly2/data/repositories/user_repository.dart';
import 'package:poly2/models/exam_model.dart';
import 'package:poly2/core/constants/app_constants.dart';
import 'package:poly2/core/constants/language_codes.dart';

/// The state of an exam session.
class ExamState {
  final List<Question> questions;
  final int currentIndex;
  final List<int?> userAnswers;
  final bool isLoading;
  final bool answered;
  final int? selectedAnswerIndex;
  final String? errorMessage;

  const ExamState({
    this.questions = const [],
    this.currentIndex = 0,
    this.userAnswers = const [],
    this.isLoading = true,
    this.answered = false,
    this.selectedAnswerIndex,
    this.errorMessage,
  });

  ExamState copyWith({
    List<Question>? questions,
    int? currentIndex,
    List<int?>? userAnswers,
    bool? isLoading,
    bool? answered,
    int? selectedAnswerIndex,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ExamState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      isLoading: isLoading ?? this.isLoading,
      answered: answered ?? this.answered,
      selectedAnswerIndex: selectedAnswerIndex,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  Question get currentQuestion => questions[currentIndex];
  bool get isLastQuestion => currentIndex >= questions.length - 1;
  bool get isEmpty => questions.isEmpty;

  int calculateScore() {
    int score = 0;
    for (int i = 0; i < questions.length; i++) {
      if (userAnswers[i] == questions[i].correctAnswerIndex) {
        score++;
      }
    }
    return score;
  }
}

/// Manages the exam session.
class ExamNotifier extends StateNotifier<ExamState> {
  final WordRepository _wordRepo;
  final UserRepository _userRepo;

  ExamNotifier(this._wordRepo, this._userRepo) : super(const ExamState());

  static List<int> generateRandomIds(int min, int max, int count) {
    final random = Random();
    final Set<int> ids = {};
    while (ids.length < count) {
      ids.add(min + random.nextInt(max - min + 1));
    }
    return ids.toList();
  }

  Future<void> loadQuestions() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final userSettings = await _userRepo.getUserChoices();
      final questionLanguage =
          userSettings?['targetLanguage'] ?? 'tr';
      final answerLanguage =
          userSettings?['mainLanguage'] ?? 'en';

      // Convert display codes to table names
      final questionTable = LanguageCodes.tableNameFor(questionLanguage);
      final answerTable = LanguageCodes.tableNameFor(answerLanguage);

      final List<Question> generatedQuestions = [];

      for (final entry in AppConstants.levelIdRanges.entries) {
        final interval = entry.value;
        final randomIds = generateRandomIds(
          interval[0],
          interval[1],
          AppConstants.questionsPerLevel,
        );

        for (final id in randomIds) {
          final questionData = await _wordRepo.fetchExamWords(questionTable, id);
          final answerData = await _wordRepo.fetchExamWords(answerTable, id);

          if (questionData.isNotEmpty && answerData.isNotEmpty) {
            final questionText = questionData.first['word'] as String;
            final correctAnswer = answerData.first['word'] as String;

            final turkishOptions = await _wordRepo.fetchExamOptions(answerTable);
            final allWords =
                turkishOptions.map((e) => e['word'] as String).toList();

            allWords.remove(correctAnswer);
            allWords.shuffle(Random());
            final distractors = allWords.take(3).toList();

            final options = [correctAnswer, ...distractors];
            options.shuffle(Random());
            final correctIndex = options.indexOf(correctAnswer);

            generatedQuestions.add(Question(
              questionText: questionText,
              options: options,
              correctAnswerIndex: correctIndex,
            ));
          }
        }
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

/// Provider for the exam session.
final examProvider =
    StateNotifierProvider.autoDispose<ExamNotifier, ExamState>((ref) {
  final wordRepo = ref.read(wordRepositoryProvider);
  final userRepo = ref.read(userRepositoryProvider);
  return ExamNotifier(wordRepo, userRepo);
});
