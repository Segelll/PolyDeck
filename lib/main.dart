import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:poly2/services/auth_service.dart';
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

/*import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:poly2/services/auth_service.dart';
import 'package:poly2/login_page.dart';
import 'strings_loader.dart';
import 'language_selection_page.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await StringsLoader.loadStrings();
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
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final AuthService _authService = AuthService();

  AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    User? currentUser = _authService.getCurrentUser();
    Text('Current User: ${currentUser?.email}');
    return currentUser != null 
        ? const LanguageSelectionPage() 
        : LoginPage();
  }
}*/