import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

import 'weekly_page.dart';
import 'monthly_page.dart';
import 'srs_settings_page.dart';
import 'decks_page.dart';
import 'package:poly2/data/repositories/progress_repository.dart';
import 'package:poly2/data/repositories/user_repository.dart';
import 'package:poly2/data/repositories/word_repository.dart';
import 'package:poly2/presentation/providers/settings_provider.dart';
import 'package:poly2/presentation/providers/deck_provider.dart';
import 'package:poly2/presentation/providers/progress_provider.dart';
import 'package:poly2/core/constants/language_codes.dart';
import 'package:poly2/core/constants/app_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poly2/presentation/widgets/half_colored_title.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final List<String> _displayLanguages = LanguageCodes.displayCodes;
  String? _motherLang;
  String? _targetLang;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  void _loadPrefs() {
    final prefs = ref.read(settingsProvider).valueOrNull;
    if (prefs != null) {
      setState(() {
        _motherLang = prefs.mainLanguage;
        _targetLang = prefs.targetLanguage;
      });
    }
  }

  Future<void> _exportData() async {
    try {
      final wordRepo = ref.read(wordRepositoryProvider);
      final userRepo = ref.read(userRepositoryProvider);
      final progressRepo = ref.read(progressRepositoryProvider);

      final favWords = await wordRepo.fetchAllFavorites();
      final userChoices = await userRepo.getUserChoices();

      final Map<String, List<Map<String, dynamic>>> seenWords = {};
      for (final lang in AppConstants.languageTables) {
        seenWords[lang] = []; // Simplified — full impl would need DB access
      }

      final exportData = {
        'version': '1.0.0',
        'exportedAt': DateTime.now().toIso8601String(),
        'userChoices': userChoices,
        'favorites': favWords,
      };

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/polydeck_backup.json');
      await file.writeAsString(
          const JsonEncoder.withIndent('  ').convert(exportData));

      if (mounted) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            subject: 'PolyDeck Backup',
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _importData() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.first.path!);
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      final wordRepo = ref.read(wordRepositoryProvider);

      if (data['favorites'] != null) {
        for (final fav in data['favorites'] as List) {
          await wordRepo.addToFavorites(
            word: fav['word'] as String,
            sentence: fav['sentence'] as String? ?? '',
            level: fav['level'] as String? ?? 'fav',
            backWord: fav['backword'] as String?,
            backSentence: fav['backsentence'] as String?,
          );
        }
      }

      if (data['userChoices'] != null) {
        final uc = data['userChoices'] as Map<String, dynamic>;
        await ref.read(settingsProvider.notifier).saveLanguages(
              LanguageCodes.displayCodeFor(uc['mainLanguage'] as String),
              LanguageCodes.displayCodeFor(uc['targetLanguage'] as String),
            );
      }

      _loadPrefs();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data imported successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }

  Future<void> _resetAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset All Data'),
        content: const Text(
          'This will clear all your progress and favorites. '
          'This cannot be undone. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final progressRepo = ref.read(progressRepositoryProvider);
      await progressRepo.resetAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data has been reset.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reset failed: $e')),
        );
      }
    }
  }

  void _saveSettings() async {
    final local = AppLocalizations.of(context)!;
    if (_motherLang != null && _targetLang != null) {
      try {
        await ref.read(settingsProvider.notifier).saveLanguages(
              _motherLang!,
              _targetLang!,
            );
        _loadPrefs();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DecksPage()),
        );
      } catch (e) {
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
        title: HalfColoredTitle(local.settings),
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
              items: _displayLanguages.map((lang) {
                return DropdownMenuItem<String>(
                  value: lang,
                  child: Text(lang.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _motherLang = val);
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
              items: _displayLanguages.map((lang) {
                return DropdownMenuItem<String>(
                  value: lang,
                  child: Text(lang.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _targetLang = val);
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
              icon: const Icon(Icons.tune),
              label: const Text('SRS Settings'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SrsSettingsPage()),
                );
              },
            ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Export'),
                  onPressed: _exportData,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Import'),
                  onPressed: _importData,
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              label:
                  const Text('Reset All Data', style: TextStyle(color: Colors.red)),
              onPressed: _resetAllData,
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
