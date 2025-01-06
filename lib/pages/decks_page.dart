import 'package:flutter/material.dart';
import 'package:poly2/pages/exam_page.dart';
import 'package:poly2/pages/settings_page.dart';
import 'card_flip_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/half_color.dart';
class DecksPage extends StatefulWidget {

  const DecksPage({super.key});

  @override
  State<DecksPage> createState() => _DecksPageState();
}

class _DecksPageState extends State<DecksPage> {

  final List<Map<String, String>> allLevels = [
    {"code": "A1", "label": "Beginner"},
    {"code": "A2", "label": "Elementary"},
    {"code": "B1", "label": "Intermediate"},
    {"code": "B2", "label": "Upper-Interm."},
    {"code": "C1", "label": "Advanced"},
    {"code": "fav", "label": "Favourites"},
  ];

  String? _selectedLevels;
  String? _selectedLanguage;

  void _toggleLevel(String code) {
    setState(() {
      if (_selectedLevels == code) {
        _selectedLevels = null;
      } else {
        _selectedLevels = code;
      }
    });
  }

  void _proceedToDeck(AppLocalizations local) {
    if (_selectedLevels == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(local.selectLanguages)), // Use localized string
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CardFlipPage(levels: _selectedLevels!),
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
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!; // Access localization

    return Scaffold(
      appBar: AppBar(
        title: halfColoredTitle(local.deckPage),
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDeck(allLevels[0]["code"]!, allLevels[0]["label"]!, local),
                _buildDeck(allLevels[1]["code"]!, allLevels[1]["label"]!, local),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDeck(allLevels[2]["code"]!, allLevels[2]["label"]!, local),
                _buildDeck(allLevels[3]["code"]!, allLevels[3]["label"]!, local),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDeck(allLevels[4]["code"]!, allLevels[4]["label"]!, local),
                _buildDeck(allLevels[5]["code"]!, allLevels[5]["label"]!, local),
              ],
            ),

            const Spacer(),
            ElevatedButton(
              onPressed: () => _proceedToDeck(local), // Pass localization
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(180, 50),
              ),
              child: Text(local.proceed), // Use localized string
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }


  Widget _buildDeck(String code, String label, AppLocalizations local) {
    final bool isSelected = _selectedLevels == code;

    final frontGradient = isSelected
        ? const LinearGradient(
      colors: [Color(0xFF2196F3), Color(0xFF64B5F6)], // Blueish
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(
      colors: [Color(0xFF9E9E9E), Color(0xFFBDBDBD)], // Grayish
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final middleGradient = isSelected
        ? const LinearGradient(
      colors: [Color(0xFF64B5F6), Color(0xFF90CAF9)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(
      colors: [Color(0xFFBDBDBD), Color(0xFFE0E0E0)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final backGradient = isSelected
        ? const LinearGradient(
      colors: [Color(0xFFBBDEFB), Color(0xFFE3F2FD)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(
      colors: [Color(0xFFEEEEEE), Color(0xFFFAFAFA)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final textColor = isSelected ? Colors.white : Colors.black87;

    return GestureDetector(
      onTap: () => _toggleLevel(code),
      child: SizedBox(
        width: 100,
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [

            Positioned(
              left: 12,
              top: 12,
              child: Container(
                width: 70,
                height: 100,
                decoration: BoxDecoration(
                  gradient: backGradient,
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
            ),


            Positioned(
              left: 6,
              top: 6,
              child: Container(
                width: 70,
                height: 100,
                decoration: BoxDecoration(
                  gradient: middleGradient,
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
            ),


            Container(
              width: 70,
              height: 100,
              decoration: BoxDecoration(
                gradient: frontGradient,
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
                    code,
                    style: TextStyle(
                      fontSize: 18,
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
