import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:poly2/login_page.dart';
import 'package:poly2/services/database_helper.dart';
import 'package:poly2/strings_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StringsLoader.loadStrings();
  Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dbHelper=DBHelper();
    return FutureBuilder<Map<String,String>?>(
      future: dbHelper.getUserChoices('user'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

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
          //home: isFirstTime ? LoginPage() : const DecksPage(),
          home: LoginPage(),
        );
      },
    );
  }
}
