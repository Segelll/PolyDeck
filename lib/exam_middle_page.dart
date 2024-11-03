import 'package:flutter/material.dart';
import 'package:poly2/decks_page.dart';
import 'package:poly2/exam_page.dart';
import 'strings_loader.dart';

class ExamMiddlePage extends StatelessWidget {
  const ExamMiddlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(StringsLoader.get("choosePage")),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExamPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
              ),
              child: Text(StringsLoader.get("goExam")),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DecksPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
              ),
              child: Text(StringsLoader.get("deckPage")),
            ),
          ],
        ),
      ),
    );
  }
}
