import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/pages/app_shell.dart';
import 'package:poly2/core/theme/app_palette.dart';
import 'package:poly2/pages/first_time_selection_page.dart';
import 'package:poly2/domain/state/language_preferences.dart';
import 'package:poly2/presentation/providers/settings_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _routeFromSplash());
  }

  Future<void> _routeFromSplash() async {
    // Start database initialization immediately, while keeping the splash
    // visible long enough to avoid a one-frame flash on fast devices.
    final preferencesFuture = ref.read(settingsProvider.future);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    var isFirstTime = true;
    try {
      final preferences = await preferencesFuture.timeout(
        const Duration(seconds: 8),
        onTimeout: () => LanguagePreferences.defaultPreferences,
      );
      isFirstTime = preferences.isFirstTime;
    } catch (_) {
      // A broken or unavailable local database must not leave the app stuck
      // on the splash screen. First-time setup can recover the preferences.
    }
    if (!mounted) return;

    unawaited(
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (_, _, _) =>
              isFirstTime ? const FirstTimeSelectionPage() : const AppShell(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.cloudDancer,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                'assets/images/polydeckic.png',
                width: 92,
                height: 92,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'PolyDeck',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: AppPalette.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
