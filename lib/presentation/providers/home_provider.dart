import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/presentation/providers/database_provider.dart';

final todaySeenCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final userRepo = ref.read(userRepositoryProvider);
  final wordRepo = ref.read(wordRepositoryProvider);
  final settings = await userRepo.getUserChoices();
  return wordRepo.getTodaySeenCount(settings?['targetLanguage'] ?? 'tr');
});
