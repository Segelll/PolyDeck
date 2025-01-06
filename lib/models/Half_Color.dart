import 'package:flutter/material.dart';

Widget halfColoredTitle(String text) {

  final half = text.length ~/ 2;

  return RichText(
    textAlign: TextAlign.center,
    text: TextSpan(
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      children: [
        TextSpan(
          text: text.substring(0, half),
          style: const TextStyle(color: Colors.black),
        ),
        TextSpan(
          text: text.substring(half),
          style: const TextStyle(color: Color(0xFFADD8E6)), // Light blue
        ),
      ],
    ),
  );
}
