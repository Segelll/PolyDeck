import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poly2/main.dart';

void main() {
  testWidgets('App starts and shows splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pump(const Duration(seconds: 1));

    // The splash screen should render the PolyDeck branding
    expect(find.text('Poly'), findsOneWidget);
    expect(find.text('Deck'), findsOneWidget);
  });
}
