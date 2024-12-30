import 'package:flutter/material.dart';
import 'package:poly2/services/database_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WeeklyPage extends StatefulWidget {
  const WeeklyPage({Key? key}) : super(key: key);

  @override
  _WeeklyPageState createState() => _WeeklyPageState();
}

class _WeeklyPageState extends State<WeeklyPage> {
  List<int> data = [];
  List<String> dates = [];
  Map<String, int> dateCounts = {};
  List<String> languageTables = ['fr', 'de', 'en', 'it', 'pr', 'tr', 'esp'];

  @override
  void initState() {
    super.initState();
    _loadWeeklyData();
  }

  Future<void> _loadWeeklyData() async {
    try {
      String? earliestDate;
      for (String table in languageTables) {
        String? tableEarliestDate = await DBHelper.instance.getEarliestDate(table);
        if (tableEarliestDate != null) {
          tableEarliestDate = tableEarliestDate.trim();

          if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(tableEarliestDate)) {
            final date = DateTime.parse(tableEarliestDate);
            if (earliestDate == null || date.isBefore(DateTime.parse(earliestDate))) {
              earliestDate = tableEarliestDate;
            }
          } else {
            throw FormatException('Invalid date format: $tableEarliestDate');
          }
        }
      }

      if (earliestDate != null) {
        final startDate = DateTime.parse(earliestDate);
        List<String> weekDates = _generateWeekDates(startDate);
        setState(() {
          dates = weekDates;
          _fetchDateCounts(weekDates);
        });
      }
    } catch (e) {
      print('Error loading weekly data: $e');
    }
  }

  Future<void> _fetchDateCounts(List<String> weekDates) async {
    try {
      final db = await DBHelper().database;
      Map<String, int> combinedCounts = {};

      for (String table in languageTables) {
        final result = await db.rawQuery(
            'SELECT date, COUNT(*) as count FROM $table WHERE date IS NOT NULL AND date != "0" GROUP BY date ORDER BY date ASC'
        );
        for (var row in result) {
          String date = row['date'] as String;
          int count = row['count'] as int;
          combinedCounts[date] = (combinedCounts[date] ?? 0) + count;
        }
      }

      setState(() {
        dateCounts = combinedCounts;
        data = weekDates.map((date) => dateCounts[date] ?? 0).toList();
      });
    } catch (e) {
      print('Error fetching date counts: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to fetch data: $e')));
    }
  }

  List<String> _generateWeekDates(DateTime startDate) {
    List<String> weekDates = [];
    for (int i = 0; i < 7; i++) {
      final date = startDate.add(Duration(days: i));
      weekDates.add(
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      );
    }
    return weekDates;
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    if (data.isEmpty || dates.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(local.weeklyProgress),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final maxVal = data.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: Text(local.weeklyProgress),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.blueGrey.shade50,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              local.weeklyProgress,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: data.asMap().entries.map((entry) {
                  final index = entry.key;
                  final value = entry.value;
                  final date = DateTime.parse(dates[index]);
                  final dayLabel = '${date.month}/${date.day}';
                  final barHeight = (value / maxVal) * 200.0;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 20,
                        height: barHeight,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(height: 4),
                      Text(dayLabel, style: const TextStyle(fontSize: 14)),
                      Text('$value', style: const TextStyle(fontSize: 14)),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
