import 'package:flutter/material.dart';
import 'package:poly2/decks_page.dart';
import 'package:poly2/services/database_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FirstTimeSelectionPage extends StatefulWidget {
  const FirstTimeSelectionPage({Key? key}) : super(key: key);

  @override
  State<FirstTimeSelectionPage> createState() => _FirstTimeSelectionPageState();
}

class _FirstTimeSelectionPageState extends State<FirstTimeSelectionPage> {
  final List<String> _languages = ['en', 'tr', 'de', 'fr', 'it', 'pr', 'esp'];
  String? _selectedMotherLanguage;
  String? _selectedTargetLanguage;

  final DBHelper _dbHelper = DBHelper();

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(local.firstTimePromptTitle),
        leading: const Icon(Icons.language),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.flag, size: 80, color: Colors.blueGrey[600]),
            const SizedBox(height: 20),
            Text(
              local.firstTimePromptContent,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // MOTHER
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: local.motherLanguage,
                prefixIcon: const Icon(Icons.home),
                border: const OutlineInputBorder(),
              ),
              value: _selectedMotherLanguage,
              items: _languages.map((lang) {
                return DropdownMenuItem<String>(
                  value: lang,
                  child: Text(lang.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedMotherLanguage = val;
                });
              },
            ),
            const SizedBox(height: 20),

            // TARGET
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: local.targetLanguage,
                prefixIcon: const Icon(Icons.flag),
                border: const OutlineInputBorder(),
              ),
              value: _selectedTargetLanguage,
              items: _languages.map((lang) {
                return DropdownMenuItem<String>(
                  value: lang,
                  child: Text(lang.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedTargetLanguage = val;
                });
              },
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: Text(local.confirm),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: (_selectedMotherLanguage != null &&
                  _selectedTargetLanguage != null)
                  ? () async {
                try {
                  await _dbHelper.saveUserChoices(
                    'user',
                    _selectedMotherLanguage!,
                    _selectedTargetLanguage!,
                  );

                  if (!mounted) return;

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const DecksPage()),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving choices: $e')),
                  );
                }
              }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
