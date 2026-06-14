import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/presentation/providers/exam_provider.dart';
import 'exam_result_page.dart';
import 'package:poly2/presentation/widgets/half_colored_title.dart';
import 'package:poly2/l10n/generated/app_localizations.dart';

class ExamPage extends ConsumerStatefulWidget {
  const ExamPage({super.key});

  @override
  ConsumerState<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends ConsumerState<ExamPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(examProvider.notifier).loadQuestions();
    });
  }

  void _nextQuestion() {
    final notifier = ref.read(examProvider.notifier);
    final state = ref.read(examProvider);

    if (state.isLastQuestion) {
      final score = state.calculateScore();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            score: score,
            totalQuestions: state.questions.length,
            questions: state.questions,
            userAnswers: state.userAnswers,
          ),
        ),
      );
    } else {
      notifier.nextQuestion();
    }
  }

  Widget _buildOption(int idx, String option) {
    final state = ref.watch(examProvider);
    Color? buttonColor;
    Color textColor = Colors.white;

    if (state.answered) {
      if (idx == state.currentQuestion.correctAnswerIndex) {
        buttonColor = Colors.green[700];
      } else if (idx == state.selectedAnswerIndex) {
        buttonColor = Colors.red[700];
      } else {
        buttonColor = Theme.of(context).colorScheme.surface;
        textColor =
            Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
      }
    } else {
      if (state.selectedAnswerIndex == idx) {
        buttonColor = Theme.of(context).colorScheme.primary;
      } else {
        buttonColor = Theme.of(context).colorScheme.surface;
        textColor =
            Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
      }
    }

    return GestureDetector(
      onTap: state.answered
          ? null
          : () => ref.read(examProvider.notifier).selectAnswer(idx),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey[400]!, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[400]!,
              offset: const Offset(2, 2),
              blurRadius: 2,
            ),
          ],
        ),
        child: Text(
          option,
          style: TextStyle(fontSize: 18, color: textColor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final state = ref.watch(examProvider);

    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: HalfColoredTitle(local.exam),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: HalfColoredTitle(local.exam),
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
                onPressed: () =>
                    ref.read(examProvider.notifier).loadQuestions(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: HalfColoredTitle(local.exam),
          centerTitle: true,
        ),
        body: const Center(child: Text('No questions available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: HalfColoredTitle(local.exam),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (state.currentIndex + 1) / state.questions.length,
              backgroundColor: Colors.grey[300],
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              '${local.question} ${state.currentIndex + 1}/${state.questions.length}',
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Theme.of(context).colorScheme.surface,
              child: Container(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  state.currentQuestion.questionText,
                  style: const TextStyle(fontSize: 28),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: state.currentQuestion.options
                    .asMap()
                    .entries
                    .map((entry) => _buildOption(entry.key, entry.value))
                    .toList(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: state.answered ? _nextQuestion : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: state.answered
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                state.isLastQuestion ? local.finishExam : local.nextQuestion,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
