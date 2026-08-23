import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/presentation/providers/exam_provider.dart';
import 'package:poly2/core/theme/app_palette.dart';

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
    unawaited(
      Future.microtask(() => ref.read(examProvider.notifier).loadQuestions()),
    );
  }

  void _nextQuestion() {
    final notifier = ref.read(examProvider.notifier);
    final state = ref.read(examProvider);

    if (state.isLastQuestion) {
      final score = state.calculateScore();
      unawaited(
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
        ),
      );
    } else {
      notifier.nextQuestion();
    }
  }

  Widget _buildOption(int idx, String option) {
    final state = ref.watch(examProvider);
    Color? buttonColor;
    Color textColor = AppPalette.ink;

    if (state.answered) {
      if (idx == state.currentQuestion.correctAnswerIndex) {
        buttonColor = AppPalette.almostAqua;
      } else if (idx == state.selectedAnswerIndex) {
        buttonColor = AppPalette.raindropsOnRoses;
      } else {
        buttonColor = Theme.of(context).colorScheme.surface;
        textColor = AppPalette.ink;
      }
    } else {
      if (state.selectedAnswerIndex == idx) {
        buttonColor = AppPalette.almostAqua;
      } else {
        buttonColor = Theme.of(context).colorScheme.surface;
        textColor = AppPalette.ink;
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
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          border: Border.all(color: AppPalette.outline, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: AppPalette.shadow,
              offset: Offset(2, 2),
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
        appBar: AppBar(title: HalfColoredTitle(local.exam), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: HalfColoredTitle(local.exam), centerTitle: true),
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
              Text(state.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    unawaited(ref.read(examProvider.notifier).loadQuestions()),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: HalfColoredTitle(local.exam), centerTitle: true),
        body: const Center(child: Text('No questions available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: HalfColoredTitle(local.exam), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (state.currentIndex + 1) / state.questions.length,
              backgroundColor: AppPalette.nimbusCloud,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              '${local.question} ${state.currentIndex + 1}/${state.questions.length}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                    ? AppPalette.almostAqua
                    : AppPalette.nimbusCloud,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
              child: Text(
                state.isLastQuestion ? local.finishExam : local.nextQuestion,
                style: const TextStyle(fontSize: 18, color: AppPalette.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
