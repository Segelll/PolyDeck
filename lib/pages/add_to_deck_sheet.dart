import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/domain/models/deck_summary.dart';
import 'package:poly2/presentation/providers/deck_repository_provider.dart';

/// Bottom sheet used to add the visible card to favorites or a custom deck.
class AddToDeckSheet extends ConsumerStatefulWidget {
  final List<DeckSummary> decks;
  final int wordId;
  final String sourceLanguage;
  final String targetLanguage;

  const AddToDeckSheet({
    super.key,
    required this.decks,
    required this.wordId,
    required this.sourceLanguage,
    required this.targetLanguage,
  });

  @override
  ConsumerState<AddToDeckSheet> createState() => _AddToDeckSheetState();
}

class _AddToDeckSheetState extends ConsumerState<AddToDeckSheet> {
  int? _busyDeckId;

  Future<void> _addToDeck(DeckSummary deck) async {
    setState(() => _busyDeckId = deck.id);
    try {
      final repo = ref.read(deckRepositoryProvider);
      await repo.addWordToDeck(
        deckId: deck.id,
        wordId: widget.wordId,
        sourceLanguage: widget.sourceLanguage,
        targetLanguage: widget.targetLanguage,
      );
      ref.invalidate(deckCatalogProvider);
      if (mounted) Navigator.pop(context, deck.id);
    } catch (e) {
      if (mounted) {
        setState(() => _busyDeckId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deste güncellenemedi: $e')),
        );
      }
    }
  }

  Future<void> _createDeck() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Yeni deste oluştur'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 60,
          decoration: const InputDecoration(
            labelText: 'Deste adı',
            hintText: 'Örn. Seyahat kelimeleri',
          ),
          onSubmitted: (value) => Navigator.pop(dialogContext, value.trim()),
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
    if (name == null || name.trim().isEmpty || !mounted) return;

    setState(() => _busyDeckId = -1);
    try {
      final repo = ref.read(deckRepositoryProvider);
      final deckId = await repo.createCustomDeck(name);
      await repo.addWordToDeck(
        deckId: deckId,
        wordId: widget.wordId,
        sourceLanguage: widget.sourceLanguage,
        targetLanguage: widget.targetLanguage,
      );
      ref.invalidate(deckCatalogProvider);
      if (mounted) Navigator.pop(context, deckId);
    } catch (e) {
      if (mounted) {
        setState(() => _busyDeckId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deste oluşturulamadı: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedDecks = [...widget.decks]
      ..sort((a, b) => (a.isFavorites ? 0 : 1).compareTo(b.isFavorites ? 0 : 1));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Desteye ekle',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 6),
            const Text('Bu kartı kaydetmek istediğin desteyi seç.'),
            const SizedBox(height: 12),
            ...sortedDecks.map(
              (deck) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  deck.isFavorites ? Icons.star_rounded : Icons.folder_outlined,
                  color: deck.isFavorites ? Colors.amber.shade700 : null,
                ),
                title: Text(deck.name),
                subtitle: Text('${deck.cardCount} kart'),
                trailing: _busyDeckId == deck.id
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: _busyDeckId == null ? () => _addToDeck(deck) : null,
              ),
            ),
            const Divider(height: 20),
            TextButton.icon(
              onPressed: _busyDeckId == null ? _createDeck : null,
              icon: const Icon(Icons.add),
              label: const Text('Yeni deste oluştur'),
            ),
          ],
        ),
      ),
    );
  }
}
