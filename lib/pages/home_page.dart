import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/core/theme/app_palette.dart';
import 'package:poly2/presentation/providers/home_provider.dart';
import 'package:poly2/presentation/providers/settings_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(todaySeenCountProvider);
    final settings = ref.watch(settingsProvider).valueOrNull;
    final pair = settings == null
        ? 'en → tr'
        : '${settings.mainLanguage.toUpperCase()} → ${settings.targetLanguage.toUpperCase()}';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        Text(
          'Bugünün çalışması',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700, color: AppPalette.ink),
        ),
        const SizedBox(height: 6),
        Text(
          pair,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppPalette.mutedInk),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          decoration: BoxDecoration(
            color: AppPalette.almostAqua,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppPalette.nimbusCloud),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bugün görülen kelime',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppPalette.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    countAsync.when(
                      loading: () => const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                      error: (_, _) => const Text('—'),
                      data: (count) => Text(
                        '$count',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: AppPalette.ink,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.auto_graph_rounded,
                size: 46,
                color: AppPalette.ink,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Çalışma akışı',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700, color: AppPalette.ink),
        ),
        const SizedBox(height: 8),
        const Text(
          'Destelerim bölümünden bir deste seçerek çalışmaya başlayabilirsin.',
          style: TextStyle(color: AppPalette.mutedInk, height: 1.4),
        ),
      ],
    );
  }
}
