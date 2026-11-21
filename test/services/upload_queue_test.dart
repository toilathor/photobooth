import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:th_photobooth/services/storage_section.dart';
import 'package:th_photobooth/services/storage_service_interface.dart';
import 'package:th_photobooth/services/storage_user.dart';
import 'package:th_photobooth/services/upload_queue.dart';

final _files = {
  'photo.jpg': Uint8List.fromList([1, 2, 3]),
};

/// Lets the queue's zero-delay retries run until [done] holds.
Future<void> _until(bool Function() done) async {
  for (var i = 0; i < 50 && !done(); i++) {
    await pumpEventQueue();
  }
}

void main() {
  test('retries a failed upload until it lands', () async {
    final storage = _FakeStorage()..failOnce.add('a');
    final queue = UploadQueue(storage: storage, retryDelay: Duration.zero)
      ..add('a', _files);

    await _until(() => queue.pending.isEmpty);

    expect(storage.uploads, ['a', 'a']);
    expect(queue.isUploaded('a'), isTrue);
  });

  test('a failing session does not block the next one', () async {
    final storage = _FakeStorage()..failOnce.add('a');
    final queue = UploadQueue(storage: storage, retryDelay: Duration.zero)
      ..add('a', _files)
      ..add('b', _files);

    await _until(() => queue.pending.isEmpty);

    expect(storage.uploads, ['a', 'b', 'a']);
    expect(queue.isUploaded('a') && queue.isUploaded('b'), isTrue);
  });

  test('waits for Google sign-in instead of uploading', () async {
    final storage = _FakeStorage()..hasScopes = false;
    final queue = UploadQueue(storage: storage, retryDelay: Duration.zero)
      ..add('a', _files);

    await pumpEventQueue();
    expect(storage.uploads, isEmpty);
    expect(queue.pending.single.failed, isTrue);

    storage.hasScopes = true;
    await _until(() => queue.pending.isEmpty);

    expect(storage.uploads, ['a']);
    expect(queue.isUploaded('a'), isTrue);
  });

  test('retries at once when asked instead of waiting', () async {
    final storage = _FakeStorage()..failOnce.add('a');
    final queue = UploadQueue(storage: storage, retryDelay: Duration(hours: 1))
      ..add('a', _files);

    await pumpEventQueue();
    expect(queue.pending.single.failed, isTrue);

    queue.retryNow();
    await _until(() => queue.pending.isEmpty);
    expect(storage.uploads, ['a', 'a']);
    expect(queue.uploadedCount, 1);
  });

  test('removes a waiting session', () async {
    final storage = _FakeStorage()..hasScopes = false;
    final queue = UploadQueue(storage: storage, retryDelay: Duration(hours: 1))
      ..add('a', _files)
      ..add('b', _files);

    await pumpEventQueue();
    expect(
      queue.remove(queue.pending.firstWhere((j) => j.sectionId == 'b')),
      isTrue,
    );
    expect(queue.pending.map((j) => j.sectionId), ['a']);

    storage.hasScopes = true;
    queue.retryNow();
    await _until(() => queue.pending.isEmpty);
    expect(storage.uploads, ['a']);
  });

  test('removing the session being uploaded moves on to the next', () async {
    final storage = _FakeStorage()..hang.add('a');
    final queue = UploadQueue(storage: storage, retryDelay: Duration.zero)
      ..add('a', _files)
      ..add('b', _files);

    await pumpEventQueue();
    expect(queue.active?.sectionId, 'a');

    expect(queue.remove(queue.active!), isTrue);
    await _until(() => queue.pending.isEmpty);

    expect(storage.uploads, ['a', 'b']);
    expect(queue.isUploaded('a'), isFalse);
    expect(queue.isUploaded('b'), isTrue);
  });
}

class _FakeStorage implements StorageService {
  final Set<String> failOnce = {};
  final List<String> uploads = [];

  /// Sections whose upload never finishes, like a request stuck offline.
  final Set<String> hang = {};
  bool hasScopes = true;

  @override
  Future<void> uploadCollection({
    required Map<String, Uint8List> files,
    required String sectionId,
    void Function(int current, int total)? onProgress,
  }) async {
    uploads.add(sectionId);
    if (hang.contains(sectionId)) return Completer<void>().future;
    if (failOnce.remove(sectionId)) throw Exception('offline');
    onProgress?.call(files.length, files.length);
  }

  @override
  Future<bool> hasRequiredScopes() async => hasScopes;

  @override
  Future<bool> requestRequiredScopes() async => true;

  @override
  StorageUser? get currentUser => null;

  @override
  Stream<StorageUser?> get onCurrentUserChanged => const Stream.empty();

  @override
  Future<void> init() async {}

  @override
  Future<StorageSection?> prepareSection(String folderName) async => null;
}
