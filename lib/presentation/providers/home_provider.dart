import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/presentation/providers/database_provider.dart';
import 'package:poly2/presentation/providers/settings_provider.dart';
import 'package:poly2/presentation/providers/study_activity_provider.dart';

final todaySeenCountProvider = FutureProvider.autoDispose<int>((ref) async {
  ref.watch(studyActivityProvider);
  final userRepo = ref.read(userRepositoryProvider);
  final wordRepo = ref.read(wordRepositoryProvider);
  final preferences = ref.watch(settingsProvider).valueOrNull;
  final targetLanguage = preferences?.targetLanguage ??
      (await userRepo.getUserChoices())?['targetLanguage'] ??
      'tr';
  return wordRepo.getTodaySeenCount(targetLanguage);
});
