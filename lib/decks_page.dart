import 'package:flutter/material.dart';
import 'package:poly2/strings_loader.dart';
import 'package:poly2/exam_page.dart';
import 'package:poly2/settings_page.dart';
import 'card_flip_page.dart';

class DecksPage extends StatefulWidget {
  const DecksPage({Key? key}) : super(key: key);

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
  ];


  final List<String> _selectedLevels = [];

  void _toggleLevel(String code) {
    setState(() {
      if (_selectedLevels.contains(code)) {
        _selectedLevels.remove(code);
      } else {
        _selectedLevels.add(code);
      }
    });
  }

  void _proceedToDeck() {
    if (_selectedLevels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one level!')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CardFlipPage(levels: _selectedLevels),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(StringsLoader.get("deckPage")),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: StringsLoader.get('examIconTooltip'),
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
              StringsLoader.get('selectLevel'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Row 1 => A1, A2
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDeck(allLevels[0]["code"]!, allLevels[0]["label"]!),
                _buildDeck(allLevels[1]["code"]!, allLevels[1]["label"]!),
              ],
            ),
            const SizedBox(height: 24),

            // Row 2 => B1, B2
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDeck(allLevels[2]["code"]!, allLevels[2]["label"]!),
                _buildDeck(allLevels[3]["code"]!, allLevels[3]["label"]!),
              ],
            ),
            const SizedBox(height: 24),

            // Row 3 => C1 in center
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDeck(allLevels[4]["code"]!, allLevels[4]["label"]!),
              ],
            ),

            const Spacer(),
            ElevatedButton(
              onPressed: _proceedToDeck,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(180, 50),
              ),
              child: Text(StringsLoader.get('proceed')),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }


  Widget _buildDeck(String code, String label) {
    final bool isSelected = _selectedLevels.contains(code);


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
                    code, // e.g. "A1"
                    style: TextStyle(
                      fontSize: 18,
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label, // e.g. "Beginner"
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
