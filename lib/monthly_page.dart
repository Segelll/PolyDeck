import 'package:flutter/material.dart';
import 'package:poly2/strings_loader.dart';
import 'dart:math';

class MonthlyPage extends StatelessWidget {
  const MonthlyPage({Key? key}) : super(key: key);

  List<int> _generateSampleData() {

    final rnd = Random();
    return List<int>.generate(4, (_) => rnd.nextInt(20) + 5);
  }

  @override
  Widget build(BuildContext context) {
    final data = _generateSampleData();

    final maxVal = data.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: Text(StringsLoader.get('monthlyProgress')),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.blueGrey.shade50,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              StringsLoader.get('chartMonthly'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: data.asMap().entries.map((entry) {
                  final index = entry.key;
                  final value = entry.value;
                  final weekLabel = 'Week ${index + 1}';
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
                      Text(weekLabel, style: const TextStyle(fontSize: 14)),
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
