import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:poly2/main.dart';
import 'package:poly2/pages/first_time_selection_page.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('App boots and shows MaterialApp shell', (WidgetTester tester) async {
    // Use a larger surface to avoid layout overflows
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    expect(find.byType(MaterialApp), findsOneWidget);

    // Let the splash timer fire and navigation complete
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();

    // After splash, we should have navigated somewhere
    expect(find.byType(MaterialApp), findsOneWidget);
    final hasHome = find.text('Ana Sayfa').evaluate().isNotEmpty;
    final hasFirstTime =
        find.byType(FirstTimeSelectionPage).evaluate().isNotEmpty;
    expect(hasHome || hasFirstTime, isTrue);
  });
}
