import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/data/database/database.dart';
import 'package:poly2/data/repositories/word_repository.dart';
import 'package:poly2/data/repositories/user_repository.dart';

/// Drift database singleton.
final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

/// Provides the [WordRepository] instance.
final wordRepositoryProvider = Provider<WordRepository>((ref) {
  return WordRepository(ref.read(appDatabaseProvider));
});

/// Provides the [UserRepository] instance.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.read(appDatabaseProvider));
});
