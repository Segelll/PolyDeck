import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/presentation/providers/progress_provider.dart';
import 'package:poly2/l10n/generated/app_localizations.dart';
import 'package:poly2/presentation/widgets/half_colored_title.dart';

class WeeklyPage extends ConsumerWidget {
  const WeeklyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = AppLocalizations.of(context)!;
    final progressAsync = ref.watch(weeklyProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: HalfColoredTitle(local.weeklyProgress),
        centerTitle: true,
      ),
      body: progressAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (progress) {
          if (progress.data.isEmpty || progress.dates.isEmpty) {
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
                      final date = DateTime.parse(progress.dates[entry.key]);
                      final dayLabel = '${date.month}/${date.day}';
                      final barHeight = (value / safeMax) * 200.0;

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
          );
        },
      ),
    );
  }
}
