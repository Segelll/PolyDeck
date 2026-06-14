import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/data/repositories/word_repository.dart';
import 'package:poly2/data/repositories/user_repository.dart';
import 'package:poly2/domain/models/exam_model.dart';
import 'package:poly2/domain/state/exam_state.dart';
import 'package:poly2/presentation/providers/database_provider.dart';
import 'package:poly2/presentation/providers/settings_provider.dart';
import 'package:poly2/core/constants/app_constants.dart';
import 'package:poly2/core/constants/language_codes.dart';
import 'package:poly2/core/utils/random_utils.dart';

class ExamNotifier extends StateNotifier<ExamState> {
  final WordRepository _wordRepo;
  final UserRepository _userRepo;

  ExamNotifier(this._wordRepo, this._userRepo) : super(const ExamState());

  Future<void> loadQuestions() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final userSettings = await _userRepo.getUserChoices();
      final questionLanguage = userSettings?['targetLanguage'] ?? 'tr';
      final answerLanguage = userSettings?['mainLanguage'] ?? 'en';
      final questionLang = LanguageCodes.tableNameFor(questionLanguage);
      final answerLang = LanguageCodes.tableNameFor(answerLanguage);
      final List<Question> generatedQuestions = [];

      for (final entry in AppConstants.levelIdRanges.entries) {
        final interval = entry.value;
        final randomIds = generateRandomIds(
            interval[0], interval[1], AppConstants.questionsPerLevel);
        for (final id in randomIds) {
          final questionData = await _wordRepo.fetchExamWords(questionLang, id);
          final answerData = await _wordRepo.fetchExamWords(answerLang, id);
          if (questionData.isNotEmpty && answerData.isNotEmpty) {
            final questionText = questionData.first.word;
            final correctAnswer = answerData.first.word;
            final optionIds = generateRandomIds(AppConstants.minWordId,
                AppConstants.maxWordId, AppConstants.distractorsPerQuestion + 10);
            final turkishOptions =
                await _wordRepo.fetchExamOptions(answerLang, optionIds);
            final allWords = turkishOptions.map((e) => e.word).toList();
            allWords.remove(correctAnswer);
            allWords.shuffle(Random());
            final distractors =
                allWords.take(AppConstants.distractorsPerQuestion).toList();
            final options = [correctAnswer, ...distractors]..shuffle(Random());
            generatedQuestions.add(Question(
                questionText: questionText,
                options: options,
                correctAnswerIndex: options.indexOf(correctAnswer)));
          }
        }
      }

      state = state.copyWith(
          questions: generatedQuestions,
          userAnswers: List.filled(generatedQuestions.length, null),
          isLoading: false,
          currentIndex: 0,
          answered: false,
          selectedAnswerIndex: null);
    } catch (e) {
      if (kDebugMode) print('ExamNotifier.loadQuestions error: $e');
      state = state.copyWith(
          isLoading: false, errorMessage: 'Failed to load exam: $e');
    }
  }

  void selectAnswer(int answerIndex) {
    if (state.answered) return;
    final newAnswers = List<int?>.from(state.userAnswers);
    newAnswers[state.currentIndex] = answerIndex;
    state = state.copyWith(
        userAnswers: newAnswers,
        answered: true,
        selectedAnswerIndex: answerIndex);
  }

  void nextQuestion() {
    if (state.isLastQuestion) return;
    state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        answered: false,
        selectedAnswerIndex: null);
  }
}

final examProvider =
    StateNotifierProvider.autoDispose<ExamNotifier, ExamState>((ref) {
  final wordRepo = ref.read(wordRepositoryProvider);
  final userRepo = ref.read(userRepositoryProvider);
  return ExamNotifier(wordRepo, userRepo);
});
