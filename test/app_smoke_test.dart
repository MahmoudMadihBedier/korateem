import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korateem/ui/theme.dart';

void main() {
  testWidgets('App shell builds', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        title: 'كورة تيم',
        theme: korateemTheme,
        home: const Scaffold(body: Text('كورة تيم')),
      ),
    );
    expect(find.text('كورة تيم'), findsWidgets);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
