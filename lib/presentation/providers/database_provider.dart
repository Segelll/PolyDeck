import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/data/database/database.dart';
import 'package:poly2/data/repositories/word_repository.dart';
import 'package:poly2/data/repositories/user_repository.dart';

/// Drift database singleton — lives for the entire app lifetime.
/// NOT autoDispose: the DB must remain open until the process exits.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Provides the [WordRepository] instance.
final wordRepositoryProvider = Provider<WordRepository>((ref) {
  return WordRepository(ref.read(appDatabaseProvider));
});

/// Provides the [UserRepository] instance.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.read(appDatabaseProvider));
});
