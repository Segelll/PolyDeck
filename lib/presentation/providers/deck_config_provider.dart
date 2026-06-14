import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/data/repositories/word_repository.dart';
import 'package:poly2/domain/models/deck_config.dart';
import 'package:poly2/presentation/providers/deck_provider.dart';

/// Provides the deck config for a given CEFR level.
///
/// Falls back to 'default' config if the level-specific one doesn't exist.
final deckConfigProvider =
    FutureProvider.family<DeckConfig, String>((ref, level) async {
  final repo = ref.read(wordRepositoryProvider);
  return repo.getDeckConfig(level);
});
