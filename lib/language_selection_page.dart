import 'package:flutter/material.dart';
import 'package:poly2/exam_page.dart';
import 'strings_loader.dart';
import 'card_flip_page.dart';

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(StringsLoader.get('appTitle')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select Language:',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {

                //denemek için exampage'ye bağladım giriş ekranını desteler ekranından bağlayabiliriz senin yaptığını
                //onun dışında senin kodlarda değişiklik yok.
                await StringsLoader.changeLanguage('en');
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => ExamPage(),
                ));
              },
              child: const Text('English'),
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
            ),
          ],
        ),
      ),
    );
  }
}
