import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:th_photobooth/features/edit_photo/widgets/completion_check_animation.dart';

import '../../../support/test_app.dart';

void main() {
  testWidgets('loads the completion check Lottie', (tester) async {
    await tester.pumpWidget(testApp(child: const CompletionCheckAnimation()));
    await tester.pumpAndSettle();

    expect(find.byType(Lottie), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reports the end only after the whole Lottie played', (
    tester,
  ) async {
    var finished = 0;
    await tester.pumpWidget(
      testApp(child: CompletionCheckAnimation(onFinished: () => finished++)),
    );
    // Lottie decodes its file off the frame clock.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 1500));
    expect(finished, 0); // the old fixed delay switched at 1.2s

    await tester.pump(const Duration(seconds: 1));
    expect(finished, 1);
  });
}
