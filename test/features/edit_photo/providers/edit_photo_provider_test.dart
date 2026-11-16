import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:th_photobooth/features/edit_photo/providers/edit_photo.provider.dart';
import 'package:th_photobooth/services/storage_section.dart';
import 'package:th_photobooth/services/storage_service_interface.dart';
import 'package:th_photobooth/services/storage_user.dart';

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

  test('retries the same section then marks the upload ready', () async {
    final storage = _FakeStorageService()..failNextUpload = true;
    final provider = EditPhotoProvider(storageService: storage)
      ..sessionId = 'session_test';
    final png = Uint8List.fromList(
      img.encodePng(img.Image(width: 2, height: 2)),
    );
    String? error;
    var completedUploads = 0;

    Future<void> request() => provider.handleQRRequest(
      onHideLoading: () {},
      onShowLogin: () {},
      onStartUpload: () {},
      onUploadComplete: () {
        expect(provider.isSectionReady, isTrue);
        completedUploads++;
      },
      onShowError: (value) => error = value,
      captureStrip: () async => png,
      capturePrintContent: () async => png,
    );

    await request();
    expect(provider.isSectionReady, isFalse);
    expect(completedUploads, 0);
    expect(error, isNotNull);

    error = null;
    await request();
    expect(error, isNull);
    expect(storage.prepareCalls, 1);
    expect(storage.uploadCalls, 2);
    expect(provider.isSectionReady, isTrue);
    expect(completedUploads, 1);
    expect(provider.isEditorLocked, isTrue);
    expect(provider.galleryUrl, contains('#/gallery/drive_section_123456'));

    final originalFilter = provider.selectedFilter;
    provider.setFilter('sepia');
    expect(provider.selectedFilter, originalFilter);
  });
}

class _FakeStorageService implements StorageService {
  int prepareCalls = 0;
  int uploadCalls = 0;
  bool failNextUpload = false;

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
    if (failNextUpload) {
      failNextUpload = false;
      throw Exception('upload failed');
    }
    onProgress?.call(files.length, files.length);
  }

  @override
  Future<String?> uploadImage(Uint8List bytes, String fileName) async => null;

  @override
  Future<StorageUser?> signIn() async => currentUser;

  @override
  Future<void> signOut() async {}

  @override
  Future<bool> hasRequiredScopes() async => true;

  @override
  Future<bool> requestRequiredScopes() async => true;
}
