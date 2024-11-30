import 'package:flutter/material.dart';
import 'exam_model.dart';
import 'exam_result_page.dart';
import 'strings_loader.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

class ExamPage extends StatefulWidget {
  const ExamPage({Key? key}) : super(key: key);

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
      final String englishJsonString =
      await rootBundle.loadString('assets/english_words_a1.json');
      final List<dynamic> englishJsonData = jsonDecode(englishJsonString);

      final String turkishJsonString =
      await rootBundle.loadString('assets/turkish_words_a1.json');
      final List<dynamic> turkishJsonData = jsonDecode(turkishJsonString);

      final Map<int, String> englishWordsById = {};
      for (var item in englishJsonData) {
        int id = item['id'];
        String word = item['word'];
        englishWordsById[id] = word;
      }

      final Map<int, String> turkishWordsById = {};
      for (var item in turkishJsonData) {
        int id = item['id'];
        String word = item['word'];
        turkishWordsById[id] = word;
      }

      final List<int> commonIds = englishWordsById.keys
          .toSet()
          .intersection(turkishWordsById.keys.toSet())
          .toList();

      commonIds.shuffle(Random());

      final List<Question> generatedQuestions = [];

      for (int i = 0; i < 20; i++) {
        if (i >= commonIds.length) break;

        int id = commonIds[i];

        String questionText = englishWordsById[id]!;
        String correctAnswer = turkishWordsById[id]!;

        List<String> allTurkishWords = turkishWordsById.values.toList();


        allTurkishWords.remove(correctAnswer);

        allTurkishWords.shuffle(Random());

        List<String> distractors = allTurkishWords.take(3).toList();
        List<String> options = [correctAnswer, ...distractors];

        options.shuffle(Random());

        int correctAnswerIndex = options.indexOf(correctAnswer);

        Question question = Question(
          questionText: questionText,
          options: options,
          correctAnswerIndex: correctAnswerIndex,
        );

        generatedQuestions.add(question);
      }

      setState(() {
        questions = generatedQuestions;
        userAnswers = List.filled(questions.length, null);
        _isLoading = false;
      });
    } catch (e) {
      print('Error in _loadQuestions: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(StringsLoader.get('exam')),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(StringsLoader.get('exam')),
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
              '${StringsLoader.get('question')} ${currentQuestionIndex + 1}/${questions.length}',
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
                backgroundColor: _answered
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                currentQuestionIndex < questions.length - 1
                    ? StringsLoader.get('nextQuestion')
                    : StringsLoader.get('finishExam'),
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
