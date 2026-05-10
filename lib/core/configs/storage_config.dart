enum StorageType {
  googleDrive,
  none, // Cho bản thương mại không dùng lưu trữ ngoài
}

class StorageConfig {
  // Bạn chỉ cần thay đổi biến này để chuyển đổi giữa bản cá nhân và bản thương mại
  static const StorageType activeStorage = StorageType.googleDrive;
}
