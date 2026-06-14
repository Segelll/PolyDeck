import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/domain/enums/proficiency_level.dart';
import 'package:poly2/presentation/providers/deck_provider.dart';
import 'package:poly2/presentation/providers/settings_provider.dart';
import 'package:poly2/presentation/providers/deck_config_provider.dart';
import 'package:poly2/core/constants/language_codes.dart';
import 'package:poly2/pages/exam_page.dart';
import 'package:poly2/pages/settings_page.dart';
import 'card_flip_page.dart';
import 'package:poly2/l10n/generated/app_localizations.dart';
import 'package:poly2/presentation/widgets/half_colored_title.dart';

class DecksPage extends ConsumerStatefulWidget {
  const DecksPage({super.key});

  @override
  ConsumerState<DecksPage> createState() => _DecksPageState();
}

class _DecksPageState extends ConsumerState<DecksPage> {
  String? _selectedLevel;

  void _toggleLevel(String code) {
    setState(() {
      _selectedLevel = (_selectedLevel == code) ? null : code;
    });
  }

  void _proceedToDeck(AppLocalizations local) {
    if (_selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(local.selectLanguages)),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CardFlipPage(levels: _selectedLevel!),
      ),
    );
  }

  void _goToExam() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ExamPage()),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: HalfColoredTitle(local.deckPage),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: local.examIconTooltip,
            icon: const Icon(Icons.quiz),
            onPressed: _goToExam,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Container(
        color: Colors.blueGrey.shade50,
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Daily progress indicator
            if (_selectedLevel != null && _selectedLevel != 'fav')
              _DailyProgressBar(level: _selectedLevel!),
            const SizedBox(height: 20),
            Icon(Icons.view_agenda, size: 60, color: Colors.blueGrey[700]),
            const SizedBox(height: 10),
            Text(
              local.selectLevel,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Build deck cards from ProficiencyLevel enum
            for (var i = 0; i < ProficiencyLevel.values.length; i += 2)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDeck(ProficiencyLevel.values[i]),
                    if (i + 1 < ProficiencyLevel.values.length)
                      _buildDeck(ProficiencyLevel.values[i + 1]),
                  ],
                ),
              ),

            const Spacer(),
            ElevatedButton(
              onPressed: () => _proceedToDeck(local),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(180, 50),
              ),
              child: Text(local.proceed),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDeck(ProficiencyLevel level) {
    final bool isSelected = _selectedLevel == level.code;

    final Color primary = isSelected ? Colors.blue : Colors.grey;
    final Color mid =
        isSelected ? Colors.blue.shade300 : Colors.grey.shade400;
    final Color back =
        isSelected ? Colors.blue.shade100 : Colors.grey.shade200;
    final Color textColor = isSelected ? Colors.white : Colors.black87;

    Positioned buildLayer(Color color, {double left = 0, double top = 0}) {
      return Positioned(
        left: left,
        top: top,
        child: Container(
          width: 70,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 3,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _toggleLevel(level.code),
      child: SizedBox(
        width: 100,
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            buildLayer(back, left: 12, top: 12),
            buildLayer(mid, left: 6, top: 6),
            Positioned.fill(
              child: Container(
                width: 70,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, mid],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      level.code,
                      style: TextStyle(
                        fontSize: 18,
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level.label,
                      style: TextStyle(fontSize: 12, color: textColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget showing today's new/review counts for a level.
class _DailyProgressBar extends ConsumerWidget {
  final String level;

  const _DailyProgressBar({required this.level});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = AppLocalizations.of(context)!;
    final configAsync = ref.watch(deckConfigProvider(level));

    return configAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (config) {
        // Fetch counts in a FutureBuilder since we need async
        return FutureBuilder<({int newCount, int reviewCount})>(
          future: _fetchCounts(ref, level),
          builder: (context, snapshot) {
            final newCount = snapshot.data?.newCount ?? 0;
            final reviewCount = snapshot.data?.reviewCount ?? 0;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 2),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StatChip(
                    icon: Icons.fiber_new,
                    color: Colors.blue,
                    label: local.newCount(newCount, config.maxNewPerDay),
                  ),
                  const SizedBox(width: 16),
                  _StatChip(
                    icon: Icons.replay,
                    color: Colors.orange,
                    label: local.reviewCount(reviewCount, config.maxReviewsPerDay),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<({int newCount, int reviewCount})> _fetchCounts(
      WidgetRef ref, String level) async {
    final repo = ref.read(wordRepositoryProvider);
    final userSettings =
        await ref.read(userRepositoryProvider).getUserChoices();
    final tableName = LanguageCodes.tableNameFor(
        userSettings?['targetLanguage'] ?? 'tr');
    // Single combined query instead of two
    return repo.getTodayCounts(tableName, level);
  }
}

/// Small chip showing an icon + label for daily stats.
class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _StatChip({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
