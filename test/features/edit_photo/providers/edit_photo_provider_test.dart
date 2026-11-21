import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:th_photobooth/features/edit_photo/providers/edit_photo.provider.dart';
import 'package:th_photobooth/services/storage_section.dart';
import 'package:th_photobooth/services/storage_service_interface.dart';
import 'package:th_photobooth/services/storage_user.dart';
import 'package:th_photobooth/services/upload_queue.dart';

void main() {
  test('exports the print PNG and unchanged source photos', () async {
    final provider = EditPhotoProvider(storageService: _FakeStorageService())
      ..sessionId = 'session_test';
    final png = Uint8List.fromList(
      img.encodePng(img.Image(width: 2, height: 2)),
    );
    final jpeg = Uint8List.fromList(
      img.encodeJpg(img.Image(width: 2, height: 2)),
    );
    provider.capturedPhotos = [
      XFile.fromData(png, mimeType: 'image/png', name: 'capture.png'),
      XFile.fromData(jpeg, mimeType: 'image/jpeg', name: 'capture.jpg'),
    ];

    final files = await provider.generateAllFiles(
      captureStrip: () async => png,
      capturePrintContent: () async => png,
    );

    expect(files, contains('session_test_anh_dem_di_in.png'));
    expect(files!['session_test_anh_goc_01.png'], orderedEquals(png));
    expect(files['session_test_anh_goc_02.jpg'], orderedEquals(jpeg));
    expect(files.keys.any((name) => name.contains('gia_lap_ban_in')), isFalse);
    expect(img.decodePng(files['session_test_anh_dem_di_in.png']!), isNotNull);
  });

  test(
    'retries on the same section, saves once, then queues the upload',
    () async {
      final storage = _FakeStorageService();
      final queue = UploadQueue(storage: storage, retryDelay: Duration.zero);
      final provider = EditPhotoProvider(
        storageService: storage,
        uploadQueue: queue,
      )..sessionId = 'session_test';
      final png = Uint8List.fromList(
        img.encodePng(img.Image(width: 2, height: 2)),
      );
      String? error;
      var completed = 0;
      var printCaptures = 0;
      final saved = <Map<String, Uint8List>>[];

      Future<void> request() => provider.handleQRRequest(
        onHideLoading: () {},
        onShowLogin: () {},
        onStartUpload: () {},
        onUploadComplete: () {
          expect(provider.isSectionReady, isTrue);
          completed++;
        },
        onShowError: (value) => error = value,
        captureStrip: () async => png,
        // The first render fails, as a stalled export would.
        capturePrintContent: () async =>
            printCaptures++ == 0 ? throw Exception('render failed') : png,
        saveToDevice: (files) async => saved.add(files),
      );

      await request();
      expect(error, isNotNull);
      expect(saved, isEmpty);
      expect(provider.isSectionReady, isFalse);
      expect(completed, 0);

      error = null;
      await request();
      expect(error, isNull);
      expect(storage.prepareCalls, 1);
      expect(saved.single, same(provider.completedFiles));
      expect(provider.isSectionReady, isTrue);
      expect(provider.isEditorLocked, isTrue);
      expect(completed, 1);
      expect(provider.galleryUrl, contains('#/gallery/drive_section_123456'));

      // The QR is shown before Drive has the files; the queue sends them after.
      await pumpEventQueue();
      expect(storage.uploadCalls, 1);
      expect(queue.isUploaded('drive_section_123456'), isTrue);

      final originalFilter = provider.selectedFilter;
      provider.setFilter('sepia');
      expect(provider.selectedFilter, originalFilter);
    },
  );

  test('names the session after the wedding and its time', () {
    expect(
      EditPhotoProvider.sessionIdAt(DateTime(2026, 11, 21, 14, 32, 5)),
      'thohien-wedding-20261121-143205',
    );
  });

  test('a retry after a timeout waits for the run in flight', () async {
    final storage = _FakeStorageService()..slowPrepare = Completer<void>();
    final queue = UploadQueue(storage: storage, retryDelay: Duration.zero);
    final provider = EditPhotoProvider(
      storageService: storage,
      uploadQueue: queue,
      prepareTimeout: const Duration(milliseconds: 20),
    )..sessionId = 'session_test';
    final png = Uint8List.fromList(
      img.encodePng(img.Image(width: 2, height: 2)),
    );
    final errors = <String>[];
    final saved = <Map<String, Uint8List>>[];

    Future<void> request() => provider.handleQRRequest(
      onHideLoading: () {},
      onShowLogin: () {},
      onStartUpload: () {},
      onUploadComplete: () {},
      onShowError: errors.add,
      captureStrip: () async => png,
      capturePrintContent: () async => png,
      saveToDevice: (files) async => saved.add(files),
    );

    await request(); // Drive is slow: times out
    expect(errors, hasLength(1));

    final retry = request();
    storage.slowPrepare!.complete();
    await retry;

    expect(storage.prepareCalls, 1);
    expect(saved, hasLength(1));
    expect(provider.isSectionReady, isTrue);
  });
}

class _FakeStorageService implements StorageService {
  int prepareCalls = 0;
  int uploadCalls = 0;

  /// When set, [prepareSection] waits for it, like Drive on a weak network.
  Completer<void>? slowPrepare;

  @override
  StorageUser? get currentUser => const StorageUser(
    id: 'user',
    email: 'user@example.com',
    displayName: 'User',
  );

  @override
  Stream<StorageUser?> get onCurrentUserChanged => const Stream.empty();

  @override
  Future<void> init() async {}

  @override
  Future<StorageSection?> prepareSection(String folderName) async {
    prepareCalls++;
    await slowPrepare?.future;
    return const StorageSection(
      id: 'drive_section_123456',
      webViewUrl: 'https://drive.google.com/drive/folders/drive_section_123456',
    );
  }

  @override
  Future<void> uploadCollection({
    required Map<String, Uint8List> files,
    required String sectionId,
    void Function(int current, int total)? onProgress,
  }) async {
    uploadCalls++;
    onProgress?.call(files.length, files.length);
  }

  @override
  Future<bool> hasRequiredScopes() async => true;

  @override
  Future<bool> requestRequiredScopes() async => true;
}
