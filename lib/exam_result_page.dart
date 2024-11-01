import 'package:flutter/material.dart';
import 'decks_page.dart';
import 'strings_loader.dart';

class ResultPage extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const ResultPage({
    super.key,
    required this.score,
    required this.totalQuestions,
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
    final level = _getLevel(score);

    return Scaffold(
      appBar: AppBar(
        title: Text(StringsLoader.get('testResult')),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 50),
            Text(
              'Score: $score / $totalQuestions',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text(
              'Recommended deck is: $level ',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const DecksPage(),
                ));
              },
              child: Text(StringsLoader.get('deckPage')),
            ),
          ],
        ),
      ),
    );
  }
}
