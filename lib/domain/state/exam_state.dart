import 'package:poly2/domain/models/exam_model.dart';

/// Immutable state for an exam session.
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
