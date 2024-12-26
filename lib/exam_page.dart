import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poly2/strings_loader.dart';
import 'package:poly2/preferences_helper.dart';
import 'exam_model.dart';
import 'exam_result_page.dart';

class ExamPage extends StatefulWidget {
  const ExamPage({Key? key}) : super(key: key);

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  List<Question> questions = [];
  List<int?> userAnswers = [];
  bool _isLoading = true;
  bool _answered = false;
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;

  final List<String> selectedLevels = ['A1', 'A2'];

  @override
  void initState() {
    super.initState();
    _loadExam();
  }

  Future<void> _loadExam() async {
    setState(() => _isLoading = true);
    try {
      final motherLang = await PreferencesHelper.getMotherLanguage() ?? 'en';
      final targetLang = await PreferencesHelper.getTargetLanguage() ?? 'tr';

      final allQuestions = <Question>[];

      for (String level in selectedLevels) {
        final chunk = await _buildQuestions(level, motherLang, targetLang, 4);
        allQuestions.addAll(chunk);
      }
      allQuestions.shuffle(Random());

      setState(() {
        questions = allQuestions;
        userAnswers = List.filled(questions.length, null);
        _isLoading = false;
      });
    } catch (e) {
      print('Error in exam load: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<List<Question>> _buildQuestions(
      String level,
      String motherLang,
      String targetLang,
      int count,
      ) async {
    final targetJson = await rootBundle.loadString('assets/json/$targetLang.json');
    final motherJson = await rootBundle.loadString('assets/json/$motherLang.json');
    final List<dynamic> targetArr = jsonDecode(targetJson);
    final List<dynamic> motherArr = jsonDecode(motherJson);

    final targetItems = targetArr.where((e) => e['level'] == level).toList();
    final motherItems = motherArr.where((e) => e['level'] == level).toList();

    final Map<int, String> tMap = { for (var x in targetItems) x['id']: x['word'] };
    final Map<int, String> mMap = { for (var x in motherItems) x['id']: x['word'] };

    final commonIds = tMap.keys.toSet().intersection(mMap.keys.toSet()).toList();
    commonIds.shuffle(Random());

    final needed = count <= commonIds.length ? count : commonIds.length;
    List<Question> result = [];

    for (int i = 0; i < needed; i++) {
      final id = commonIds[i];
      final questionText = tMap[id]!;
      final correctAnswer = mMap[id]!;

      final distractors = mMap.values.toList();
      distractors.remove(correctAnswer);
      distractors.shuffle(Random());

      final options = [correctAnswer, ...distractors.take(3)];
      options.shuffle(Random());
      final correctIndex = options.indexOf(correctAnswer);

      result.add(
        Question(
          questionText: questionText,
          options: options,
          correctAnswerIndex: correctIndex,
        ),
      );
    }
    return result;
  }

  void _selectAnswer(int idx) {
    if (!_answered) {
      setState(() {
        _selectedAnswerIndex = idx;
        _answered = true;
        userAnswers[_currentQuestionIndex] = idx;
      });
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _answered = false;
        _selectedAnswerIndex = null;
      });
    } else {
      // score
      int score = 0;
      for (int i = 0; i < questions.length; i++) {
        if (userAnswers[i] == questions[i].correctAnswerIndex) {
          score++;
        }
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
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
    Color bgColor;
    Color txtColor = Colors.white;

    if (_answered) {
      if (idx == questions[_currentQuestionIndex].correctAnswerIndex) {
        bgColor = Colors.green.shade700;
      } else if (idx == _selectedAnswerIndex) {
        bgColor = Colors.red.shade700;
      } else {
        bgColor = Colors.blueGrey.shade100;
        txtColor = Colors.black;
      }
    } else {
      if (_selectedAnswerIndex == idx) {
        bgColor = Colors.blueAccent;
      } else {
        bgColor = Colors.blueGrey.shade50;
        txtColor = Colors.black;
      }
    }

    return GestureDetector(
      onTap: _answered ? null : () => _selectAnswer(idx),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.blueGrey.shade300, width: 1.5),
        ),
        child: Text(
          option,
          style: TextStyle(fontSize: 18, color: txtColor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(StringsLoader.get('exam'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(StringsLoader.get('exam')),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / questions.length,
              backgroundColor: Colors.grey[300],
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 16),
            Text(
              '${StringsLoader.get('question')} ${_currentQuestionIndex + 1}/${questions.length}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  questions[_currentQuestionIndex].questionText,
                  style: const TextStyle(fontSize: 28),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: questions[_currentQuestionIndex]
                    .options
                    .asMap()
                    .entries
                    .map((entry) => _buildOption(entry.key, entry.value))
                    .toList(),
              ),
            ),
            ElevatedButton(
              onPressed: _answered ? _nextQuestion : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: _answered ? Colors.blue : Colors.grey,
              ),
              child: Text(
                _currentQuestionIndex < questions.length - 1
                    ? StringsLoader.get('nextQuestion')
                    : StringsLoader.get('finishExam'),
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
