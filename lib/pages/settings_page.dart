import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'weekly_page.dart';
import 'monthly_page.dart';
import 'decks_page.dart';
import 'package:poly2/services/database_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/half_color.dart';
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<String> _languages = ['en', 'tr', 'de', 'fr', 'it', 'pr', 'esp'];
  String? _motherLang;
  String? _targetLang;
  final DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  void _logout() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      String? userId = user?.uid;

      if (userId != null) {
        List<Map<String, dynamic>> favWords = await _dbHelper.fetchAllFavWords();
        Map<String, List<Map<String, dynamic>>> seenWords = {};

        for (String language in _languages) {
          List<Map<String, dynamic>> seenWordsForLanguage =
          await _dbHelper.fetchAllIsSeenId(language);
          seenWords[language] = seenWordsForLanguage;
        }
        await FirebaseFirestore.instance.collection('user_data').doc(userId).set({
          'favWords': favWords,
          'seenWords': seenWords,
        });

        if (kDebugMode) {
          print("Database uploaded successfully.");
        }

        await FirebaseAuth.instance.signOut();
        if (kDebugMode) {
          print("User logged out successfully.");
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => exit(0)),
        );
      } else {
        if (kDebugMode) {
          print("No user is logged in.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error uploading database: $e");
      }
    }
  }

  Future<void> _loadPrefs() async {
    final userSettings = await _dbHelper.getUserChoices('user');
    if (kDebugMode) {
      print(userSettings);
    }
    setState(() {
      _motherLang = userSettings?['mainLanguage'] ?? "en";
      _targetLang = userSettings?['targetLanguage'] ?? "tr";
    });
  }

  void _saveSettings() async {
    final local = AppLocalizations.of(context)!;
    if (_motherLang != null && _targetLang != null) {
      try {
        await _dbHelper.saveUserChoices('user', _motherLang!, _targetLang!);
        await _loadPrefs();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DecksPage()),
        );
      } catch (e) {
        if (kDebugMode) {
          print('Failed to save settings: $e');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(local.saveFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(local.selectLanguages),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: halfColoredTitle(local.settings),
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
                labelText: local.motherLanguage,
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
                labelText: local.targetLanguage,
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
              label: Text(local.confirm),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _saveSettings,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_view_week),
              label: Text(local.weeklyProgress),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WeeklyPage()),
                );
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_month),
              label: Text(local.monthlyProgress),
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
              label: Text(local.logout),
              onPressed: () async {
                _logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
