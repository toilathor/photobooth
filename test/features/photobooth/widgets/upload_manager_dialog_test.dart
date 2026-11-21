import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:th_photobooth/features/photobooth/widgets/upload_manager_dialog.dart';
import 'package:th_photobooth/i18n/strings.g.dart';
import 'package:th_photobooth/services/no_op_storage_service.dart';
import 'package:th_photobooth/services/upload_queue.dart';

import '../../../support/test_app.dart';

/// Signed out, so every job fails and waits: nothing uploads during the test.
class _SignedOutStorage extends NoOpStorageService {
  @override
  Future<bool> hasRequiredScopes() async => false;
}

void main() {
  testWidgets('lists waiting sessions and removes one', (tester) async {
    final queue = UploadQueue(
      storage: _SignedOutStorage(),
      retryDelay: const Duration(hours: 1),
    );
    final files = {'photo.jpg': Uint8List(1)};
    await tester.runAsync(() async {
      queue
        ..add('a', files)
        ..add('b', files);
      await pumpEventQueue();
    });

    await tester.pumpWidget(
      testApp(
        child: Scaffold(body: UploadManagerDialog(queue: queue)),
      ),
    );

    expect(find.byType(ListTile), findsNWidgets(2));
    expect(find.text(t.google_drive.upload_retrying), findsOneWidget);
    expect(find.text(t.google_drive.job_waiting), findsOneWidget);

    await tester.tap(find.byTooltip(t.google_drive.remove_job).last);
    await tester.pump();

    expect(find.byType(ListTile), findsOneWidget);
    expect(queue.pending, hasLength(1));
  });
}
