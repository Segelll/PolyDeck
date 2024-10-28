import 'package:flutter/material.dart';
import 'strings_loader.dart';
import 'card_flip_page.dart'; 
class LanguageSelectionPage extends StatelessWidget {
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
            Text(
              'Select Language:',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await StringsLoader.changeLanguage('en');
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => CardFlipPage(),
                ));
              },
              child: Text('English'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await StringsLoader.changeLanguage('tr');
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => CardFlipPage(),
                ));
              },
              child: Text('Türkçe'),
            ),
          ],
        ),
      ),
    );
  }
}
