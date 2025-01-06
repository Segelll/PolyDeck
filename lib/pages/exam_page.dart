import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:poly2/services/database_helper.dart';
import '../models/exam_model.dart';
import 'exam_result_page.dart';
// remove 'strings_loader.dart'
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExamPage extends StatefulWidget {
  const ExamPage({super.key});

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  int currentQuestionIndex = 0;
  List<int?> userAnswers = [];
  List<Question> questions = [];
  bool _isLoading = true;
  bool _answered = false;
  int? _selectedAnswerIndex;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final db = DBHelper.instance;
      Map<String, List<int>> levelIntervals = {
        'A1': [1, 702],
        'A2': [704, 1425],
        'B1': [1428, 2163],
        'B2': [2166, 3539],
        'C1': [3543, 4790],
      };

      final List<Question> generatedQuestions = [];

      for (String level in levelIntervals.keys) {
        final interval = levelIntervals[level]!;
        final randomIds = _generateRandomIds(interval[0], interval[1], 4);

        for (int id in randomIds) {

          final userSettings = await db.getUserChoices('user');
          String ?questionLanguage = userSettings?['targetLanguage'] ?? "tr";
          String ?answerLanguage = userSettings?['mainLanguage'] ?? "en";

          final questiona = await db.fetchExamWords(questionLanguage, id);
          final answer = await db.fetchExamWords(answerLanguage, id);

          if (questiona.isNotEmpty && answer.isNotEmpty) {
            String questionText = questiona.first['word'];
            String correctAnswerTurkish = answer.first['word'];

            final turkishOptions = await db.fetchExamOptions(answerLanguage);
            List<String> allTurkishWords =
            turkishOptions.map((e) => e['word'] as String).toList();

            allTurkishWords.remove(correctAnswerTurkish);
            allTurkishWords.shuffle(Random());
            List<String> distractors = allTurkishWords.take(3).toList();

            List<String> options = [correctAnswerTurkish, ...distractors];
            options.shuffle(Random());
            int correctAnswerIndex = options.indexOf(correctAnswerTurkish);

            Question question = Question(
              questionText: questionText,
              options: options,
              correctAnswerIndex: correctAnswerIndex,
            );

            generatedQuestions.add(question);
          }
        }
      }

      setState(() {
        questions = generatedQuestions;
        userAnswers = List.filled(questions.length, null);
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading questions: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<int> _generateRandomIds(int min, int max, int count) {
    Random random = Random();
    Set<int> randomIds = {};

    while (randomIds.length < count) {
      randomIds.add(min + random.nextInt(max - min + 1));
    }
    return randomIds.toList();
  }

  void _selectAnswer(int answerIndex) {
    if (!_answered) {
      setState(() {
        _selectedAnswerIndex = answerIndex;
        _answered = true;
        userAnswers[currentQuestionIndex] = answerIndex;
      });
    }
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        _answered = false;
        _selectedAnswerIndex = null;
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
            questions: questions,
            userAnswers: userAnswers,
          ),
        ),
      );
    }
  }

  Widget _buildOption(int idx, String option) {
    final local = AppLocalizations.of(context)!;
    Color? buttonColor;
    Color textColor = Colors.white;

    if (_answered) {
      if (idx == questions[currentQuestionIndex].correctAnswerIndex) {
        buttonColor = Colors.green[700];
      } else if (idx == _selectedAnswerIndex) {
        buttonColor = Colors.red[700];
      } else {
        buttonColor = Theme.of(context).colorScheme.surface;
        textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
      }
    } else {
      if (_selectedAnswerIndex == idx) {
        buttonColor = Theme.of(context).colorScheme.primary;
      } else {
        buttonColor = Theme.of(context).colorScheme.surface;
        textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
      }
    }

    return GestureDetector(
      onTap: _answered ? null : () => _selectAnswer(idx),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: Colors.grey[400]!,
            width: 1.5,
          ),
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

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(local.exam),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(local.exam),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / questions.length,
              backgroundColor: Colors.grey[300],
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              '${local.question} ${currentQuestionIndex + 1}/${questions.length}',
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
                  questions[currentQuestionIndex].questionText,
                  style: const TextStyle(fontSize: 28),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: questions[currentQuestionIndex]
                    .options
                    .asMap()
                    .entries
                    .map((entry) => _buildOption(entry.key, entry.value))
                    .toList(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _answered ? _nextQuestion : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor:
                _answered ? Theme.of(context).colorScheme.primary : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                currentQuestionIndex < questions.length - 1
                    ? local.nextQuestion
                    : local.finishExam,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
