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
}
