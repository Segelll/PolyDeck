import 'package:flutter/material.dart';
import 'strings_loader.dart';
import 'exam_model.dart';

class ResultPage extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final List<Question> questions;
  final List<int?> userAnswers;

  const ResultPage({
    Key? key,
    required this.score,
    required this.totalQuestions,
    required this.questions,
    required this.userAnswers,
  }) : super(key: key);

  String _getLevel(int score) {
    if (score >= 17) return 'C1';
    if (score >= 13) return 'B2';
    if (score >= 9) return 'B1';
    if (score >= 5) return 'A2';
    return 'A1';
  }

  @override
  Widget build(BuildContext context) {
    final level = _getLevel(score);

    return Scaffold(
      appBar: AppBar(
        title: Text(StringsLoader.get('testResult')),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 20),
          Center(
            child: Text(
              '${StringsLoader.get('yourScore')}: $score / $totalQuestions',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              '${StringsLoader.get('recommendedDeck')}: $level',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 10),
          Center(
            child: Text(
              StringsLoader.get('reviewAnswers'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          ...questions.asMap().entries.map((entry) {
            int idx = entry.key;
            Question question = entry.value;
            int? userAnswer = userAnswers[idx];
            bool isCorrect = userAnswer == question.correctAnswerIndex;

            return Card(
              color: isCorrect ? Colors.green[50] : Colors.red[50],
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(
                  '${idx + 1}. ${question.questionText}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Text(
                      '${StringsLoader.get('yourAnswer')}: ${question.options[userAnswer ?? 0]}',
                      style: TextStyle(
                        color: isCorrect ? Colors.green : Colors.red,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (!isCorrect)
                      Text(
                        '${StringsLoader.get('correctAnswer')}: ${question.options[question.correctAnswerIndex]}',
                        style: const TextStyle(color: Colors.green, fontSize: 16),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
