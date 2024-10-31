import 'package:flutter/material.dart';
import 'package:poly2/exam_model.dart';
import 'package:poly2/exam_questions.dart';
import 'package:poly2/exam_result_page.dart';
import 'package:poly2/strings_loader.dart';

class ExamPage extends StatefulWidget {
  const ExamPage({super.key});

  @override
  State<ExamPage>   createState(){
    return _ExamPageState();
  }
}

class _ExamPageState extends State<ExamPage> {
  int currentQuestionIndex = 0;
  List<int?> userAnswers = List.filled(20, null);
  final List<Question> questions = QuestionsData.questions;

  void _selectAnswer(int answerIndex) {
    setState(() {
      userAnswers[currentQuestionIndex] = answerIndex;
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      int score = 0;
      for (int i = 0; i < questions.length; i++) {
        if (userAnswers[i] == questions[i].correctAnswerIndex) {
          score++;
        }
      }
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            score: score,
            totalQuestions: questions.length,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(StringsLoader.get('exam')),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${currentQuestionIndex + 1} / ${questions.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              questions[currentQuestionIndex].questionText,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ...questions[currentQuestionIndex].options.asMap().entries.map((entry) {
              final int idx = entry.key;
              final String option = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () => _selectAnswer(idx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: userAnswers[currentQuestionIndex] == idx
                        ? Colors.blue
                        : null,
                  ),
                  child: Text(option),
                ),
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: userAnswers[currentQuestionIndex] != null
                  ? _nextQuestion 
                  : null,
              child: Text(
                currentQuestionIndex < questions.length - 1
                    ? StringsLoader.get('nextQuestion')
                    : StringsLoader.get('finishExam'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}