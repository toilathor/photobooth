import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:th_photobooth/components/primary_button.dart';
import 'package:th_photobooth/components/shortcut_keycap.dart';

import '../support/test_app.dart';

Future<void> _pumpButton(
  WidgetTester tester, {
  required Size size,
  VoidCallback? onTap,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    testApp(
      child: Scaffold(
        body: Center(
          child: SizedBox(
            width: 320,
            child: PrimaryButton(
              onTap: onTap,
              label: 'Hoàn tất',
              shortcut: ShortcutKey.enter,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(); // breakpoints settle after the first frame
}

void main() {
  testWidgets('shows the keycap on desktop while the button works', (
    tester,
  ) async {
    await _pumpButton(tester, size: const Size(1280, 800), onTap: () {});
    expect(find.byType(CustomPaint), findsWidgets);
    expect(
      find.descendant(
        of: find.byType(ShortcutKeycap),
        matching: find.byType(CustomPaint),
      ),
      findsOneWidget,
    );
  });

  testWidgets('hides it on phones and on a disabled button', (tester) async {
    await _pumpButton(tester, size: const Size(390, 844), onTap: () {});
    expect(find.byType(ShortcutKeycap), findsNothing);

    await _pumpButton(tester, size: const Size(1280, 800));
    expect(find.byType(ShortcutKeycap), findsNothing);
  });
}
