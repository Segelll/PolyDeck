import 'package:flutter/material.dart';
import 'package:poly2/pages/decks_page.dart';
import '../models/analysis_result.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AnalysisPage extends StatelessWidget {
  final List<AnalysisResult> analysisResults;
  final String previousDeckName;
  final Function onNewDeck;
  final int deckIndex;

  const AnalysisPage({super.key,
    required this.analysisResults,
    required this.previousDeckName,
    required this.onNewDeck,
    required this.deckIndex,
  });

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(local.analysis),
        centerTitle: true,
        automaticallyImplyLeading: false, // Removes the default back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              previousDeckName,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              local.analysisResults,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: analysisResults.length,
                itemBuilder: (context, index) {
                  final result = analysisResults[index];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: result.color,
                    ),
                    title: Text(
                      '${result.word} - ${result.meaning}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                },
              ),
            ),
            // Row containing "New Deck" and "Back to Decks Page" buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // "New Deck" Button
                ElevatedButton(
                  onPressed: () {
                    onNewDeck();
                    Navigator.of(context).pop();
                  }, // Use localized string
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 50),
                  ),
                  child: Text(local.startNewDeck),
                ),
                // "Back to Decks Page" Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DecksPage()),
                    );
                  }, // Use localized string
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 50),
                  ),
                  child: Text(local.decksPage),
                ),
              ],
            ),
            const SizedBox(height: 20), // Adds space below the buttons
          ],
        ),
      ),
    );
  }
}
