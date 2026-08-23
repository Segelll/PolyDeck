import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/core/theme/app_palette.dart';
import 'package:poly2/domain/enums/proficiency_level.dart';
import 'package:poly2/domain/models/deck_summary.dart';
import 'package:poly2/pages/card_flip_page.dart';
import 'package:poly2/presentation/providers/deck_repository_provider.dart';

class DecksPage extends ConsumerWidget {
  const DecksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(deckCatalogProvider);

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const Material(
            color: AppPalette.cloudDancer,
            child: TabBar(
              tabs: [
                Tab(text: 'Varsayılan'),
                Tab(text: 'Kişiselleştirilmiş'),
                Tab(text: 'Kategoriler'),
              ],
            ),
          ),
          Expanded(
            child: catalog.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _CatalogError(
                message: error.toString(),
                onRetry: () => ref.invalidate(deckCatalogProvider),
              ),
              data: (decks) => TabBarView(
                children: [
                  _DefaultDeckList(decks: decks),
                  _CustomDeckList(decks: decks),
                  const _CategoryPlaceholder(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DefaultDeckList extends StatelessWidget {
  final List<DeckSummary> decks;

  const _DefaultDeckList({required this.decks});

  @override
  Widget build(BuildContext context) {
    final favorites = decks.where((deck) => deck.isFavorites).firstOrNull;
    final levels = ProficiencyLevel.standardLevels
        .map(
          (level) => DeckSummary(
            id: 0,
            name: level.code,
            deckType: 'system',
            systemKey: level.code,
            cardCount: 0,
          ),
        )
        .toList();
    if (favorites != null) levels.insert(0, favorites);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      itemCount: levels.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _DeckRow(
        deck: levels[index],
        icon: levels[index].isFavorites
            ? Icons.star_rounded
            : Icons.auto_awesome_outlined,
        subtitle: levels[index].isFavorites
            ? '${levels[index].cardCount} kart'
            : 'CEFR seviye destesi',
        onTap: () => _openDeck(context, levels[index]),
      ),
    );
  }
}

class _CustomDeckList extends ConsumerWidget {
  final List<DeckSummary> decks;

  const _CustomDeckList({required this.decks});

  Future<void> _createDeck(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Yeni deste oluştur'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 60,
          decoration: const InputDecoration(labelText: 'Deste adı'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Oluştur'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty || !context.mounted) return;
    await ref.read(deckRepositoryProvider).createCustomDeck(name);
    ref.invalidate(deckCatalogProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customDecks = decks.where((deck) => deck.isCustom).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Kendi çalışma listelerin',
                  style: TextStyle(color: AppPalette.mutedInk),
                ),
              ),
              IconButton(
                tooltip: 'Yeni deste oluştur',
                icon: const Icon(Icons.add),
                onPressed: () => _createDeck(context, ref),
              ),
            ],
          ),
        ),
        Expanded(
          child: customDecks.isEmpty
              ? Center(
                  child: TextButton.icon(
                    onPressed: () => _createDeck(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('İlk desteni oluştur'),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  itemCount: customDecks.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final deck = customDecks[index];
                    return _DeckRow(
                      deck: deck,
                      icon: Icons.folder_outlined,
                      subtitle: '${deck.cardCount} kart',
                      onTap: () => _openDeck(context, deck),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _DeckRow extends StatelessWidget {
  final DeckSummary deck;
  final IconData icon;
  final String subtitle;
  final VoidCallback onTap;

  const _DeckRow({
    required this.deck,
    required this.icon,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPalette.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppPalette.ink),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deck.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(color: AppPalette.mutedInk),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppPalette.mutedInk),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryPlaceholder extends StatelessWidget {
  const _CategoryPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.category_outlined, size: 46, color: AppPalette.ink),
          SizedBox(height: 12),
          Text('Kategoriler yakında burada.'),
        ],
      ),
    );
  }
}

class _CatalogError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CatalogError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 40,
              color: AppPalette.raindropsOnRoses,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Tekrar dene'),
            ),
          ],
        ),
      ),
    );
  }
}

void _openDeck(BuildContext context, DeckSummary deck) {
  unawaited(
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CardFlipPage(
          levels: deck.systemKey ?? 'custom',
          deckId: deck.id == 0 ? null : deck.id,
          deckName: deck.name,
        ),
      ),
    ),
  );
}
