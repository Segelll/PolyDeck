import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/data/repositories/progress_repository.dart';

/// Provides the [ProgressRepository] instance.
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository();
});

/// Holds weekly progress data.
class WeeklyProgressState {
  final List<int> data;
  final List<String> dates;
  final bool isLoading;

  const WeeklyProgressState({
    this.data = const [],
    this.dates = const [],
    this.isLoading = true,
  });
}

/// Manages weekly progress data.
final weeklyProgressProvider =
    FutureProvider.autoDispose<WeeklyProgressState>((ref) async {
  final repo = ref.read(progressRepositoryProvider);

  final earliestDate = await repo.getEarliestDate();
  if (earliestDate == null) {
    return const WeeklyProgressState(isLoading: false);
  }

  final startDate = DateTime.parse(earliestDate);
  final List<String> weekDates = [];
  for (int i = 0; i < 7; i++) {
    final date = startDate.add(Duration(days: i));
    weekDates.add(
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
    );
  }

  final dateCounts = await repo.fetchDateCounts();
  final data = weekDates.map((d) => dateCounts[d] ?? 0).toList();

  return WeeklyProgressState(
    data: data,
    dates: weekDates,
    isLoading: false,
  );
});

/// Holds monthly progress data.
class MonthlyProgressState {
  final List<int> data;
  final List<String> monthLabels;
  final bool isLoading;

  const MonthlyProgressState({
    this.data = const [],
    this.monthLabels = const [],
    this.isLoading = true,
  });
}

/// Manages monthly progress data.
final monthlyProgressProvider =
    FutureProvider.autoDispose<MonthlyProgressState>((ref) async {
  final repo = ref.read(progressRepositoryProvider);

  final earliestDateStr = await repo.getEarliestDate();
  if (earliestDateStr == null) {
    return const MonthlyProgressState(isLoading: false);
  }

  final earliestDate = DateTime.parse(earliestDateStr);
  final data = await repo.fetchMonthlyCounts(earliestDate);

  final List<String> labels = [];
  for (int i = 0; i < 4; i++) {
    final d = DateTime(earliestDate.year, earliestDate.month + i);
    labels.add('${d.year}-${d.month.toString().padLeft(2, "0")}');
  }

  return MonthlyProgressState(
    data: data,
    monthLabels: labels,
    isLoading: false,
  );
});
