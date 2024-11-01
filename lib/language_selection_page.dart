import 'package:flutter/material.dart';
import 'package:poly2/decks_page.dart';
import 'exam_page.dart';
import 'strings_loader.dart';

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(StringsLoader.get('appTitle')),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Spacer(),
              const Text(
                'Select Language:',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await StringsLoader.changeLanguage('en');
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => ExamPage(),
                  ));
                },
                child: const Text('English'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200, 50),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await StringsLoader.changeLanguage('tr');
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => ExamPage(),
                  ));
                },
                child: const Text('Türkçe'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200, 50),
                ),
              ),
              const SizedBox(height: 10),
              //direkt test ile uğraşmadan kartlar sayfasına gitmek için
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DecksPage()),
                  );
                },
                child: const Text("Desteler sayfası"),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
