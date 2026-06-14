import 'package:flutter/material.dart';
import 'package:poly2/pages/decks_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 700),
            pageBuilder: (_, __, ___) => const DecksPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image.asset(
                'assets/images/polydeckic.png',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: 'Poly',
                    style: TextStyle(color: Colors.black),
                  ),
                  TextSpan(
                    text: 'Deck',
                    style: TextStyle(color: Color(0xFFADD8E6)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
