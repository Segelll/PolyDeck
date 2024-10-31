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
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CardFlipPage()),
            );
          },
          child: Text(StringsLoader.get("a1Deck")),
        ),
      ),
    );
  }
}