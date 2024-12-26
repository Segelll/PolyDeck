import 'package:flutter/material.dart';
import 'package:poly2/services/auth_service.dart';
import 'package:poly2/services/data_loader.dart';

/* class LoginPage extends StatelessWidget {
  final AuthService authService = AuthService();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            //veriler veri tabanına şuan yükleniyor
            await DataLoader().loadJsonFilesToDatabase();
            try {
              final user = await authService.signInWithGoogle();
              if (user != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LanguageSelectionPage()
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Google Sign-In failed'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Login error: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text('Sign in with Google'),
        ),
      ),
    );
  }
} */