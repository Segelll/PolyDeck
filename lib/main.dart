import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:poly2/pages/decks_page.dart';

import 'package:poly2/pages/login_page.dart';
import 'package:poly2/services/database_helper.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          title: 'PolyDeck',
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en'),
            Locale('es'),
            Locale('pt'),
            Locale('tr'),
            Locale('it'),
            Locale('de'),
            Locale('fr')
          ],
          theme: ThemeData(
            primarySwatch: Colors.blueGrey,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.blueGrey,
            brightness: Brightness.dark,
          ),
          themeMode: ThemeMode.light,
          locale: Locale(Platform.localeName),
          home: LoginPage(),
        );
      },
    );
  }
}
