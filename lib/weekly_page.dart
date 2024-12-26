import 'package:flutter/material.dart';
import 'package:poly2/strings_loader.dart';
import 'dart:math';

class WeeklyPage extends StatelessWidget {
  const WeeklyPage({Key? key}) : super(key: key);

  List<int> _generateSampleData() {

    final rnd = Random();
    return List<int>.generate(7, (_) => rnd.nextInt(10) + 1);
  }

  @override
  Widget build(BuildContext context) {
    final data = _generateSampleData();

    final maxVal = data.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: Text(StringsLoader.get('weeklyProgress')),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.blueGrey.shade50,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              StringsLoader.get('chartWeekly'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // A simple bar chart
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: data.asMap().entries.map((entry) {
                  final index = entry.key;
                  final value = entry.value;
                  final dayLabel = 'Day ${index + 1}';
                  // bar height
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
