import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caloriewala/main.dart';

void main() {
  testWidgets('CalorieWalaApp smoke test - app builds without error',
      (WidgetTester tester) async {
    // Pump the app inside a ProviderScope (required for Riverpod)
    await tester.pumpWidget(
      const ProviderScope(
        child: CalorieWalaApp(),
      ),
    );

    // Allow async post-frame callbacks to settle
    await tester.pump(const Duration(seconds: 1));

    // Verify the Material app is in the widget tree
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
