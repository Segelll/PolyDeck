import 'dart:async';
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

import 'package:poly2/presentation/providers/database_provider.dart';
import 'package:poly2/presentation/providers/settings_provider.dart';
import 'package:poly2/presentation/providers/deck_repository_provider.dart';
import 'package:poly2/presentation/providers/progress_provider.dart';
import 'package:poly2/core/constants/language_codes.dart';
import 'package:poly2/core/theme/app_palette.dart';
import 'package:poly2/domain/state/language_preferences.dart';
import 'package:poly2/l10n/generated/app_localizations.dart';
import 'package:poly2/presentation/widgets/half_colored_title.dart';
import 'package:poly2/domain/enums/review_input_mode.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final List<String> _displayLanguages = LanguageCodes.displayCodes;
  String? _motherLang;
  String? _targetLang;
  ReviewInputMode _reviewInputMode = ReviewInputMode.buttons;

  @override
  void initState() {
    super.initState();
    ref.listenManual<AsyncValue<LanguagePreferences>>(settingsProvider, (
      _,
      next,
    ) {
      final prefs = next.valueOrNull;
      if (prefs == null || !mounted) return;
      setState(() {
        _motherLang = prefs.mainLanguage;
        _targetLang = prefs.targetLanguage;
        _reviewInputMode = prefs.reviewInputMode;
      });
    });
    _loadPrefs();
  }

  void _loadPrefs() {
    final prefs = ref.read(settingsProvider).valueOrNull;
    if (prefs != null) {
      setState(() {
        _motherLang = prefs.mainLanguage;
        _targetLang = prefs.targetLanguage;
        _reviewInputMode = prefs.reviewInputMode;
      });
    }
  }

  Future<void> _exportData() async {
    try {
      final db = ref.read(appDatabaseProvider);
      final userRepo = ref.read(userRepositoryProvider);
      final deckRepo = ref.read(deckRepositoryProvider);

      final userChoices = await userRepo.getUserChoices();
      final revlog = await db.fetchAllRevlog();
      final srsProgress = await db.fetchSrsProgress();
      final deckConfigs = await db.fetchAllDeckConfigs();
      final decks = await db.fetchDeckSummaries();
      final deckCards = await deckRepo.fetchAllDeckCardsForExport();

      final exportData = {
        'exportedAt': DateTime.now().toIso8601String(),
        'userChoices': userChoices,
        'srsProgress': srsProgress,
        'revlog': revlog,
        'deckConfig': deckConfigs,
        'decks': decks
            .map(
              (deck) => {
                'id': deck.id,
                'name': deck.name,
                'deck_type': deck.deckType,
                'system_key': deck.systemKey,
              },
            )
            .toList(),
        'deckCards': deckCards,
      };

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/polydeck_backup.json');
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(exportData),
      );

      if (mounted) {
        await SharePlus.instance.share(
          ShareParams(files: [XFile(file.path)], subject: 'PolyDeck Backup'),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  Future<void> _importData() async {
    try {
      final files = await FilePicker.pickFiles(type: FileType.any);
      if (files.isEmpty) return;

      final path = files.first.path;
      if (path == null) return;
      final file = File(path);
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      final db = ref.read(appDatabaseProvider);
      final wordRepo = ref.read(wordRepositoryProvider);
      final deckRepo = ref.read(deckRepositoryProvider);

      // ── Import user choices ──
      if (data['userChoices'] != null) {
        final uc = data['userChoices'] as Map<String, dynamic>;
        await ref
            .read(settingsProvider.notifier)
            .saveLanguages(
              LanguageCodes.displayCodeFor(
                (uc['mainLanguage'] as String?) ?? 'en',
              ),
              LanguageCodes.displayCodeFor(
                (uc['targetLanguage'] as String?) ?? 'tr',
              ),
              reviewInputMode: ReviewInputMode.fromStorage(
                uc['reviewMode'] as String?,
              ),
            );
      }

      // ── Restore SRS progress ──
      final choices = await ref.read(userRepositoryProvider).getUserChoices();
      final sourceLanguage = LanguageCodes.tableNameFor(
        choices?['mainLanguage'] ?? 'en',
      );
      final targetLanguage = LanguageCodes.tableNameFor(
        choices?['targetLanguage'] ?? 'tr',
      );
      final favoriteDeckId = await deckRepo.ensureFavoritesDeck();
      final importedDeckIds = <int, int>{};

      if (data['decks'] != null) {
        for (final rawDeck in data['decks'] as List) {
          final deck = rawDeck as Map<String, dynamic>;
          final oldId = (deck['id'] as num?)?.toInt();
          if (oldId == null) continue;
          if (deck['system_key'] == 'favorites') {
            importedDeckIds[oldId] = favoriteDeckId;
          } else if (deck['deck_type'] == 'custom') {
            final name = (deck['name'] as String?)?.trim() ?? '';
            if (name.isNotEmpty) {
              importedDeckIds[oldId] = await deckRepo.createCustomDeck(name);
            }
          }
        }
      }

      if (data['deckCards'] != null) {
        for (final rawCard in data['deckCards'] as List) {
          final card = rawCard as Map<String, dynamic>;
          final oldDeckId = (card['deck_id'] as num?)?.toInt();
          final newDeckId = oldDeckId == null
              ? null
              : importedDeckIds[oldDeckId];
          if (newDeckId == null) continue;
          final target = (card['target_language'] as String?) ?? targetLanguage;
          final word = await wordRepo.fetchWordById(
            target,
            (card['word_id'] as num).toInt(),
          );
          if (word == null) continue;
          await deckRepo.addWordToDeck(
            deckId: newDeckId,
            wordId: word.id,
            sourceLanguage:
                (card['source_language'] as String?) ?? sourceLanguage,
            targetLanguage: target,
          );
        }
      }

      if (data['srsProgress'] != null) {
        for (final entry in data['srsProgress'] as List) {
          final e = entry as Map<String, dynamic>;
          final langCode = LanguageCodes.tableNameFor(
            (e['language_code'] as String?) ?? 'en',
          );
          final id = (e['id'] as num).toInt();
          // Verify the word exists at the correct language.
          final existing = await db.fetchWordById(langCode, id);
          if (existing == null) continue;
          await db.updateSrsState(
            langCode,
            id,
            cardState: (e['card_state'] as num?)?.toInt() ?? 0,
            stability: (e['stability'] as num?)?.toDouble() ?? 0.0,
            difficulty: (e['difficulty'] as num?)?.toDouble() ?? 0.0,
            due: e['due'] as String?,
            elapsedDays: (e['elapsed_days'] as num?)?.toInt() ?? 0,
            scheduledDays: (e['scheduled_days'] as num?)?.toInt() ?? 0,
            reps: (e['reps'] as num?)?.toInt() ?? 0,
            lapses: (e['lapses'] as num?)?.toInt() ?? 0,
            lastReview: e['last_review'] as String?,
          );
          if ((e['isSeen'] as num?)?.toInt() == 1) {
            await db.markAsSeen(
              langCode,
              id,
              (e['date'] as String?) ?? DateTime.now().toIso8601String(),
            );
          }
        }
      }

      // ── Restore deck configs ──
      if (data['deckConfig'] != null) {
        for (final entry in data['deckConfig'] as List) {
          final e = entry as Map<String, dynamic>;
          await db.saveDeckConfigEntry(
            level: (e['level'] as String?) ?? 'default',
            maxNewPerDay: (e['max_new_per_day'] as num?)?.toInt() ?? 10,
            maxReviewsPerDay: (e['max_reviews_per_day'] as num?)?.toInt() ?? 20,
            learningSteps: (e['learning_steps'] as String?) ?? '[1,10]',
            enableFuzz: (e['enable_fuzz'] as num?)?.toInt() == 1,
            requestRetention:
                (e['request_retention'] as num?)?.toDouble() ?? 0.9,
            w: e['w'] as String?,
          );
        }
      }

      _loadPrefs();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data imported successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Import failed: $e')));
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
            child: const Text('Reset', style: TextStyle(color: AppPalette.ink)),
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Reset failed: $e')));
      }
    }
  }

  void _saveSettings() async {
    final local = AppLocalizations.of(context)!;
    if (_motherLang != null && _targetLang != null) {
      try {
        await ref
            .read(settingsProvider.notifier)
            .saveLanguages(
              _motherLang!,
              _targetLang!,
              reviewInputMode: _reviewInputMode,
            );
        _loadPrefs();
        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(local.saveFailed),
            backgroundColor: AppPalette.raindropsOnRoses,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(local.selectLanguages),
          backgroundColor: AppPalette.peachDust,
        ),
      );
    }
  }

  Future<void> _selectReviewMode(ReviewInputMode mode) async {
    final local = AppLocalizations.of(context)!;
    setState(() => _reviewInputMode = mode);
    try {
      await ref.read(settingsProvider.notifier).saveReviewInputMode(mode);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(local.saveFailed),
          backgroundColor: AppPalette.raindropsOnRoses,
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
        color: AppPalette.cloudDancer,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Icon(Icons.tune, size: 80, color: AppPalette.ink),
            const SizedBox(height: 20),
            // MOTHER language
            DropdownButtonFormField<String>(
              initialValue: _motherLang,
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
              initialValue: _targetLang,
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Kart değerlendirme yöntemi',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<ReviewInputMode>(
              segments: const [
                ButtonSegment<ReviewInputMode>(
                  value: ReviewInputMode.buttons,
                  label: Text('Butonlar'),
                  icon: Icon(Icons.touch_app_outlined),
                ),
                ButtonSegment<ReviewInputMode>(
                  value: ReviewInputMode.swipe,
                  label: Text('Kaydırma'),
                  icon: Icon(Icons.swipe),
                ),
              ],
              selected: {_reviewInputMode},
              onSelectionChanged: (selection) {
                if (selection.isNotEmpty) {
                  unawaited(_selectReviewMode(selection.first));
                }
              },
            ),
            const SizedBox(height: 24),
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
                unawaited(
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SrsSettingsPage()),
                  ),
                );
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_view_week),
              label: Text(local.weeklyProgress),
              onPressed: () {
                unawaited(
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WeeklyPage()),
                  ),
                );
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_month),
              label: Text(local.monthlyProgress),
              onPressed: () {
                unawaited(
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MonthlyPage()),
                  ),
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
              icon: const Icon(
                Icons.delete_forever,
                color: AppPalette.raindropsOnRoses,
              ),
              label: const Text(
                'Reset All Data',
                style: TextStyle(color: AppPalette.ink),
              ),
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
