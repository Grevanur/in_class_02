import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_class_02/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('the switch changes from light to dark mode', (tester) async {
    await tester.pumpWidget(const ThemeSwitcherApp());
    await tester.pump();

    expect(find.text('Light mode active'), findsOneWidget);
    expect(find.byIcon(Icons.wb_sunny), findsWidgets);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text('Dark mode active'), findsOneWidget);
    expect(find.byIcon(Icons.nightlight_round), findsWidgets);
  });

  testWidgets('a saved dark choice is restored', (tester) async {
    SharedPreferences.setMockInitialValues({'themeMode': 'dark'});

    await tester.pumpWidget(const ThemeSwitcherApp());
    await tester.pumpAndSettle();

    expect(find.text('Dark mode active'), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
  });
}
