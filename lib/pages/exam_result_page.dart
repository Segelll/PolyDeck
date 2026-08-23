import 'package:flutter/material.dart';
import 'package:poly2/domain/models/exam_model.dart';
import 'package:poly2/core/theme/app_palette.dart';
import 'package:poly2/pages/app_shell.dart';
import 'package:poly2/l10n/generated/app_localizations.dart';
import 'package:poly2/presentation/widgets/half_colored_title.dart';

class ResultPage extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final List<Question> questions;
  final List<int?> userAnswers;

  const ResultPage({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.questions,
    required this.userAnswers,
  });

  String _getLevel(int score) {
    if (score >= 17) return 'C1';
    if (score >= 13) return 'B2';
    if (score >= 9) return 'B1';
    if (score >= 5) return 'A2';
    return 'A1';
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final level = _getLevel(score);

    return Scaffold(
      appBar: AppBar(
        title: HalfColoredTitle(local.testResult),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const AppShell(initialIndex: 1),
              ),
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 20),
          Center(
            child: Text(
              '${local.yourScore}: $score / $totalQuestions',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              '${local.recommendedDeck}: $level',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 10),
          Center(
            child: Text(
              local.reviewAnswers,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          // Display each question and the user's answer
          ...questions.asMap().entries.map((entry) {
            int idx = entry.key;
            Question question = entry.value;
            int? userAnswer = userAnswers[idx];
            bool isCorrect = userAnswer == question.correctAnswerIndex;

            return Card(
              color: isCorrect
                  ? AppPalette.almostAqua
                  : AppPalette.raindropsOnRoses,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(
                  '${idx + 1}. ${question.questionText}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppPalette.ink,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Text(
                      '${local.yourAnswer}: ${userAnswer != null && userAnswer < question.options.length ? question.options[userAnswer] : 'No Answer'}',
                      style: const TextStyle(
                        color: AppPalette.ink,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (!isCorrect &&
                        question.correctAnswerIndex < question.options.length)
                      Text(
                        '${local.correctAnswer}: ${question.options[question.correctAnswerIndex]}',
                        style: const TextStyle(
                          color: AppPalette.ink,
                          fontSize: 16,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
