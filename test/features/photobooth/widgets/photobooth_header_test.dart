import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:th_photobooth/components/photobooth_header.dart';
import '../../../test_app.dart';

void main() {
  testWidgets('PhotoboothHeader renders correct text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        child: const Scaffold(body: PhotoboothHeader()),
        withProvider: false,
      ),
    );

    expect(find.text('Thuy Hen ❤️ Quang To'), findsOneWidget);
  });
}
