// Basic widget test for the demo app's landing screen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainingkit_flutter_example/screens/welcome_screen.dart';

void main() {
  testWidgets('Welcome screen shows the wordmark and CTA', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

    expect(find.text('B2B DEMO'), findsOneWidget);
    expect(find.text('Liste des séances'), findsOneWidget);
  });
}
