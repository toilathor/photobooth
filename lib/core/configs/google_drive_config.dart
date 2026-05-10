class GoogleDriveConfig {
  static const String clientId =
      '846567411119-ohav9pgij858i92jou6v5ujsdg9jdvu9.apps.googleusercontent.com';

  static const List<String> scopes = [
    'https://www.googleapis.com/auth/drive.file',
  ];

  // Tên thư mục sẽ tạo trên Google Drive để lưu ảnh
  static const String folderName = 'My Photobooth Photos';
}
