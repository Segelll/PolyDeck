import 'package:flutter/material.dart';
import 'strings_loader.dart';
import 'language_selection_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StringsLoader.loadStrings(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LanguageSelectionPage(), 
    );
  }
}
