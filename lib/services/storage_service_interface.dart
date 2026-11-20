import 'dart:typed_data';

import 'storage_section.dart';
import 'storage_user.dart';

abstract class StorageService {
  /// Khởi tạo dịch vụ
  Future<void> init();

  /// Đăng nhập (nếu cần)
  Future<StorageUser?> signIn();

  /// Đăng xuất
  Future<void> signOut();

  /// Tải ảnh lên và trả về URL
  Future<String?> uploadImage(Uint8List bytes, String fileName);

  /// Tìm hoặc tạo section Drive trước khi render QR vào ảnh.
  Future<StorageSection?> prepareSection(String folderName);

  /// Tải bộ sưu tập tệp vào section đã được tạo.
  Future<void> uploadCollection({
    required Map<String, Uint8List> files,
    required String sectionId,
    void Function(int current, int total)? onProgress,
  });

  /// Kiểm tra trạng thái người dùng hiện tại
  StorageUser? get currentUser;

  /// Luồng sự kiện thay đổi người dùng
  Stream<StorageUser?> get onCurrentUserChanged;

  /// Kiểm tra xem người dùng đã cấp quyền các scope cần thiết chưa (chỉ dùng cho Web)
  Future<bool> hasRequiredScopes();

  /// Yêu cầu cấp quyền các scope cần thiết (chỉ dùng cho Web)
  Future<bool> requestRequiredScopes();
}
