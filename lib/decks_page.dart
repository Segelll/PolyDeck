import 'package:flutter/material.dart';
import 'package:poly2/card_flip_page.dart';
import 'package:poly2/strings_loader.dart';

class DecksPage extends StatelessWidget {
  const DecksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(StringsLoader.get("deckPage")),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // A1 Deck Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CardFlipPage(level: 'a1')),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
              ),
              child: Text(StringsLoader.get("a1Deck")),
            ),
            const SizedBox(height: 20),
            // You can add more decks here, e.g., A2, B1
            // A2 Deck Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CardFlipPage(level: 'a2')),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
              ),
              child: const Text("A2 Deck"),
            ),
            // Add more buttons for different levels if needed
          ],
        ),
      ),
    );
  }
}
