import 'dart:async';
import 'dart:typed_data';

import 'storage_service_interface.dart';
import 'storage_user.dart';

/// StorageService không thực hiện bất kỳ thao tác lưu trữ nào.
/// Dùng cho bản Commercial khi không cần tích hợp storage bên ngoài.
class NoOpStorageService implements StorageService {
  @override
  Future<void> init() async {
    // Không cần khởi tạo gì
  }

  @override
  Future<StorageUser?> signIn() async => null;

  @override
  Future<void> signOut() async {}

  @override
  Future<String?> uploadImage(Uint8List bytes, String fileName) async => null;

  @override
  Future<String?> uploadCollection({
    required Map<String, Uint8List> files,
    required String folderName,
    void Function(int current, int total)? onProgress,
  }) async => null;

  @override
  StorageUser? get currentUser => null;

  @override
  Future<String?> getFolderLink(String folderName) async => null;

  @override
  Stream<StorageUser?> get onCurrentUserChanged => const Stream.empty();

  @override
  Future<bool> hasRequiredScopes() async => true;

  @override
  Future<bool> requestRequiredScopes() async => true;
}
