import 'package:camera/camera.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:th_photobooth/components/language_switcher.dart';
import 'package:th_photobooth/core/configs/app_config.dart';
import 'package:th_photobooth/features/edit_photo/providers/edit_photo.provider.dart';
import 'package:th_photobooth/features/edit_photo/screens/edit_photo.screen.dart';
import 'package:th_photobooth/features/edit_photo/widgets/editor_panel.dart';
import 'package:th_photobooth/features/edit_photo/widgets/qr_share_panel.dart';
import 'package:th_photobooth/features/photobooth/providers/photobooth.provider.dart';
import 'package:th_photobooth/services/no_op_storage_service.dart';

import '../../../support/test_app.dart';

class _TestEditPhotoProvider extends EditPhotoProvider {
  _TestEditPhotoProvider() : super(storageService: NoOpStorageService());

  @override
  Future<void> initWithPhotoboothData({
    required List<XFile> photos,
    required int photoCount,
    required bool photoIsMirrored,
    required bool videoIsMirrored,
    XFile? videoFile,
    List<Duration>? timestamps,
  }) async {}
}

Future<void> _pumpEditPhotoScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    testApp(
      child: ChangeNotifierProvider(
        create: (_) => PhotoboothProvider(),
        child: const EditPhotoScreen(
          photos: [],
          photoCount: 4,
          photoIsMirrored: false,
          videoIsMirrored: false,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() async {
    AppConfig.cameras = [];
    await GetIt.instance.reset();
    GetIt.instance.registerFactory<EditPhotoProvider>(
      _TestEditPhotoProvider.new,
    );
  });

  tearDown(() => GetIt.instance.reset());

  testWidgets('back button does not overlap the desktop language switcher', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpEditPhotoScreen(tester);

    final backButton = find.byIcon(Icons.arrow_back_ios_new_rounded);
    final languageSwitcher = find.byType(LanguageSwitcher);

    expect(backButton, findsOneWidget);
    expect(languageSwitcher, findsOneWidget);
    final backRect = tester.getRect(backButton);
    final languageRect = tester.getRect(languageSwitcher);
    expect(
      backRect.overlaps(languageRect),
      isFalse,
      reason: 'Back button $backRect overlaps language switcher $languageRect',
    );
    expect(backRect.center.dy, languageRect.center.dy);
  });

  testWidgets('morphs the editor panel into the QR after upload', (
    tester,
  ) async {
    final provider = _TestEditPhotoProvider();
    GetIt.instance.unregister<EditPhotoProvider>();
    GetIt.instance.registerFactory<EditPhotoProvider>(() => provider);

    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpEditPhotoScreen(tester);

    expect(find.byType(EditorPanel), findsOneWidget);
    expect(find.byType(QrSharePanel), findsNothing);

    provider
      ..galleryUrl =
          'https://toilathor.github.io/photobooth/#/gallery/section_123456'
      ..isSectionReady = true
      ..notifyListeners();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(EditorPanel), findsOneWidget);
    expect(find.byType(QrSharePanel), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(EditorPanel), findsNothing);
    expect(find.byType(QrSharePanel), findsOneWidget);
  });
}
