import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/data/repositories/deck_repository.dart';
import 'package:poly2/domain/models/deck_summary.dart';
import 'package:poly2/presentation/providers/database_provider.dart';

final deckRepositoryProvider = Provider<DeckRepository>((ref) {
  return DeckRepository(ref.read(appDatabaseProvider));
});

final deckCatalogProvider = FutureProvider.autoDispose<List<DeckSummary>>((ref) async {
  final repo = ref.read(deckRepositoryProvider);
  await repo.ensureFavoritesDeck();
  return repo.fetchDeckSummaries();
});
