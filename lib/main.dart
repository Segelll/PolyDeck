import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:poly2/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:poly2/pages/splash_screen.dart';
import 'package:poly2/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'PolyDeck',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('pt'),
        Locale('tr'),
        Locale('it'),
        Locale('de'),
        Locale('fr'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // Match on language code only, with 'en' as fallback
        if (locale != null) {
          for (final supported in supportedLocales) {
            if (supported.languageCode == locale.languageCode) {
              return supported;
            }
          }
        }
        return const Locale('en');
      },
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
