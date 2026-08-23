import 'package:flutter/material.dart';
import 'package:poly2/domain/models/analysis_result.dart';
import 'package:poly2/presentation/widgets/half_colored_title.dart';
import 'package:poly2/l10n/generated/app_localizations.dart';

class AnalysisPage extends StatefulWidget {
  final List<AnalysisResult> analysisResults;
  final String previousDeckName;
  final Future<void> Function() onNewDeck;
  final int deckIndex;

  const AnalysisPage({
    super.key,
    required this.analysisResults,
    required this.previousDeckName,
    required this.onNewDeck,
    required this.deckIndex,
  });

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  bool _isStartingNewDeck = false;

  Future<void> _startNewDeck() async {
    if (_isStartingNewDeck) return;
    setState(() => _isStartingNewDeck = true);
    Navigator.of(context).pop();
    await Future<void>.delayed(Duration.zero);
    try {
      await widget.onNewDeck();
    } finally {
      if (mounted) setState(() => _isStartingNewDeck = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: HalfColoredTitle(local.analysis),
        centerTitle: true,
        automaticallyImplyLeading: false, // Removes the default back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(widget.previousDeckName, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            Text(local.analysisResults, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.analysisResults.length,
                itemBuilder: (context, index) {
                  final result = widget.analysisResults[index];

                  return ListTile(
                    leading: CircleAvatar(backgroundColor: result.color),
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
                  onPressed: _isStartingNewDeck ? null : _startNewDeck,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 50),
                  ),
                  child: _isStartingNewDeck
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(local.startNewDeck),
                ),
                // "Back to Decks Page" Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
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
