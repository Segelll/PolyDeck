import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:poly2/services/database_helper.dart';
import '../models/half_color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MonthlyPage extends StatefulWidget {
  const MonthlyPage({super.key});

  @override
  _MonthlyPageState createState() => _MonthlyPageState();
}

class _MonthlyPageState extends State<MonthlyPage> {
  List<int> data = [];
  List<String> monthLabels = [];
  List<String> languageTables = ['fr', 'de', 'en', 'it', 'pr', 'tr', 'esp'];

  @override
  void initState() {
    super.initState();
    _loadMonthlyData();
  }

  Future<void> _loadMonthlyData() async {
    try {
      DateTime? earliestDate;
      for (String table in languageTables) {
        final tableEarliestDate = await DBHelper.instance.getEarliestDate(table);
        if (tableEarliestDate != null) {
          final date = DateTime.parse(tableEarliestDate.trim());
          if (earliestDate == null || date.isBefore(earliestDate)) {
            earliestDate = date;
          }
        }
      }

      if (earliestDate != null) {
        await _fetchMonthlyCounts(earliestDate);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading monthly data: $e');
      }
    }
  }

  Future<void> _fetchMonthlyCounts(DateTime startDate) async {
    try {
      final db = await DBHelper().database;
      List<int> monthlyCounts = [];
      List<String> labels = [];

      for (int i = 0; i < 4; i++) {
        final currentDate = DateTime(startDate.year, startDate.month + i);
        final nextMonth = DateTime(currentDate.year, currentDate.month + 1);

        int totalCount = 0;
        for (String table in languageTables) {
          final result = await db.rawQuery(
            'SELECT COUNT(*) as count FROM $table WHERE date BETWEEN ? AND ?',
            [
              '${currentDate.year}-${currentDate.month.toString().padLeft(2, "0")}-01',
              '${nextMonth.year}-${nextMonth.month.toString().padLeft(2, "0")}-01',
            ],
          );

          totalCount += result.first['count'] as int;
        }
        monthlyCounts.add(totalCount);
        labels.add('${currentDate.year}-${currentDate.month.toString().padLeft(2, "0")}');
      }

      setState(() {
        data = monthlyCounts;
        monthLabels = labels;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching monthly counts: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    if (data.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: halfColoredTitle(local.monthlyProgress),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final maxVal = data.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: halfColoredTitle(local.monthlyProgress),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.blueGrey.shade50,
        child: Column(
          children: [

            const SizedBox(height: 20),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: data.asMap().entries.map((entry) {
                  final index = entry.key;
                  final value = entry.value;
                  final barHeight = (value / maxVal) * 200.0;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 30,
                        height: barHeight,
                        color: Colors.purpleAccent,
                      ),
                      const SizedBox(height: 4),
                      Text(monthLabels[index], style: const TextStyle(fontSize: 14)),
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
