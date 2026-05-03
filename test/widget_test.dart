import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuzzyboard/app.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const FuzzyBoardApp());
    // Allow async providers to settle
    await tester.pump(const Duration(milliseconds: 100));
    // The app should render at least the scaffold / header
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
