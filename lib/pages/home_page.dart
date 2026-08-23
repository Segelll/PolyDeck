import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF162A32),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          pair,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: const Color(0xFF6D7C80), letterSpacing: 0.5),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F1ED),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD5E5DE)),
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
                        color: const Color(0xFF31554A),
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
                              color: const Color(0xFF162A32),
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
                color: Color(0xFF4E8572),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Çalışma akışı',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF162A32),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Destelerim bölümünden bir deste seçerek çalışmaya başlayabilirsin.',
          style: TextStyle(color: Color(0xFF6D7C80), height: 1.4),
        ),
      ],
    );
  }
}
