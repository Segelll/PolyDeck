import 'package:flutter/material.dart';
import 'package:poly2/services/database_helper.dart';
import 'strings_loader.dart';
import 'language_selection_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await StringsLoader.loadStrings();
    await DBHelper.instance.database;
  } catch (e) {
    runApp(const InitializationErrorApp());
    return;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blueGrey,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.dark,
      home: const LanguageSelectionPage(),
    );
  }
}
class InitializationErrorApp extends StatelessWidget {
  const InitializationErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Initialization Error')),
        body: const Center(
          child: Text(
            'An error occurred during initialization. Please try restarting the app.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
