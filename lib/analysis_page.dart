import 'package:flutter/material.dart';

class AnalysisPage extends StatelessWidget {
  final List<String> analysisResults;
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
    return Scaffold(
      appBar: AppBar(title: Text('Analysis')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Previous Deck: $previousDeckName'),
            SizedBox(height: 20),
            Text('Analysis Results:', style: TextStyle(fontSize: 20)),
            Expanded(
              child: ListView.builder(
                itemCount: analysisResults.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(analysisResults[index]),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                onNewDeck(); 
                Navigator.of(context).pop(); 
              },
              child: Text('Start New Deck'),
            ),
          ],
        ),
      ),
    );
  }
}
