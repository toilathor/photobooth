import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:th_photobooth/components/photobooth_header.dart';

void main() {
  testWidgets('PhotoboothHeader renders correct text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: PhotoboothHeader())),
    );

    expect(find.text('PhotoXinhh'), findsOneWidget);
    expect(find.text('Capture Memories'), findsOneWidget);
  });
}
