import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/domain/enums/proficiency_level.dart';
import 'package:poly2/pages/exam_page.dart';
import 'package:poly2/pages/settings_page.dart';
import 'card_flip_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
            const SizedBox(height: 30),
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

    Container buildLayer(Color color, {double left = 0, double top = 0}) {
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
