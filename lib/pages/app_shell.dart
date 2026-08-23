import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/pages/decks_page.dart';
import 'package:poly2/pages/exam_page.dart';
import 'package:poly2/pages/home_page.dart';
import 'package:poly2/pages/settings_page.dart';

class AppShell extends ConsumerStatefulWidget {
  final int initialIndex;

  const AppShell({super.key, this.initialIndex = 0});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  late int _selectedIndex = widget.initialIndex;
  late final Set<int> _visitedIndices = {widget.initialIndex};

  void _selectDestination(int index) {
    _visitedIndices.add(index);
    setState(() => _selectedIndex = index);
    Navigator.of(context).pop();
  }

  void _openSettings() {
    Navigator.of(context).pop();
    unawaited(Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDecks = _selectedIndex == 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: Text(isDecks ? 'Destelerim' : 'Ana Sayfa'),
        actions: [
          if (isDecks)
            IconButton(
              tooltip: 'Sınav',
              icon: const Icon(Icons.quiz_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ExamPage()),
              ),
            ),
          IconButton(
            tooltip: 'Ayarlar',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      drawer: NavigationDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectDestination,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/polydeckic.png',
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'PolyDeck',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: Text('Ana Sayfa'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.layers_outlined),
            selectedIcon: Icon(Icons.layers_rounded),
            label: Text('Destelerim'),
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Ayarlar'),
            onTap: _openSettings,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _visitedIndices.contains(0)
              ? const HomePage()
              : const SizedBox.shrink(),
          _visitedIndices.contains(1)
              ? const DecksPage()
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
