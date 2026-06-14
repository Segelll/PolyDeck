/// Formats a [DateTime] as a "YYYY-MM-DD" string.
String formatDate(DateTime date) {
  return '${date.year}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

/// Generates a list of 7 consecutive date strings starting from [startDate].
List<String> generateWeekDates(DateTime startDate) {
  final List<String> weekDates = [];
  for (int i = 0; i < 7; i++) {
    weekDates.add(formatDate(startDate.add(Duration(days: i))));
  }
  return weekDates;
}

/// Generates a list of 4 month-label strings starting from [startDate].
List<String> generateMonthLabels(DateTime startDate) {
  final List<String> labels = [];
  for (int i = 0; i < 4; i++) {
    final d = DateTime(startDate.year, startDate.month + i);
    labels.add('${d.year}-${d.month.toString().padLeft(2, "0")}');
  }
  return labels;
}
