import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:th_photobooth/components/photobooth_header.dart';
import 'package:th_photobooth/i18n/strings.g.dart';

import '../../../support/test_app.dart';

void main() {
  testWidgets('PhotoboothHeader renders correct text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      testApp(child: const Scaffold(body: PhotoboothHeader())),
    );

    expect(find.text(t.header.titlePersonal), findsOneWidget);
  });
}
