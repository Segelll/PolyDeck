import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/presentation/providers/database_provider.dart';

/// Provides the deck config for a given CEFR level as a Map.
///
/// Falls back to 'default' config if the level-specific one doesn't exist.
final deckConfigProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, level) async {
  final repo = ref.read(wordRepositoryProvider);
  return repo.getDeckConfig(level);
});
