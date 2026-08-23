import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/presentation/providers/progress_provider.dart';
import 'package:poly2/core/theme/app_palette.dart';
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (progress) {
          final totalCount = progress.data.fold<int>(
            0,
            (total, value) => total + value,
          );

          final maxVal = progress.data
              .reduce((a, b) => a > b ? a : b)
              .toDouble();
          final safeMax = maxVal == 0 ? 1.0 : maxVal;

          return Container(
            color: AppPalette.cloudDancer,
            child: Column(
              children: [
                const SizedBox(height: 16),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: AppPalette.almostAqua,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_graph, color: AppPalette.ink),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            local.weeklySeenWords(totalCount),
                            style: const TextStyle(
                              color: AppPalette.ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          '$totalCount',
                          style: const TextStyle(
                            color: AppPalette.ink,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: progress.data.asMap().entries.map((entry) {
                      final value = entry.value;
                      final date = DateTime.tryParse(progress.dates[entry.key]);
                      final dayLabel = date == null
                          ? '-'
                          : '${date.month}/${date.day}';
                      final barHeight = (value / safeMax) * 200.0;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '$value',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 20,
                            height: barHeight == 0 ? 2 : barHeight,
                            color: AppPalette.iceMelt,
                          ),
                          const SizedBox(height: 4),
                          Text(dayLabel, style: const TextStyle(fontSize: 14)),
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
