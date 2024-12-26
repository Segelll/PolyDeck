import 'package:flutter/material.dart';
import 'package:poly2/preferences_helper.dart';
import 'package:poly2/strings_loader.dart';
import 'weekly_page.dart';
import 'monthly_page.dart';
import 'decks_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<String> _languages = ['en', 'tr', 'de', 'fr', 'it', 'pr', 'esp'];
  String? _motherLang;
  String? _targetLang;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final mother = await PreferencesHelper.getMotherLanguage() ?? 'en';
    final target = await PreferencesHelper.getTargetLanguage() ?? 'tr';
    setState(() {
      _motherLang = mother;
      _targetLang = target;
    });
  }

  void _saveSettings() async {
    if (_motherLang != null && _targetLang != null) {
      await PreferencesHelper.setMotherLanguage(_motherLang!);
      await PreferencesHelper.setTargetLanguage(_targetLang!);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DecksPage()),
      );
    }
  }

  void _logout() {

    print("Logout");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(StringsLoader.get('settings')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.blueGrey.shade50,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.tune, size: 80, color: Colors.blueGrey[700]),
            const SizedBox(height: 20),
            // MOTHER language
            DropdownButtonFormField<String>(
              value: _motherLang,
              decoration: InputDecoration(
                labelText: StringsLoader.get('motherLanguage'),
                prefixIcon: const Icon(Icons.home),
                border: const OutlineInputBorder(),
              ),
              items: _languages.map((lang) {
                return DropdownMenuItem<String>(
                  value: lang,
                  child: Text(lang.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _motherLang = val;
                });
              },
            ),
            const SizedBox(height: 20),
            // TARGET language
            DropdownButtonFormField<String>(
              value: _targetLang,
              decoration: InputDecoration(
                labelText: StringsLoader.get('targetLanguage'),
                prefixIcon: const Icon(Icons.flag),
                border: const OutlineInputBorder(),
              ),
              items: _languages.map((lang) {
                return DropdownMenuItem<String>(
                  value: lang,
                  child: Text(lang.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _targetLang = val;
                });
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: Text(StringsLoader.get('confirm')),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _saveSettings,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_view_week),
              label: Text(StringsLoader.get('weeklyProgress')),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WeeklyPage()),
                );
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_month),
              label: Text(StringsLoader.get('monthlyProgress')),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MonthlyPage()),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: Text(StringsLoader.get('logout')),
              onPressed: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
