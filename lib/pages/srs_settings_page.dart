import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/domain/enums/proficiency_level.dart';
import 'package:poly2/domain/models/deck_config.dart';
import 'package:poly2/presentation/providers/deck_config_provider.dart';
import 'package:poly2/presentation/providers/deck_provider.dart';
import 'package:poly2/presentation/widgets/half_colored_title.dart';

/// Settings page for FSRS / spaced repetition configuration.
class SrsSettingsPage extends ConsumerWidget {
  const SrsSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const HalfColoredTitle('SRS Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionHeader('Daily Limits'),
          const SizedBox(height: 8),
          for (final level
              in ProficiencyLevel.values.where((l) => l != ProficiencyLevel.favourites))
            _LevelConfigTile(level: level.code),
          const Divider(height: 32),
          const _SectionHeader('Global Settings'),
          const SizedBox(height: 8),
          _GlobalConfigTile(),
          const Divider(height: 32),
          const _SectionHeader('Danger Zone'),
          const SizedBox(height: 8),
          _ResetSrsButton(),
        ],
      ),
    );
  }
}

/// Displays and edits per-level limits.
class _LevelConfigTile extends ConsumerWidget {
  final String level;

  const _LevelConfigTile({required this.level});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(deckConfigProvider(level));

    return configAsync.when(
      loading: () => ListTile(title: Text('$level'), subtitle: const Text('Loading...')),
      error: (_, __) => const SizedBox.shrink(),
      data: (config) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            title: Text('Level $level'),
            subtitle: Text(
                '${config.maxNewPerDay} new / ${config.maxReviewsPerDay} reviews per day'),
            children: [
              _SliderSetting(
                label: 'Max new per day',
                value: config.maxNewPerDay.toDouble(),
                min: 1,
                max: 50,
                divisions: 49,
                onChanged: (v) => _save(ref, config.copyWith(maxNewPerDay: v.toInt())),
              ),
              _SliderSetting(
                label: 'Max reviews per day',
                value: config.maxReviewsPerDay.toDouble(),
                min: 1,
                max: 200,
                divisions: 199,
                onChanged: (v) =>
                    _save(ref, config.copyWith(maxReviewsPerDay: v.toInt())),
              ),
            ],
          ),
        );
      },
    );
  }

  void _save(WidgetRef ref, DeckConfig config) {
    final repo = ref.read(wordRepositoryProvider);
    repo.saveDeckConfig(config);
    ref.invalidate(deckConfigProvider(level));
  }
}

/// Global retention + fuzz settings.
class _GlobalConfigTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(deckConfigProvider('default'));

    return configAsync.when(
      loading: () => const ListTile(title: Text('Loading...')),
      error: (_, __) => const SizedBox.shrink(),
      data: (config) {
        return Card(
          child: Column(
            children: [
              _SliderSetting(
                label: 'Request retention: ${config.requestRetention.toStringAsFixed(2)}',
                value: config.requestRetention,
                min: 0.70,
                max: 0.97,
                divisions: 27,
                onChanged: (v) {
                  final newConfig = config.copyWith(requestRetention: v);
                  final repo = ref.read(wordRepositoryProvider);
                  repo.saveDeckConfig(newConfig);
                  ref.invalidate(deckConfigProvider('default'));
                },
              ),
              SwitchListTile(
                title: const Text('Enable fuzz'),
                subtitle: const Text('Adds random variance to intervals'),
                value: config.enableFuzz,
                onChanged: (v) {
                  final newConfig = config.copyWith(enableFuzz: v);
                  final repo = ref.read(wordRepositoryProvider);
                  repo.saveDeckConfig(newConfig);
                  ref.invalidate(deckConfigProvider('default'));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Resets all SRS state to New.
class _ResetSrsButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: Colors.red.shade50,
      child: ListTile(
        leading: const Icon(Icons.warning, color: Colors.red),
        title: const Text('Reset All SRS Progress'),
        subtitle: const Text(
            'Resets every card to New state. Review history is preserved in the log.'),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Reset SRS State?'),
                content: const Text(
                    'This will mark all cards as New. '
                    'Your review history will be kept. Continue?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Reset',
                          style: TextStyle(color: Colors.red))),
                ],
              ),
            );
            if (confirmed == true) {
              final repo = ref.read(wordRepositoryProvider);
              for (final lang
                  in ['en', 'tr', 'de', 'fr', 'it', 'pr', 'esp', 'fav']) {
                await repo.resetSrsState(lang);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('SRS state has been reset.')),
                );
              }
            }
          },
          child: const Text('Reset', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

/// Label row in settings.
class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}

/// Slider with a label.
class _SliderSetting extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderSetting({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// Helper extensions for DeckConfig (needed for copyWith-like fluent API)
extension _DeckConfigMut on DeckConfig {
  DeckConfig copyWith({
    int? maxNewPerDay,
    int? maxReviewsPerDay,
    double? requestRetention,
    bool? enableFuzz,
  }) {
    return DeckConfig(
      level: level,
      maxNewPerDay: maxNewPerDay ?? this.maxNewPerDay,
      maxReviewsPerDay: maxReviewsPerDay ?? this.maxReviewsPerDay,
      learningSteps: learningSteps,
      enableFuzz: enableFuzz ?? this.enableFuzz,
      requestRetention: requestRetention ?? this.requestRetention,
      w: w,
    );
  }
}
