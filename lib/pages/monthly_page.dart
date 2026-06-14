import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/presentation/providers/progress_provider.dart';
import 'package:poly2/presentation/widgets/half_colored_title.dart';
import 'package:poly2/l10n/generated/app_localizations.dart';

class MonthlyPage extends ConsumerWidget {
  const MonthlyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = AppLocalizations.of(context)!;
    final progressAsync = ref.watch(monthlyProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: HalfColoredTitle(local.monthlyProgress),
        centerTitle: true,
      ),
      body: progressAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (progress) {
          if (progress.data.isEmpty) {
            return const Center(child: Text('No data yet.'));
          }

          final maxVal = progress.data.reduce((a, b) => a > b ? a : b).toDouble();
          final safeMax = maxVal == 0 ? 1.0 : maxVal;

          return Container(
            color: Colors.blueGrey.shade50,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: progress.data.asMap().entries.map((entry) {
                      final value = entry.value;
                      final barHeight = (value / safeMax) * 200.0;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 30,
                            height: barHeight,
                            color: Colors.purpleAccent,
                          ),
                          const SizedBox(height: 4),
                          Text(progress.monthLabels[entry.key],
                              style: const TextStyle(fontSize: 14)),
                          Text('$value',
                              style: const TextStyle(fontSize: 14)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
