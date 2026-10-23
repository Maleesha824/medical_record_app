// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:medical_record_app/main.dart';
import 'package:medical_record_app/screens/profile_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

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

  testWidgets('saving profile switches to edit mode', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Save Profile'), findsOneWidget);
    await tester.tap(find.text('Save Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Save Profile'), findsNothing);
    expect(find.text('Edit Profile'), findsOneWidget);

    await tester.tap(find.text('Edit Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Save Profile'), findsOneWidget);
  });
}
