import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:narmada_water_monitor/main.dart';

void main() {
  testWidgets('App starts correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const NarmadaWaterApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
