import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/pages/app_shell.dart';
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
    await Future<void>.delayed(const Duration(milliseconds: 650));
    var isFirstTime = true;
    try {
      final preferences = await ref
          .read(settingsProvider.future)
          .timeout(
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
      backgroundColor: const Color(0xFFF8FAF8),
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
                color: Color(0xFF162A32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
