import 'package:flutter/material.dart';
import 'package:poly2/decks_page.dart';
import 'analysis_result.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AnalysisPage extends StatelessWidget {
  final List<AnalysisResult> analysisResults;
  final String previousDeckName;
  final Function onNewDeck;
  final int deckIndex;

  AnalysisPage({
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
            ElevatedButton(
              onPressed: () {
                onNewDeck();
                Navigator.of(context).pop();
              },
              child: Text(local.startNewDeck), // Use localized string
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DecksPage()),
                );
              },
              child: Text(local.decksPage), // Use localized string
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
