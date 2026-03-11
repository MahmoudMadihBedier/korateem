import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korateem/main.dart';

void main() {
  testWidgets('App launches and shows home/login', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('كورة تيم'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
