import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korateem/ui/modern_components.dart';
import 'package:korateem/ui/theme.dart';

void main() {
  testWidgets('Modern components build', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: korateemTheme,
        home: const Scaffold(
          appBar: ModernAppBar(title: 'Test'),
          body: ModernCard(child: Text('Body')),
        ),
      ),
    );

    expect(find.byType(ModernAppBar), findsOneWidget);
    expect(find.byType(ModernCard), findsOneWidget);
    expect(find.text('Body'), findsOneWidget);
  });
}
