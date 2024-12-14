import 'package:flutter/material.dart';
import 'package:poly2/services/database_helper.dart';

class ProgressReport extends StatefulWidget {
  const ProgressReport({Key? key}) : super(key: key);

  @override
  _ProgressReportState createState() => _ProgressReportState();
}

class _ProgressReportState extends State<ProgressReport> {
  Map<String, int> dateCounts = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDateCounts();
  }

Future<void> _fetchDateCounts() async {
  try {
    final db = await DBHelper().database;
    final result = await db.rawQuery(
      'SELECT date, COUNT(*) as count FROM en WHERE date IS NOT NULL GROUP BY date ORDER BY date ASC',
    );
    setState(() {
      dateCounts = {
        for (var row in result)
          row['date'] as String: row['count'] as int
      };
      isLoading = false;
    });

    print('Date Counts: $dateCounts');
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    print('Error fetching date counts: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to fetch data: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Report'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : dateCounts.isEmpty
              ? const Center(child: Text('No data available'))
              : ListView.builder(
                  itemCount: dateCounts.length,
                  itemBuilder: (context, index) {
                    final date = dateCounts.keys.elementAt(index);
                    final count = dateCounts[date]!;
                    return ListTile(
                      title: Text('Date: $date'),
                      subtitle: Text('Count: $count'),
                    );
                  },
                ),
    );
  }
}
