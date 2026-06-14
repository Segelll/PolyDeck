import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/data/repositories/progress_repository.dart';
import 'package:poly2/data/repositories/user_repository.dart';
import 'package:poly2/presentation/providers/database_provider.dart';
import 'package:poly2/core/utils/date_utils.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository(ref.read(appDatabaseProvider));
});

class WeeklyProgressState {
  final List<int> data;
  final List<String> dates;
  final bool isLoading;
  const WeeklyProgressState(
      {this.data = const [], this.dates = const [], this.isLoading = true});
}

final weeklyProgressProvider =
    FutureProvider.autoDispose<WeeklyProgressState>((ref) async {
  final repo = ref.read(progressRepositoryProvider);
  final userRepo = ref.read(userRepositoryProvider);
  final settings = await userRepo.getUserChoices();
  final language = settings?['targetLanguage'] ?? 'tr';

  final earliestDate = await repo.getEarliestDate(language);
  if (earliestDate == null) {
    return const WeeklyProgressState(isLoading: false);
  }
  final weekDates = generateWeekDates(DateTime.parse(earliestDate));
  final dateCounts = await repo.fetchDateCounts(language);
  final data = weekDates.map((d) => dateCounts[d] ?? 0).toList();
  return WeeklyProgressState(data: data, dates: weekDates, isLoading: false);
});

class MonthlyProgressState {
  final List<int> data;
  final List<String> monthLabels;
  final bool isLoading;
  const MonthlyProgressState(
      {this.data = const [], this.monthLabels = const [], this.isLoading = true});
}

final monthlyProgressProvider =
    FutureProvider.autoDispose<MonthlyProgressState>((ref) async {
  final repo = ref.read(progressRepositoryProvider);
  final userRepo = ref.read(userRepositoryProvider);
  final settings = await userRepo.getUserChoices();
  final language = settings?['targetLanguage'] ?? 'tr';

  final earliestDateStr = await repo.getEarliestDate(language);
  if (earliestDateStr == null) {
    return const MonthlyProgressState(isLoading: false);
  }
  final earliestDate = DateTime.parse(earliestDateStr);
  final data = await repo.fetchMonthlyCounts(earliestDate, language);
  final labels = generateMonthLabels(earliestDate);
  return MonthlyProgressState(
      data: data, monthLabels: labels, isLoading: false);
});
