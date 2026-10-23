// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:medical_record_app/main.dart';

void main() {
  testWidgets('lock screen displays unlock prompt', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: LockScreen(onUnlock: () {})));

    expect(find.text('Medical records locked'), findsOneWidget);
    expect(
      find.text('Use your device PIN, pattern or biometrics to continue.'),
      findsOneWidget,
    );
    expect(find.text('Unlock'), findsOneWidget);
  });
}
