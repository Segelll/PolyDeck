import 'package:flutter/material.dart';
import 'package:poly2/strings_loader.dart';
import 'package:poly2/preferences_helper.dart';


import 'decks_page.dart';
import 'first_time_selection_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StringsLoader.loadStrings();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: PreferencesHelper.isFirstTime(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final isFirstTime = snapshot.data!;
        return MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.blueGrey,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.blueGrey,
            brightness: Brightness.dark,
          ),
          themeMode: ThemeMode.light,
          home: isFirstTime ? const FirstTimeSelectionPage() : const DecksPage(),
        );
      },
    );
  }
}
