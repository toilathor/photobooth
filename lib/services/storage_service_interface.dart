import 'dart:typed_data';

abstract class StorageService {
  /// Khởi tạo dịch vụ
  Future<void> init();

  /// Đăng nhập (nếu cần)
  Future<dynamic> signIn();

  /// Đăng xuất
  Future<void> signOut();

  /// Tải ảnh lên và trả về URL
  Future<String?> uploadImage(Uint8List bytes, String fileName);

  /// Tải bộ sưu tập tệp lên một thư mục và trả về URL của thư mục đó
  Future<String?> uploadCollection({
    required Map<String, Uint8List> files,
    required String folderName,
    void Function(int current, int total)? onProgress,
  });

  /// Kiểm tra trạng thái người dùng hiện tại
  dynamic get currentUser;

  /// Kiểm tra xem thư mục đã tồn tại chưa và trả về URL
  Future<String?> getFolderLink(String folderName);

  /// Luồng sự kiện thay đổi người dùng
  Stream<dynamic> get onCurrentUserChanged;
}
