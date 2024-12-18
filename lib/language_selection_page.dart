import 'package:flutter/material.dart';
import 'package:poly2/services/data_loader.dart';
import 'strings_loader.dart';
import 'exam_middle_page.dart';

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
                'Choose Your Language:',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {                  
                  await DataLoader().loadJsonFilesToDatabase();
                  await StringsLoader.changeLanguage('en');
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const ExamMiddlePage(),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200, 50),
                  
                ),
                child: const Text('English'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await DataLoader().loadJsonFilesToDatabase();
                  await StringsLoader.changeLanguage('tr');
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const ExamMiddlePage(),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200, 50),
                ),
                child: const Text('Türkçe'),
              ),
              const SizedBox(height: 10),


              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
