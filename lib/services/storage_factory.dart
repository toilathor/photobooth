import 'storage_service_interface.dart';
import 'google_drive_service.dart';
import '../core/configs/storage_config.dart';

class StorageFactory {
  static StorageService? _instance;

  static StorageService get instance {
    if (_instance != null) return _instance!;

    switch (StorageConfig.activeStorage) {
      case StorageType.googleDrive:
        _instance = GoogleDriveService();
        break;
      case StorageType.none:
        // Bạn có thể tạo một MockStorageService nếu muốn
        throw UnimplementedError('Storage is disabled in Commercial version');
    }
    return _instance!;
  }
}
